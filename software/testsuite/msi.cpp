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

static void ep_intr_with_dma(int irqs, int mbs) {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

void test_01() {
    constexpr size_t buffer_size = 0x10000;
    constexpr int irqs = 1000;

    auto ctlr = framework::api::dma::open(buffer_size);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }

    framework::api::intr::stop();
}

void test_02() {
    ep_intr_with_dma(1000, 500);
}

void test_03() {
    ep_intr_with_dma(1000, 420);
}

void test_04() {
    ep_intr_with_dma(1000, 415);
}

void test_05() {
    ep_intr_with_dma(1000, 400);
}

void test_06() {
    ep_intr_with_dma(1000, 200);
}

void test_07() {
    constexpr size_t buffer_size = 0x10000;
    constexpr int runs = 100;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 200);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < runs; ++i) {
        framework::api::dma::start_c2h_block(ctlr, 0, 0x20000);
        bool running = framework::api::dma::c2h_running(ctlr, 0);
        while (running) {
            usleep(1000);
            running = framework::api::dma::c2h_running(ctlr, 0);
        }
    }

    framework::api::intr::stop();
}

} // namespace msi
} // namespace testsuite
} // namespace app
