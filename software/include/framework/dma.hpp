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

#ifndef FRAMEWORK_API_DMA_H
#define FRAMEWORK_API_DMA_H

#include <platform/dma-pcie.hpp>

namespace app {
namespace framework {
namespace api {
namespace dma {

using controller_ptr = platform::pcie::dma::controller_ptr;

void init();

controller_ptr open(size_t buffer_size);

void set_c2h_data_rate(size_t channel, int mbs);

void set_h2c_data_rate(int mbs);

void test_data_validation(controller_ptr ctlr);

void start_c2h_pipeline(controller_ptr ctlr, size_t channel);

void stop_c2h_pipeline(controller_ptr ctlr, size_t channel);

void start_c2h_block(controller_ptr ctlr, size_t channel, size_t length);

void start_h2c_block(controller_ptr ctlr, size_t channel, size_t length);

} // namespace dma
} // namespace api
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_API_DMA_H
