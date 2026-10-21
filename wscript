#! /usr/bin/env python
## encoding: utf-8

#
# App Waf script
#

import buildcontrol
import builditems
import buildver
import software.firmware.uboot as uboot
import hog

from waflib import Logs
from waflib.Build import BuildContext

rtems_version = "7"

directories = ['software']

sources = []

defines = []

includes = ['.']

cflags = []

cxxflags = []

try:
    import rtems_waf.rtems
    import rtems_waf.rtems_bsd
except:
    print('error: no rtems_waf git submodule')
    import sys
    sys.exit(1)


class HardwarePLContext(BuildContext):
    cmd = 'build_pl'
    variant = 'hardware_pl'


class HardwareEndpointContext(BuildContext):
    cmd = 'build_ep'
    variant = 'hardware_ep'


def init(ctx):
    rtems_waf.rtems.init(ctx, version=rtems_version, long_commands=True)
    buildcontrol.recurse(ctx, directories)


def bsp_configure(conf, arch_bsp):
    rtems_waf.rtems_bsd.bsp_configure(conf, arch_bsp)
    conf.env.DEFINES += ['_BSD_SOURCE=1']
    conf.env.LIB = ['bsd', 'z'] + conf.env.LIB


def options(opt):
    opt.add_option_group('PCIe Benchmark Build')
    pbb_opts = opt.get_option_group('PCIe Benchmark Build')
    pbb_opts.add_option('--build',
                        default='both',
                        dest='build_type',
                        choices=['software', 'hardware', 'both'],
                        help='Build hardware, software or both')

    buildcontrol.recurse(opt, directories)
    buildcontrol.options(opt)
    rtems_waf.rtems.options(opt)
    rtems_waf.rtems_bsd.options(opt)


def configure_software(conf):
    buildcontrol.recurse(conf, directories)
    buildcontrol.options(conf)
    uboot.configure(conf)
    rtems_waf.rtems.configure(conf, bsp_configure=bsp_configure)


def configure_hardware(conf):
    hog.configure(conf)


def configure(conf):
    conf.env.BUILD_TYPE = conf.options.build_type

    if conf.options.build_type == 'both':
        configure_software(conf)
        configure_hardware(conf)
    if conf.options.build_type == 'software':
        configure_software(conf)
    if conf.options.build_type == 'hardware':
        configure_hardware(conf)


def build_software(bld):
    buildcontrol.recurse(bld, directories)

    bld.objects(features='cxx cxxprogram',
                target='app',
                cflags=builditems.get_cflags(bld, cflags),
                cxxflags=builditems.get_cxxflags(bld, cxxflags),
                includes=builditems.get_includes(bld, includes),
                defines=builditems.get_defines(bld, defines),
                use=[
                    'app_firmware', 'app_platform', 'app_framework',
                    'app_externals', 'app_testsuite'
                ],
                source=sources)

    rtems_waf.rtems.build(bld)

    uboot.mkimage(bld, 'app')


def build_ep(bld):
    buildver.build_vhdl(bld)
    hog.hog_build(bld, 'endpoint')


def build_pl(bld):
    buildver.build_vhdl(bld)
    hog.hog_build(bld, 'pl')


def build(bld):
    if (bld.variant == 'hardware_pl'):
        if (bld.env.BUILD_TYPE != 'hardware' and bld.env.BUILD_TYPE != 'both'):
            bld.fatal('Not configured to build hardware')
        build_pl(bld)
    elif (bld.variant == 'hardware_ep'):
        if (bld.env.BUILD_TYPE != 'hardware' and bld.env.BUILD_TYPE != 'both'):
            bld.fatal('Not configured to build hardware')
        build_ep(bld)
    elif (bld.variant != 'hardware_pl' and bld.variant != 'hardware_ep'):
        if (bld.env.BUILD_TYPE != 'software' and bld.env.BUILD_TYPE != 'both'):
            bld.fatal('Not configured to build software')
        build_software(bld)
