/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Copyright 2026 Aaron Nyholm, All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *gt
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string>

#include <rtems.h>
#include <rtems/rtems/intr.h>

#include <framework/cpuuse.hpp>
#include <framework/dma.hpp>
#include <framework/intr.hpp>
#include <framework/io.hpp>
#include <framework/logging.hpp>
#include <framework/events.hpp>

#include <externals/rtems/thread.hpp>

namespace app {
namespace framework {
namespace api {
namespace intr {

constexpr uint32_t PL_INTR_EVENT = RTEMS_EVENT_0;

intr_ctlr_ptr ic;

intr_ctlr_ptr make_intr_ctlr() {
    if (!ic) {
        ic = std::make_shared<intr_ctlr>();
    }
    return ic;
}

struct intr_ctlr {
    using lock_type = std::recursive_mutex;
    using lock_guard = std::lock_guard<lock_type>;
    using rtems_thread = ::rtems::thread::thread;
    using rtems_event_ptr = std::shared_ptr<rtems::events::event>;

    lock_type lock;
    bool running;
    rtems_thread pl_intr_thread;
    rtems_interrupt_entry rie;
    rtems_interrupt_lock ilock;
    rtems_id waiter;
    rtems_event_ptr ep_evt;
    rtems_event_ptr pl_evt;

    intr_ctlr() : running(false), waiter(RTEMS_ID_NONE) {};

    ~intr_ctlr() {
        stop();
    }

    void start() {
        lock_guard guard(lock);
        start_worker();
        while(!running) {
            lock.unlock();
            usleep(1000);
            lock.lock();
        }
    }

    void stop() {
        {
        lock_guard guard(lock);
        running = false;
        }
        if (pl_intr_thread.joinable()) {
            pl_intr_thread.join();
        }
    }

    bool is_running() {
        lock_guard guard(lock);
        return running;
    }

    void set_ep_event(rtems_event_ptr evt_) {
        lock_guard guard(lock);
        ep_evt = evt_;
    }

    void clear_ep_event() {
        lock_guard guard(lock);
        ep_evt = nullptr;
    }

    rtems_event_ptr get_ep_event() {
        return ep_evt;
    }

    void set_pl_event(rtems_event_ptr evt_) {
        lock_guard guard(lock);
        pl_evt = evt_;
    }

    void clear_pl_event() {
        lock_guard guard(lock);
        pl_evt = nullptr;
    }

    rtems_event_ptr get_pl_event() {
        return pl_evt;
    }

    void worker() {
        cpuuse::log_guard lguard("PL_INTR");
        lock_guard guard(lock);
        rtems_event_set event_out;
        rtems_status_code status;
        rtems_interrupt_lock_context lock_context;
        rtems_interval timeout = RTEMS_MILLISECONDS_TO_TICKS(100);

        rtems_interrupt_lock_acquire(&ic->ilock, &lock_context);
        if (waiter == RTEMS_ID_NONE) {
            waiter = rtems_task_self();
        }
        rtems_interrupt_lock_release(&ic->ilock, &lock_context);
        running = true;
        while (running) {
            lock.unlock();
            status = rtems_event_system_receive(
                PL_INTR_EVENT,
                RTEMS_WAIT,
                timeout,
                &event_out
            );
            lock.lock();

            if (status == RTEMS_SUCCESSFUL) {
                benchmark::log::timestamp_and_log(
                    benchmark::log::record::PL_USER_INTR_END);
                auto evt = ic->get_pl_event();
                if (evt != nullptr) {
                    evt->signal();
                }
            } else if (status != RTEMS_TIMEOUT) {
                std::ostringstream oss;
                running = false;
                rtems_interrupt_lock_acquire(&ic->ilock, &lock_context);
                waiter = RTEMS_ID_NONE;
                rtems_interrupt_lock_release(&ic->ilock, &lock_context);
                oss << "pl: intr: worker: wait failed: " << status;
                throw std::runtime_error(oss.str());
            }
        }
        rtems_interrupt_lock_acquire(&ic->ilock, &lock_context);
        waiter = RTEMS_ID_NONE;
        rtems_interrupt_lock_release(&ic->ilock, &lock_context);
    }

