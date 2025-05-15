#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


printf '%s\n' ** | cpio -H newc -o | zstd -f -o ../../pkg/${PN}_${PV}_${XABI}.czst