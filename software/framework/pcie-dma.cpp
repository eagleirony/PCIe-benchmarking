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

#include <framework/pcie-dma.hpp>

namespace app {
namespace framework {
namespace pcie {
namespace dma {

constexpr int pcie_device_count = 4;

constexpr uint32_t dma_devid = 0x56781234;
constexpr uint16_t dma_vendor = 0x1234;
constexpr uint16_t dma_subvendor = 0x9876;
constexpr uint16_t dma_subdevice = 0x5432;

constexpr size_t dma_chan_desc_count = 16;
constexpr size_t dma_chan_desc_size = 0x4000;

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

void registers::write(uint32_t target, uint32_t channel, uint32_t offset,
    uint32_t value) {
    uint32_t* reg = address(target, channel, offset);

    *reg = value;
}

channel::channel(registers& reg_, uint32_t dir_, size_t id_,
    size_t desc_count_, size_t desc_size_) : regs(reg_), dir(dir_), id(id_),
    desc_count(desc_count_), desc_size(desc_size_) {
    auto id_reg = read(XLNX_PCIE_DMA_CHAN_ID);
    if (id_reg & XLNX_PCIE_CHAN_ID_AXIS_MASK) {
        streamed = true;
    }

    for (auto i = 0; i < desc_count; i++) {
    }

    /* Set performance tracking to auto */
    write(XLNX_PCIE_DMA_CHAN_PERF_CTRL, XLNX_PCIE_DMA_CHAN_PERF_CTRL_AUTO);
}

uint32_t channel::read(uint32_t offset) {
    return regs.read(dir, id, offset);
}

void channel::write(uint32_t offset, uint32_t value) {
    regs.write(dir, id, offset, value);
}

void channel::report() {
    uint64_t cycle_count;
    uint64_t data_count;
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

    cycle_count = static_cast<uint64_t>(read(XLNX_PCIE_DMA_CHAN_PERF_CYC_HI))
        << 32;
    cycle_count |= (read(XLNX_PCIE_DMA_CHAN_PERF_CYC_LO) &
        XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK);
    if (read(XLNX_PCIE_DMA_CHAN_PERF_CYC_LO) &
            XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK) {
        maxed_str = "Maxed ";
    }
    std::cout << "Clock Cycle Count: " << maxed_str << cycle_count
        << std::endl;

    data_count = static_cast<uint64_t>(read(XLNX_PCIE_DMA_CHAN_PERF_DATA_HI))
        << 32;
    data_count |= (read(XLNX_PCIE_DMA_CHAN_PERF_DATA_LO) &
        XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK);
    if (read(XLNX_PCIE_DMA_CHAN_PERF_DATA_LO) &
            XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK) {
        maxed_str = "Maxed ";
    }
    std::cout << "Data Count: " << maxed_str << data_count
        << std::endl;
}

controller::controller(std::string& path) {
    int fd;
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
        throw std::runtime_error("dma: error: mmap failed");
    }

    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_H2C_CHANS, i, dma_chan_desc_count,
                dma_chan_desc_size);
            h2c_chans.push_back(chan);
        }
    }
    for (auto i = 0; i < XLNX_PCIE_DMA_MAX_CHANS; i++) {
        if (regs.read(XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, XLNX_PCIE_DMA_CHAN_ID)
            != 0) {
            auto chan = std::make_shared<channel>(regs,
                XLNX_PCIE_DMA_TARGET_C2H_CHANS, i, dma_chan_desc_count,
                dma_chan_desc_size);
            c2h_chans.push_back(chan);
        }
    }

    h2c_count = h2c_chans.size();
    c2h_count = c2h_chans.size();
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
    std::vector<controller> eps;

    for (int i = 0; i < pcie_device_count; i++) {
        std::ostringstream oss;
        oss << "/dev/pci_iodev" << i;
        if (!std::filesystem::exists(oss.str())) {
            break;
        }

        auto path = oss.str();
        if (probe_dma(path)) {
            try {
                controller d(path);
                eps.push_back(d);
            } catch (const std::runtime_error& e) {
                std::cout << e.what() << std::endl;
            }
        }
    }

    for (auto ep : eps) {
        ep.report();
    }
}

} // namespace dma
} // namespace pcie
} // framework
} // app
