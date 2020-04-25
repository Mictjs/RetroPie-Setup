#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-flycast"
rp_module_desc="Dreamcast/NAOMI/Atomiswave emulator - Reicast port for libretro"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd\nNaomi/Atomiswave ROM Extension: .zip (.chd (NAOMI-GD))\n\nCopy your Dreamcast roms to $romdir/dreamcast\nCopy your NAOMI roms to $romdir/naomi\nCopy your Atomiswave roms to $romdir/atomiswave\n\nCopy the required BIOS files dc_boot.bin, dc_flash.bin, naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_section="opt"
rp_module_flags="!mali !armv6"

function depends_lr-flycast() {
    local depends=()
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    getDepends "${depends[@]}"
}

function _update_hook_lr-flycast() {
    renameModule "lr-reicast" "lr-beetle-dc"
    renameModule "lr-beetle-dc" "lr-flycast"
}

function sources_lr-flycast() {
    gitPullOrClone "$md_build" https://github.com/libretro/flycast.git
    # don't override our C/CXXFLAGS and set LDFLAGS to CFLAGS to avoid warnings on linking
    applyPatch "$md_data/01_flags_fix.diff"
}

function build_lr-flycast() {
    local params=("HAVE_LTCG=0")
    make clean
    if isPlatform "rpi"; then
        if isPlatform "rpi4"; then
            params+=("platform=rpi4")
        elif isPlatform "mesa"; then
            params+=("platform=rpi-mesa")
        else
            params+=("platform=rpi")
        fi
    fi
    # temporarily disable distcc due to segfaults with cross compiler and lto
    DISTCC_HOSTS="" make "${params[@]}" -j`nproc`
    md_ret_require="$md_build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=(
        'flycast_libretro.so'
        'LICENSE'
    )
}

function configure_lr-flycast() {
    mkUserDir "$biosdir/dc"

    local system
    for system in dreamcast naomi naomigd atomiswave; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"

        # system-specific
        if isPlatform "gl"; then
            iniConfig " = " "" "$configdir/$system/retroarch.cfg"
            iniSet "video_shared_context" "true"
        fi

        local def=0
        isPlatform "kms" && def=1
        # segfaults on the rpi without redirecting stdin from </dev/null
        addEmulator $def "$md_id" "$system" "$md_inst/flycast_libretro.so </dev/null"
        addSystem "$system"
    done
}
