#! /usr/bin/env python
## encoding: utf-8

#
# App Waf script
#

import buildcontrol
import builditems
import buildver
import software.firmware.uboot as uboot

rtems_version = "7"

directories = ['software']

sources = []

defines = []

includes = ['.']

cflags = []

try:
    import rtems_waf.rtems
    import rtems_waf.rtems_bsd
except:
    print('error: no rtems_waf git submodule')
    import sys
    sys.exit(1)


def init(ctx):
    rtems_waf.rtems.init(ctx, version=rtems_version, long_commands=True)
    buildcontrol.recurse(ctx, directories)


def bsp_configure(conf, arch_bsp):
    rtems_waf.rtems_bsd.bsp_configure(conf, arch_bsp)
    conf.env.DEFINES += ['_BSD_SOURCE=1']
    conf.env.LIB = ['bsd', 'z'] + conf.env.LIB


def options(opt):
    buildcontrol.recurse(opt, directories)
    buildcontrol.options(opt)
    rtems_waf.rtems.options(opt)
    rtems_waf.rtems_bsd.options(opt)


def configure(conf):
    buildcontrol.recurse(conf, directories)
    buildcontrol.options(conf)
    uboot.configure(conf)
    rtems_waf.rtems.configure(conf, bsp_configure=bsp_configure)


def build(bld):
    buildcontrol.recurse(bld, directories)

    bld.objects(features='cxx cxxprogram',
                target='app',
                cflags=builditems.get_cflags(bld, cflags),
                include=builditems.get_includes(bld, includes),
                defines=builditems.get_defines(bld, defines),
                use=['app_firmware', 'app_platform'],
                source=sources)

    rtems_waf.rtems.build(bld)

    uboot.mkimage(bld, 'app')
