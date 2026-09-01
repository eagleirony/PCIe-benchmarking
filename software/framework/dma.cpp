/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Copyright 2026 Aaron Nyholm, All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <iostream>
#include <sstream>
#include <filesystem>
#include <algorithm>

#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <time.h>

#include <dev/io/iodev.h>

#include <rtems/bsd/pci-iodev.h>

#include <framework/dma.hpp>

namespace app {
namespace framework {
namespace pcie {
namespace dma {

constexpr int pcie_device_count = 4;

constexpr uint32_t dma_devid = 0x902410ee;
constexpr uint16_t dma_vendor = 0x10ee;
constexpr uint16_t dma_subvendor = 0x10ee;
constexpr uint16_t dma_subdevice = 0x0007;

controllers_ptr eps;

controllers_ptr make_controllers() {
    if (!eps) {
        eps = std::make_shared<controllers>();
    }
    return eps;
}

uint32_t* registers::address(uint32_t target,
    uint32_t channel, uint32_t offset) {
    uint64_t address = reinterpret_cast<uint64_t>(base);

    address &= ~(XLNX_PCIE_DMA_REG_TAR_ADDR_MASK |
        XLNX_PCIE_DMA_REG_CHAN_ADDR_MASK |
        XLNX_PCIE_DMA_REG_BYTE_ADDR_MASK);

    address |= XLNX_PCIE_DMA_REG_TAR_ADDR_MASK &
        (target << XLNX_PCIE_DMA_REG_TAR_ADDR_SHIFT);

    address |= XLNX_PCIE_DMA_REG_CHAN_ADDR_MASK &
        (channel << XLNX_PCIE_DMA_REG_CHAN_ADDR_SHIFT);

    address |= XLNX_PCIE_DMA_REG_BYTE_ADDR_MASK &
        (offset << XLNX_PCIE_DMA_REG_BYTE_ADDR_SHIFT);

    return reinterpret_cast<uint32_t*>(address);
}

uint32_t registers::read(uint32_t target, uint32_t channel, uint32_t offset) {
    uint32_t* reg = address(target, channel, offset);

    return *reg;
}

uint32_t registers::read(uint32_t target, uint32_t offset) {
    uint32_t* reg = address(target, 0, offset);

    return *reg;
}

void registers::write(uint32_t target, uint32_t channel, uint32_t offset,
    uint32_t value) {
    uint32_t* reg = address(target, channel, offset);

    *reg = value;
}

void registers::write(uint32_t target, uint32_t offset, uint32_t value) {
    uint32_t* reg = address(target, 0, offset);

    *reg = value;
}

channel::channel(registers& reg_, uint32_t dir_, size_t id_,
    size_t desc_count_) : regs(reg_), dir(dir_), id(id_), running(false) {
    bufs.create(2 * XLNX_PCIE_DMA_CHAN_DESC_COUNT);

    descs[0].desc = rtems_cache_coherent_allocate(
        XLNX_PCIE_DMA_DESC_SIZE * XLNX_PCIE_DMA_CHAN_DESC_COUNT,
        XLNX_PCIE_DMA_DESC_ALIGNMENT,
        XLNX_PCIE_DMA_DESC_BOUNDARY);
    if (descs[0].desc == nullptr) {
        throw std::bad_alloc();
    }

    wbs[0].wb = rtems_cache_coherent_allocate(
        XLNX_PCIE_DMA_WB_SIZE * XLNX_PCIE_DMA_CHAN_DESC_COUNT,
        XLNX_PCIE_DMA_WB_ALIGNMENT,
        XLNX_PCIE_DMA_WB_BOUNDARY);
    if (wbs[0].wb == nullptr) {
        rtems_cache_coherent_free(descs[0].desc);
        throw std::bad_alloc();
    }

    uint64_t nxt_desc = reinterpret_cast<uint64_t>(descs[0].desc);
    uint64_t nxt_wb = reinterpret_cast<uint64_t>(wbs[0].wb);
    nxt_desc += XLNX_PCIE_DMA_DESC_SIZE;
    nxt_wb += XLNX_PCIE_DMA_WB_SIZE;

    for (int i = 1; i < XLNX_PCIE_DMA_CHAN_DESC_COUNT; i++) {
        descs[i].desc = reinterpret_cast<void*>(nxt_desc);
        wbs[i].wb = reinterpret_cast<void*>(nxt_wb);

        nxt_desc += XLNX_PCIE_DMA_DESC_SIZE;
        nxt_wb += XLNX_PCIE_DMA_WB_SIZE;
    }

    /* Set performance tracking to auto */
    write_chan(XLNX_PCIE_DMA_CHAN_PERF_CTRL, XLNX_PCIE_DMA_CHAN_PERF_CTRL_RUN
        | XLNX_PCIE_DMA_CHAN_PERF_CTRL_CLR
        | XLNX_PCIE_DMA_CHAN_PERF_CTRL_AUTO);

    /* Enable Intr */
    write_chan(XLNX_PCIE_DMA_CHAN_CTRL, XLNX_PCIE_DMA_CHAN_CTRL_LOG_ENA);

    uint32_t irq_reg = regs.read(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK,
        XLNX_PCIE_DMA_IRQ_CHAN_EN);
    regs.write(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK, XLNX_PCIE_DMA_IRQ_CHAN_EN,
        irq_reg | 0x3);

    write_chan(XLNX_PCIE_DMA_CHAN_INTR, XLNX_PCIE_DMA_CHAN_INTR_ENA);
}

void channel::set_pipeline() {
    lock_guard guard(lock);
    if (pipelined) {
        return;
    }
    descs[0].zero();
    descs[0].header(true, false, XLNX_PCIE_DMA_CHAN_DESC_COUNT - 2);
    descs[0].set_length(DMA_BUFF_SIZE);
    descs[0].set_wb(wbs[0]);
    wbs[0].clear();
    auto buf = bufs.request();
    buf->zero();
    descs[0].set_buffer(buf);

    for (int i = 1; i < XLNX_PCIE_DMA_CHAN_DESC_COUNT; i++) {
        descs[i].zero();
        auto nxt_adj = std::max(0UL, XLNX_PCIE_DMA_CHAN_DESC_COUNT - i - 2);
        descs[i].header(true, false, nxt_adj);
        descs[i].set_length(DMA_BUFF_SIZE);
        descs[i].set_wb(wbs[i]);
        wbs[i].clear();
        auto buf = bufs.request();
        buf->zero();
        descs[i].set_buffer(buf);
    }
    for (int i = 0; i < XLNX_PCIE_DMA_CHAN_DESC_COUNT - 1; ++i) {
        descs[i].set_next(descs[i + 1]);
    }
    descs[XLNX_PCIE_DMA_CHAN_DESC_COUNT - 1].set_next(descs[0]);

    tail = 0;
    head = 0;

    pipelined = true;
}

void channel::set_block(size_t length) {
    lock_guard guard(lock);

    size_t desc_index = 0;
    auto desc_chain_len = (length + DMA_BUFF_SIZE - 1) / DMA_BUFF_SIZE;
    if (desc_chain_len > XLNX_PCIE_DMA_CHAN_DESC_COUNT) {
        throw std::runtime_error("Length too long for block transfer");
    }

    while (length > DMA_BUFF_SIZE) {
        descs[desc_index].zero();
        auto nxt_adj = std::max(0UL, desc_chain_len - desc_index - 2);
        descs[desc_index].header(false, false, nxt_adj);
        descs[desc_index].set_length(DMA_BUFF_SIZE);
        descs[desc_index].set_wb(wbs[desc_index]);
        wbs[desc_index].clear();
        auto buf = bufs.request();
        buf->zero();
        descs[desc_index].set_buffer(buf);

        desc_index++;
        length = length - DMA_BUFF_SIZE;
    }

    descs[desc_index].zero();
    descs[desc_index].header(false, true, 0);
    descs[desc_index].set_length(length);
    descs[desc_index].set_wb(wbs[desc_index]);
    wbs[desc_index].clear();
    auto buf = bufs.request();
    buf->zero();
    descs[desc_index].set_buffer(buf);

    for (int i = 0; i <= desc_index; ++i) {
        descs[i].set_next(descs[i + 1]);
    }

    head = 0;
    tail = desc_index + 1;

    pipelined = false;
}

bool channel::is_running() {
    return running;
}

void channel::set_callback(callback& cb_) {
    if (is_running()) {
        throw std::runtime_error("Channel is running");
    }
    lock_guard guard(lock);
    cb = cb_;
}

void channel::run() {
    if (is_running()) {
        return;
    }
    lock_guard guard(lock);
    uint32_t desc_hi;
    uint32_t desc_lo;
    mem::descriptor* desc;

    set_pipeline();

    desc = &descs[head];

    desc_lo = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) & 0xFFFFFFFF);
    desc_hi = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) >> 32);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_LO, desc_lo);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_HI, desc_hi);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADJ, 0);

    running = true;
    auto reg = read_chan(XLNX_PCIE_DMA_CHAN_CTRL);
    reg |= XLNX_PCIE_DMA_CHAN_CTRL_RUN;
    write_chan(XLNX_PCIE_DMA_CHAN_CTRL, reg);
}

