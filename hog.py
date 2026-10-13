 # SPDX-License-Identifier: Apache-2.0 #/

 #
 # Copyright 2026 Aaron Nyholm, All rights reserved.
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #     http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #

import shutil
import sys

from waflib.Context import Context

import buildver

hog_data = {
    'endpoint': {
        'bit': 'Projects/endpoint/endpoint.runs/impl_1/top.bit',
        'ltx': 'Projects/endpoint/endpoint.runs/impl_1/top.ltx'
        },
    'pl': {
        'xsa': 'Projects/pl/pl.xsa'
        }
}

def hog_build(bld, project):
    from waflib import Task

    hog_cmd = './Hog/Do CREATEWORKFLOW ' + project
    xsa_cmd = ('vivado -mode batch -source ./hardware/tcl/pl/xsa.tcl -notrace '
        '-tclargs ' + hog_data['pl']['xsa'])

    def run_hog(task):
        cmd = hog_cmd
        if task.env.WIN_BASH:
            cmd = [task.env.WIN_BASH[0], '-c', hog_cmd]

        return task.exec_command(cmd, cwd='.', stdout=None, stderr=None)

    def export_xsa(task):
        if project == 'pl':
            cmd = xsa_cmd
            if task.env.WIN_BASH:
                cmd = [task.env.WIN_BASH[0], '-c', xsa_cmd]
            return task.exec_command(cmd, cwd='.',
                                     stdout=None, stderr=None)

    def copy_files(task):
        if project == 'endpoint':
            bit_file = task.outputs[0].abspath();
            ltx_file = task.outputs[1].abspath();
            shutil.copy(hog_data[project]['bit'], bit_file)
            shutil.copy(hog_data[project]['ltx'], ltx_file)
        elif project == 'pl':
            xsa_file = task.outputs[0].abspath();
            shutil.copy(hog_data[project]['xsa'], xsa_file)

    class hog_task(Task.Task):
        color = 'PINK'
        run_str = (run_hog, export_xsa, copy_files)

    hog_tsk = hog_task(env=bld.env)

    if project == 'endpoint':
        hog_tsk.set_outputs(bld.path.find_or_declare(bld.env.BUILD_ID + '.bit'))
        hog_tsk.set_outputs(bld.path.find_or_declare(bld.env.BUILD_ID + '.ltx'))
    elif project == 'pl':
        hog_tsk.set_outputs(bld.path.find_or_declare(bld.env.BUILD_ID + '.xsa'))
    bld.add_to_group(hog_tsk)


def options(opt):
    pass


def configure(conf):
    conf.find_program('vivado', var='VIVADO', mandatory=True)

    if sys.platform == 'win32':
        conf.find_program('bash', var='WIN_BASH', mandatory=True)

