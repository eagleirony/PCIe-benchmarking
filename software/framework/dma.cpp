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

#include <framework/dma.hpp>
#include <framework/logging.hpp>

#include <platform/dma-pcie.hpp>

namespace app {
namespace framework {
namespace api {
namespace dma {

using pcallback = platform::pcie::dma::channel::pcallback;
using bcallback = platform::pcie::dma::channel::bcallback;

void init() {
    platform::pcie::dma::init();
}

controller_ptr open(size_t buffer_size) {
    auto ctlr = platform::pcie::dma::open(buffer_size);

    usleep(1000);

    return ctlr;
}

bool c2h_running(controller_ptr ctlr, size_t channel) {
    return ctlr->c2h_chans[channel]->is_running();
}

bool h2c_running(controller_ptr ctlr, size_t channel) {
    return ctlr->h2c_chans[channel]->is_running();
}

static void set_data_rate(uint32_t addr, int mbs) {
    uint32_t reg_value;
    double pa_value;
    constexpr uint32_t max_speed = 2000;
    auto ior = io::get_io_registers();

    if (mbs <= 0) {
        throw std::runtime_error(
            "error: dma: set_data_rate: invalid data rate");
    }

    pa_value = mbs * std::pow(2, 32) / max_speed;
    reg_value = static_cast<uint32_t>(std::round(pa_value));

    ior->endpoint.write(addr, reg_value);
}
void set_h2c_data_rate(int mbs) {
    set_data_rate(io::EP_REG_H2C_0_PN23_RATE_OFF, mbs);
}

void set_c2h_data_rate(size_t channel, int mbs) {
    uint32_t addr;

    if (channel == 0) {
        addr = io::EP_REG_C2H_0_PN23_RATE_OFF;
    } else if (channel == 1) {
        addr = io::EP_REG_C2H_1_PN23_RATE_OFF;
    } else {
        throw std::runtime_error("error: dma: set_data_rate: invalid channel");
    }

    set_data_rate(addr, mbs);
}

void test_data_validation(controller_ptr ctlr) {

}

void start_c2h_pipeline(controller_ptr ctlr, size_t channel) {
    if (ctlr->c2h_count <= channel || channel < 0) {
        throw std::runtime_error(
            "error: dma: start_c2h_pipeline: invalid channel");
    }

    pcallback cb = [](platform::pcie::dma::mem::dma_buffer_ptr buf){
        auto id = benchmark::log::timestamp_and_log(
            benchmark::log::record::EP_DMA_PIPELINE_RECV);
        benchmark::log::set_buf_stats(id, buf->stats);
    };

    ctlr->c2h_chans[channel]->set_pipeline_callback(cb);

    ctlr->c2h_chans[channel]->run();
}

void stop_c2h_pipeline(controller_ptr ctlr, size_t channel) {
    if (ctlr->c2h_count <= channel || channel < 0) {
        throw std::runtime_error(
            "error: dma: start_c2h_pipeline: invalid channel");
    }

    ctlr->c2h_chans[channel]->stop();
}

void start_c2h_block(controller_ptr ctlr, size_t channel, size_t length) {
    if (ctlr->c2h_count <= channel || channel < 0) {
        throw std::runtime_error(
            "error: dma: start_c2h_pipeline: invalid channel");
    }

    bcallback cb = [length, ctlr](
        std::vector<platform::pcie::dma::mem::dma_buffer_ptr> bufs) {
        auto id = benchmark::log::timestamp_and_log(
            benchmark::log::record::EP_DMA_BLOCK_RX_END);
        platform::pcie::dma::mem::buffer::statistics stats;
        stats.length = length;
        stats.eop = true;
        benchmark::log::set_buf_stats(id, stats);
        std::cout << "Hello WOrld " << c2h_running(ctlr, 0) << std::endl;
    };

    ctlr->c2h_chans[channel]->set_block_callback(cb);

    ctlr->c2h_chans[channel]->run(length);
        std::cout << "Hello run " << c2h_running(ctlr, 0) << std::endl;
}

void start_h2c_block(controller_ptr ctlr, size_t channel, size_t buffers) {
    uint32_t length = buffers * ctlr->c2h_chans[channel]->buffer_size;

    bcallback cb = [length](
        std::vector<platform::pcie::dma::mem::dma_buffer_ptr> bufs){
        auto id = benchmark::log::timestamp_and_log(
            benchmark::log::record::EP_DMA_BLOCK_TX_END);
        platform::pcie::dma::mem::buffer::statistics stats;
        stats.length = length;
        stats.eop = true;
        benchmark::log::set_buf_stats(id, stats);
        for (auto buf : bufs) {
            std::cout << "Buf: " << buf->stats.length << " " << buf->stats.eop << std::endl;
        }
    };

    ctlr->h2c_chans[channel]->set_block_callback(cb);

    for (size_t i = 0; i < buffers; ++i) {
        auto buf = ctlr->h2c_chans[channel]->get_tx_buffer();
        ctlr->h2c_chans[channel]->add_tx_buffer(buf);
    }
    ctlr->h2c_chans[channel]->run();
}

} // namespace dma
} // namespace api
} // framework
} // app
