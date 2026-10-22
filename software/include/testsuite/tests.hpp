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

namespace app {
namespace testsuite {

using test = framework::api::harness::test;

const std::array<test, 12> tests = {
    test{msi::test_07, "msi_07", "EP intrs, block 200mbs c2h"},
    test{msi::test_01, "msi_01", "1000 EP intr, no dma"},
    test{msi::test_02, "msi_02", "1000 EP intr, 500mbs c2h"},
    test{msi::test_03, "msi_03", "1000 EP intr, 420mbs c2h"},
    test{msi::test_04, "msi_04", "1000 EP intr, 415mbs c2h"},
    test{msi::test_05, "msi_05", "1000 EP intr, 400mbs c2h"},
    test{msi::test_06, "msi_06", "1000 EP intr, 200mbs c2h"},
    test{io::test_01, "io_01", "10000 io read/write, no dma"},
    test{io::test_02, "io_02", "10000 io read/write, 500mbs c2h"},
    test{io::test_03, "io_03", "10000 io read/write, 420mbs c2h"},
    test{io::test_04, "io_04", "10000 io read/write, 415mbs c2h"},
    test{io::test_05, "io_05", "10000 io read/write, 200mbs c2h"},
};

} // namespace testsuite
} // namespace app
#endif /* TESTSUITE_TESTS_H */
