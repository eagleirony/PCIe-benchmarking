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


void init();

} // namespace io
} // namespace api
} // namespace framework
} // namespace app

#endif  // FRAMEWORK_API_IO_H
