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

#ifndef FRAMEWORK_BENCHMARK_LOG_LOGGING_H
#define FRAMEWORK_BENCHMARK_LOG_LOGGING_H

#include <memory>

#include <rtems.h>

#include <framework/logbook.hpp>
#include <framework/dma-mem.hpp>

#include <externals/nlohmann/json.hpp>

namespace app {
namespace framework {
namespace benchmark {
namespace log {

using json = nlohmann::json;

constexpr size_t LOGBOOK_MAX_RECORDS = 20000;

struct cpuusage_info {
    rtems_id task_id;
    struct timespec usage;
};

struct record {
    using id = size_t;
    using type = size_t;

    static constexpr type EP_DMA_PIPELINE_START = 0;
    static constexpr type EP_DMA_PIPELINE_RECV = 1;
    static constexpr type EP_DMA_PIPELINE_END = 2;

    static constexpr type EP_DMA_BLOCK_RX_START = 10;
    static constexpr type EP_DMA_BLOCK_RX_END = 11;
    static constexpr type EP_DMA_BLOCK_TX_START = 12;
    static constexpr type EP_DMA_BLOCK_TX_END = 13;

    static constexpr type EP_USER_INTR_START = 20;
    static constexpr type EP_USER_INTR_END = 21;
    static constexpr type PL_USER_INTR_START = 22;
    static constexpr type PL_USER_INTR_END = 23;

    static constexpr type EP_IO_READ_START = 30;
    static constexpr type EP_IO_READ_OCCURED = 31;
    static constexpr type EP_IO_READ_RETURNED = 32;
    static constexpr type PL_IO_READ_START = 33;
    static constexpr type PL_IO_READ_RETURNED = 34;

    static constexpr type EP_IO_WRITE_START = 40;
    static constexpr type EP_IO_WRITE_OCCURED = 41;
    static constexpr type EP_IO_WRITE_RETURNED = 42;
    static constexpr type PL_IO_WRITE_START = 43;
    static constexpr type PL_IO_WRITE_RETURNED = 44;

    static constexpr type CPU_USE = 50;
    static constexpr type THREAD_START = 51;
    static constexpr type THREAD_END = 52;

    id id_;
    type type_;
    struct timespec timestamp;
    union {
        pcie::dma::mem::buffer::statistics buf_stats;
        cpuusage_info cpu_usage;
        struct timespec latency;
    };

    void set_buf_stats(pcie::dma::mem::buffer::statistics& buf_stats_) {
        buf_stats = buf_stats_;
    }

    void set_cpu_usage_id(rtems_id id) {
        cpu_usage.task_id = id;
    }

    struct timespec* get_cpu_usage_timespec() {
        return &cpu_usage.usage;
    }

    struct timespec* get_latency_timespec() {
        return &latency;
    }

    void serialise(json& j);
    constexpr std::string_view type_to_str(type rt) {
        switch (rt) {
            case EP_DMA_PIPELINE_START:
                return "EP_DMA_PIPELINE_START";
            case EP_DMA_PIPELINE_RECV:
                return "EP_DMA_PIPELINE_RECV";
            case EP_DMA_PIPELINE_END:
                return "EP_DMA_PIPELINE_END";

            case EP_DMA_BLOCK_RX_START:
                return "EP_DMA_BLOCK_RX_START";
            case EP_DMA_BLOCK_RX_END:
                return "EP_DMA_BLOCK_RX_END";
            case EP_DMA_BLOCK_TX_START:
                return "EP_DMA_BLOCK_TX_START";
            case EP_DMA_BLOCK_TX_END:
                return "EP_DMA_BLOCK_TX_END";

            case EP_USER_INTR_START:
                return "EP_USER_INTR_START";
            case EP_USER_INTR_END:
                return "EP_USER_INTR_END";
            case PL_USER_INTR_START:
                return "PL_USER_INTR_START";
            case PL_USER_INTR_END:
                return "PL_USER_INTR_END";

            case EP_IO_READ_START:
                return "EP_IO_READ_START";
            case EP_IO_READ_OCCURED:
                return "EP_IO_READ_OCCURED";
            case EP_IO_READ_RETURNED:
                return "EP_IO_READ_RETURNED";
            case PL_IO_READ_START:
                return "PL_IO_READ_START";
            case PL_IO_READ_RETURNED:
                return "PL_IO_READ_RETURNED";

            case EP_IO_WRITE_START:
                return "EP_IO_WRITE_START";
            case EP_IO_WRITE_OCCURED:
                return "EP_IO_WRITE_OCCURED";
            case EP_IO_WRITE_RETURNED:
                return "EP_IO_WRITE_RETURNED";
            case PL_IO_WRITE_START:
                return "PL_IO_WRITE_START";
            case PL_IO_WRITE_RETURNED:
                return "PL_IO_WRITE_RETURNED";

            case CPU_USE:
                return "CPU USE";
            case THREAD_START:
                return "THREAD START";
            case THREAD_END:
                return "THREAD END";

            default:
                return "UNKNOWN TYPE";
        }
    }

};

using logbook_type = logbook::logbook<LOGBOOK_MAX_RECORDS, record>;
using logbook_ptr = std::shared_ptr<logbook_type>;

logbook_ptr make_logbook();
static logbook_ptr lb_ = make_logbook();

inline void reset() {
    lb_->reset();
}

inline void output_and_reset(std::string out_path) {
    lb_->output_and_reset(out_path);
}

inline record::id timestamp_and_log(record::type type) {
    return lb_->timestamp_and_log(type);
}

inline record::id log_and_timestamp(record::type type) {
    return lb_->log_and_timestamp(type);
}

inline record::id log(record::type type) {
    return lb_->log(type);
}

inline void timestamp(record::id id) {
    lb_->timestamp(id);
}

inline void set_buf_stats(record::id id,
    pcie::dma::mem::buffer::statistics& buf_stats_) {
    lb_->records[id].set_buf_stats(buf_stats_);
}

inline void set_cpu_usage_id(record::id id, rtems_id id_) {
    lb_->records[id].set_cpu_usage_id(id_);
}

inline struct timespec* get_cpu_usage_timespec(record::id id) {
    return lb_->records[id].get_cpu_usage_timespec();
}

inline struct timespec* get_latency_timespec(record::id id) {
    return lb_->records[id].get_latency_timespec();
}

} // namespace log
} // namespace benchmark
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_BENCHMARK_LOG_LOGGING_H
