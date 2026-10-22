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

#ifndef APP_CONFIG_H
#define APP_CONFIG_H

namespace app {
namespace config {

constexpr int CPUUSE_LOG_FREQ_MS = 1;

constexpr std::string_view PL_IMAGE_NAME = "pl_5.bit";
constexpr std::string_view EMMC_MNT_PATH = "/emmc";
constexpr std::string_view NFS_MNT_PATH = "/net";
constexpr std::string_view LOGGING_PATH = "/pciebench/logging";

} // namespace config
} // namespace app
#endif /* APP_CONFIG_H */
