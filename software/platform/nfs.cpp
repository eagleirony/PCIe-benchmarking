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

#include <filesystem>
#include <cstring>

#include <rtems/fsmount.h>

#include <platform/nfs.hpp>

namespace app {
namespace platform {
namespace nfs {

static constexpr char nfs_path[] = "10.10.5.4:/opt/src";

void init() {

}

void mount(std::string& mnt_path) {
    std::filesystem::create_directories(mnt_path);

    auto r = ::mount(nfs_path, mnt_path.c_str(), "nfs",
                RTEMS_FILESYSTEM_READ_WRITE, nullptr);
    if (r < 0) {
        std::ostringstream oss;
        oss << "error: fs: nfs: failed to mount: " << strerror(errno);
        throw std::runtime_error(oss.str());
    }
}

} // nfs
} // platform
} // app
