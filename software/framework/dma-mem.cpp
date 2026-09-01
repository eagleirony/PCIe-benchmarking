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

void descriptor::zero() {
    write(XLNX_PCIE_DMA_DESC_MAGIC_NXT_CTRL_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_LOWER_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_UPPER_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_DST_ADDR_LOWER_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_DST_ADDR_UPPER_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_NXT_ADDR_LOWER_OFF, 0x0);
    write(XLNX_PCIE_DMA_DESC_NXT_ADDR_UPPER_OFF, 0x0);
}

void descriptor::header(bool cmpl, bool stop) {
    header(cmpl, stop, 0);
}

void descriptor::header(bool cmpl, bool stop, size_t adj) {
    uint32_t reg = XLNX_PCIE_DMA_DESC_MAGIC_VAL;

    if (adj > 0x3F) {
        throw std::runtime_error("Too many adjacent descriptors");
    }
    uint32_t nxt_adj = static_cast<uint32_t>(adj & 0xFFFFFFFF);

    reg |= (nxt_adj << XLNX_PCIE_DMA_DESC_NXT_SHIFT) & XLNX_PCIE_DMA_DESC_NXT_MASK;

    if (stop) {
        reg |= XLNX_PCIE_DMA_DESC_CTRL_STOP;
    }

    if (cmpl) {
        reg |= XLNX_PCIE_DMA_DESC_CTRL_CMPL;
    }

    write(XLNX_PCIE_DMA_DESC_MAGIC_NXT_CTRL_OFF, reg);
}

void descriptor::set_length(size_t length) {
    uint32_t len_trunc;

    if (desc == nullptr) {
        return;
    }

    if (length > XLNX_PCIE_DMA_DESC_LEN_MASK) {
        throw std::runtime_error(
            "Request too large for single descriptor transfer");
    }

    len_trunc = static_cast<uint32_t>(length & XLNX_PCIE_DMA_DESC_LEN_MASK);

    write(XLNX_PCIE_DMA_DESC_LEN_OFF, len_trunc);
}

void descriptor::set_wb(writeback& wb_) {
    uint64_t wb_addr;
    uint32_t wb_hi;
    uint32_t wb_lo;

    if (desc == nullptr) {
        return;
    }

    wb = &wb_;
    wb_addr = reinterpret_cast<uint64_t>(wb->wb);

    wb_lo = static_cast<uint32_t>(wb_addr & 0xFFFFFFFF);
    wb_hi = static_cast<uint32_t>(wb_addr >> 32);

    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_LOWER_OFF, wb_lo);
    write(XLNX_PCIE_DMA_DESC_SRC_ADDR_UPPER_OFF, wb_hi);
}

void descriptor::set_next(descriptor& next_) {
    uint64_t nxt_addr;
    uint32_t nxt_hi;
    uint32_t nxt_lo;
    next = &next_;

    nxt_addr = reinterpret_cast<uint64_t>(next->desc);

    nxt_lo = static_cast<uint32_t>(nxt_addr & 0xFFFFFFFF);
    nxt_hi = static_cast<uint32_t>(nxt_addr >> 32);

    write(XLNX_PCIE_DMA_DESC_NXT_ADDR_LOWER_OFF, nxt_lo);
    write(XLNX_PCIE_DMA_DESC_NXT_ADDR_UPPER_OFF, nxt_hi);
}

void descriptor::set_buffer(dma_buffer_ptr buf_) {
    uint64_t buf_addr;
    uint32_t buf_hi;
    uint32_t buf_lo;

    if (desc == nullptr) {
        return;
    }

    buf = buf_;
    buf_addr = reinterpret_cast<uint64_t>(buf->buf);

    buf_lo = static_cast<uint32_t>(buf_addr & 0xFFFFFFFF);
    buf_hi = static_cast<uint32_t>(buf_addr >> 32);

    write(XLNX_PCIE_DMA_DESC_DST_ADDR_LOWER_OFF, buf_lo);
    write(XLNX_PCIE_DMA_DESC_DST_ADDR_UPPER_OFF, buf_hi);
}

} // namespace mem
} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app
