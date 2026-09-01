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

#include <stdio.h>

#include <rtems.h>
#include <rtems/fatal.h>
#include <rtems/shell.h>

#include <platform/network.hpp>
#include <platform/pl.hpp>
#include <platform/app-build-id.h>
#include <platform/emmc.hpp>
#include <platform/nfs.hpp>

#include <framework/dma.hpp>
#include <framework/io.hpp>

static constexpr char emmc_mnt_path[] = "/emmc";
static constexpr char nfs_mnt_path[] = "/net";

int main(int argc, char** argv) {
    rtems_status_code sc;

    app::platform::network::init();

    std::string emmc_mnt_path_str = emmc_mnt_path;
    app::platform::emmc::mount(emmc_mnt_path_str);

    app::platform::pl::init();

    app::platform::network::start(30, false);

    std::string nfs_mnt_path_str = nfs_mnt_path;
    app::platform::nfs::mount(nfs_mnt_path_str);

    std::string pl_bitfile_path_str = "/emmc/pl_4.bit";
    app::platform::pl::load(pl_bitfile_path_str);

    std::cout << std::endl << "PCITB version: " << app_build_id() << std::endl;

    try {
        app::framework::api::io::init();
        app::framework::pcie::dma::init();
    } catch (const std::exception& e) {
        std::cout << "Error in DMA: " << e.what() << std::endl;
    }

    sc = rtems_shell_init(
        "PCITB",
        60 * 1024,
        200,
        "stdin", 0, 1, NULL);
    if (sc != RTEMS_SUCCESSFUL) {
        printf("Shell init failed\n");
    }

}
