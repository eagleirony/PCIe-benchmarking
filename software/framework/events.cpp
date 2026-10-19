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

#include <rtems.h>
#include <rtems/rtems/intr.h>

#include <framework/events.hpp>

namespace app {
namespace framework {
namespace rtems {
namespace events {

event::event(bool pending_, rtems_event_set event_set_) : waiting(false),
    pending_allowed(pending_), waiter(RTEMS_ID_NONE), event_set(event_set_) {
    waiter = rtems_task_self();
}

event::status_code event::wait(int timeout_ms) {
    rtems_event_set event_out;
    rtems_interval timeout;
    rtems_status_code status;

    if (timeout_ms == 0) {
        timeout = RTEMS_NO_TIMEOUT;
    } else {
        timeout = RTEMS_MILLISECONDS_TO_TICKS(timeout_ms);
    }

    lock.lock();
    waiter = rtems_task_self();
    waiting = true;
    lock.unlock();

    status = rtems_event_receive(
        event_set,
        RTEMS_WAIT,
        timeout,
        &event_out
    );

    lock.lock();
    waiting = false;
    lock.unlock();

    if (status == RTEMS_TIMEOUT) {
        return status_code::TIMED_OUT;
    }
    return status_code::SUCCESSFUL;
}

event::status_code event::wait() {
    return wait(0);
}

event::status_code event::signal() {
    rtems_status_code status;
    lock_guard guard(lock);
    if (!pending_allowed && !waiting) {
        return status_code::NOT_WAITING;
    }

    status = rtems_event_send(waiter, event_set);

    if (status == RTEMS_INVALID_ID) {
        return status_code::ID_ERROR;
    }
    return status_code::SUCCESSFUL;
}

} // namespace events
} // namespace rtems
} // namespace framework
} // namespace app
