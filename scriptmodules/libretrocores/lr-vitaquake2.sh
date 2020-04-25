#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-vitaquake2"
rp_module_desc="Quake 2 engine - vitaQuake II port for libretro"
rp_module_help="ROM Extensions: .pak"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vitaquake2/libretro/LICENSE"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function sources_lr-vitaquake2() {
    gitPullOrClone "$md_build" https://github.com/libretro/vitaquake2.git libretro
}

function build_lr-vitaquake2() {
    mkdir -p "quake2-cores"
    local basegame
    local params=()
    for i in _ -rogue_ -xatrix_ -zaero_; do
        if [[ $i == -rogue_ ]]; then 
            j="rogue"
        elif [[ $i == -xatrix_ ]]; then 
            j="xatrix"
        elif [[ $i == -zaero_ ]]; then 
            j="zaero"
        fi
        params+=(basegame=$j)
        make "${params[@]}" clean
        make "${params[@]}" -j`nproc`
        mv "vitaquake2"$i"libretro.so" "quake2-cores"
        md_ret_require="$md_build/quake2-cores/vitaquake2"$i"libretro.so"
    done
}

function install_lr-vitaquake2() {
    md_ret_files=(
        'LICENSE'
        'quake2-cores/vitaquake2_libretro.so'
        'quake2-cores/vitaquake2-rogue_libretro.so'
        'quake2-cores/vitaquake2-xatrix_libretro.so'
        'quake2-cores/vitaquake2-zaero_libretro.so'
    )
}

function add_games_lr-vitaquake2() {
    local cmd1="$md_inst/vitaquake2_libretro.so"
    local cmd2="$md_inst/vitaquake2-rogue_libretro.so"
    local cmd3="$md_inst/vitaquake2-xatrix_libretro.so"
    local cmd4="$md_inst/vitaquake2-zaero_libretro.so"
    declare -A games=(
	['baseq2']="Quake II"
        ['rogue']="Quake II Mission Pack Ground Zero (rogue)"
        ['xatrix']="Quake II Mission Pack The Reckoning (xatrix)"
        ['zaero']="Quake II Mission Pack Zaero (zaero)"
    )
    local dir
    local pak
    local pak_all
    for dir in "${!games[@]}"; do
        pak="$romdir/ports/quake2/$dir/pak0.pak"
        pak_all="$romdir/ports/quake2/baseq2/pak0.pak"
        if [[ -f "$pak" ]]; then
            if [[ "$dir" == baseq2 ]]; then
                addPort "$md_id" "quake2" "${games[$dir]}" "$cmd1" "$pak_all"
            elif [[ "$dir" == rogue ]]; then
                addPort "$md_id-rogue" "quake2" "${games[$dir]}" "$cmd2" "$pak_all"
            elif [[ "$dir" == xatrix ]]; then
                addPort "$md_id-xatrix" "quake2" "${games[$dir]}" "$cmd3" "$pak_all"
            elif [[ "$dir" == zaero ]]; then
                addPort "$md_id-zaero" "quake2" "${games[$dir]}" "$cmd4" "$pak_all"
            fi       
        fi
    done
}

function configure_lr-vitaquake2() {
    setConfigRoot "ports"
    mkRomDir "ports/quake2"

    [[ "$md_mode" == "install" ]] && add_games_lr-vitaquake2

    ensureSystemretroconfig "ports/quake2"

    chown $user:$user "ports/quake2"
}
