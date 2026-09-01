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
#include <mutex>

#include <framework/dma-mem.hpp>
#include <framework/io.hpp>

#include <externals/cs/pool.hpp>
#include <externals/rtems/thread.hpp>

constexpr uint32_t XLNX_PCIE_DMA_MAX_CHANS = 4;
constexpr size_t XLNX_PCIE_DMA_CHAN_DESC_COUNT = 16;

/* AXI Lite registers */

static constexpr uint32_t C2H_CHAN_0_PACKET_LEN_OFF = 0x90;

/* Descriptors */
static constexpr uint32_t XLNX_PCIE_DMA_DESC_SIZE = 0x20;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_ALIGNMENT = 0x20;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_BOUNDARY = 0x1000;

static constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_NXT_CTRL_OFF = 0x00;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_VAL  = 0xAD4B0000;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_MAGIC_MASK = 0xFFFF0000;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_MASK   = 0x3F00;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_SHIFT  = 8;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_MASK = 0x000000FF;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_STOP  = (1 << 0);
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_CMPL  = (1 << 1);
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_CTRL_EOP   = (1 << 4);
static constexpr uint32_t XLNX_PCIE_DMA_DESC_LEN_OFF            = 0x04;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_LEN_MASK           = 0x0FFFFFFF;
  static constexpr uint32_t XLNX_PCIE_DMA_DESC_LEN_GRAN           = 0x0000003F;;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_SRC_ADDR_LOWER_OFF = 0x08;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_SRC_ADDR_UPPER_OFF = 0x0C;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_DST_ADDR_LOWER_OFF = 0x10;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_DST_ADDR_UPPER_OFF = 0x14;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_ADDR_LOWER_OFF = 0x18;
static constexpr uint32_t XLNX_PCIE_DMA_DESC_NXT_ADDR_UPPER_OFF = 0x1C;

/* Write back */

static constexpr uint32_t XLNX_PCIE_DMA_WB_SIZE = 0x8;
static constexpr uint32_t XLNX_PCIE_DMA_WB_ALIGNMENT = 0x8;
static constexpr uint32_t XLNX_PCIE_DMA_WB_BOUNDARY = 0x0;

static constexpr uint32_t XLNX_PCIE_DMA_WB_MAGIC_STATUS_OFF = 0x0;
  static constexpr uint32_t XLNX_PCIE_DMA_WB_MAGIC_MASK       = 0xFFFF0000;
  static constexpr uint32_t XLNX_PCIE_DMA_WB_MAGIC_VAL        = 0x52B40000;
  static constexpr uint32_t XLNX_PCIE_DMA_WB_STATUS_MASK      = 0x00000001;
static constexpr uint32_t XLNX_PCIE_DMA_WB_LENGTH_OFF       = 0x4;

/* Register addresses */
static constexpr uint32_t XLNX_PCIE_DMA_REG_TAR_ADDR_MASK   = 0x0000F000;
static constexpr uint32_t XLNX_PCIE_DMA_REG_TAR_ADDR_SHIFT  = 12;
static constexpr uint32_t XLNX_PCIE_DMA_REG_CHAN_ADDR_MASK  = 0x00000F00;
static constexpr uint32_t XLNX_PCIE_DMA_REG_CHAN_ADDR_SHIFT = 8;
static constexpr uint32_t XLNX_PCIE_DMA_REG_BYTE_ADDR_MASK  = 0x000000FF;
static constexpr uint32_t XLNX_PCIE_DMA_REG_BYTE_ADDR_SHIFT = 0;

static constexpr uint32_t XLNX_PCIE_DMA_TARGET_H2C_CHANS = 0;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_C2H_CHANS = 1;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_IRQ_BLOCK = 2;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_CONFIG    = 3;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_H2C_SGDMA = 4;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_C2H_SGDMA = 5;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_SGDMA     = 6;
static constexpr uint32_t XLNX_PCIE_DMA_TARGET_MSIX      = 8;

/* H2C and C2H registers */
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_ID           = 0x00;
  static constexpr uint32_t XLNX_PCIE_CHAN_ID_AXIS_MASK     = (1 << 15);
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_CTRL         = 0x04;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_CTRL_RUN     = (1 << 0);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_CTRL_LOG_ENA = 0x00F83E7E;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS          = 0x40;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_BUSY     = (1 << 0);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_STOP     = (1 << 1);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_COMP     = (1 << 2);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_ALIGN    = (1 << 3);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_MAGIC    = (1 << 4);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_INV_LEN  = (1 << 5);
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_STS_IDLE     = (1 << 6);
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_DESC_COMP    = 0x48;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_ALIGN        = 0x4C;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_INTR         = 0x90;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_INTR_ENA     = 0x00F83E56;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL    = 0xC0;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL_RUN  = 0x00000004;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL_CLR  = 0x00000002;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CTRL_AUTO = 0x00000001;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CYC_LO  = 0xC4;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_CYC_HI  = 0xC8;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_DATA_LO = 0xCC;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_DATA_HI = 0xD0;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_HI_COUNT_MASK = 0x000003FF;
  static constexpr uint32_t XLNX_PCIE_DMA_CHAN_PERF_HI_MAXED_MASK = 0x00010000;

