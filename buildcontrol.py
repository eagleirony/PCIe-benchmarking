#
# Flare Build Control
#

import os


def recurse(ctx, directories):
    for d in directories:
        ctx.recurse(d)


def options(opt):
    pass


def configure(conf):
    pass
