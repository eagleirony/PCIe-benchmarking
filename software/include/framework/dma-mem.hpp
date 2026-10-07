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

#ifndef FRAMEWORK_PCIE_MEM_H
#define FRAMEWORK_PCIE_MEM_H

#include <iostream>
#include <cstdint>
#include <cstddef>
#include <cstring>
#include <memory>

#include <rtems/rtems/cache.h>

static constexpr size_t DMA_BUFF_SIZE = 0x10000;
static constexpr size_t DMA_BUFF_ALIGN = 0x100;
static constexpr size_t DMA_BUFF_BOUNDARY = 0;

namespace app {
namespace framework {
namespace pcie {
namespace dma {
namespace mem {

struct buffer {
    struct statistics {
        bool eop;
        bool eos;
        size_t length;
    };

    void* buf;
    statistics stats;
    size_t size;
    size_t alignment;
    size_t boundary;

    size_t get_size() {
        return size;
    }
    size_t get_alignment() {
        return alignment;
    }
    size_t get_boundary() {
        return boundary;
    }

    buffer(size_t size_, size_t alignment_, size_t boundary_) :
        size(size_), alignment(alignment_), boundary(boundary_) {
        buf = rtems_cache_coherent_allocate(
            size,
            alignment,
            boundary);
        if (buf == nullptr) {
            throw std::bad_alloc();
        }
    };

    buffer(const buffer&) = delete;
    buffer& operator=(const buffer&) = delete;
    buffer(buffer&&) = delete;
    buffer& operator=(const buffer&&) = delete;
};

using dma_buffer = buffer;
using dma_buffer_ptr =
    std::shared_ptr<buffer>;

struct writeback {
    void* wb;

    writeback() : wb(nullptr) {};
    writeback(const writeback&) = delete;
    writeback& operator=(const writeback&) = delete;
    writeback(writeback&&) = delete;
    writeback& operator=(const writeback&&) = delete;

    void clear();

    bool valid();
    bool eop();
    uint32_t length();

protected:
    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);
};

struct descriptor {
    void* desc;
    uint32_t length;
    dma_buffer_ptr buf;
    writeback* wb;
    descriptor* next;

    descriptor() : desc(nullptr), length(0), buf(nullptr), wb(nullptr) {};
    descriptor(const descriptor&) = delete;
    descriptor& operator=(const descriptor&) = delete;
    descriptor(descriptor&&) = delete;
    descriptor& operator=(const descriptor&&) = delete;

    void zero();
    void header(bool cmpl, bool stop);
    void header(bool cmpl, bool stop, size_t adj);
    void set_length(size_t len);
    void set_wb(writeback& wb);
    void set_next(descriptor& next);
    void clear_next();

    void set_dst_buffer(dma_buffer_ptr buf);
    void set_src_buffer(dma_buffer_ptr buf);

protected:
    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);
};

} // namespace mem
} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app
#endif /* FRAMEWORK_PCIE_MEM_H */
