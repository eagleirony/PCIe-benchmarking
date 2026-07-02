#
# Copyright 2024 Chris Johns (chrisj@rtems.org)
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

import gzip
import os
import shutil

mkimage_data = {
    'build-aarch64-rtems7-k26': {
        'objcopy': 'AARCH64_RTEMS%s_OBJCOPY',
        'arch': 'arm',
        'start_addr': 0x00010000,
        'entry_point': 0x00010000
    },
    'build-aarch64-rtems7-zynqmp_apu': {
        'objcopy': 'AARCH64_RTEMS%s_OBJCOPY',
        'arch': 'arm',
        'start_addr': 0x00010000,
        'entry_point': 0x00010000
    },
    'build-arm-rtems7-xilinx_zynq_microzed': {
        'objcopy': 'ARM_RTEMS%s_OBJCOPY',
        'arch': 'arm',
        'start_addr': 0x00104000,
        'entry_point': 0x00104040
    }
}


def mkimage(bld, elf_image):
    if bld.cmd in mkimage_data:
        #
        # Use a waf command chain to create a compressed u-boot image.
        # The ELF file is copied to a binary file (.bin) removing all
        # symbols, relocation records and debug info. We do not need
        # the debug info on the target as the ELF file remains on the
        # host. Compress the binary (.bin) file to create a .bin.gz
        # file then use mkimage to make the image file (.img). Clean
        # up once done removing the .bin and .bin.gz files.
        #
        from waflib import Task

        def gzip_file(task):
            src = task.inputs[0].abspath() + '.img.bin'
            tgt = task.outputs[0].abspath() + '.bin.gz'
            with open(src, 'rb') as f_in:
                with gzip.open(tgt, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)

        def remove_files(task):
            files = [
                task.inputs[0].abspath() + ext
                for ext in ['.img.bin', '.img.bin.gz']
            ]
            for f in files:
                try:
                    os.remove(f)
                except OSError:
                    if os.path.exists(f):
                        raise ValueError('cannot remove %r' % f)

        data = mkimage_data[bld.cmd]
        objcopy_cmd = bld.env[data['objcopy'] % bld.env.RTEMS_VERSION][
            0] + ' -R -S --strip-debug -O binary ${SRC} ${TGT}.bin'
        mkimage_cmd = bld.env.MKIMAGE[0] + ' -A ' + data[
            'arch'] + ' -O rtems -T kernel -a ' + hex(
                data['start_addr']) + ' -e ' + hex(
                    data['entry_point']
                ) + ' -n "RTEMS" -d ${TGT}.bin.gz ${TGT}'

        class mkimage_task(Task.Task):
            color = 'PINK'
            run_str = (objcopy_cmd, gzip_file, mkimage_cmd, remove_files)

        mkimage_tsk = mkimage_task(env=bld.env)
        mkimage_tsk.set_inputs(bld.path.find_or_declare(elf_image))
        mkimage_tsk.set_outputs(bld.path.find_or_declare(elf_image + '.img'))
        bld.add_to_group(mkimage_tsk)


def options(opt):
    pass


def configure(conf):
    conf.find_program('mkimage', var='MKIMAGE', mandatory=True)
