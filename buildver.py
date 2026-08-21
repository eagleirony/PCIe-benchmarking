import os
import shutil
import time
import subprocess

outputs_c = ['app-build-id.c']
outputs_vhdl = ['hardware/generated/build_info.vhd']

build_ver_template_c = [
    '''/*
 * Copyright 2025 Contemporary Software
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

/*
 * Header file for generated file containing the git hash and unix time of
 * build as an ID.
 */

#include <platform/app-build-id.h>

const char* app_build_id() {
    return "''', '''";
}

size_t app_build_id_length() {
    return ''', ''';
}'''
]

build_ver_template_vhdl = [
    '''
 -- Copyright 2026 Contemporary Software
 --
 -- Licensed under the Apache License, Version 2.0 (the "License");
 -- you may not use this file except in compliance with the License.
 -- You may obtain a copy of the License at
 --
 --     http://www.apache.org/licenses/LICENSE-2.0
 --
 --     Unless required by applicable law or agreed to in writing, software
 --     distributed under the License is distributed on an "AS IS" BASIS,
 --     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 --     See the License for the specific language governing permissions and
 --     limitations under the License.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_signed.all;

entity build_info is
  port (
    build_ver : out   std_logic_vector(32 - 1 downto 0);
    build_id : out   std_logic_vector(32 - 1 downto 0)
  );
end entity build_info;

architecture arch of build_info is

  signal git  : std_logic_vector( 32 - 1 downto 0);
  signal time_hex : std_logic_vector( 32 - 1 downto 0);

begin

  git <= x"''', '''";
  time_hex <= x"''', '''";

  build_ver(32 - 1 downto 0) <= git;
  build_id(32 - 1 downto 0) <= time_hex;

end architecture arch;''']


def set_build_id(bld):
    ''' Build id is `git_hash[-m]-hex_time` where
    `-m` means the repo is dirty'''
    import waflib
    bid = None
    try:
        cmd = 'git ls-files --modified'
        modified = bld.cmd_and_log(cmd, quiet=waflib.Context.BOTH).strip()
        cmd = 'git rev-parse --verify HEAD'
        out = bld.cmd_and_log(cmd, quiet=waflib.Context.BOTH).strip()
    except WafError:
        bid = 'no-repo'
    if out:
        bid = out[:7]
    elif bid is None:
        bid = 'no-repo'
    if modified:
        bid += '-m'
    bid += '-' + hex(int(time.time()))[2:]
    bld.env.BUILD_ID = bid


def build_c(bld):
    from waflib import Task

    def create_build_ver_c(task):
        output = str(task.outputs[0])
        with open(output, 'w') as bv:
            bv.write(build_ver_template_c[0])
            bv.write(task.env.BUILD_ID)
            bv.write(build_ver_template_c[1])
            bv.write(hex(len(task.env.BUILD_ID)))
            bv.write(build_ver_template_c[2])

    class build_ver(Task.Task):
        color = 'CYAN'
        always_run = True
        run_str = [create_build_ver_c]

    set_build_id(bld)

    board = bld.env.FLARE_BOARD
    outs = [bld.path.find_or_declare(file) for file in outputs_c]

    build_ver_tsk = build_ver(env=bld.env)
    build_ver_tsk.set_outputs(outs)
    bld.add_to_group(build_ver_tsk)

def build_vhdl():
    bid = None
    bver = None
    modified = None
    out = None
    try:
        cmd = ["git", "ls-files", "--modified"]
        res = subprocess.run(cmd, capture_output=True, text = True)
        modified = res.stdout;
        cmd = ["git", "rev-parse", "--verify", "HEAD"]
        res = subprocess.run(cmd, capture_output=True, text = True)
        out = res.stdout;
    except:
        out = '0000000'
        modified = False

    if out:
        bver = out[:7]

    if modified:
        bver = '8' + bver
    else:
        bver = '0' + bver

    bid = hex(int(time.time()))[2:]

    with open(outputs_vhdl[0], 'w') as bv:
        bv.write(build_ver_template_vhdl[0])
        bv.write(bver)
        bv.write(build_ver_template_vhdl[1])
        bv.write(bid)
        bv.write(build_ver_template_vhdl[2])
