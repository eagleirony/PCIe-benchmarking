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

#include <cstdint>
#include <cstddef>
#include <iostream>
#include <sstream>
#include <filesystem>

#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#include <dev/io/iodev.h>
#include <rtems/bsd/pci-iodev.h>

#include <framework/io.hpp>

namespace app {
namespace framework {
namespace api {
namespace io {

constexpr int pcie_device_count = 4;

constexpr uint32_t dma_devid = 0x902410ee;
constexpr uint16_t dma_vendor = 0x10ee;
constexpr uint16_t dma_subvendor = 0x10ee;
constexpr uint16_t dma_subdevice = 0x0007;

uint32_t* registers::address(uint32_t offset) {
    uint64_t address = reinterpret_cast<uint64_t>(base);

    address = address + offset;

    return reinterpret_cast<uint32_t*>(address);
}

uint32_t registers::read(uint32_t offset) {
    uint32_t* reg = address(offset);

    return *reg;
}

void registers::write(uint32_t offset, uint32_t value) {
    uint32_t* reg = address(offset);

    *reg = value;
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
    int fd;
    int status;
    size_t region_count;
    struct rtems_iodev_region region;
    registers axis;
    std::string path;

    for (int i = 0; i < pcie_device_count; i++) {
        std::ostringstream oss;
        oss << "/dev/pci_iodev" << i;
        if (!std::filesystem::exists(oss.str())) {
            break;
        }

        path = oss.str();
        if (probe_dma(path)) {
            break;
        }
    }

    fd = ::open(path.c_str(), O_RDWR);
    if (fd == -1) {
        throw std::runtime_error("dma: error: iodev open failed");
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

    std::cout << std::endl <<  "Git Hash: ";
    uint32_t git = axis.read(0x30) & 0x0FFFFFFF;
    bool modified = ((axis.read(0x30) & 0x80000000) != 0);
    std::cout << std::hex << "0x" << git << " modified: " << modified << std::endl;
    std::cout << "Build ID: ";
    std::cout << std::hex << "0x" << axis.read(0x2C) << std::endl;
    std::cout << "Register Test Patterns: " << std::endl;
    std::cout << std::hex << "0x" << axis.read(0x0) << std::endl;
    std::cout << std::hex << "0x" << axis.read(0x4) << std::endl;
    std::cout << std::hex << "0x" << axis.read(0x8) << std::endl;
    std::cout << std::hex << "0x" << axis.read(0xC) << std::endl;
    std::cout << std::hex << "0x" << axis.read(0x10) << std::endl;
    std::cout << std::hex << "0x" << axis.read(0x14) << std::endl;
    std::cout << "PCIe Status Register: ";
    std::cout << std::hex << "0x" << axis.read(0x18) << std::endl;
    std::cout << "FIFO Status Register: ";
    std::cout << std::hex << "0x" << axis.read(0x1C) << std::endl;
    uint64_t uptime = (((uint64_t)axis.read(0x20)) << 32)
        | (axis.read(0x24));
    std::cout << "Uptime Register: ";
    std::cout << std::hex << "0x" << uptime << std::endl;
    std::cout << "Counter Register: ";
    std::cout << std::hex << "0x" << axis.read(0x28) << std::endl;
}

} // namespace io
} // namespace api
} // namespace framework
} // namespace app
