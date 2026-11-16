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

#ifndef TESTSUITE_LOG_H
#define TESTSUITE_LOG_H

#include <framework/logging.hpp>

namespace app {
namespace testsuite {
namespace log {

template <int requests, int interval_ms>
void baseline_log() {
    for (int i = 0; i < requests; ++i) {
        framework::benchmark::log::log_and_timestamp(
            framework::benchmark::log::record::BASELINE_START);
        framework::benchmark::log::timestamp_and_log(
            framework::benchmark::log::record::BASELINE_END);
        usleep(interval_ms * 1000);
    }
}

} // namespace log
} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_LOG_H */
