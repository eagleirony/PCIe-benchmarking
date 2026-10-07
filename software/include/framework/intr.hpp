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

#ifndef FRAMEWORK_API_INTR_H
#define FRAMEWORK_API_INTR_H

#include <memory>
#include <mutex>

namespace app {
namespace framework {
namespace api {
namespace intr {

struct intr_ctlr;
using intr_ctlr_ptr = std::shared_ptr<intr_ctlr>;

intr_ctlr_ptr make_intr_ctlr();
static intr_ctlr_ptr ic_ = make_intr_ctlr();

constexpr uint32_t PL_INTR_VECTOR = 121;

void init();

void start();

void stop();

void log_pl_intr();

void log_ep_intr();

} // namespace intr
} // namespace api
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_API_INTR_H
