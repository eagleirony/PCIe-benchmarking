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

#ifndef FRAMEWORK_BENCHMARK_LOG_H
#define FRAMEWORK_BENCHMARK_LOG_H

#include <filesystem>
#include <fstream>
#include <atomic>

#include <externals/nlohmann/json.hpp>

namespace app {
namespace framework {
namespace benchmark {
namespace log {

using json = nlohmann::json;

constexpr size_t LOGBOOK_MAX_RECORDS = 20000;

struct logbook;
using logbook_ptr = std::shared_ptr<logbook>;

logbook_ptr make_logbook();
static logbook_ptr lb_ = make_logbook();

enum record_type {
    EP_DMA_PIPELINE_START,
    EP_DMA_PIPELINE_RECV,
    EP_DMA_PIPELINE_END,

    EP_DMA_BLOCK_RX_START,
    EP_DMA_BLOCK_RX_END,
    EP_DMA_BLOCK_TX_START,
    EP_DMA_BLOCK_TX_END,

    EP_USER_INTR_START,
    EP_USER_INTR_END,
    PL_USER_INTR_START,
    PL_USER_INTR_END,

    EP_IO_READ_START,
    EP_IO_READ_OCCURED,
    EP_IO_READ_RETURNED,
    PL_IO_READ_START,
    PL_IO_READ_RETURNED,

    EP_IO_WRITE_START,
    EP_IO_WRITE_OCCURED,
    EP_IO_WRITE_RETURNED,
    PL_IO_WRITE_START,
    PL_IO_WRITE_RETURNED,

    CPU_USE
};

constexpr std::string_view record_type_to_str(record_type rt) {
    switch (rt) {
        case record_type::EP_DMA_PIPELINE_START:
            return "EP_DMA_PIPELINE_START";
        case record_type::EP_DMA_PIPELINE_RECV:
            return "EP_DMA_PIPELINE_RECV";
        case record_type::EP_DMA_PIPELINE_END:
            return "EP_DMA_PIPELINE_END";

        case record_type::EP_DMA_BLOCK_RX_START:
            return "EP_DMA_BLOCK_RX_START";
        case record_type::EP_DMA_BLOCK_RX_END:
            return "EP_DMA_BLOCK_RX_END";
        case record_type::EP_DMA_BLOCK_TX_START:
            return "EP_DMA_BLOCK_TX_START";
        case record_type::EP_DMA_BLOCK_TX_END:
            return "EP_DMA_BLOCK_TX_END";

        case record_type::EP_USER_INTR_START:
            return "EP_USER_INTR_START";
        case record_type::EP_USER_INTR_END:
            return "EP_USER_INTR_END";
        case record_type::PL_USER_INTR_START:
            return "PL_USER_INTR_START";
        case record_type::PL_USER_INTR_END:
            return "PL_USER_INTR_END";

        case record_type::EP_IO_READ_START:
            return "EP_IO_READ_START";
        case record_type::EP_IO_READ_OCCURED:
            return "EP_IO_READ_OCCURED";
        case record_type::EP_IO_READ_RETURNED:
            return "EP_IO_READ_RETURNED";
        case record_type::PL_IO_READ_START:
            return "PL_IO_READ_START";
        case record_type::PL_IO_READ_RETURNED:
            return "PL_IO_READ_RETURNED";

        case record_type::EP_IO_WRITE_START:
            return "EP_IO_WRITE_START";
        case record_type::EP_IO_WRITE_OCCURED:
            return "EP_IO_WRITE_OCCURED";
        case record_type::EP_IO_WRITE_RETURNED:
            return "EP_IO_WRITE_RETURNED";
        case record_type::PL_IO_WRITE_START:
            return "PL_IO_WRITE_START";
        case record_type::PL_IO_WRITE_RETURNED:
            return "PL_IO_WRITE_RETURNED";

        case record_type::CPU_USE:
            return "CPU USE";

        default:
            return "UNKNOWN TYPE";
    }
}

struct record {
    using record_id = ssize_t;
    static constexpr ssize_t no_parent = -1;

    record_id id;
    record_id parent;
    record_type type;
    struct timespec timestamp;
    union {
        uint32_t reg_value;
        size_t transfer_size;
    };
};

struct logbook {
    using record_id = record::record_id;
    std::array<record, LOGBOOK_MAX_RECORDS> records;
    std::atomic<record::record_id> tail{0};

    logbook() {
        reset();
    }

    void reset() {
        tail.store(0);
    }

