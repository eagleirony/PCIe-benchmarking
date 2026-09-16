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

#ifndef FRAMEWORK_API_IO_H
#define FRAMEWORK_API_IO_H

namespace app {
namespace framework {
namespace api {
namespace io {

constexpr int pcie_device_count = 4;

constexpr uint32_t dma_devid = 0x902410ee;
constexpr uint16_t dma_vendor = 0x10ee;
constexpr uint16_t dma_subvendor = 0x10ee;
constexpr uint16_t dma_subdevice = 0x0007;

constexpr uint64_t PL_REG_BASE = 0x80000000;

constexpr uint32_t PL_REG_PATTERN_0_OFF   = 0x00;
  constexpr uint32_t PL_REG_PATTERN_0_VAL   = 0x55AA55AA;
constexpr uint32_t PL_REG_PATTERN_1_OFF   = 0x04;
  constexpr uint32_t PL_REG_PATTERN_1_VAL   = 0xAA55AA55;
constexpr uint32_t PL_REG_PATTERN_2_OFF   = 0x08;
  constexpr uint32_t PL_REG_PATTERN_2_VAL   = 0x00000000;
constexpr uint32_t PL_REG_PATTERN_3_OFF   = 0x0c;
  constexpr uint32_t PL_REG_PATTERN_3_VAL   = 0xFFFFFFFF;
constexpr uint32_t PL_REG_PATTERN_4_OFF   = 0x10;
  constexpr uint32_t PL_REG_PATTERN_4_VAL   = 0x01234567;
constexpr uint32_t PL_REG_PATTERN_5_OFF   = 0x14;
  constexpr uint32_t PL_REG_PATTERN_5_VAL   = 0x89ABCDEF;

constexpr uint32_t PL_REG_UPTIME_HI_OFF     = 0x20;
constexpr uint32_t PL_REG_UPTIME_LO_OFF     = 0x24;
constexpr uint32_t PL_REG_USER_TIME_LO_OFF  = 0x28;

constexpr uint32_t PL_REG_BUILD_ID_OFF  = 0x2C;
constexpr uint32_t PL_REG_BUILD_VER_OFF = 0x30;

constexpr uint32_t PL_REG_SCRATCH_0_OFF = 0x80;
constexpr uint32_t PL_REG_SCRATCH_1_OFF = 0x84;
constexpr uint32_t PL_REG_SCRATCH_2_OFF = 0x88;
constexpr uint32_t PL_REG_SCRATCH_3_OFF = 0x8C;

constexpr uint32_t PL_REG_SIGNALS_OFF = 0x90;
  constexpr uint32_t PL_REG_SIGNALS_USER_TIMER_RSTN = (1U << 0);
  constexpr uint32_t PL_REG_SIGNALS_EXPANSION_OUT   = (1U << 1);
  constexpr uint32_t PL_REG_SIGNALS_IRQ_OUT         = (1U << 2);

constexpr uint32_t EP_REG_PATTERN_0_OFF   = 0x00;
  constexpr uint32_t EP_REG_PATTERN_0_VAL   = 0x55AA55AA;
constexpr uint32_t EP_REG_PATTERN_1_OFF   = 0x04;
  constexpr uint32_t EP_REG_PATTERN_1_VAL   = 0xAA55AA55;
constexpr uint32_t EP_REG_PATTERN_2_OFF   = 0x08;
  constexpr uint32_t EP_REG_PATTERN_2_VAL   = 0x00000000;
constexpr uint32_t EP_REG_PATTERN_3_OFF   = 0x0c;
  constexpr uint32_t EP_REG_PATTERN_3_VAL   = 0xFFFFFFFF;
constexpr uint32_t EP_REG_PATTERN_4_OFF   = 0x10;
  constexpr uint32_t EP_REG_PATTERN_4_VAL   = 0x01234567;
constexpr uint32_t EP_REG_PATTERN_5_OFF   = 0x14;
  constexpr uint32_t EP_REG_PATTERN_5_VAL   = 0x89ABCDEF;

constexpr uint32_t EP_REG_PCIE_STS_OFF      = 0x18;
constexpr uint32_t EP_REG_UPTIME_HI_OFF     = 0x20;
constexpr uint32_t EP_REG_UPTIME_LO_OFF     = 0x24;
constexpr uint32_t EP_REG_USER_TIME_LO_OFF  = 0x28;

constexpr uint32_t EP_REG_BUILD_ID_OFF  = 0x2C;
constexpr uint32_t EP_REG_BUILD_VER_OFF = 0x30;

constexpr uint32_t EP_REG_C2H_0_FIFO_STS_OFF  = 0x1C;
constexpr uint32_t EP_REG_C2H_1_FIFO_STS_OFF  = 0x34;
constexpr uint32_t EP_REG_H2C_0_FIFO_STS_OFF  = 0x38;

constexpr uint32_t EP_REG_VALIDATE_ERROR_OFF  = 0x3C;
constexpr uint32_t EP_REG_VALIDATE_CORR_OFF   = 0x40;

constexpr uint32_t EP_REG_SCRATCH_0_OFF = 0x80;
constexpr uint32_t EP_REG_SCRATCH_1_OFF = 0x84;
constexpr uint32_t EP_REG_SCRATCH_2_OFF = 0x88;
constexpr uint32_t EP_REG_SCRATCH_3_OFF = 0x8C;

constexpr uint32_t EP_REG_C2H_0_PACK_LEN_OFF = 0x90;
constexpr uint32_t EP_REG_C2H_1_PACK_LEN_OFF = 0x94;

constexpr uint32_t EP_REG_SIGNALS_OFF = 0x98;
  constexpr uint32_t EP_REG_SIGNALS_EXPANSION_OUT   = (1U << 0);
  constexpr uint32_t EP_REG_SIGNALS_STOP_USER_CLK   = (1U << 1);

struct registers {
    void* base;

    registers() : base(nullptr) {};
    registers(const registers& src) {
        base = src.base;
    }

    uint32_t read(uint32_t offset);
    void write(uint32_t offset, uint32_t value);

protected:
    uint32_t* address(uint32_t offset);
};

void test_latency();

void init();

} // namespace io
} // namespace api
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_API_IO_H
