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

#ifndef FRAMEWORK_PCIE_DMA_H
#define FRAMEWORK_PCIE_DMA_H

#include <vector>
#include <cstdint>
#include <memory>

#include <externals/cs/aligned.hpp>

constexpr uint32_t XLNX_PCIE_DMA_MAX_CHANS = 4;

/* Descriptors */
constexpr uint32_t XLNX_PCIE_DMA_DESC_SIZE = 0x20;

constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_NXT_CTRL_OFF = 0x00;
constexpr uint32_t XLNX_PCIE_DMA_DESC_LEN_OFF            = 0x04;
constexpr uint32_t XLNX_PCIE_DMA_DESC_SRC_ADDR_LOWER_OFF = 0x08;
constexpr uint32_t XLNX_PCIE_DMA_DESC_SRC_ADDR_UPPER_OFF = 0x0C;
constexpr uint32_t XLNX_PCIE_DMA_DESC_DST_ADDR_LOWER_OFF = 0x10;
constexpr uint32_t XLNX_PCIE_DMA_DESC_DST_ADDR_UPPER_OFF = 0x14;
constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_ADDR_LOWER_OFF = 0x18;
constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_ADDR_UPPER_OFF = 0x1C;

constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_MASK = 0xFFFF0000;
constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_ADJ_MASK = 0x00003F00;
constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_MASK = 0x000000FF;

constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_VAL = 0xAD4B0000;

constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_STOP = 0x01;
constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_COMP = 0x02;
constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_EOP  = 0x10;

/* Register addresses */
constexpr uint32_t XLNX_PCIE_DMA_REG_TAR_ADDR_MASK   = 0x0000F000;
constexpr uint32_t XLNX_PCIE_DMA_REG_TAR_ADDR_SHIFT  = 12;
constexpr uint32_t XLNX_PCIE_DMA_REG_CHAN_ADDR_MASK  = 0x00000F00;
constexpr uint32_t XLNX_PCIE_DMA_REG_CHAN_ADDR_SHIFT = 8;
constexpr uint32_t XLNX_PCIE_DMA_REG_BYTE_ADDR_MASK  = 0x000000FF;
constexpr uint32_t XLNX_PCIE_DMA_REG_BYTE_ADDR_SHIFT = 0;

constexpr uint32_t XLNX_PCIE_DMA_TARGET_H2C_CHANS = 0;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_C2H_CHANS = 1;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_IRQ_BLOCK = 2;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_CONFIG    = 3;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_H2C_SGDMA = 4;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_C2H_SGDMA = 5;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_SGDMA     = 6;
constexpr uint32_t XLNX_PCIE_DMA_TARGET_MSIX      = 8;

/* H2C and C2H registers */
constexpr uint32_t XLNX_PCIE_DMA_CHAN_ID           = 0x00;
  constexpr uint32_t XLNX_PCIE_CHAN_ID_AXIS_MASK     = (1 << 15);
constexpr uint32_t XLNX_PCIE_DMA_CHAN_CTRL_RW      = 0x04;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS          = 0x40;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_ALIGN        = 0x4C;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_INTR         = 0x90;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL    = 0xC0;
  constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL_AUTO = 0x00000001;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CYC_LO  = 0xC4;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CYC_HI  = 0xC8;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_DATA_LO = 0xCC;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_DATA_HI = 0xD0;
  constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK = 0x000003FF;
  constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK = 0x00010000;

/* IRQ block */
constexpr uint32_t XLNX_PCIE_DMA_IRQ_ID          = 0x00;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_EN      = 0x04;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_EN     = 0x10;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_INT     = 0x40;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_INT    = 0x44;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_PEND    = 0x48;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_PEND   = 0x4C;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_VEC_LO  = 0x80;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_VEC_HI  = 0x84;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_VEC_LO = 0xA0;
constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_VEC_HI = 0xA4;

/* Config Block */
constexpr uint32_t XLNX_PCIE_DMA_CFG_ID               = 0x00;
constexpr uint32_t XLNX_PCIE_DMA_CFG_BUSDEV           = 0x04;
constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_MAX_PL_SIZE = 0x08;
constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_MAX_RR_SIZE = 0x0C;
constexpr uint32_t XLNX_PCIE_DMA_CFG_SYS_ID           = 0x10;
constexpr uint32_t XLNX_PCIE_DMA_CFG_MSI_ENA          = 0x14;
constexpr uint32_t XLNX_PCIE_DMA_CFG_AXIS_WIDTH       = 0x18;
constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_RLX_ORDER   = 0x1C;
constexpr uint32_t XLNX_PCIE_DMA_CFG_AXI_MAX_PL_SIZE  = 0x40;
constexpr uint32_t XLNX_PCIE_DMA_CFG_AXI_MAX_RR_SIZE  = 0x44;
constexpr uint32_t XLNX_PCIE_DMA_CFG_WR_FLUSH_TIME    = 0x60;

/* H2C and C2H SGDMA registers */
constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_ID           = 0x00;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_LO = 0x80;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_HI = 0x84;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADJ     = 0x88;
constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_CRED    = 0x8C;

/* Common SGDMA registers */
constexpr uint32_t XLNX_PCIE_DMA_SGDMA_ID             = 0x00;
constexpr uint32_t XLNX_PCIE_DMA_SGDMA_DESC_CTRL      = 0x10;
constexpr uint32_t XLNX_PCIE_DMA_SGDMA_DESC_CRED_MODE = 0x20;

namespace app {
namespace framework {
namespace pcie {
namespace dma {

struct registers {
    void* base;

    registers() : base(nullptr) {};
    registers(const registers& src) {
        base = src.base;
    }

    uint32_t read(uint32_t target, uint32_t channel, uint32_t offset);
    void write(uint32_t target, uint32_t channel, uint32_t offset,
        uint32_t value);

protected:
    uint32_t* address(uint32_t target, uint32_t channel, uint32_t offset);
};

struct descriptor {
    void* desc;
    void* buf;
    uint32_t length;
    std::shared_ptr<descriptor> next;

    descriptor(void* desc_) : desc(desc_) {};
};

struct descriptor_chain {
    std::shared_ptr<descriptor> start;
    std::shared_ptr<descriptor> end;

    descriptor_chain(std::vector<descriptor> descs, size_t length);
};

struct channel {
    registers regs;
    size_t id;
    bool streamed;
    uint32_t dir;
    size_t desc_count;
    size_t desc_size;
    cs::pool::aligned::pool<descriptor> descs;

    channel(registers& regs, uint32_t dir, size_t id, size_t desc_count,
        size_t desc_size);

    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);

    void report();
};

struct controller {
    registers regs;

    std::vector<std::shared_ptr<channel>> c2h_chans;
    std::vector<std::shared_ptr<channel>> h2c_chans;
    size_t c2h_count;
    size_t h2c_count;

    controller(std::string& path);

    void report();
};

void init();

} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app

  #endif  // FRAMEWORK_PCIE_DMA_H
