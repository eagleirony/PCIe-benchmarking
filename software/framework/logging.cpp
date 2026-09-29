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

#include <framework/logging.hpp>

namespace app {
namespace framework {
namespace benchmark {
namespace log {

logbook_ptr lb;

logbook_ptr make_logbook() {
    if (!lb) {
        lb = std::make_shared<logbook_type>();
    }
    return lb;
}

void record::serialise(json& rj) {
    rj["id"] = id_;
    rj["type"] = type_to_str(type_);
    rj["timestamp"]["seconds"] = timestamp.tv_sec;
    rj["timestamp"]["nanoseconds"] = timestamp.tv_nsec;

    switch (type_) {
        case EP_DMA_PIPELINE_RECV:
        case EP_DMA_BLOCK_RX_END:
        case EP_DMA_BLOCK_TX_END:
            rj["transfer_size"] = transfer_size;
            break;
        default:
            break;
    }
}

} // namespace log
} // namespace benchmark
} // namespace framework
} // namespace app
