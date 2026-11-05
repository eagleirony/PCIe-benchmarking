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

#ifndef TESTSUITE_MSI_H
#define TESTSUITE_MSI_H

#include <framework/dma.hpp>
#include <framework/intr.hpp>

namespace app {
namespace testsuite {
namespace msi {

template <int irqs, int interval_ms>
void ep_intrs() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void ep_intr_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::intr::start_ep(ctlr);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_ep_intr(ctlr);
        usleep(interval_ms * 1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void ep_intr_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::intr::log_ep_intr(ctlr);
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void ep_intr_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::intr::log_ep_intr(ctlr);
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void ep_intr_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    framework::api::intr::start_ep(ctlr);

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::intr::log_ep_intr(ctlr);
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <int irqs, int interval_ms>
void pl_intrs() {
    constexpr size_t buffer_size = 0x10000;

    auto ctlr = framework::api::dma::open(buffer_size);

    framework::api::intr::start_pl();

    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_pl_intr();
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void pl_intr_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::intr::start_pl();

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < irqs; ++i) {
        framework::api::intr::log_pl_intr();
        usleep(interval_ms * 1000);
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void pl_intr_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::intr::start_pl();

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::intr::log_pl_intr();
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void pl_intr_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    framework::api::intr::start_pl();

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::intr::log_pl_intr();
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

template <size_t buffer_size, int irqs, int mbs, int interval_ms>
void pl_intr_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    framework::api::intr::start_pl();

    for (int i = 0; i < irqs; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::intr::log_pl_intr();
        usleep(interval_ms * 1000);
    }

    framework::api::intr::stop();
}

} // namespace msi
} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_MSI_H */
