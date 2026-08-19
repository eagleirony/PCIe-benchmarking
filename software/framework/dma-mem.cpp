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

namespace app {
namespace framework {
namespace pcie {
namespace dma {
namespace mem {

writeback::writeback() {
    wb = rtems_cache_coherent_allocate(
        XLNX_PCIE_DMA_WB_SIZE,
        XLNX_PCIE_DMA_WB_ALIGNMENT,
        XLNX_PCIE_DMA_WB_BOUNDARY);
    if (wb == nullptr) {
        throw std::bad_alloc();
    }
}

uint32_t writeback::read(uint32_t offset) {
    uint64_t address = reinterpret_cast<uint64_t>(wb);
    address += offset;
    uint32_t* reg = reinterpret_cast<uint32_t*>(address);
    return *reg;
}

void writeback::write(uint32_t offset, uint32_t value) {
    uint64_t address = reinterpret_cast<uint64_t>(wb);
    address += offset;
    uint32_t* reg = reinterpret_cast<uint32_t*>(address);
    *reg = value;
}

void writeback::clear() {
    write(XLNX_PCIE_DMA_WB_MAGIC_STATUS_OFF, 0);
    write(XLNX_PCIE_DMA_WB_LENGTH_OFF, 0);
}

bool writeback::valid() {
    uint32_t magic = read(XLNX_PCIE_DMA_WB_MAGIC_STATUS_OFF)
        & XLNX_PCIE_DMA_WB_MAGIC_MASK;

    return (magic == XLNX_PCIE_DMA_WB_MAGIC_VAL);
}

bool writeback::eop() {
    return ((read(XLNX_PCIE_DMA_WB_MAGIC_STATUS_OFF)
      & XLNX_PCIE_DMA_WB_STATUS_MASK) == 1);
}

uint32_t writeback::length() {
    if (!valid()) {
        return 0;
    }
    return read(XLNX_PCIE_DMA_WB_LENGTH_OFF);
}

descriptor::descriptor() : length(0), buf(nullptr) {
    desc = rtems_cache_coherent_allocate(
        XLNX_PCIE_DMA_DESC_SIZE,
        XLNX_PCIE_DMA_DESC_ALIGNMENT,
        XLNX_PCIE_DMA_DESC_BOUNDARY);
    if (desc == nullptr) {
        throw std::bad_alloc();
    }
}

uint32_t descriptor::read(uint32_t offset) {
    uint64_t address = reinterpret_cast<uint64_t>(desc);
    address += offset;
    uint32_t* reg = reinterpret_cast<uint32_t*>(address);
    return *reg;
}

void descriptor::write(uint32_t offset, uint32_t value) {
    uint64_t address = reinterpret_cast<uint64_t>(desc);
    address += offset;
    uint32_t* reg = reinterpret_cast<uint32_t*>(address);
    *reg = value;
}

void descriptor::init() {
    write(XLNX_PCIE_DMA_DESC_MAGIC_NXT_CTRL_OFF,
        XLNX_PCIE_DMA_DESC_MAGIC_VAL | XLNX_PCIE_DMA_DESC_CTRL_STOP);
}

void descriptor::set_buffer(dma_buffer_ptr buf_) {
    uint64_t buf_addr;
    uint32_t dst_hi;
    uint32_t dst_lo;

    buf = buf_;
    buf_addr = reinterpret_cast<uint64_t>(buf->buf);

    dst_lo = static_cast<uint32_t>(buf_addr & 0xFFFFFFFF);
    dst_hi = static_cast<uint32_t>(buf_addr >> 32);

    write(XLNX_PCIE_DMA_DESC_DST_ADDR_LOWER_OFF, dst_lo);
    write(XLNX_PCIE_DMA_DESC_DST_ADDR_UPPER_OFF, dst_hi);
}

void descriptor::set_length(size_t length) {
    uint32_t len_trunc;

    if (length > XLNX_PCIE_DMA_DESC_LEN_MASK) {
        throw std::runtime_error(
            "Request too large for single descriptor transfer");
    }

    len_trunc = static_cast<uint32_t>(length & XLNX_PCIE_DMA_DESC_LEN_MASK);

    write(XLNX_PCIE_DMA_DESC_LEN_OFF, len_trunc);
}

void descriptor::set_wb(writeback_ptr wb_) {
    uint64_t wb_addr;
    uint32_t dst_hi;
    uint32_t dst_lo;

    wb = wb_;
    wb_addr = reinterpret_cast<uint64_t>(wb->wb);

    dst_lo = static_cast<uint32_t>(wb_addr & 0xFFFFFFFF);
    dst_hi = static_cast<uint32_t>(wb_addr >> 32);

    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_LOWER_OFF, dst_lo);
    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_UPPER_OFF, dst_hi);
}

} // namespace mem
} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app
