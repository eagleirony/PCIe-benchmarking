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

    struct thread_info {
        rtems_id id;
        std::string name;
        bool active;
        size_t uid;
    };

    lock_type lock;
    bool logging;
    std::vector<thread_info> index;
    rtems_thread cpuuse_thread;
    size_t uid;
    uint64_t timeout_ms;

    thread_index() : logging(false), uid(0), timeout_ms(1) {};

    ~thread_index() {
        stop();
    }

    void add(std::string name, rtems_id id) {
        lock_guard guard(lock);
        index.emplace_back(id, name, true, uid++);
    }

    void remove(rtems_id id) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&id](const auto& item) {
            return item.id == id;
        });
        if (it != index.end()) {
            it->active = false;;
        }
    }

    void remove_all() {
        lock_guard guard(lock);
        index.clear();
    }

    rtems_id get_uid_by_rtems_id(rtems_id id) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&id](const auto& item) {
            return (item.id == id && item.active == true);
        });
        if (it != index.end()) {
            return it->uid;
        }
        return RTEMS_ID_NONE;
    }

    std::string get_name_by_uid(size_t uid) {
        lock_guard guard(lock);
        auto it = std::find_if(index.begin(), index.end(), [&uid](const auto& item) {
            return (item.uid == uid);
        });
        if (it != index.end()) {
            return it->name;
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

    void log(size_t uid) {
        for (auto& item : index) {
            if (item.uid == uid) {
                log(item);
                return;
            }
        }
        std::ostringstream oss;
        oss << "cpuuse: log: unable to find uid: "
            << uid;
        throw std::runtime_error(oss.str());
    }

    void log(thread_info& item) {
        if (item.active) {
            rtems_status_code sc;
            struct timespec usage_ts;
            struct timespec* log_ts;
            sc = rtems_task_get_cpu_usage(item.id, &usage_ts);
            if (sc == RTEMS_INVALID_ID) {
                item.active = false;
                return;
            }
            if (sc != RTEMS_SUCCESSFUL) {
                std::ostringstream oss;
                oss << "cpuuse: worker: failed to get cpu usage for "
                    << item.name << ": " << sc;
                throw std::runtime_error(oss.str());
            }

            auto log_id = benchmark::log::timestamp_and_log(
                benchmark::log::record::CPU_USE);
            benchmark::log::set_cpu_usage_uid(log_id, item.uid);
            log_ts = benchmark::log::get_cpu_usage_timespec(log_id);
            log_ts->tv_sec = usage_ts.tv_sec;
            log_ts->tv_nsec = usage_ts.tv_nsec;
        }
    }

    void worker() {
        log_guard lguard("CPU_USE");
        lock_guard guard(lock);
        uint64_t timeout_us = timeout_ms * 1000;
        logging = true;
        while (logging) {

            for (auto& item : index) {
                log(item);
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

void init(uint64_t msecs) {
    ti->set_timeout(msecs);
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
    ti->add(name, rtems_task_self());

    auto log_id = benchmark::log::timestamp_and_log(
        benchmark::log::record::THREAD_START);
    auto uid = ti->get_uid_by_rtems_id(rtems_task_self());
    benchmark::log::set_cpu_usage_uid(log_id, uid);

    ti->log(uid);
}

void unregister_thread() {
    auto uid = ti->get_uid_by_rtems_id(rtems_task_self());
    ti->log(uid);

    ti->remove(rtems_task_self());

    auto end_log_id = benchmark::log::timestamp_and_log(benchmark::log::record::THREAD_END);
    benchmark::log::set_cpu_usage_uid(end_log_id, uid);
}

std::string name_from_uid(size_t uid) {
    return ti->get_name_by_uid(uid);
}

} // namespace cpuuse
} // namespace api
} // namespace framework
} // namespace app
