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

int main(int argc, char** argv) {
    rtems_status_code sc;

    app::platform::network::init();
    app::platform::pl::init();

    app::platform::network::start(30, false);

    std::cout << std::endl << "PCITB version: " << app_build_id() << std::endl;

    sc = rtems_shell_init(
        "PCITB",
        60 * 1024,
        200,
        "stdin", 0, 1, NULL);
    if (sc != RTEMS_SUCCESSFUL) {
        printf("Shell init failed\n");
    }

}
