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

#include <vector>
#include <string>
#include <iostream>
#include <filesystem>
#include <fstream>

#include <rtems/shell.h>

#include <bsp/aarch64-mmu.h>

#include <dev/pm/pm.h>

namespace app {
namespace platform {
namespace pl {

static constexpr uint64_t M_AXI_HPM0_LPD_BASE = 0x80000000;
static constexpr uint64_t M_AXI_HPM0_LPD_LENGTH = 0x20000000;

struct image_loader {
    std::vector<char> image;
    size_t size;
};

void init() {
    rtems_shell_add_cmd_struct(&bsp_pm_load_shell_command);

    aarch64_mmu_map(
        M_AXI_HPM0_LPD_BASE,
        M_AXI_HPM0_LPD_BASE + M_AXI_HPM0_LPD_LENGTH - 1,
        AARCH64_MMU_DEVICE);
}

void load(std::string& path) {
    int r;
    uint32_t flags = 0;
    uint32_t fpga_status;
    image_loader image;

    if (!std::filesystem::exists(path)) {
        throw std::runtime_error("error: pl: load: " + path + " does not exist");
    }

    image.size = std::filesystem::file_size(path);
    image.image.resize(image.size);

    std::ifstream bitfile(path, std::ios::in | std::ios::binary);
    bitfile.read(image.image.data(), image.size);

    r = bitfile.gcount();
    if (r != image.size) {
        throw std::runtime_error("error: pl: load: read failed");
    }
    bitfile.close();

    std::cout << "Loading " << path << " to PL" << std::endl;
    r = rtems_pm_fpga_load(image.image.data(), image.size, flags, &fpga_status);

    if (r < 0) {
        throw std::runtime_error("error: pl: load: bitfile failed to load");
    }
    std::cout << "PL loaded: status: 0x" << std::hex << fpga_status << std::dec << std::endl;
}

} // pl
} // platform
} // app