    void start_worker() {
        lock_guard guard(lock);
        ::rtems::thread::attributes attr;
        std::ostringstream oss;

        oss << "PL_INTR";

        attr.set_name(oss.str().c_str());
        attr.set_rtems_priority(97);
        attr.set_stack_size(RTEMS_MINIMUM_STACK_SIZE);

        pl_intr_thread = ::rtems::thread::thread(attr, &intr_ctlr::worker, this);
    }
};

static void pl_intr_handler(void* arg) {
    rtems_interrupt_lock_context lock_context;
    uint32_t reg;
    auto ior = io::get_io_registers();

    reg = ior->pl.read(io::PL_REG_SIGNALS_OFF);
    reg = reg & ~io::PL_REG_SIGNALS_IRQ_OUT;
    ior->pl.write(io::PL_REG_SIGNALS_OFF, reg);

    rtems_interrupt_lock_acquire(&ic->ilock, &lock_context);
    if (ic->waiter != RTEMS_ID_NONE) {
        rtems_event_system_send(ic->waiter, PL_INTR_EVENT);
    }
    rtems_interrupt_lock_release(&ic->ilock, &lock_context);
}

void init() {
    const char pl_intr_name[] = "PL_INTR_HANDLER";

    rtems_interrupt_lock_initialize(&ic->ilock, pl_intr_name);

    rtems_interrupt_entry_initialize(&ic->rie, pl_intr_handler, NULL, pl_intr_name);
    rtems_interrupt_entry_install(PL_INTR_VECTOR, RTEMS_INTERRUPT_SHARED, &ic->rie);

    pcie::dma::controller::callback ccb = [](int irq) {
        uint32_t reg;

        benchmark::log::timestamp_and_log(
            benchmark::log::record::EP_USER_INTR_END);

        auto ior = io::get_io_registers();

        reg = ior->pl.read(io::PL_REG_SIGNALS_OFF);
        reg = reg & ~io::PL_REG_SIGNALS_EXPANSION_OUT;
        ior->pl.write(io::PL_REG_SIGNALS_OFF, reg);

        reg = ior->endpoint.read(io::EP_REG_SIGNALS_OFF);
        reg = reg | io::EP_REG_SIGNALS_ACK_USER_IRQ;
        ior->endpoint.write(io::EP_REG_SIGNALS_OFF, reg);

        reg = reg & ~io::EP_REG_SIGNALS_ACK_USER_IRQ;
        ior->endpoint.write(io::EP_REG_SIGNALS_OFF, reg);

        auto evt = ic->get_ep_event();
        if (evt != nullptr) {
            evt->signal();
        }
    };

    try {
        auto ctlr = pcie::dma::get_controller(0);
        ctlr->set_user_irq_callback(ccb);
    } catch (const std::runtime_error& e) {
        throw std::runtime_error("intr: init: dma must be initialised before intr");
    }
}

void start() {
    ic->start();
}

void stop() {
    ic->stop();
}

void log_pl_intr() {
    uint32_t reg;
    auto ior = io::get_io_registers();

    if (!ic->is_running()) {
        throw std::runtime_error("io: log_pl_intr: PL_INTR not running");
    }

    auto evt = std::make_shared<rtems::events::event>(true, RTEMS_EVENT_1);
    ic->set_pl_event(evt);

    reg = ior->pl.read(io::PL_REG_SIGNALS_OFF);
    reg = reg | io::PL_REG_SIGNALS_IRQ_OUT;

    benchmark::log::log_and_timestamp(benchmark::log::record::PL_USER_INTR_START);
    ior->pl.write(io::PL_REG_SIGNALS_OFF, reg);

    evt->wait();
    ic->clear_pl_event();
}

void log_ep_intr() {
    uint32_t reg;
    auto ior = io::get_io_registers();

    reg = ior->pl.read(io::PL_REG_SIGNALS_OFF);
    reg = reg & ~io::PL_REG_SIGNALS_EXPANSION_OUT;
    ior->pl.write(io::PL_REG_SIGNALS_OFF, reg);

    reg = ior->endpoint.read(io::EP_REG_SIGNALS_OFF);
    reg = reg | io::EP_REG_SIGNALS_ACK_USER_IRQ;
    ior->endpoint.write(io::EP_REG_SIGNALS_OFF, reg);

    reg = reg & ~io::EP_REG_SIGNALS_ACK_USER_IRQ;
    ior->endpoint.write(io::EP_REG_SIGNALS_OFF, reg);

    auto ctlr = pcie::dma::get_controller(0);
    ctlr->enable_user_irq(0);
    auto evt = std::make_shared<rtems::events::event>(true, RTEMS_EVENT_0);
    ic->set_ep_event(evt);

    reg = ior->pl.read(io::PL_REG_SIGNALS_OFF);
    reg = reg | io::PL_REG_SIGNALS_EXPANSION_OUT;

    benchmark::log::log_and_timestamp(benchmark::log::record::EP_USER_INTR_START);
    ior->pl.write(io::PL_REG_SIGNALS_OFF, reg);

    evt->wait();
    ic->clear_ep_event();
    ctlr->disable_user_irq(0);
}

} // namespace intr
} // namespace api
} // namespace framework
} // namespace app
