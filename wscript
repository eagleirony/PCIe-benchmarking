#
# App Waf script
#
import uboot
import fdt

rtems_version = "7"

try:
    import rtems_waf.rtems
    import rtems_waf.rtems_bsd
except:
    print('error: no rtems_waf git submodule')
    import sys
    sys.exit(1)

def init(ctx):
    rtems_waf.rtems.init(ctx, version = rtems_version, long_commands = True)

def bsp_configure(conf, arch_bsp):
    rtems_waf.rtems_bsd.bsp_configure(conf, arch_bsp)
    conf.env.DEFINES += ['_BSD_SOURCE=1']
    conf.env.LIB = ['bsd', 'z'] + conf.env.LIB

def options(opt):
    rtems_waf.rtems.options(opt)
    rtems_waf.rtems_bsd.options(opt)

def configure(conf):
    uboot.configure(conf)
    fdt.configure(conf)
    rtems_waf.rtems.configure(conf, bsp_configure = bsp_configure)

def build(bld):
    rtems_waf.rtems.build(bld)

    sources = [
        'main.c',
        'init.c',
    ]

    cflags = ['-g', '-O2', '-DFDT=1']

    if 'aarch64' in bld.cmd:
        fdt.build_fdt_blob(bld, 'axu2cgb')
        sources.append('axu2cgb-fdt.c')
        cflags += ['-DZYNQMP=1']

    bld(features = 'c cprogram',
        target = 'app',
        cflags = cflags,
        source = sources)

    uboot.mkimage(bld, 'app')