void channel::run(size_t length) {
    if (is_running()) {
        return;
    }
    lock_guard guard(lock);
    uint32_t desc_hi;
    uint32_t desc_lo;
    mem::descriptor* desc;

    set_block(length);

    desc = &descs[head];
    pipelined = false;

    desc_lo = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) & 0xFFFFFFFF);
    desc_hi = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) >> 32);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_LO, desc_lo);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_HI, desc_hi);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADJ, 0);

    running = true;
    auto reg = read_chan(XLNX_PCIE_DMA_CHAN_CTRL);
    reg |= XLNX_PCIE_DMA_CHAN_CTRL_RUN;
    write_chan(XLNX_PCIE_DMA_CHAN_CTRL, reg);
}

void channel::stop() {
    if (!is_running()) {
        return;
    }
    lock_guard guard(lock);
    auto reg = read_chan(XLNX_PCIE_DMA_CHAN_CTRL);
    reg &= ~XLNX_PCIE_DMA_CHAN_CTRL_RUN;
    write_chan(XLNX_PCIE_DMA_CHAN_CTRL, reg);
    running = false;
}

void channel::handle_intr() {
    lock_guard guard(lock);
    /* Clear intr sources */
    uint32_t status = read_chan(XLNX_PCIE_DMA_CHAN_STS);
    write_chan(XLNX_PCIE_DMA_CHAN_STS, status);

    if (pipelined) {
        ++tail;
    }

    while (head < tail) {
        mem::dma_buffer_ptr cmpl_buf;
        auto& d = descs[head++];
        head = head % XLNX_PCIE_DMA_CHAN_DESC_COUNT;

        cmpl_buf = d.buf;
        d.buf = bufs.request();

        if (!d.wb->valid()) {
            throw std::runtime_error("Invalid DMA transfer");
        }

        cmpl_buf->stats.eop = d.wb->eop();
        cmpl_buf->stats.length = d.wb->length();
        d.wb->clear();

        cb(cmpl_buf);
    }
}

