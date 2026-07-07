#! /usr/bin/env python
# encoding: utf-8
#
# Global Item Manager
#

defines = []

includes = []

cflags = [
    '-g',
    '-O2',
    '-Wall',
    '-mcpu=cortex-a53',
    '-mfix-cortex-a53-835769',
    '-mfix-cortex-a53-843419',
    '-mlittle-endian',
    '-DFDT=1',
]


def get_defines(bld, items):
    vals = []
    vals += items
    vals += defines
    return vals


def get_includes(bld, items):
    vals = []
    vals += items
    vals += includes
    return vals


def get_cflags(bld, items):
    vals = []
    vals += items
    vals += cflags
    return vals
