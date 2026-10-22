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
    constexpr int irqs = 1000;

    auto ctlr = framework::api::dma::open(buffer_size);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(1000);
    }

    framework::api::intr::stop();
}

static void ep_intr_with_pipeline(int irqs, int mbs) {
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

void test_02() {
    ep_intr_with_pipeline(1000, 500);
}

void test_03() {
    ep_intr_with_pipeline(1000, 420);
}

void test_04() {
    ep_intr_with_pipeline(1000, 415);
}

void test_05() {
    ep_intr_with_pipeline(1000, 400);
}

void test_06() {
    ep_intr_with_pipeline(1000, 200);
}

static void ep_intr_with_block(int runs, int mbs) {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, 200);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < runs; ++i) {
        framework::api::dma::start_c2h_block(ctlr, 0, 64 * buffer_size);
        while (framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::intr::log_ep_intr(ctlr);
        }
    }

    framework::api::intr::stop();
}

void test_07() {
    ep_intr_with_block(100, 500);
}

void test_08() {
    ep_intr_with_block(100, 420);
}

void test_09() {
    ep_intr_with_block(100, 415);
}

void test_10() {
    ep_intr_with_block(100, 400);
}

void test_11() {
    ep_intr_with_block(100, 200);
}

} // namespace msi
} // namespace testsuite
} // namespace app