uint32_t channel::read_chan(uint32_t offset) {
    return regs.read(dir, id, offset);
}

void channel::write_chan(uint32_t offset, uint32_t value) {
    regs.write(dir, id, offset, value);
}

uint32_t channel::read_sgdma(uint32_t offset) {
    return regs.read(dir + XLNX_PCIE_DMA_TARGET_H2C_SGDMA, id, offset);
}

void channel::write_sgdma(uint32_t offset, uint32_t value) {
    regs.write(dir + XLNX_PCIE_DMA_TARGET_H2C_SGDMA, id, offset, value);
}

void channel::report() {
    lock_guard guard(lock);
    uint64_t cycle_count;
    uint64_t data_count;
    uint32_t desc_count;
    uint32_t status;
    std::string dir_str = "C2H";
    std::string maxed_str = "";

    if (dir == XLNX_PCIE_DMA_TARGET_H2C_CHANS) {
        dir_str = "H2C";
    }
    std::cout << dir_str << " " << id << " channel:" << std::endl;

    cycle_count = static_cast<uint64_t>(read_chan(XLNX_PCIE_DMA_CHAN_PERF_CYC_HI))
        << 32;
    cycle_count |= (read_chan(XLNX_PCIE_DMA_CHAN_PERF_CYC_LO) &
        XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK);
    if (read_chan(XLNX_PCIE_DMA_CHAN_PERF_CYC_LO) &
            XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK) {
        maxed_str = "Maxed ";
    }
    std::cout << "Clock Cycle Count: " << maxed_str << cycle_count
        << std::endl;

    data_count = static_cast<uint64_t>(read_chan(XLNX_PCIE_DMA_CHAN_PERF_DATA_HI))
        << 32;
    data_count |= (read_chan(XLNX_PCIE_DMA_CHAN_PERF_DATA_LO) &
        XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK);
    if (read_chan(XLNX_PCIE_DMA_CHAN_PERF_DATA_LO) &
            XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK) {
        maxed_str = "Maxed ";
    }
    std::cout << "Data Count: " << maxed_str << data_count
        << std::endl;

    desc_count = read_chan(XLNX_PCIE_DMA_CHAN_DESC_COMP);
    std::cout << "Descriptors Complete Count: " << desc_count << std::endl;
    status = read_chan(XLNX_PCIE_DMA_CHAN_STS);
    std::cout << "Status: 0x" << std::hex << status << std::dec << std::endl;
}

