#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-vice"
rp_module_desc="Commodore 64/128/CBM-II/PET/Plus-4/VIC-20 emulator - port of VICE for libretro"
rp_module_help="ROM Extensions: .d64 .d71 .d80 .d81 .d82 .g64 .g41 .x64 .t64 .tap .prg .p00 .crt .bin .zip .gz .d6z .d7z .d8z .g6z .g4z .x6z .cmd .m3u .vfl .vsf .20 .40 .60 .a0 .b0 \n\nCopy your C64 games to $romdir/c64\nCopy your Plus-4 games to $romdir/cplus4\nCopy your VIC-20 games to $romdir/vic20\nCopy your C128 games to $romdir/c128\nCopy your CBM-II games to $romdir/cbm2\nCopy your PET games to $romdir/pet"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vice-libretro/master/vice/COPYING"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-vice() {
    gitPullOrClone "$md_build" https://github.com/libretro/vice-libretro.git
}

function build_lr-vice() {
    mkdir -p "vice-cores"
    local params=()
    for i in x64 x64sc xcbm2 xpet xplus4 xvic x128; do
        params+=(EMUTYPE=$i)
        make "${params[@]}" clean
        make "${params[@]}" -j`nproc`
        mv "vice_"$i"_libretro.so" "vice-cores"
        md_ret_require="$md_build/vice-cores/vice_"$i"_libretro.so"
    done
}

function install_lr-vice() {
    md_ret_files=(
        'vice/data'
        'vice/COPYING'
        'vice-cores/vice_x64_libretro.so'
        'vice-cores/vice_x64sc_libretro.so'
        'vice-cores/vice_xcbm2_libretro.so'
        'vice-cores/vice_xpet_libretro.so'
        'vice-cores/vice_xplus4_libretro.so'
        'vice-cores/vice_xvic_libretro.so'
        'vice-cores/vice_x128_libretro.so'
    )
}

function configure_lr-vice() {
    local system
    for system in c64 cbm2 pet cplus4 vic20 c128; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        if [[ $system == c64 ]]; then
            addEmulator 0 "$md_id-x64" "$system" "$md_inst/vice_x64_libretro.so"
            addEmulator 1 "$md_id-x64sc" "$system" "$md_inst/vice_x64sc_libretro.so"
        elif [[ $system == cbm2 ]]; then
            addEmulator 0 "$md_id-xcbm2" "$system" "$md_inst/vice_xcbm2_libretro.so"
        elif [[ $system == pet ]]; then
            addEmulator 0 "$md_id-xpet" "$system" "$md_inst/vice_xpet_libretro.so"
        elif [[ $system == cplus4 ]]; then
            addEmulator 0 "$md_id-xplus4" "$system" "$md_inst/vice_xplus4_libretro.so"
        elif [[ $system == vic20 ]]; then
            addEmulator 0 "$md_id-xvic" "$system" "$md_inst/vice_xvic_libretro.so"
        else
            addEmulator 0 "$md_id-x128" "$system" "$md_inst/vice_x128_libretro.so"
        fi
        addSystem "$system"
    done

    cp -R "$md_inst/data" "$biosdir"
    chown -R $user:$user "$biosdir/data"
}
