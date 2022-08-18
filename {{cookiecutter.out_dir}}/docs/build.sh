#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))/..
./control.sh make_docs
# vim:set et sts=4 ts=4 tw=80:
