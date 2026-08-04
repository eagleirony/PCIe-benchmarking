/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Copyright (C) 2022 Contemporary Software Pty Ltd
 * All rights reserved.
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

#ifndef CS_ALIGNED_HPP
#define CS_ALIGNED_HPP

#include <cstring>
#include <memory>

#include <externals/cs/pool.hpp>

namespace cs {
namespace pool {
namespace aligned {
/**
 * @brief Aligned buffer
 */
template<typename T> struct buffer {
    using value_type = T;
    using value_ptr = T*;

    std::unique_ptr<value_type> data;

    buffer();
    buffer(const size_t size, const size_t alignment);
};

/**
 * @brief Aligned pool of buffers
 *
 * The data element of a buffer points to aligned memory.
 */
template<typename T> struct pool : public cs::pool::pool<buffer<T>> {
    pool(const size_t number, const size_t alignment, const size_t size);
    pool();

    /*
     * Create a pool of buffers aligned to the alignment argument and of
     * the number of items of type T.
     *
     * @param number Numer of buffers
     *
     * @param alignment Align the start of the buffer to the alignment, this is in
     *     units of the type.
     *
     * @param ize The number of items in a buffer, this is in units of the type.
     */
    void create(const size_t number, const size_t alignment, const size_t size);

    size_t alignment;
    size_t size;

private:
    pool(const size_t number);
    void create(const size_t number) = delete;
};

template<typename T> using handle_type = cs::pool::handle_type<buffer<T>>;
template<typename T> using queue = cs::pool::queue<buffer<T>>;

template<typename T> buffer<T>::buffer() : data(nullptr) {}

template<typename T> pool<T>::pool(
    const size_t number_, const size_t alignment_, const size_t size_)
    : cs::pool::pool<buffer<T>>::pool(), alignment(alignment_), size(size_) {
    create(number_, alignment_, size_);
}

template<typename T> pool<T>::pool() : alignment(0), size(0) {}

template<typename T> void pool<T>::create(
    const size_t number_, const size_t alignment_, const size_t size_) {
    lock_guard guard(this->lock);
    this->cs::pool::pool<buffer<T>>::unprotected_create(number_);
    for (auto& buf : this->objects) {
        void* mem = nullptr;
        auto r = ::posix_memalign(
            &mem, alignment_ * sizeof(T), size_ * sizeof(T));
        if (r != 0) {
            this->cs::pool::pool<buffer<T>>::unprotected_destroy();
            if (errno == ENOMEM) {
                throw std::bad_alloc();
            }
            std::string what =
                std::string("aligned: alloc: ") +
                std::to_string(alignment_) + '/' + std::to_string(size_) +
                ": " + std::strerror(r);
            throw std::runtime_error(what);
        }
        buf->data = std::unique_ptr<T>(static_cast<T*>(mem));
    }
    alignment = alignment_;
    size = size_;
}

}  // namespace aligned
}  // namespace pool
}  // namespace cs

#endif /* CS_ALIGN_HPP */
