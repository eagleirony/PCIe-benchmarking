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

#include <cstdint>
#include <cstddef>
#include <cstring>
#include <memory>

#include <rtems/rtems/cache.h>

static constexpr size_t DMA_BUFF_SIZE = 0x1000;
static constexpr size_t DMA_BUFF_ALIGN = 0x1000;
static constexpr size_t DMA_BUFF_BOUNDARY = 0;

namespace app {
namespace framework {
namespace pcie {
namespace dma {
namespace mem {

template<size_t Size, size_t Alignment, size_t Boundary> struct buffer {
    void* buf;

    size_t get_size() {
        return Size;
    }
    size_t get_alignment() {
        return Alignment;
    }
    size_t get_boundary() {
        return Boundary;
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
};

using dma_buffer = buffer<DMA_BUFF_SIZE, DMA_BUFF_ALIGN, DMA_BUFF_BOUNDARY>;
using dma_buffer_ptr =
    std::shared_ptr<buffer<DMA_BUFF_SIZE, DMA_BUFF_ALIGN, DMA_BUFF_BOUNDARY>>;

struct writeback {
    void* wb;

    writeback();

    void clear();

    bool valid();
    bool eop();
    uint32_t length();

protected:
    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);
};

using writeback_ptr = std::shared_ptr<writeback>;

struct descriptor {
    void* desc;
    uint32_t length;
    dma_buffer_ptr buf;
    writeback_ptr wb;

    descriptor();

    void init();
    void set_buffer(dma_buffer_ptr buf);
    void set_length(size_t len);
    void set_wb(writeback_ptr wb);

    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);
};

using descriptor_ptr = std::shared_ptr<descriptor>;

} // namespace mem
} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app
#endif /* FRAMEWORK_PCIE_MEM_H */