controller::controller(std::string& path) {
    int status;
    size_t region_count;
    struct rtems_iodev_region region;

    h2c_count = 0;
    c2h_count = 0;

    fd = ::open(path.c_str(), O_RDWR);
    if (fd == -1) {
        throw std::runtime_error("dma: error: iodev open failed");
    }

    region.index = 1;
    region.address = NULL;
    region.size = 0;
    region.name = NULL;
    status = ::ioctl(fd, RTEMS_IODEV_IOCTL_REGION_GET, &region);
    if (status == -1) {
        close(fd);
        fd = 0;
        throw std::runtime_error("dma: error: IOCTL get region failed");
    }

    regs.base = mmap(
        NULL,
        region.size,
        ( PROT_READ | PROT_WRITE ),
        MAP_SHARED,
        fd,
        region.index
    );
    if (regs.base == MAP_FAILED ) {
        close(fd);
        fd = 0;
        throw std::runtime_error("dma: error: mmap failed");
    }

    region.index = 0;
    region.address = NULL;
    region.size = 0;
    region.name = NULL;
    status = ::ioctl(fd, RTEMS_IODEV_IOCTL_REGION_GET, &region);
    if (status == -1) {
        close(fd);
        fd = 0;
        throw std::runtime_error("dma: error: IOCTL get region failed");
    }

    axis.base = mmap(
        NULL,
        region.size,
        ( PROT_READ | PROT_WRITE ),
        MAP_SHARED,
        fd,
        region.index
    );
    if (axis.base == MAP_FAILED ) {
        close(fd);
        fd = 0;
        throw std::runtime_error("dma: error: mmap failed");
    }

    axis.write(C2H_CHAN_0_PACKET_LEN_OFF, DMA_BUFF_SIZE/8);

    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, XLNX_PCIE_DMA_CHAN_DESC_COUNT);
            h2c_chans.push_back(chan);
        }
    }
    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, XLNX_PCIE_DMA_CHAN_DESC_COUNT);
            c2h_chans.push_back(chan);
        }
    }

    h2c_count = h2c_chans.size();
    c2h_count = c2h_chans.size();

    start_msi_thread();
}

