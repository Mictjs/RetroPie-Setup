#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mesen"
<<<<<<< HEAD
rp_module_desc="NES emu - Mesen port for libretro"
rp_module_help="ROM Extensions: .nes .fds .unf .unif .zip .7z\n\nCopy your NES roms to $romdir/nes\nCopy your Famicom Disk System roms to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir\n\nOptional: HD Packs go in $biosdir/HdPacks/<rom_name> and Custom palette in $biosdir/MesenPalette.pal"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen/master/LICENSE"
rp_module_section="opt"
=======
rp_module_desc="High-accuracy NES and Famicom emulator"
rp_module_help="ROM Extensions: .nes .fds .unf .unif .zip\n\nCopy your NES roms to $romdir/nes\nFamicom roms to $romdir/fds\nCopy the recommended BIOS file disksys.rom to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/sourmesen/mesen/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!armv6"
>>>>>>> upstream/master

function sources_lr-mesen() {
    gitPullOrClone "$md_build" https://github.com/SourMesen/Mesen.git
}

function build_lr-mesen() {
<<<<<<< HEAD
    cd Libretro
    make clean
    make -j`nproc`
=======
    make -C Libretro clean
    make -C Libretro
>>>>>>> upstream/master
    md_ret_require="$md_build/Libretro/mesen_libretro.so"
}

function install_lr-mesen() {
    md_ret_files=(
<<<<<<< HEAD
        'README.md'
        'Libretro/mesen_libretro.so'
=======
        'Libretro/mesen_libretro.so'
        'LICENSE'
        'README.md'
>>>>>>> upstream/master
    )
}

function configure_lr-mesen() {
    local system
<<<<<<< HEAD
    for system in nes fds; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        addEmulator 1 "$md_id" "$system" "$md_inst/mesen_libretro.so"
=======
    for system in "nes" "fds"; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mesen_libretro.so"
>>>>>>> upstream/master
        addSystem "$system"
    done
}
