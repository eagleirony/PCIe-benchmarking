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

#ifndef FRAMEWORK_RTEMS_EVENTS_H
#define FRAMEWORK_RTEMS_EVENTS_H

#include <mutex>
#include <ostream>
#include <iostream>

#include <rtems.h>

namespace app {
namespace framework {
namespace rtems {
namespace events {

struct event {
    using lock_type = std::recursive_mutex;
    using lock_guard = std::lock_guard<lock_type>;

    enum status_code {
        SUCCESSFUL,
        TIMED_OUT,
        ID_ERROR,
        NOT_WAITING
    };

    lock_type lock;
    bool waiting;
    bool pending_allowed;
    rtems_id waiter;
    rtems_event_set event_set;

    event(bool pending_, rtems_event_set event_set_) : waiting(false),
        pending_allowed(pending_), waiter(RTEMS_ID_NONE), event_set(event_set_) {}

    status_code wait();
    status_code wait(int timeout_ms);
    status_code signal();
};

} // namespace events
} // namespace rtems
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_RTEMS_EVENTS_H
