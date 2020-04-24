#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bluemsx"
rp_module_desc="MSX/MSX2/Colecovision/SG-1000 emu - blueMSX port for libretro"
rp_module_help="ROM Extensions: .rom .ri .mx1 .mx2 .col .dsk .cas .sg .sc .m3u .zip .7z\n\nCopy your MSX games to $romdir/msx\nCopy your MSX2 games to $romdir/msx2\nCopy your Colecovision games to $romdir/coleco\nCopy your SG-1000 games to $romdir/sg-1000\n\nYou need the 'Databases' and 'Machines' folders from an official full standalone blueMSX emulator installation and copy them to $biosdir."
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/blueMSX-libretro/master/license.txt"
rp_module_section="opt"

function sources_lr-bluemsx() {
    gitPullOrClone "$md_build" https://github.com/libretro/blueMSX-libretro.git
}

function build_lr-bluemsx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/bluemsx_libretro.so"
}

function install_lr-bluemsx() {
    md_ret_files=(
        'bluemsx_libretro.so'
        'README.md'
        'system/bluemsx/Databases'
        'system/bluemsx/Machines'
    )
}

function configure_lr-bluemsx() {
    local system
    for system in msx msx2 coleco sg-1000; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/bluemsx_libretro.so"
        addSystem "$system"
    done

    cp -rv "$md_inst/"{Databases,Machines} "$biosdir/"
    chown -R $user:$user "$biosdir/"{Databases,Machines}
}
