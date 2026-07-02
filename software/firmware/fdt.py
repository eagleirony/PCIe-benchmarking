#
# Pixie Embedded Platform Flat Device Tree
#

import os.path

fdt_template = {
    'header': [
        '/* Generated, do not edit */', '', '#include <bsp.h>',
        '#include <bsp/fdt.h>', '', 'static unsigned char bsp_dtb[] = {'
    ],
    'footer': [
        '};', '', 'const void* bsp_fdt_get(void) {', '    return bsp_dtb;',
        '}', '',
        'uint32_t bsp_fdt_map_intr(const uint32_t *intr, size_t icells) {',
        '    if (icells != 3) {', '        return 0;', '    }',
        '    return (intr[0] == 0 ? 32 : 16) + intr[1];', '}', '', ''
    ]
}


def get_net_config(board_config, bsp_name):
    lines = []
    if board_config is not None:
        if not os.path.exists(board_config):
            conf.fatal('board config not found: ' + board_config)
        try:
            config = configparser.ConfigParser()
            config.read(board_config)
            if bsp_name in config.sections():
                lines += ['#define HAVE_BUILD_CONFIG 1']
                bsp_config = config[bsp_name]
                for cfg in net_configs_bool:
                    if cfg in bsp_config:
                        if bsp_config.getboolean(cfg):
                            lines += ['#define %s 1' % (cfg)]
                for cfg in net_configs:
                    if cfg in bsp_config:
                        bcfg = prep_define(bsp_config[cfg])
                        lines += ['#define %s %s' % (cfg, bcfg)]
        except configparser.ParsingError as ce:
            raise conf.fatal('config: %s' % (ce))
    return lines


def bsp_has_net_config(conf, arch_bsp):
    lines = get_net_config(conf.options.board_config,
                           buildcontrol.arch_bsp_name(arch_bsp))
    return len(lines) != 0


def build_fdt_blob(bld, dts):
    #
    # Use a waf command chain to create a FDT blob as a C
    # source file.
    #
    from waflib import Task

    def bin_to_c(task):
        src = task.inputs[0].abspath() + '.dtb'
        tgt = task.outputs[0].abspath()
        with open(src, 'rb') as f_in:
            data = f_in.read()
            lines = fdt_template['header']
            count = 0
            for b in data:
                if count == 0:
                    lines += ['']
                lines[-1] += hex(b) + ', '
            lines[-1] = lines[-1][:-2]
            lines += fdt_template['footer']
            with open(tgt, 'w') as f_out:
                f_out.write(os.linesep.join(lines))

    def remove_files(task):
        files = [task.inputs[0].abspath() + ext for ext in ['.dtb']]
        for f in files:
            try:
                os.remove(f)
            except OSError:
                if os.path.exists(f):
                    raise ValueError('cannot remove %r' % f)

    dtc_cmd = bld.env.DTC[0] + ' -O dtb -I dts -o ${SRC}.dtb ${SRC}'

    class fdt_c_task(Task.Task):
        color = 'PINK'
        run_str = (dtc_cmd, bin_to_c, remove_files)

    c_src = dts + '-fdt.c'

    fdt_c_tsk = fdt_c_task(env=bld.env)
    fdt_c_tsk.set_inputs(bld.path.find_resource(dts + '.dts'))
    fdt_c_tsk.set_outputs(bld.path.find_or_declare(c_src))
    fdt_c_tsk.before = ['c', 'cxx']
    bld.add_to_group(fdt_c_tsk)

    bld.objects(target='platform-rtems-fdt', source=c_src)


def options(opt):
    pass


def configure(conf):
    conf.find_program('dtc', var='DTC', mandatory=True)