/* IRQ block */
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_ID          = 0x00;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_EN      = 0x04;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_EN     = 0x10;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_INT     = 0x40;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_INT    = 0x44;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_PEND    = 0x48;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_PEND   = 0x4C;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_VEC_LO  = 0x80;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_USR_VEC_HI  = 0x84;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_VEC_LO = 0xA0;
static constexpr uint32_t XLNX_PCIE_DMA_IRQ_CHAN_VEC_HI = 0xA4;

/* Config Block */
static constexpr uint32_t XLNX_PCIE_DMA_CFG_ID               = 0x00;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_BUSDEV           = 0x04;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_MAX_PL_SIZE = 0x08;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_MAX_RR_SIZE = 0x0C;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_SYS_ID           = 0x10;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_MSI_ENA          = 0x14;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_AXIS_WIDTH       = 0x18;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_PCIE_RLX_ORDER   = 0x1C;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_AXI_MAX_PL_SIZE  = 0x40;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_AXI_MAX_RR_SIZE  = 0x44;
static constexpr uint32_t XLNX_PCIE_DMA_CFG_WR_FLUSH_TIME    = 0x60;

/* H2C and C2H SGDMA registers */
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_ID           = 0x00;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_LO = 0x80;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADDR_HI = 0x84;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_ADJ     = 0x88;
static constexpr uint32_t XLNX_PCIE_DMA_CHAN_SG_DESC_CRED    = 0x8C;

/* Common SGDMA registers */
static constexpr uint32_t XLNX_PCIE_DMA_SGDMA_ID             = 0x00;
static constexpr uint32_t XLNX_PCIE_DMA_SGDMA_DESC_CTRL      = 0x10;
static constexpr uint32_t XLNX_PCIE_DMA_SGDMA_DESC_CRED_MODE = 0x20;

namespace app {
namespace framework {
namespace pcie {
namespace dma {

struct controller;
using controller_ptr = std::shared_ptr<controller>;
using controllers = std::vector<controller_ptr>;
using controllers_ptr = std::shared_ptr<controllers>;

controllers_ptr make_controllers();
static controllers_ptr eps_ = make_controllers();

struct registers {
    void* base;

    registers() : base(nullptr) {};
    registers(const registers& src) {
        base = src.base;
    }

    uint32_t read(uint32_t target, uint32_t channel, uint32_t offset);
    uint32_t read(uint32_t target, uint32_t offset);
    void write(uint32_t target, uint32_t channel, uint32_t offset,
        uint32_t value);
    void write(uint32_t target, uint32_t offset,
        uint32_t value);

protected:
    uint32_t* address(uint32_t target, uint32_t channel, uint32_t offset);
};

struct channel {
    using callback = std::function<void(mem::dma_buffer_ptr buf)>;
    using lock_type = std::recursive_mutex;
    using lock_guard = std::lock_guard<lock_type>;

    lock_type lock;
    registers regs;
    size_t id;
    uint32_t dir;
    bool running;
    bool pipelined;
    size_t head;
    size_t tail;
    callback cb;
    std::array<mem::descriptor, XLNX_PCIE_DMA_CHAN_DESC_COUNT> descs;
    std::array<mem::writeback, XLNX_PCIE_DMA_CHAN_DESC_COUNT> wbs;
    cs::pool::pool<mem::dma_buffer> bufs;

    channel(registers& regs, uint32_t dir, size_t id, size_t desc_count);
    channel(const channel&) = delete;
    channel& operator=(const channel&) = delete;
    channel(channel&&) = delete;
    channel& operator=(const channel&&) = delete;

    void run();
    void run(size_t length);
    void stop();

    void set_callback(callback& cb);

    bool is_running();
    void report();

    void handle_intr();

protected:
    void set_pipeline();
    void set_block(size_t length);

    uint32_t read_chan(uint32_t offset);
    void write_chan(uint32_t offset, uint32_t value);
    uint32_t read_sgdma(uint32_t offset);
    void write_sgdma(uint32_t offset, uint32_t value);
};

using channel_ptr = std::shared_ptr<channel>;

struct controller {
    using lock_type = std::recursive_mutex;
    using lock_guard = std::lock_guard<lock_type>;

    lock_type lock;
    registers regs;
    api::io::registers axis;
    int fd;
    std::shared_ptr<rtems::thread::thread> msi_thread;

    std::vector<channel_ptr> c2h_chans;
    std::vector<channel_ptr> h2c_chans;
    size_t c2h_count;
    size_t h2c_count;

    controller(std::string& path);
    controller(const controller&) = delete;
    controller& operator=(const controller&) = delete;
    controller(controller&&) = delete;
    controller& operator=(const controller&&) = delete;

    void report();

protected:
    void start_msi_thread();
    void msi_worker();
    void join_msi_thread();
};

void init();

} // namespace dma
} // namespace pcie
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_PCIE_DMA_H
