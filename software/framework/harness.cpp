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

#include <framework/harness.hpp>
#include <framework/cpuuse.hpp>
#include <framework/logging.hpp>

#include <testsuite/tests.hpp>

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
    for (const auto& test : tests) {
        std::ostringstream oss;
        std::string name(test.name);
        rtems::thread::attributes attr;

        app::framework::api::cpuuse::reset_and_run();
        oss << name;

        attr.set_name(oss.str().c_str());
        attr.set_rtems_priority(99);
        attr.set_stack_size(64 * 1024);

        auto test_task = rtems::thread::thread(
              attr, &test_runner, test); 

        test_task.join();

        app::framework::api::cpuuse::suspend();

        oss.str("");
        oss.clear();
        oss << "/net/pciebench/logging/" << name << ".log";

        app::framework::benchmark::log::output_and_reset(oss.str());
    }
}

void start() {

    run(testsuite::tests);

}

} // namespace harness
} // namespace api
} // namespace framework
} // namespace app
