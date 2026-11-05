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

#ifndef TESTSUITE_DMA_H
#define TESTSUITE_DMA_H

#include <framework/dma.hpp>

namespace app {
namespace testsuite {
namespace dma {

template <size_t buffer_size, int mbs, int secs> void run_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    sleep(secs);
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);
}

template <size_t buffer_size, int mbs, int runs> void run_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    for (int i = 0; i < runs; ++i) {
        framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        while (framework::api::dma::c2h_running(ctlr, 0)) {
            continue;
        }
    }
}

template <size_t buffer_size, int mbs, int runs> void run_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < runs; ++i) {
        framework::api::dma::start_h2c_block(ctlr, 0, 128);
        while (framework::api::dma::h2c_running(ctlr, 0)) {
            continue;
        }
    }
}

template <size_t buffer_size, int mbs, int runs> void run_bidir_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < runs; ++i) {
        framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        framework::api::dma::start_h2c_block(ctlr, 0, 128);
        while (framework::api::dma::c2h_running(ctlr, 0)
            || framework::api::dma::h2c_running(ctlr, 0)) {
            continue;
        }
    }
}

} // namespace dma
} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_DMA_H */
