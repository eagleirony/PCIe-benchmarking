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

#include <machine/rtems-bsd-kernel-space.h>

#include <dev/xdma/xdma.h>
#include <dev/ofw/ofw_bus.h>
#include <dev/xilinx/axidma.h>

#include <framework/axidma.h>

struct axidma_controller {
    xdma_controller_t* xdma_tx;
    xdma_channel_t* xchan_tx;
    void* ih_tx;

    xdma_controller_t* xdma_rx;
    xdma_channel_t* xchan_rx;
    void* ih_rx;
};

int axidma_init() {
    device_t dma_dev;
    phandle_t node;
    struct axidma_controller* axidma = malloc(sizeof(struct axidma_controller));

    node = OF_finddevice("/amba/dma@80000000");
    if (node == -1) {
        return -1;
    }

    dma_dev = OF_device_from_xref(node);
    if (dma_dev == NULL) {
        return -1;
    }


    return 0;
}
