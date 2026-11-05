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

#include <config.hpp>

#include <framework/harness.hpp>
#include <framework/io.hpp>
#include <framework/cpuuse.hpp>
#include <framework/logging.hpp>

#include <testsuite/tests.hpp>

#include <platform/app-build-id.h>

#include <externals/rtems/thread.hpp>

namespace app {
namespace framework {
namespace api {
namespace harness {

static void test_runner(const test t) {
    std::string name(t.name);
    cpuuse::log_guard lguard(name);

    t.test();
}

template <size_t N>
static void run(const std::array<test, N>& tests) {
    std::ostringstream logging_dir;
    bool first = true;
    logging_dir << config::NFS_MNT_PATH << "/"
        << config::LOGGING_PATH << "/" << app_build_id() << "/";
    std::string index = logging_dir.str() + "index.txt";

    if (!std::filesystem::exists(logging_dir.str())) {
        std::filesystem::create_directories(logging_dir.str());
    }

    std::filesystem::remove(index);
    std::ofstream ofile(index, std::ios::out | std::ios::trunc);

    ofile << "Software: " << app_build_id() << std::endl;
    ofile << "PL image: " << framework::api::io::pl_build_id() << std::endl;
    ofile << "EP image: " << framework::api::io::ep_build_id() << std::endl;

    std::cout << "Completed: ";
    for (const auto& test : tests) {
        std::string name(test.name);

        std::ostringstream log_path;
        log_path << logging_dir.str() << name << ".log";
        ::rtems::thread::attributes attr;

        framework::api::cpuuse::reset_and_run();

        attr.set_name(name.c_str());
        attr.set_rtems_priority(99);
        attr.set_stack_size(64 * 1024);

        auto test_task = ::rtems::thread::thread(
              attr, &test_runner, test); 

        if (test_task.joinable()) {
            test_task.join();
        } else {
            throw std::runtime_error("error: harness: test_task not joinable");
        }

        framework::api::cpuuse::suspend();
        framework::benchmark::log::output_and_reset(log_path.str());
        ofile << name << ".log: " << test.desc << std::endl;

        if (first == true) {
            std::cout << test.name << std::flush;
            first = false;
        } else {
            std::cout << ", " << test.name << std::flush;
        }
    }
    std::cout << std::endl;
}

void start() {

    run(testsuite::tests);

}

} // namespace harness
} // namespace api
} // namespace framework
} // namespace app
