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

#include <framework/harness.hpp>
#include <framework/dma.hpp>
#include <framework/intr.hpp>
#include <framework/cpuuse.hpp>
#include <framework/logging.hpp>

namespace app {
namespace testsuite {
namespace msi {

void test_01() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < 1000; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }

    framework::api::intr::stop();
}

void test_02() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 400);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < 1000; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

void test_03() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 415);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < 1000; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

void test_04() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 200);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < 1000; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

void test_05() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 500);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < 1000; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

} // namespace msi
} // namespace testsuite
} // namespace app