    void output_and_reset(std::string out_path) {
        json j;
        size_t records_len;
        std::ofstream ofile(out_path, std::ios::out | std::ios::trunc);
        if (!ofile.is_open()) {
            ofile.close();
            std::ostringstream oss;
            oss << "logbook: unable to open: " + out_path << ": "
                << std::strerror(errno);
            throw std::runtime_error(oss.str());
        }

        records_len = tail.load();

        for (auto i = 0; i < records_len; i++) {
            json rj;
            auto& r = records[i];

            rj["id"] = r.id;
            rj["parent"] = r.parent;
            rj["type"] = record_type_to_str(r.type);
            rj["timestamp"]["seconds"] = r.timestamp.tv_sec;
            rj["timestamp"]["nanoseconds"] = r.timestamp.tv_nsec;

            switch (r.type) {
                case record_type::EP_DMA_PIPELINE_RECV:
                case record_type::EP_DMA_BLOCK_RX_END:
                case record_type::EP_DMA_BLOCK_TX_END:
                    rj["transfer_size"] = r.transfer_size;
                    break;
                case record_type::EP_IO_READ_OCCURED:
                case record_type::EP_IO_WRITE_OCCURED:
                    rj["reg_value"] = r.reg_value;
                    break;
                default:
                    break;
            }

            j.push_back(rj);
        }

        ofile << j.dump(4);
        ofile.close();

        reset();
    }

    record_id timestamp_and_log(record_type type, record_id parent) {
        struct timespec timestamp;
        ::clock_gettime(CLOCK_MONOTONIC, &timestamp);

        auto id = tail.fetch_add(1, std::memory_order_relaxed);
        if (id >= LOGBOOK_MAX_RECORDS) {
            throw std::runtime_error("logbook: too many records");
        }

        records[id].id = id;
        records[id].type = type;
        records[id].parent = parent;
        records[id].timestamp.tv_sec = timestamp.tv_sec;
        records[id].timestamp.tv_nsec = timestamp.tv_nsec;

        return id;
    }
    record_id timestamp_and_log(record_type type) {
        return timestamp_and_log(type, record::no_parent);
    }

    record_id log_and_timestamp(record_type type, record_id parent) {
        auto id = tail.fetch_add(1, std::memory_order_relaxed);
        if (id >= LOGBOOK_MAX_RECORDS) {
            throw std::runtime_error("logbook: too many records");
        }

        records[id].id = id;
        records[id].type = type;
        records[id].parent = parent;

        ::clock_gettime(CLOCK_MONOTONIC, &records[id].timestamp);
        return id;
    }
    record_id log_and_timestamp(record_type type) {
        return log_and_timestamp(type, record::no_parent);
    }

    void set_reg_value(record_id id, uint32_t value) {
        if (records[id].type != EP_IO_READ_OCCURED &&
            records[id].type != EP_IO_WRITE_OCCURED) {
            std::ostringstream oss;
            oss << "logbook: invalid record type for register value " << id;
            throw std::runtime_error(oss.str());
        }

        records[id].reg_value = value;
    }

    void set_transfer_size(record_id id, size_t value) {
        if (records[id].type != EP_DMA_PIPELINE_RECV &&
            records[id].type != EP_DMA_BLOCK_TX_END &&
            records[id].type != EP_DMA_BLOCK_RX_END) {
            std::ostringstream oss;
            oss << "logbook: invalid record type for transfer size " << id;
            throw std::runtime_error(oss.str());
        }

        records[id].transfer_size = value;
    }
};

inline void reset() {
    lb_->reset();
}

inline void output_and_reset(std::string out_path) {
    lb_->output_and_reset(out_path);
}

inline logbook::record_id timestamp_and_log(record_type type, logbook::record_id parent) {
    return lb_->timestamp_and_log(type, parent);
}

inline logbook::record_id timestamp_and_log(record_type type) {
    return lb_->timestamp_and_log(type);
}

inline logbook::record_id log_and_timestamp(record_type type, logbook::record_id parent) {
    return lb_->log_and_timestamp(type, parent);
}

inline logbook::record_id log_and_timestamp(record_type type) {
    return lb_->log_and_timestamp(type);
}

inline void set_reg_value(logbook::record_id id, uint32_t value) {
    lb_->set_reg_value(id, value);
}

inline void set_transfer_size(logbook::record_id id, size_t value) {
    lb_->set_transfer_size(id, value);
}

} // namespace log
} // namespace benchmark
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_BENCHMARK_LOG_H
