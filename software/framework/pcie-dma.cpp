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

static bool probe_iodev(std::string path) {
    int fd;
    int status;
    struct pci_iodev_info info;

    fd = ::open(path.c_str(), O_RDWR);
    if (fd == -1) {
        std::cout << "OPEN FAILED " << path << std::endl;
        return false;
    }

    status = ::ioctl(fd, RTEMS_IODEV_IOCTL_DEVICE_INFO, &info);
    if (status == -1) {
        close(fd);
        std::cout << "IOCTL FAILED " << path << std::endl;
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
        if (probe_iodev(oss.str())) {
            std::cout << "FOUND PCIE DMA: " << oss.str() << std::endl;
        }
    }

}

} // namespace dma
} // namespace pcie
} // framework
} // app
