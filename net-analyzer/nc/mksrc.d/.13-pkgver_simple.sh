#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


mapfile -tn '1' -d $'\n' PV < 'src_uri.lst'

PV=${PV##*/}
PV=${PV##*$PN[-]}
PV=${PV##*$PN}
PV=${PV#[a-z][a-z]*[-]}
PV=${PV%.*}
PV=${PV%.tar}

PV=${PV%.*}