void controller::report() {
    lock_guard guard(lock);
    std::cout << "--- PCIE DMA report ---" << std::endl;
    std::cout << "C2H channels: " << c2h_count << std::endl;
    for (auto& chan : c2h_chans) {
        chan->report();
    }
    std::cout << "H2C channels: " << h2c_count << std::endl;
    for (auto& chan : h2c_chans) {
        chan->report();
    }
}

void controller::start_msi_thread() {
    lock_guard guard(lock);
    rtems::thread::attributes attr;
    attr.set_name("CTLR_MSI_IRQ");
    attr.set_rtems_priority(97);
    attr.set_stack_size(RTEMS_MINIMUM_STACK_SIZE);
    msi_thread = std::make_shared<rtems::thread::thread>(attr, &controller::msi_worker, this);
}

void controller::msi_worker() {
    int status;
    size_t count;
    rtems_iodev_event_args event_args;

    std::cout << "MSI thread started" << std::endl;

    status = ioctl(fd, RTEMS_IODEV_IOCTL_EVENT_COUNT, &count);
    if (status != 0) {
        std::cout << "controller: msi_worker: failed to get event count" << std::endl;
        return;
    }

    if (count < 1) {
        std::cout << "controller: msi_worker: no valid event" << std::endl;
        return;
    }

    while (true) {
        event_args.index = 0;
        event_args.timeout.tv_sec = 0;
        event_args.timeout.tv_nsec = 0;
        event_args.args = NULL;

        status = ::ioctl(fd, RTEMS_IODEV_IOCTL_EVENT_WAIT, &event_args);
        if (status == -1) {
            std::cout << "controller: msi_worker: event wait failed " << errno << " " << fd << std::endl;
            return;
        }

        {
            lock_guard guard(lock);
            uint32_t reqs = regs.read(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK,
                XLNX_PCIE_DMA_IRQ_CHAN_INT);
            for (int i = 0; i < c2h_count + h2c_count; i++) {
                if (reqs & (1U << i)) {
                    if (i < h2c_count) {
                        h2c_chans[i]->handle_intr();
                    }
                    if (i >= h2c_count) {
                        auto chan_index = i - h2c_count;
                        c2h_chans[chan_index]->handle_intr();
                    }
                }
            }
        }
    }
}

static bool probe_dma(std::string path) {
    int fd;
    int status;
    struct pci_iodev_info info;

    fd = ::open(path.c_str(), O_RDWR);
    if (fd == -1) {
        return false;
    }

    status = ::ioctl(fd, RTEMS_IODEV_IOCTL_DEVICE_INFO, &info);
    if (status == -1) {
        close(fd);
        return false;
    }

    if (info.devid != dma_devid ||
        info.vendor != dma_vendor ||
        info.subvendor != dma_subvendor ||
        info.subdevice != dma_subdevice) {
        close(fd);
        return false;
    }

    ::close(fd);

    return true;
}

void init() {

    for (int i = 0; i < pcie_device_count; i++) {
        std::ostringstream oss;
        oss << "/dev/pci_iodev" << i;
        if (!std::filesystem::exists(oss.str())) {
            break;
        }

        auto path = oss.str();
        if (probe_dma(path)) {
            try {
                auto ep = std::make_shared<controller>(path);
                eps->emplace_back(ep);
            } catch (const std::runtime_error& e) {
                std::cout << e.what() << std::endl;
            }
        }
    }

    for (auto& ep : *eps) {
        ep->report();
    }

    channel::callback cb = [](mem::dma_buffer_ptr buf){
        return;
    };

    eps->at(0)->c2h_chans[0]->set_callback(cb);
    eps->at(0)->c2h_chans[0]->run();
}

} // namespace dma
} // namespace pcie
} // framework
} // app
