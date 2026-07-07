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

#include <fstream>
#include <filesystem>
#include <iostream>

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <rtems.h>

#include <bsp/aarch64-mmu.h>
#include <bsp.h>

#include <bsp/irq.h>

#define RTEMS_BSD_CONFIG_BSP_CONFIG

#define RTEMS_BSD_CONFIG_NET_PF_UNIX
#define RTEMS_BSD_CONFIG_NET_IF_BRIDGE
#define RTEMS_BSD_CONFIG_NET_IF_LAGG
#define RTEMS_BSD_CONFIG_NET_IF_VLAN

#define RTEMS_BSD_CONFIG_DOMAIN_PAGE_MBUFS_SIZE (128 * 1024 * 1024)

#define RTEMS_BSD_CONFIG_INIT

#include <bsp/irq-info.h>
#include <rtems/netcmds-config.h>
#include <machine/rtems-bsd-config.h>

#include <rtems/shell.h>

extern "C" {
#include <rtems/bsd/iface.h>
}

namespace app {
namespace platform {
namespace network {

void init() {
    rtems_bsd_initialize();
    rtems_shell_add_cmd_struct(&bsp_interrupt_shell_command);
    rtems_shell_add_cmd_struct(&rtems_shell_ARP_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_HOSTNAME_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_IFCONFIG_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_NETSTAT_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_PING_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_ROUTE_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_SYSCTL_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_TCPDUMP_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_NVMECONTROL_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_PCICONF_Command);
    rtems_shell_add_cmd_struct(&rtems_shell_VMSTAT_Command);
}

static void run_rc_conf(int timeout, bool trace) {
    int r = rtems_bsd_run_etc_rc_conf(timeout, trace);
    if (r < 0) {
        std::cout << "Failed to run rc.conf" << std::endl;
    }
}

static bool wait_for_iface_up(const char* iface, int wait_for_secs) {
    bool state = false;
    while (!state && wait_for_secs > 0) {
        --wait_for_secs;
        if (rtems_bsd_iface_link_state(iface, &state) == 0) {
            if (!state) {
                sleep(1);
            }
        }
    }
    return state;
}

static void init_rc_conf(const std::string iface) {
    std::ofstream rc_conf("/etc/rc.conf");

    rc_conf << "hostname=\"PCITB\"" << std::endl;
    rc_conf << "ifconfig_" << iface << "=\"DHCP rxcsum txcsum\"" << std::endl;
    rc_conf << "dhcpcd_priority=\"200\"" << std::endl;
    rc_conf << "dhcpcd_options=\"--debug --nobackground --timeout 30\"" << std::endl;
    rc_conf.close();
}

void start(int timeout, bool trace) {

    const std::string iface = "cgem0";

    if (!std::filesystem::exists("/etc/rc.conf")) {
        init_rc_conf(iface);
    }

    run_rc_conf(timeout, trace);

    wait_for_iface_up(iface.c_str(), timeout);
}

} // network
} // platform
} // app
