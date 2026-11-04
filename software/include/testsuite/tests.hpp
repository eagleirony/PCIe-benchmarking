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

const std::array<test, 26> tests = {
    test{dma::test_01, "dma_01", "500mbs c2h"},
    test{msi::test_01, "msi_01", "1000 EP intr, no dma"},
    test{msi::test_02, "msi_02", "1000 EP intr, 500mbs c2h"},
    test{msi::test_03, "msi_03", "1000 EP intr, 420mbs c2h"},
    test{msi::test_04, "msi_04", "1000 EP intr, 415mbs c2h"},
    test{msi::test_05, "msi_05", "1000 EP intr, 400mbs c2h"},
    test{msi::test_06, "msi_06", "1000 EP intr, 200mbs c2h"},
    test{msi::test_07, "msi_07", "EP intrs, block 500mbs c2h"},
    test{msi::test_08, "msi_08", "EP intrs, block 420mbs c2h"},
    test{msi::test_09, "msi_09", "EP intrs, block 415mbs c2h"},
    test{msi::test_10, "msi_10", "EP intrs, block 400mbs c2h"},
    test{msi::test_11, "msi_11", "EP intrs, block 200mbs c2h"},
    test{msi::test_12, "msi_12", "1000 PL intrs"},
    test{msi::test_13, "msi_13", "1000 PL intrs, 400mbs c2h"},
    test{msi::test_14, "msi_14", "EP intrs, block 400mbs h2c"},
    test{io::test_01, "io_01", "10000 io read/write, no dma"},
    test{io::test_02, "io_02", "10000 io read/write, 500mbs c2h"},
    test{io::test_03, "io_03", "10000 io read/write, 420mbs c2h"},
    test{io::test_04, "io_04", "10000 io read/write, 415mbs c2h"},
    test{io::test_05, "io_05", "10000 io read/write, 200mbs c2h"},
    test{io::test_06, "io_06", "io read, block 500mbs h2c"},
    test{io::test_07, "io_07", "io write, block 500mbs h2c"},
    test{io::test_08, "io_08", "io one way read, block 500mbs h2c"},
    test{io::test_09, "io_09", "io one way write, block 500mbs h2c"},
    test{io::test_10, "io_10", "block 500mbs h2c"},
    test{io::test_11, "io_11", "block 200mbs h2c"},
};

} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_TESTS_H */
