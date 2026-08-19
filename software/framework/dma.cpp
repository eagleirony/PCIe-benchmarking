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

#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

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

constexpr size_t dma_chan_desc_count = 16;

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
    size_t desc_count_) : regs(reg_), dir(dir_), id(id_),
    desc_count(desc_count_) {
    auto id_reg = read_chan(XLNX_PCIE_DMA_CHAN_ID);
    if (id_reg & XLNX_PCIE_CHAN_ID_AXIS_MASK) {
        streamed = true;
    }

    descs.create(desc_count);
    bufs.create(desc_count);
    wbs.create(desc_count);

    /* Set performance tracking to auto */
    write_chan(XLNX_PCIE_DMA_CHAN_PERF_CTRL, XLNX_PCIE_DMA_CHAN_PERF_CTRL_RUN
        | XLNX_PCIE_DMA_CHAN_PERF_CTRL_CLR
        | XLNX_PCIE_DMA_CHAN_PERF_CTRL_AUTO);

    /* Enable Intr */
    uint32_t irq_reg = regs.read(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK,
        XLNX_PCIE_DMA_IRQ_CHAN_EN);
    regs.write(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK, XLNX_PCIE_DMA_IRQ_CHAN_EN,
        irq_reg | 0x3);

    write_chan(XLNX_PCIE_DMA_CHAN_INTR, XLNX_PCIE_DMA_CHAN_INTR_ENA);
}

void channel::run(size_t length, transfer::callback& cb) {
    uint32_t desc_hi;
    uint32_t desc_lo;
    auto desc = descs.request();
    auto buf = bufs.request();
    auto wb = wbs.request();

    trans.cb = cb;
    trans.desc = desc;
    trans.buf = buf;
    trans.wb = wb;

    desc->init();
    desc->set_buffer(buf);
    desc->set_length(length);
    desc->set_wb(wb);

    desc_lo = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) & 0xFFFFFFFF);
    desc_hi = static_cast<uint32_t>(reinterpret_cast<uint64_t>(desc->desc) >> 32);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_LO, desc_lo);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_HI, desc_hi);
    write_sgdma(XLNX_PCIE_DMA_CHAN_SG_DESC_ADJ, 0);

    write_chan(XLNX_PCIE_DMA_CHAN_CTRL, XLNX_PCIE_DMA_CHAN_CTRL_LOG_ENA
        | XLNX_PCIE_DMA_CHAN_CTRL_RUN);
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
    uint64_t cycle_count;
    uint64_t data_count;
    uint32_t desc_count;
    uint32_t status;
    std::string dir_str = "C2H";
    std::string stream_str = "AXI Memory Mapped";
    std::string maxed_str = "";

    if (dir == XLNX_PCIE_DMA_TARGET_H2C_CHANS) {
        dir_str = "H2C";
    }
    if (streamed) {
        stream_str = "AXI Stream";
    }
    std::cout << dir_str << " " << id << " " << stream_str << " channel:"
        << std::endl;

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

    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, dma_chan_desc_count);
            h2c_chans.push_back(chan);
        }
    }
    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, dma_chan_desc_count);
            c2h_chans.push_back(chan);
        }
    }

    h2c_count = h2c_chans.size();
    c2h_count = c2h_chans.size();

    start_msi_thread();
}

void controller::report() {
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
        std::cout << "MSI event received" << std::endl;

        uint32_t reqs = regs.read(XLNX_PCIE_DMA_TARGET_IRQ_BLOCK,
            XLNX_PCIE_DMA_IRQ_CHAN_INT);
        for (int i = 0; i < c2h_count + h2c_count; i++) {
            if (reqs & (1U << i)) {
                if (i < h2c_count) {
                    auto& trans = h2c_chans[i]->trans;
                    trans.cb(trans);
                }
                if (i >= h2c_count) {
                    auto chan_index = i - h2c_count;
                    auto& trans = c2h_chans[chan_index]->trans;
                    trans.cb(trans);
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
                eps->emplace_back(path);
            } catch (const std::runtime_error& e) {
                std::cout << e.what() << std::endl;
            }
        }
    }

    for (auto& ep : *eps) {
        ep.report();
    }

    transfer::callback cb = [](transfer& trans){
        uint64_t* buf = reinterpret_cast<uint64_t*>(trans.buf->buf);
        eps->at(0).report();

        std::cout << "Length: " << trans.wb->length() << std::endl;

        for (int i = 0; i < 9; ++i) {
            std::cout << std::hex << "0x" << buf[i] << std::dec << std::endl;
        }
    };

    eps->at(0).c2h_chans[0]->run(512, cb);
}

} // namespace dma
} // namespace pcie
} // framework
} // app
