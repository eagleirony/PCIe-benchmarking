/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Copyright 2026 Aaron Nyholm, All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *gt
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <iostream>

#include <rtems.h>
#include <rtems/rtems/tasks.h>

#include <framework/cpuuse.hpp>
#include <framework/logging.hpp>

#include <externals/rtems/thread.hpp>

namespace app {
namespace framework {
namespace api {
namespace cpuuse {

thread_index_ptr ti;

thread_index_ptr make_thread_index() {
    if (!ti) {
        ti = std::make_shared<thread_index>();
    }
    return ti;
}

struct thread_index {
    using lock_type = std::recursive_mutex;
    using lock_guard = std::lock_guard<lock_type>;
    using rtems_thread = rtems::thread::thread;

    lock_type lock;
    bool logging;
    std::vector<std::pair<std::string, rtems_id>> index;
    rtems_thread cpuuse_thread;
    uint64_t timeout_ms;

    thread_index() : logging(0) {};

    ~thread_index() {
        stop();
    }

    void add(std::string name, rtems_id id) {
        lock_guard guard(lock);
        index.push_back({name, id});
    }

    void remove(std::string name) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&name](const auto& item) {
            return item.first == name;
        });
        if (it != index.end()) {
            index.erase(it);
        }
    }

    void remove(rtems_id id) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&id](const auto& item) {
            return item.second == id;
        });
        if (it != index.end()) {
            index.erase(it);
        }
    }

    void remove_all() {
        lock_guard guard(lock);
        index.clear();
    }

    std::string get_name(rtems_id id) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&id](const auto& item) {
            return item.second == id;
        });
        if (it != index.end()) {
            return it->first;
        }
        return "Unknown Thread";
    }

    void set_timeout(uint64_t timeout_) {
        lock_guard guard(lock);
        timeout_ms = timeout_;
    }

    void run() {
        lock_guard guard(lock);
        uint64_t timeout_us = timeout_ms * 1000;
        start_worker();
        while(!logging) {
            lock.unlock();
            usleep(timeout_us);
            lock.lock();
        }
    }

    void stop() {
        {
        lock_guard guard(lock);
        logging = false;
        }
        if (cpuuse_thread.joinable()) {
            cpuuse_thread.join();
        }
    }

    void worker() {
        log_guard lguard("CPU_USE");
        lock_guard guard(lock);
        uint64_t timeout_us = timeout_ms * 1000;
        logging = true;
        while (logging) {
            rtems_status_code sc;

            for (auto& item : index) {
                auto log_id = benchmark::log::log(
                    benchmark::log::record::CPU_USE);
                benchmark::log::set_cpu_usage_id(log_id, item.second);
                sc = rtems_task_get_cpu_usage(item.second,
                    benchmark::log::get_cpu_usage_timespec(log_id));
                benchmark::log::timestamp(log_id);
                if (sc != RTEMS_SUCCESSFUL) {
                    std::ostringstream oss;
                    oss << "cpuuse: worker: failed to get cpu usage for "
                        << item.first << ": " << sc;
                    throw std::runtime_error(oss.str());
                }
            }

            lock.unlock();
            usleep(timeout_us);
            lock.lock();
        }
    }

    void start_worker() {
        lock_guard guard(lock);
        rtems::thread::attributes attr;
        std::ostringstream oss;

        oss << "CPU_USE";

        attr.set_name(oss.str().c_str());
        attr.set_rtems_priority(99);
        attr.set_stack_size(RTEMS_MINIMUM_STACK_SIZE);

        cpuuse_thread = rtems::thread::thread(attr, &thread_index::worker,
            this);
    }
};

void init(uint64_t usecs) {
    ti->set_timeout(usecs);
}

void run() {
    ti->run();
}

void reset() {
    ti->stop();
    ti->remove_all();
}

void reset_and_run() {
    ti->remove_all();
    ti->run();
}

void stop() {
    ti->stop();
}

void register_thread(std::string name) {
    auto id = benchmark::log::timestamp_and_log(benchmark::log::record::THREAD_START);
    ti->add(name, rtems_task_self());
    benchmark::log::set_cpu_usage_id(id, rtems_task_self());
}

void unregister_thread() {
    auto id = benchmark::log::log(benchmark::log::record::THREAD_END);
    benchmark::log::set_cpu_usage_id(id, rtems_task_self());
    benchmark::log::timestamp(id);
}

std::string name_from_id(rtems_id id) {
    return ti->get_name(id);
}

} // namespace cpuuse
} // namespace api
} // namespace framework
} // namespace app
