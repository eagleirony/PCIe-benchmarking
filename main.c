/*
 * Hello world example
 */
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <rtems.h>

#ifdef ZYNQMP
#include <dev/pm/pm.h>
#include <bsp/aarch64-mmu.h>
#endif /* ZYNQMP */
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

#include <rtems/bsd/iface.h>

#include <dev/iospace/iospace.h>

void event_task(int fd) {
    rtems_iospace_event_args args;

    args.index = 0;
    args.timeout.tv_sec = 0;
    args.timeout.tv_nsec = 0;

    printf("event waiting\n");
    int status = ioctl(fd, RTEMS_IOSPACE_IOCTL_EVENT_WAIT, &args);

    printf("EVENT RECV\n");
}

rtems_task Init(rtems_task_argument ignored)
{
    rtems_status_code sc;

    printf("RTEMS begin\n");
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
#ifdef ZYNQMP
    rtems_shell_add_cmd_struct(&bsp_pm_load_shell_command);

    aarch64_mmu_map(0xa0000000, 0xa4000000, AARCH64_MMU_DEVICE);
#endif /* ZYNQMP */

    /*
    int fd = open("/dev/pci_iospace0", O_RDWR);

    size_t count = 0;
    int status = ioctl(fd, RTEMS_IOSPACE_IOCTL_REGION_COUNT, &count);
    printf("Region count: %d\n", count);
    status = ioctl(fd, RTEMS_IOSPACE_IOCTL_EVENT_COUNT, &count);
    printf("Event count: %d\n", count);

    rtems_id task_id;
    sc = rtems_task_create(
        rtems_build_name('E', 'V', 'T', 'W'),
        110,
        8 * 1024,
        RTEMS_DEFAULT_MODES,
        RTEMS_DEFAULT_ATTRIBUTES,
        &task_id
      );

    sc = rtems_task_start(task_id, (rtems_task_entry)event_task, fd);

    rtems_iospace_region region;
    region.index = 0;
    status = ioctl(fd, RTEMS_IOSPACE_IOCTL_REGION_GET, &region);
    printf("Region %d: address: %p, size: %d, name: %s\n",
        region.index,
        region.address,
        region.size,
        region.name
    );

    void *addr = mmap(
        NULL,
        region.size,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        fd,
        region.index
    );

    uint32_t *bar0_reg;
    bar0_reg = addr;

    void *buf = malloc(512);
    bzero(buf, 512);

    printf("MMAP: %p to %p\n", addr, buf);
    *bar0_reg = (uint32_t)buf;
    */

    sc = rtems_shell_init(
        "SHLL",
        60 * 1024,
        200,
        "stdin", 0, 1, NULL);
    if (sc != RTEMS_SUCCESSFUL) {
        printf("Shell init failed\n");
    }

    exit(0);
}
