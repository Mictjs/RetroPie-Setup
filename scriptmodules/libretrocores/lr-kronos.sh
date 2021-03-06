#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-kronos"
rp_module_desc="Saturn & ST-V emulator - Kronos port for libretro"
rp_module_help="ROM Extensions: .iso .cue .chd .zip .ccd .mds .7z\n\nCopy your Sega Saturn to $romdir/saturn\nCopy your Sega ST-V roms to $romdir/stv\n\nCopy the required BIOS file saturn_bios.bin / stvbios.zip to $biosdir/kronos"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/kronos/yabause/COPYING"
rp_module_section="exp"
rp_module_flags="!arm"

function sources_lr-kronos() {
    gitPullOrClone "$md_build" https://github.com/libretro/yabause.git kronos
}

function build_lr-kronos() {
    cd yabause/src/libretro
    make clean
    make -j`nproc`
    md_ret_require="$md_build/yabause/src/libretro/kronos_libretro.so"
}

function install_lr-kronos() {
    md_ret_files=(
        'yabause/src/libretro/kronos_libretro.so'
        'yabause/AUTHORS'
        'yabause/COPYING'
        'yabause/ChangeLog'
        'yabause/GOALS'
        'yabause/README'
        'yabause/README.LIN'
    )
}

function configure_lr-kronos() {
    local system
    for system in saturn stv; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/kronos_libretro.so"
        addSystem "$system"
    done
}
