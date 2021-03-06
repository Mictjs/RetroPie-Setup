#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-smsplus-gx"
rp_module_desc="Colecovision/Sega 8-bit (MS/GG) emulator - SMSPlus-GX RS97 (improved) port for libretro."
rp_module_help="ROM Extensions: .sms .bin .rom .col .gg .zip .7z\n\nCopy your Game Gear roms to $romdir/gamegear\nCopy your MasterSystem roms to $romdir/mastersystem\nCopy your Colecovision roms to $romdir/coleco\n\nCopy bios.sms (Master System BIOS - Optional) to $biosdir\nCopy BIOS.col (Colecovision BIOS) to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/smsplus-gx/master/docs/license"
rp_module_section="exp x86=opt"
rp_module_flags=""

function sources_lr-smsplus-gx() {
    gitPullOrClone "$md_build" https://github.com/libretro/smsplus-gx.git
}

function build_lr-smsplus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro -j`nproc`
    md_ret_require="$md_build/smsplus_libretro.so"
}

function install_lr-smsplus-gx() {
    md_ret_files=(
        'docs/license'
        'smsplus_libretro.so'
    )
}

function configure_lr-smsplus-gx() {
    local system
    for system in mastersystem gamegear coleco; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/smsplus_libretro.so"
        addSystem "$system"
    done
}
