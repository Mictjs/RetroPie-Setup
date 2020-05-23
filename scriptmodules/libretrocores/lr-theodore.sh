#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-theodore"
<<<<<<< HEAD
rp_module_desc="Thomson MO/TO 8-bit computers emulator for libretro"
rp_module_help="ROM Extension: .fd .sap .k7 .m7 .m5 .rom .zip\n\nCopy your Thomson TO roms to $romdir/thomson"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Zlika/theodore/master/LICENSE"
rp_module_section="exp"

function sources_lr-theodore() {
    gitPullOrClone "$md_build" https://github.com/Zlika/theodore.git
=======
rp_module_desc="Thomson MO/TO system emulator"
rp_module_help="ROM Extensions: *.fd, *.sap, *.k7, *.m5, *.m7, *.rom\n\nAdd your game files in $romdir/moto"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/theodore/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-theodore() {
    gitPullOrClone "$md_build" https://github.com/Zlika/theodore
>>>>>>> upstream/master
}

function build_lr-theodore() {
    make clean
<<<<<<< HEAD
    make -j`nproc`
    md_ret_require="$md_build/theodore_libretro.so"
=======
    make
    md_ret_require="theodore_libretro.so"
>>>>>>> upstream/master
}

function install_lr-theodore() {
    md_ret_files=(
        'theodore_libretro.so'
<<<<<<< HEAD
=======
        'README.md'
        'README-FR.md'
        'LICENSE'
>>>>>>> upstream/master
    )
}

function configure_lr-theodore() {
<<<<<<< HEAD
    mkRomDir "thomson"
    ensureSystemretroconfig "thomson"

    addEmulator 1 "$md_id" "thomson" "$md_inst/theodore_libretro.so"
    addSystem "thomson"
=======
    mkRomDir "moto"
    ensureSystemretroconfig "moto"

    addEmulator 1 "$md_id" "moto" "$md_inst/theodore_libretro.so"
    addSystem "moto"
>>>>>>> upstream/master
}
