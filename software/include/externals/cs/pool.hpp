/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Copyright 2021 XIA LLC, All rights reserved.
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

/*
 * Apache-2.0 notice:
 *  Changed and adapted by Chris Johns.
 *       Copyright 2022 Contemporary Software, All rights reserved.
 */

/** @file pools.h
 * @brief Defines functions and data structures for creating threaded object
 *        pools and queues
 */

#ifndef CS_POOL_HPP
#define CS_POOL_HPP

#include <atomic>
#include <forward_list>
#include <iostream>
#include <list>
#include <memory>
#include <mutex>
#include <stdexcept>

#include <externals/cs/sync.hpp>

namespace cs {
/**
 * @brief Handles thread safe pools of objects
 */
namespace pool {
/**
 * @brief Defines the pool/queue lock type
 */
using lock_type = cs::sync::variable::lock_type;
/**
 * @brief A lock_guard for the lock_type.
 */
using lock_guard = std::lock_guard<lock_type>;
/**
 * @brief The object types.
 */
template<typename T> using object_type = T;
template<typename T> using object_ptr_type = T*;
template<typename T> using handle_type = std::shared_ptr<object_type<T>>;

/**
 * @brief The object pool to manage the objects.
 */
template<typename T> struct pool {
    using object = object_type<T>;
    using object_ptr = object_ptr_type<T>;
    using handle = handle_type<T>;

    static constexpr size_t wait_for_ever = sync::variable::wait_for_ever;

    pool(const size_t number);
    pool();
    virtual ~pool();

    void create(const size_t number);
    void destroy();

    void wake();

    /**
     * Request an object and raise an exception if the pool is empty.
     */
    handle request();

    /**
     * Request an object and block if the pool is empty waking when an
     * object is release back to the pool. Set the timeout to
     * wait_for_ever to not timeout or provide a timeout in
     * milli-seconds. And empty handle is returned so check using the
     * bool operator.
     */
    handle request(size_t timeout_msec);

    bool valid() const;
    bool empty() const;
    bool full() const;
    size_t count() const;

    size_t number;

    virtual void output(std::ostream& out);

protected:
    struct releaser {
        pool& pool_;
        releaser(pool& pool__) : pool_(pool__) {}
        void operator()(object* obj) const {
            pool_.release(obj);
        }
    };

    void release(object_ptr obj);

    void unprotected_create(const size_t number);
    void unprotected_destroy();
    void unprotected_wake();
    handle unprotected_request();

    std::atomic_size_t count_;

    std::forward_list<object_ptr> objects;

    lock_type lock;

    sync::variable waiter;
    bool waiting;
    bool wakeup;
};

/**
 * @brief Object queue.
 */
template<typename T> struct queue {
    using object = object_type<T>;
    using object_ptr = object_ptr_type<T>;
    using handle = handle_type<T>;

    using handles = std::list<handle>;

    static constexpr size_t wait_for_ever = sync::variable::wait_for_ever;

    queue();
    queue(const queue& que);

    void wait(size_t timeout_msec = 0);
    void wake();

    bool push(handle obj);
    handle pop();
    handle pop(size_t timeout_msec);

    bool move(queue& from);
    bool copy(queue& from);

    handle front();
    handle back();

    bool empty() const;

    size_t count() const;

    void flush();

    queue& operator=(queue& from); /* moves */
    queue& operator=(handle obj);
    operator handle();
    operator bool();

    void output(std::ostream& out);

protected:
    void unprotected_wake();
    handle unprotected_pop();

    handles objects;
    lock_type lock;
    std::atomic_size_t count_;
    sync::variable waiter;
    bool waiting;
    bool wakeup;
};

template<typename T> pool<T>::pool(const size_t number_)
    : number(0), count_(0), waiter(lock), waiting(false), wakeup(false) {
    create(number_);
}

template<typename T> pool<T>::pool()
    : number(0), count_(0), waiter(lock), waiting(false), wakeup(false) {
}

template<typename T> pool<T>::~pool() {
    try {
        destroy();
    } catch (...) {
        /* @todo any error should be logged */
    }
}

template<typename T> void pool<T>::create(const size_t number_) {
    lock_guard guard(lock);
    unprotected_create(number_);
}

template<typename T> void pool<T>::destroy() {
    lock_guard guard(lock);
    unprotected_destroy();
}

template<typename T> void pool<T>::wake() {
    lock_guard guard(lock);
    if (waiting) {
        wakeup = true;
        unprotected_wake();
    }
}

template<typename T> handle_type<T> pool<T>::request() {
    lock_guard guard(lock);
    if (empty()) {
      return handle_type<T>();
    }
    return unprotected_request();
}

template<typename T> handle_type<T> pool<T>::request(size_t timeout_msec) {
    lock_guard guard(lock);
    if (waiting) {
        return handle_type<T>();
    }
    waiting = true;
    while (empty()) {
        auto notified = waiter.wait(timeout_msec);
        if (wakeup || notified) {
            waiting = false;
            wakeup = false;
            return handle_type<T>();
        }
    }
    waiting = false;
    return unprotected_request();
}

template<typename T> bool pool<T>::valid() const {
    return number != 0;
}

template<typename T> bool pool<T>::empty() const {
    return count_.load() == 0;
}

template<typename T> bool pool<T>::full() const {
    return number != 0 && count_.load() == number;
}

template<typename T> size_t pool<T>::count() const {
    return count_.load();
}

template<typename T> void pool<T>::output(std::ostream& out) {
    out << "count=" << count_.load() << " num=" << number;
}

template<typename T> void pool<T>::unprotected_create(const size_t number_) {
    if (valid()) {
        throw std::runtime_error("pool is already created");
    }
    number = number_;
    for (size_t n = 0; n < number; ++n) {
        object_ptr obj = new object;
        objects.push_front(obj);
    }
    count_ = number;
}

template<typename T> void pool<T>::unprotected_destroy() {
    if (number > 0) {
        if (count_.load() != number) {
            throw std::runtime_error("pool destroy made while busy");
        }
        while (!objects.empty()) {
            object_ptr obj = objects.front();
            delete obj;
            objects.pop_front();
        }
        number = 0;
        count_ = 0;
    }
}

template<typename T> void pool<T>::unprotected_wake() {
    if (waiting) {
        waiter.notify();
    }
}

template<typename T> handle_type<T> pool<T>::unprotected_request() {
    count_--;
    object_ptr obj = objects.front();
    objects.pop_front();
    return handle(obj, releaser(*this));
}

template<typename T> void pool<T>::release(object_ptr obj) {
    lock_guard guard(lock);
    objects.push_front(obj);
    count_++;
    unprotected_wake();
}

template<typename T> queue<T>::queue()
    : count_(0), waiter(lock), waiting(false), wakeup(false) {}

template<typename T> queue<T>::queue(const queue& que)
    : waiter(lock), waiting(false), wakeup(false) {
    objects = que.objects;
    count_ = que.count_.load();
}

template<typename T> void queue<T>::wait(size_t timeout_msec) {
    lock_guard guard(lock);
    if (!waiting) {
        waiting = true;
        while (empty()) {
            auto notified = waiter.wait(timeout_msec);
            if (wakeup || notified) {
                wakeup = false;
                break;
            }
        }
        waiting = false;
    }
}

template<typename T> void queue<T>::wake() {
    lock_guard guard(lock);
    if (waiting) {
        wakeup = true;
        unprotected_wake();
    }
}

template<typename T> bool queue<T>::push(handle obj) {
    lock_guard guard(lock);
    bool is_zero = count_ == 0;
    objects.push_back(obj);
    ++count_;
    unprotected_wake();
    return is_zero;
}

template<typename T> handle_type<T> queue<T>::pop() {
    lock_guard guard(lock);
    return unprotected_pop();
}

template<typename T> handle_type<T> queue<T>::pop(size_t timeout_msec) {
    lock_guard guard(lock);
    if (waiting) {
        throw std::runtime_error("queue pop wait while waiting");
    }
    waiting = true;
    while (count_.load() == 0) {
        if (waiter.wait(timeout_msec)) {
            waiting = false;
            break;
        }
        if (wakeup) {
            wakeup = false;
            return handle();
        }
    }
    waiting = false;
    return unprotected_pop();
}

template<typename T> bool queue<T>::move(queue& from) {
    lock_guard guard(lock);
    lock_guard other_guard(from.lock);
    bool is_zero = count_ == 0;
    count_ += from.count_.load();
    objects.splice(objects.end(), from.objects);
    from.count_ = 0;
    unprotected_wake();
    return is_zero;
}

template<typename T> bool queue<T>::copy(queue& from) {
    lock_guard guard(lock);
    lock_guard other_guard(from.lock);
    bool is_zero = count_ == 0;
    count_ += from.count_.load();
    objects.insert(objects.end(), from.objects.begin(), from.objects.end());
    unprotected_wake();
    return is_zero;
}

template<typename T> handle_type<T> queue<T>::front() {
    handle obj;
    if (count_ != 0) {
        obj = objects.front();
    }
    return obj;
}

template<typename T> handle_type<T> queue<T>::back() {
    handle obj;
    if (count_ != 0) {
        obj = objects.back();
    }
    return obj;
}

template<typename T> bool queue<T>::empty() const {
    return count_.load() == 0;
}

template<typename T> size_t queue<T>::count() const {
    return count_.load();
}

template<typename T> void queue<T>::flush() {
    lock_guard guard(lock);
    objects.clear();
    count_ = 0;
}

template<typename T> queue<T>& queue<T>::operator=(queue<T>& from) {
    move(from);
    return *this;
}

template<typename T> queue<T>& queue<T>::operator=(handle obj) {
    push(obj);
    return *this;
}

template<typename T> queue<T>::operator queue<T>::handle() {
    return pop();
}

template<typename T> queue<T>::operator bool() {
    return !empty();
}

template<typename T> void queue<T>::output(std::ostream& out) {
    out << "count=" << count();
}

template<typename T> void queue<T>::unprotected_wake() {
    if (waiting) {
        waiter.notify();
    }
}

template<typename T> handle_type<T> queue<T>::unprotected_pop() {
    handle obj;
    if (count_ != 0) {
        obj = objects.front();
        objects.pop_front();
        --count_;
    }
    return obj;
}
}  // namespace pool
}  // namespace cs

template<typename T>
std::ostream& operator<<(std::ostream& out, cs::pool::pool<T>& pool) {
    pool.output(out);
    return out;
}
template<typename T>
std::ostream& operator<<(std::ostream& out, cs::pool::queue<T>& queue) {
    queue.output(out);
    return out;
}

#endif  // CS_POOLS_HPP
