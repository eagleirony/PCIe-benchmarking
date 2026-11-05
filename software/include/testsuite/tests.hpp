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

#ifndef TESTSUITE_TESTS_H
#define TESTSUITE_TESTS_H

#include <testsuite/msi.hpp>
#include <testsuite/io.hpp>
#include <testsuite/dma.hpp>

namespace app {
namespace testsuite {

using test = framework::api::harness::test;

const auto tests = std::array{
    /* Baseline pipeline tests */
    test{dma::run_pipeline<0x10000, 435, 2>, "dma_01",
        "0x10000 buf, 435 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 430, 2>, "dma_02",
        "0x10000 buf, 430 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 429, 2>, "dma_03",
        "0x10000 buf, 429 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 428, 2>, "dma_04",
        "0x10000 buf, 428 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 427, 2>, "dma_05",
        "0x10000 buf, 427 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 425, 2>, "dma_06",
        "0x10000 buf, 425 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 420, 2>, "dma_07",
        "0x10000 buf, 420 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 415, 2>, "dma_08",
        "0x10000 buf, 415 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 400, 2>, "dma_09",
        "0x10000 buf, 400 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 300, 2>, "dma_10",
        "0x10000 buf, 300 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 200, 2>, "dma_11",
        "0x10000 buf, 200 c2h pipeline"},

    /* Buffer size tests */
    test{dma::run_pipeline<0x8000, 500, 2>, "dma_12",
        "0x8000 buf, 500 c2h pipeline"},
    test{dma::run_pipeline<0x10000, 500, 2>, "dma_13",
        "0x10000 buf, 500 c2h pipeline"},
    test{dma::run_pipeline<0x20000, 500, 2>, "dma_14",
        "0x20000 buf, 500 c2h pipeline"},
    test{dma::run_pipeline<0x30000, 500, 2>, "dma_15",
        "0x30000 buf, 500 c2h pipeline"},
    test{dma::run_pipeline<0x40000, 500, 2>, "dma_16",
        "0x40000 buf, 500 c2h pipeline"},

    /* Baseline block transfer tests */
    test{dma::run_c2h_block<0x10000, 500, 10>, "dma_17",
        "0x10000 buf, 500 c2h block"},
    test{dma::run_h2c_block<0x10000, 500, 10>, "dma_18",
        "0x10000 buf, 500 h2c block"},
    test{dma::run_bidir_block<0x10000, 500, 10>, "dma_19",
        "0x10000 buf, 500 c2h block, 500 h2c block"},
    test{dma::run_bidir_block<0x10000, 400, 10>, "dma_20",
        "0x10000 buf, 400 c2h block, 400 h2c block"},
    test{dma::run_bidir_block<0x10000, 300, 10>, "dma_21",
        "0x10000 buf, 300 c2h block, 300 h2c block"},
    test{dma::run_bidir_block<0x10000, 200, 10>, "dma_22",
        "0x10000 buf, 200 c2h block, 200 h2c block"},

    /* EP interrupts with pipeline and block transfers */
    test{msi::ep_intrs<1000, 1>, "msi_01",
        "1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 500, 1>, "msi_02",
        "0x10000 buf, 500 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 430, 1>, "msi_03",
        "0x10000 buf, 430 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 429, 1>, "msi_04",
        "0x10000 buf, 429 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 428, 1>, "msi_05",
        "0x10000 buf, 428 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 427, 1>, "msi_06",
        "0x10000 buf, 427 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 420, 1>, "msi_07",
        "0x10000 buf, 420 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_pipeline<0x10000, 1000, 400, 1>, "msi_08",
        "0x10000 buf, 400 c2h pipeline, 1000 ep intrs"},
    test{msi::ep_intr_with_c2h_block<0x10000, 1000, 500, 1>, "msi_09",
        "0x10000 buf, 500 c2h block, 1000 ep intrs"},
    test{msi::ep_intr_with_c2h_block<0x10000, 1000, 430, 1>, "msi_10",
        "0x10000 buf, 430 c2h block, 1000 ep intrs"},
    test{msi::ep_intr_with_c2h_block<0x10000, 1000, 420, 1>, "msi_11",
        "0x10000 buf, 420 c2h block, 1000 ep intrs"},
    test{msi::ep_intr_with_c2h_block<0x10000, 1000, 400, 1>, "msi_12",
        "0x10000 buf, 400 c2h block, 1000 ep intrs"},
    test{msi::ep_intr_with_h2c_block<0x10000, 1000, 500, 1>, "msi_13",
        "0x10000 buf, 500 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_h2c_block<0x10000, 1000, 430, 1>, "msi_14",
        "0x10000 buf, 430 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_h2c_block<0x10000, 1000, 420, 1>, "msi_15",
        "0x10000 buf, 420 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_h2c_block<0x10000, 1000, 400, 1>, "msi_16",
        "0x10000 buf, 400 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_bidir_blocks<0x10000, 1000, 500, 1>, "msi_17",
        "0x10000 buf, 500 c2h block, 500 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_bidir_blocks<0x10000, 1000, 430, 1>, "msi_18",
        "0x10000 buf, 430 c2h block, 430 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_bidir_blocks<0x10000, 1000, 420, 1>, "msi_19",
        "0x10000 buf, 420 c2h block, 420 h2c block, 1000 ep intrs"},
    test{msi::ep_intr_with_bidir_blocks<0x10000, 1000, 400, 1>, "msi_20",
        "0x10000 buf, 400 c2h block, 400 h2c block, 1000 ep intrs"},

    /* PL interrupts baseline tests */
    test{msi::pl_intrs<1000, 1>, "msi_21",
        "1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 500, 1>, "msi_22",
        "0x10000 buf, 500 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 430, 1>, "msi_23",
        "0x10000 buf, 430 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 429, 1>, "msi_24",
        "0x10000 buf, 429 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 428, 1>, "msi_25",
        "0x10000 buf, 428 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 427, 1>, "msi_26",
        "0x10000 buf, 427 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 420, 1>, "msi_27",
        "0x10000 buf, 420 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_pipeline<0x10000, 1000, 400, 1>, "msi_28",
        "0x10000 buf, 400 c2h pipeline, 1000 pl intrs"},
    test{msi::pl_intr_with_c2h_block<0x10000, 1000, 500, 1>, "msi_29",
        "0x10000 buf, 500 c2h block, 1000 pl intrs"},
    test{msi::pl_intr_with_c2h_block<0x10000, 1000, 430, 1>, "msi_30",
        "0x10000 buf, 430 c2h block, 1000 pl intrs"},
    test{msi::pl_intr_with_c2h_block<0x10000, 1000, 420, 1>, "msi_31",
        "0x10000 buf, 420 c2h block, 1000 pl intrs"},
    test{msi::pl_intr_with_c2h_block<0x10000, 1000, 400, 1>, "msi_32",
        "0x10000 buf, 400 c2h block, 1000 pl intrs"},
    test{msi::pl_intr_with_h2c_block<0x10000, 1000, 500, 1>, "msi_29",
        "0x10000 buf, 500 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_h2c_block<0x10000, 1000, 430, 1>, "msi_30",
        "0x10000 buf, 430 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_h2c_block<0x10000, 1000, 420, 1>, "msi_31",
        "0x10000 buf, 420 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_h2c_block<0x10000, 1000, 400, 1>, "msi_32",
        "0x10000 buf, 400 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_bidir_blocks<0x10000, 1000, 500, 1>, "msi_33",
        "0x10000 buf, 500 c2h block, 500 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_bidir_blocks<0x10000, 1000, 430, 1>, "msi_34",
        "0x10000 buf, 430 c2h block, 430 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_bidir_blocks<0x10000, 1000, 420, 1>, "msi_35",
        "0x10000 buf, 420 c2h block, 420 h2c block, 1000 pl intrs"},
    test{msi::pl_intr_with_bidir_blocks<0x10000, 1000, 400, 1>, "msi_36",
        "0x10000 buf, 400 c2h block, 400 h2c block, 1000 pl intrs"},

    /* IO read with pipeline tests */
    test{io::read_with_pipeline<0x10000, 500, 10000, 0>, "io_01",
        "0x10000 buf, 500 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 500, 10000, 1>, "io_02",
        "0x10000 buf, 500 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 430, 10000, 0>, "io_03",
        "0x10000 buf, 430 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 430, 10000, 1>, "io_04",
        "0x10000 buf, 430 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 429, 10000, 0>, "io_05",
        "0x10000 buf, 429 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 429, 10000, 1>, "io_06",
        "0x10000 buf, 429 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 428, 10000, 0>, "io_07",
        "0x10000 buf, 428 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 428, 10000, 1>, "io_08",
        "0x10000 buf, 428 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 427, 10000, 0>, "io_09",
        "0x10000 buf, 427 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 427, 10000, 1>, "io_10",
        "0x10000 buf, 427 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 425, 10000, 0>, "io_11",
        "0x10000 buf, 425 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 425, 10000, 1>, "io_12",
        "0x10000 buf, 425 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 400, 10000, 0>, "io_13",
        "0x10000 buf, 400 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 400, 10000, 1>, "io_14",
        "0x10000 buf, 400 c2h pipeline, 10000 ep read latency 1ms interval"},
    test{io::read_with_pipeline<0x10000, 200, 10000, 0>, "io_15",
        "0x10000 buf, 200 c2h pipeline, 10000 ep read latency 0ms interval"},
    test{io::read_with_pipeline<0x10000, 200, 10000, 1>, "io_16",
        "0x10000 buf, 200 c2h pipeline, 10000 ep read latency 1ms interval"},

    /* IO write with pipeline tests */
    test{io::write_with_pipeline<0x10000, 500, 10000>, "io_17",
        "0x10000 buf, 500 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 429, 10000>, "io_19",
        "0x10000 buf, 429 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 428, 10000>, "io_20",
        "0x10000 buf, 428 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 427, 10000>, "io_21",
        "0x10000 buf, 427 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 426, 10000>, "io_22",
        "0x10000 buf, 426 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 425, 10000>, "io_23",
        "0x10000 buf, 425 c2h pipeline, 10000 ep writes"},
    test{io::write_with_pipeline<0x10000, 200, 10000>, "io_24",
        "0x10000 buf, 200 c2h pipeline, 10000 ep writes"},

    /* IO one way read with pipeline tests */
    test{io::one_way_read_with_pipeline<0x10000, 500, 10000>, "io_25",
        "0x10000 buf, 500 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 430, 10000>, "io_26",
        "0x10000 buf, 430 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 429, 10000>, "io_27",
        "0x10000 buf, 429 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 428, 10000>, "io_28",
        "0x10000 buf, 428 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 427, 10000>, "io_29",
        "0x10000 buf, 427 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 426, 10000>, "io_30",
        "0x10000 buf, 426 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 425, 10000>, "io_31",
        "0x10000 buf, 425 c2h pipeline, 10000 ep one way read latency"},
    test{io::one_way_read_with_pipeline<0x10000, 200, 10000>, "io_32",
        "0x10000 buf, 200 c2h pipeline, 10000 ep one way read latency"},

    /* IO one way write with pipeline tests */
    test{io::one_way_write_with_pipeline<0x10000, 500, 10000>, "io_33",
        "0x10000 buf, 500 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 430, 10000>, "io_34",
        "0x10000 buf, 430 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 429, 10000>, "io_35",
        "0x10000 buf, 429 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 428, 10000>, "io_36",
        "0x10000 buf, 428 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 427, 10000>, "io_37",
        "0x10000 buf, 427 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 426, 10000>, "io_38",
        "0x10000 buf, 426 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 425, 10000>, "io_39",
        "0x10000 buf, 425 c2h pipeline, 10000 ep one way write latency"},
    test{io::one_way_write_with_pipeline<0x10000, 200, 10000>, "io_40",
        "0x10000 buf, 200 c2h pipeline, 10000 ep one way write latency"},

};

} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_TESTS_H */
