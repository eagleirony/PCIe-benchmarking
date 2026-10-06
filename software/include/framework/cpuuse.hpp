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

#ifndef FRAMEWORK_API_CPUUSE_H
#define FRAMEWORK_API_CPUUSE_H

#include <memory>
#include <mutex>

namespace app {
namespace framework {
namespace api {
namespace cpuuse {

struct thread_index;
using thread_index_ptr = std::shared_ptr<thread_index>;

thread_index_ptr make_thread_index();
static thread_index_ptr ti_ = make_thread_index();

void init(uint64_t usecs);

void stop();

void run();

void reset();

void reset_and_run();

void register_thread(std::string name);

void unregister_thread();

std::string name_from_id(rtems_id id);

struct log_guard {
    log_guard(std::string name) {
        register_thread(name);
    }
    ~log_guard() {
        unregister_thread();
    }
};

} // namespace cpuuse
} // namespace api
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_API_CPUUSE_H
