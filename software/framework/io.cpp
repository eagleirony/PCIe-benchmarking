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
#include <framework/logging.hpp>

namespace app {
namespace framework {
namespace api {
namespace io {

io_registers_ptr ior;

io_registers_ptr make_io_registers() {
    if (!ior) {
        ior = std::make_shared<io_registers>();
    }
    return ior;
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

static void verify_registers() {
    if (ior->endpoint.read(EP_REG_PATTERN_0_OFF) != EP_REG_PATTERN_0_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 0 did not match");
    }
    if (ior->endpoint.read(EP_REG_PATTERN_1_OFF) != EP_REG_PATTERN_1_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 1 did not match");
    }
    if (ior->endpoint.read(EP_REG_PATTERN_2_OFF) != EP_REG_PATTERN_2_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 2 did not match");
    }
    if (ior->endpoint.read(EP_REG_PATTERN_3_OFF) != EP_REG_PATTERN_3_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 3 did not match");
    }
    if (ior->endpoint.read(EP_REG_PATTERN_4_OFF) != EP_REG_PATTERN_4_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 4 did not match");
    }
    if (ior->endpoint.read(EP_REG_PATTERN_5_OFF) != EP_REG_PATTERN_5_VAL) {
        throw std::runtime_error("io: verify: endpoint pattern 5 did not match");
    }

    if (ior->pl.read(PL_REG_PATTERN_0_OFF) != PL_REG_PATTERN_0_VAL) {
        throw std::runtime_error("io: verify: pl pattern 0 did not match");
    }
    if (ior->pl.read(PL_REG_PATTERN_1_OFF) != PL_REG_PATTERN_1_VAL) {
        throw std::runtime_error("io: verify: pl pattern 1 did not match");
    }
    if (ior->pl.read(PL_REG_PATTERN_2_OFF) != PL_REG_PATTERN_2_VAL) {
        throw std::runtime_error("io: verify: pl pattern 2 did not match");
    }
    if (ior->pl.read(PL_REG_PATTERN_3_OFF) != PL_REG_PATTERN_3_VAL) {
        throw std::runtime_error("io: verify: pl pattern 3 did not match");
    }
    if (ior->pl.read(PL_REG_PATTERN_4_OFF) != PL_REG_PATTERN_4_VAL) {
        throw std::runtime_error("io: verify: pl pattern 4 did not match");
    }
    if (ior->pl.read(PL_REG_PATTERN_5_OFF) != PL_REG_PATTERN_5_VAL) {
        throw std::runtime_error("io: verify: pl pattern 5 did not match");
    }
}

void init() {
    int fd;
    int status;
    struct rtems_iodev_region region;
    std::string path;
    bool modified;
    uint32_t git_hash;

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

    ior->endpoint.base = mmap(
        NULL,
        region.size,
        ( PROT_READ | PROT_WRITE ),
        MAP_SHARED,
        fd,
        region.index
    );
    if (ior->endpoint.base == MAP_FAILED ) {
        close(fd);
        fd = 0;
        throw std::runtime_error("dma: error: mmap failed");
    }

    ior->pl.base = reinterpret_cast<void*>(PL_REG_BASE);

    verify_registers();

    std::cout << "Endpoint Git Hash: ";
    git_hash = ior->endpoint.read(EP_REG_BUILD_VER_OFF) & 0x0FFFFFFF;
    modified = ((ior->endpoint.read(EP_REG_BUILD_VER_OFF) & 0x80000000) != 0);
    std::cout << std::hex << git_hash << " modified: " << modified
        << std::endl;
    std::cout << "Endpoint Build ID: 0x" << ior->endpoint.read(EP_REG_BUILD_ID_OFF)
        << std::endl;

    std::cout << "PL Git Hash: ";
    git_hash = ior->pl.read(PL_REG_BUILD_VER_OFF) & 0x0FFFFFFF;
    modified = ((ior->pl.read(PL_REG_BUILD_VER_OFF) & 0x80000000) != 0);
    std::cout << std::hex << git_hash << " modified: " << modified
        << std::endl;
    std::cout << "PL Build ID: 0x" << ior->pl.read(PL_REG_BUILD_ID_OFF)
        << std::endl;
}

io_registers_ptr get_io_registers() {
    return ior;
}

void log_ep_read_latency() {
    benchmark::log::log_and_timestamp(benchmark::log::record::EP_IO_READ_START);
    ior->endpoint.read(EP_REG_PATTERN_0_OFF);
    benchmark::log::timestamp_and_log(benchmark::log::record::EP_IO_READ_RETURNED);
}

void log_ep_write_latency() {
    benchmark::log::log_and_timestamp(benchmark::log::record::EP_IO_WRITE_START);
    ior->endpoint.write(EP_REG_SCRATCH_0_OFF, EP_REG_PATTERN_0_VAL);
    benchmark::log::timestamp_and_log(benchmark::log::record::EP_IO_WRITE_RETURNED);
}

void log_ep_one_way_read_latency() {
    struct timespec* latency_ts;
    uint32_t latency;
    uint32_t pl_reg = ior->pl.read(PL_REG_SIGNALS_OFF);
    pl_reg = pl_reg & ~PL_REG_SIGNALS_EXPANSION_OUT;

    ior->pl.write(PL_REG_SIGNALS_OFF, pl_reg);

    pl_reg = pl_reg | PL_REG_SIGNALS_EXPANSION_OUT;

    auto log_id = benchmark::log::log_and_timestamp(benchmark::log::record::EP_IO_READ_OCCURED);
    ior->pl.write(PL_REG_SIGNALS_OFF, pl_reg);
    latency = ior->endpoint.read(EP_REG_USER_TIME_OFF);

    latency_ts = benchmark::log::get_latency_timespec(log_id);
    latency_ts->tv_sec = 0;
    latency_ts->tv_nsec = CLK_PERIOD_NS * latency;
}

void log_ep_one_way_write_latency() {
    struct timespec* latency_ts;
    uint32_t latency;
    uint32_t pl_reg = ior->pl.read(PL_REG_SIGNALS_OFF);
    uint32_t ep_reg = ior->pl.read(EP_REG_SIGNALS_OFF);
    pl_reg = pl_reg & ~PL_REG_SIGNALS_USER_TIMER_RSTN;
    ep_reg = ep_reg & ~EP_REG_SIGNALS_EXPANSION_OUT;

    ior->pl.write(PL_REG_SIGNALS_OFF, pl_reg);
    ior->endpoint.write(EP_REG_SIGNALS_OFF, ep_reg);

    pl_reg = pl_reg | PL_REG_SIGNALS_USER_TIMER_RSTN;
    ep_reg = ep_reg | EP_REG_SIGNALS_EXPANSION_OUT;

    auto log_id = benchmark::log::log_and_timestamp(benchmark::log::record::EP_IO_WRITE_OCCURED);
    ior->pl.write(PL_REG_SIGNALS_OFF, pl_reg);
    ior->endpoint.write(EP_REG_SIGNALS_OFF, ep_reg);
    latency = ior->pl.read(PL_REG_USER_TIME_OFF);

    latency_ts = benchmark::log::get_latency_timespec(log_id);
    latency_ts->tv_sec = 0;
    latency_ts->tv_nsec = CLK_PERIOD_NS * latency;
}

void log_pl_read_latency() {
    benchmark::log::log_and_timestamp(benchmark::log::record::PL_IO_READ_START);
    ior->pl.read(PL_REG_PATTERN_0_OFF);
    benchmark::log::timestamp_and_log(benchmark::log::record::PL_IO_READ_RETURNED);
}

void log_pl_write_latency() {
    benchmark::log::log_and_timestamp(benchmark::log::record::PL_IO_WRITE_START);
    ior->pl.write(PL_REG_SCRATCH_0_OFF, PL_REG_PATTERN_0_VAL);
    benchmark::log::timestamp_and_log(benchmark::log::record::PL_IO_WRITE_RETURNED);
}

} // namespace io
} // namespace api
} // namespace framework
} // namespace app
