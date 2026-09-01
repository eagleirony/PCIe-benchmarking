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

template<size_t Size, size_t Alignment, size_t Boundary> struct buffer {
    struct statistics {
        bool eop;
        size_t length;
    };

    void* buf;
    statistics stats;

    size_t get_size() {
        return Size;
    }
    size_t get_alignment() {
        return Alignment;
    }
    size_t get_boundary() {
        return Boundary;
    }

    void zero() {
        uint64_t* buf_ = static_cast<uint64_t*>(buf);
        for (size_t i = 0; i < Size/sizeof(uint64_t); i++) {
            buf_[i] = 0x0;
        }
    }

    buffer() {
        buf = rtems_cache_coherent_allocate(
            Size,
            Alignment,
            Boundary);
        if (buf == nullptr) {
            throw std::bad_alloc();
        }
    };

    buffer(const buffer&) = delete;
    buffer& operator=(const buffer&) = delete;
    buffer(buffer&&) = delete;
    buffer& operator=(const buffer&&) = delete;
};

using dma_buffer = buffer<DMA_BUFF_SIZE, DMA_BUFF_ALIGN, DMA_BUFF_BOUNDARY>;
using dma_buffer_ptr =
    std::shared_ptr<buffer<DMA_BUFF_SIZE, DMA_BUFF_ALIGN, DMA_BUFF_BOUNDARY>>;

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
    void set_length(size_t len);
    void set_wb(writeback& wb);
    void set_next(descriptor& next);

    void set_buffer(dma_buffer_ptr buf);

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
