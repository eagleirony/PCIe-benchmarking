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

#ifndef TESTSUITE_IO_H
#define TESTSUITE_IO_H

namespace app {
namespace testsuite {
namespace io {

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void read_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < requests; ++i) {
        framework::api::io::log_ep_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);
}

template <size_t buffer_size, int mbs, int requests>
void write_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < requests; ++i) {
        framework::api::io::log_ep_write_latency();
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);
}

template <size_t buffer_size, int mbs, int requests>
void one_way_read_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < requests; ++i) {
        framework::api::io::log_ep_one_way_read_latency();
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);
}

template <size_t buffer_size, int mbs, int requests>
void one_way_write_with_pipeline() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    framework::api::dma::start_c2h_pipeline(ctlr, 0);
    for (int i = 0; i < requests; ++i) {
        framework::api::io::log_ep_one_way_write_latency();
    }
    framework::api::dma::stop_c2h_pipeline(ctlr, 0);
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void read_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::io::log_ep_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void write_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::io::log_ep_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_read_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::io::log_ep_one_way_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_write_with_c2h_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        framework::api::io::log_ep_one_way_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void read_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void write_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_read_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_one_way_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_write_with_h2c_block() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_one_way_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void read_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void write_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_read_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_one_way_read_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <size_t buffer_size, int mbs, int requests, int interval_ms>
void one_way_write_with_bidir_blocks() {
    auto ctlr = framework::api::dma::open(buffer_size);
    framework::api::dma::set_c2h_data_rate(0, mbs);
    framework::api::dma::set_h2c_data_rate(0, mbs);

    for (int i = 0; i < requests; ++i) {
        if (!framework::api::dma::c2h_running(ctlr, 0)) {
            framework::api::dma::start_c2h_block(ctlr, 0, 128 * buffer_size);
        }
        if (!framework::api::dma::h2c_running(ctlr, 0)) {
            framework::api::dma::start_h2c_block(ctlr, 0, 128);
        }
        framework::api::io::log_ep_one_way_write_latency();
        if (interval_ms != 0) {
            usleep(interval_ms * 1000);
        }
    }
}

template <int requests, int interval_ms>
void pl_read() {
    for (int i = 0; i < requests; ++i) {
        framework::api::io::log_pl_read_latency();
    }
}

} // namespace io
} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_IO_H */
