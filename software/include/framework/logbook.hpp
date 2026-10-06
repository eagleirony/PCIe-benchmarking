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

#ifndef FRAMEWORK_BENCHMARK_LOGBOOK_H
#define FRAMEWORK_BENCHMARK_LOGBOOK_H

#include <filesystem>
#include <fstream>
#include <atomic>
#include <utility>

#include <externals/nlohmann/json.hpp>

namespace app {
namespace framework {
namespace benchmark {
namespace logbook {

using json = nlohmann::json;

template<typename T>
concept RecordStruct = requires(T a, json& j, size_t t) {
    { a.id_ } -> std::convertible_to<size_t>;
    { a.type_ } -> std::convertible_to<size_t>;
    { a.timestamp } -> std::convertible_to<struct timespec>;

    { a.serialise(j) } -> std::same_as<void>;
    { a.type_to_str(t) } -> std::constructible_from<std::string>;
};

template<size_t Size, RecordStruct Record> struct logbook {
    using record_id = size_t;
    using record_type = size_t;

    std::array<Record, Size> records;
    std::atomic<record_id> tail{0};

    logbook() {
        reset();
    }

    void reset() {
        tail.store(0);
    }

    void output_and_reset(std::string out_path) {
        json j;
        size_t records_len;

        std::filesystem::remove(out_path);
        std::ofstream ofile(out_path, std::ios::out | std::ios::trunc);
        if (!ofile.is_open()) {
            ofile.close();
            std::ostringstream oss;
            oss << "logbook: unable to open: " + out_path << ": "
                << std::strerror(errno);
            throw std::runtime_error(oss.str());
        }

        records_len = tail.load();

        for (size_t i = 0; i < records_len; i++) {
            json rj;
            records[i].serialise(rj);

            j.push_back(rj);
        }

        ofile << j.dump(2);
        ofile.close();

        reset();
    }

    record_id timestamp_and_log(record_type type) {
        struct timespec timestamp;
        ::clock_gettime(CLOCK_MONOTONIC, &timestamp);

        auto id = tail.fetch_add(1, std::memory_order_relaxed);
        if (id >= Size) {
            throw std::runtime_error("logbook: too many records");
        }

        records[id].id_ = id;
        records[id].type_ = type;
        records[id].timestamp.tv_sec = timestamp.tv_sec;
        records[id].timestamp.tv_nsec = timestamp.tv_nsec;

        return id;
    }

    record_id log(record_type type) {
        auto id = tail.fetch_add(1, std::memory_order_relaxed);
        if (id >= Size) {
            throw std::runtime_error("logbook: too many records");
        }

        records[id].id_ = id;
        records[id].type_ = type;

        return id;
    }

    void timestamp(record_id id) {
        ::clock_gettime(CLOCK_MONOTONIC, &records[id].timestamp);
    }

    record_id log_and_timestamp(record_type type) {
        auto id = log(type);
        timestamp(id);
        return id;
    }
};

} // namespace logbook
} // namespace benchmark
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_BENCHMARK_LOGBOOK_H
