#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mame-tools"
rp_module_desc="Additional tools for MAME/MESS"
rp_module_help="Main tools:\nCastool, CHDMAN, Floptool, Imgtool, ROMcmp\n\nOther tools:\nJedutil, LDresample, LDverify, PNGcmp, Regrep, Split, Srcclean, Testkeys, Unidasm."
rp_module_licence="GPL2 https://raw.githubusercontent.com/mamedev/mame/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function depends_mame-tools() {
    if compareVersions $__gcc_version lt 5.0.0; then
        md_ret_errors+=("Sorry, you need an OS with gcc 5.0 or newer to compile mame-tools")
        return 1
    fi
}

function sources_mame-tools() {
    gitPullOrClone "$md_build" https://github.com/mamedev/mame.git
}

function build_mame-tools() {
    rpSwap on 2000
    local params=(SOURCES=./src/mame/drivers/pacman.cpp SUBTARGET=pacman TOOLS=1 REGENIE=1)
    isPlatform "64bit" && params+=(PTR64=1)
    make clean
    make -j`nproc` "${params[@]}"
    rpSwap off
}

function install_mame-tools() {
    md_ret_files=(
        'castool'
	'chdman'
	'floptool'
	'imgtool'
	'jedutil'
	'ldresample'
	'ldverify'
	'pngcmp'
	'regrep'
	'romcmp'
	'split'
	'srcclean'
	'testkeys'
	'unidasm'
        'COPYING'
  	'docs/man'
    )
}

function batch_convert_castool_mame-tools() {
    d="$1"
    local sys="$2"
    local m="ERROR: Input invalid !!!"
    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
        for j in *.*; do
	    > castool.rp
	    $md_inst/castool convert $sys "$j" "${j%.*}.wav"
        done
        chown $user:$user *".wav"

	if [[ -f "castool.rp" ]]; then
	    rm -rf castool.rp
	    m="Files successfully converted."
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function convert_castool_mame-tools(){
    local f="$1"
    local sys="$2"
    local m="ERROR: Input invalid !!!"
    if [ -f "$f" ]; then
        $md_inst/castool convert $sys "$FILE" "${FILE%.*}.wav"
        cd && cd `dirname "$FILE"`
        if [[ -f "${FILE%.*}.wav" ]]; then
            m="File successfully converted."
        else
	    m="ERROR: Invalid input file."
        fi
        chown $user:$user "${FILE%.*}.wav"
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function __aux_castool_mame-tools(){
    local format="$1"
    local system="$2"
    export IFS='
'
    __DIR=$(dialog --stdout --title "Castool - Choose a ROM Directory" --dselect "$romdir/" 10 70)
    [ ! -z $__DIR ] && batch_convert_castool_mame-tools "$__DIR" "$system"
}

function _aux_castool_mame-tools() {
    local format="$1"
    local system="$2"
    export IFS='
'
    FILE=$(dialog --stdout --title "Castool - ROM supported ($format)" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && convert_castool_mame-tools "$FILE" "$system"
}

function aux_castool_mame-tools(){
    local cmd_1="$1"
    local cmd_2="$2"
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Castool - Choose a option" 22 76 16)
        local options=(
            1 "single conversion"
            2 "batch conversion"
	)
	
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		1)
		    _aux_castool_mame-tools "$cmd_1" "$cmd_2"
		    ;;
		2)
	            __aux_castool_mame-tools "$cmd_1" "$cmd_2"
		    ;;
            esac
        else
            break
        fi
    done
}

function castool_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Castool - Choose a system" 22 76 16)
        local options=(
            S "see manual"
            1 "a26 - Atari 2600 SuperCharger"
            2 "apf - APF Imagination Machine"
	    3 "atom - Acorn Atom"
	    4 "bbc - Acorn BBC & Electron"
	    5 "cbm - Commodore 8-bit series"
	    6 "cdt - Amstrad CPC"
	    7 "cgenie - EACA Colour Genie"
	    8 "coco - Tandy Radio Shack Color Computer"
	    9 "csw - Compressed Square Wave"
	    10 "ddp - Coleco ADAM"
	    11 "fm7 - Fujitsu FM-7"
	    12 "fmsx - MSX"
	    13 "gtp - Elektronika inzenjering Galaksija"
	    14 "hector - Micronique Hector & Interact Family Computer"
	    15 "jupiter - Jupiter Cantab Jupiter Ace"
	    16 "kc85 - VEB Mikroelektronik KC 85"
	    17 "kim1 - MOS KIM-1"
	    18 "lviv - PK-01 Lviv"
	    19 "mo5 - Thomson MO-series"
	    20 "mz - Sharp MZ-700"
	    21 "orao - PEL Varazdin Orao"
	    22 "oric - Tangerine Oric"
	    23 "pc6001 - NEC PC-6001"
            24 "phc25 - Sanyo PHC-25"
            25 "pmd85 - Tesla PMD-85"
            26 "primo - Microkey Primo"
            27 "rku - UT-88"
            28 "rk8 - Mikro-80"
            29 "rks - Specialist"
            30 "rko - Orion"
            31 "rkr - Radio-86RK"
            32 "rka - Zavod BRA Apogee BK-01"
            33 "rkm - Mikrosha"
            34 "rkp - SAM SKB VM Partner-01.01"
            35 "sc3000 - Sega SC-3000"
            36 "sol20 - PTC SOL-20"
            37 "sorcerer - Exidy Sorcerer"
            38 "sordm5 - Sord M5"
            39 "spc1000 - Samsung SPC-1000"
            40 "svi - Spectravideo SVI-318 & SVI-328"
            41 "to7 - Thomson TO-series"
            42 "trs80l2 - TRS-80 Level 2"
            43 "tvc64 - Videoton TVC 64"
            44 "tzx - Sinclair ZX Spectrum"
            45 "vg5k - Philips VG 5000"
            46 "vtech1 - Video Technology Laser 110-310"
            47 "vtech2 - Video Technology Laser 350-700"
            48 "x07 - Canon X-07"
            49 "x1 - Sharp X1"
            50 "zx80_o - Sinclair ZX80"
            51 "zx81_p - Sinclair ZX81"
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/castool.1" > man.txt
 		    dialog --stdout --title "CASTOOL - MANUAL" --clear --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                1)
                    aux_castool_mame-tools 'a26 (supercharger)' 'a26'
                    ;;
                2)
                    aux_castool_mame-tools 'cas|cpf|apt' 'apf'
                    ;;
                3)
                    aux_castool_mame-tools 'tap|csw|uef' 'atom'
                    ;;
                4)
                    aux_castool_mame-tools 'csw|uef' 'bbc'
                    ;;
                5)
                    aux_castool_mame-tools 'tap' 'cbm'
                    ;;
                6)
                    aux_castool_mame-tools 'cdt' 'cdt'
                    ;;
                7)
                    aux_castool_mame-tools 'cas' 'cgenie'
                    ;;
                8)
                    aux_castool_mame-tools 'cas' 'coco'
                    ;;
                9)
                    aux_castool_mame-tools 'csw' 'csw'
                    ;;
                10)
                    aux_castool_mame-tools 'ddp' 'ddp'
                    ;;
                11)
                    aux_castool_mame-tools 't77' 'fm7'
                    ;;
                12)
                    aux_castool_mame-tools 'tap|cas' 'fmsx'
                    ;;
                13)
                    aux_castool_mame-tools 'gtp' 'gtp'
                    ;;
                14)
                    aux_castool_mame-tools 'k7|cin|for' 'hector'
                    ;;
                15)
                    aux_castool_mame-tools 'tap' 'jupiter'
                    ;;
                16)
                    aux_castool_mame-tools 'kcc|kcb|tap|853|854|855|tp2|kcm|sss' 'kc85'
                    ;;
                17)
                    aux_castool_mame-tools 'kim|kim1' 'kim'
                    ;;
                18)
                    aux_castool_mame-tools 'lvt|lvr|lv0|lv1|lv2|lv3' 'lviv'
                    ;;
                19)
                    aux_castool_mame-tools 'k5|k7' 'mo5'
                    ;;
                20)
                    aux_castool_mame-tools 'm12|mzf|mzt' 'mz'
                    ;;
                21)
                    aux_castool_mame-tools 'tap' 'orao'
                    ;;
                22)
                    aux_castool_mame-tools 'tap' 'oric'
                    ;;
                23)
                    aux_castool_mame-tools 'cas' 'pc6001'
                    ;;
                24)
                    aux_castool_mame-tools 'phc' 'phc25'
                    ;;
                25)
                    aux_castool_mame-tools 'pmd|tap|ptp' 'pmd85'
                    ;;
                26)
                    aux_castool_mame-tools 'ptp' 'primo'
                    ;;
                27)
                    aux_castool_mame-tools 'rku' 'rku'
                    ;;
                28)
                    aux_castool_mame-tools 'rk8' 'rk8'
                    ;;
                29)
                    aux_castool_mame-tools 'rks' 'rks'
                    ;;
                30)
                    aux_castool_mame-tools 'rko' 'rko'
                    ;;
                31)
                    aux_castool_mame-tools 'rk|rkr' 'rkr'
                    ;;
                32)
                    aux_castool_mame-tools 'rka' 'rka'
                    ;;
                33)
                    aux_castool_mame-tools 'rkm' 'rkm'
                    ;;
                34)
                    aux_castool_mame-tools 'rkp' 'rkp'
                    ;;
                35)
                    aux_castool_mame-tools 'bit' 'sc3000'
                    ;;
                36)
                    aux_castool_mame-tools 'svt' 'sol20'
                    ;;
                37)
                    aux_castool_mame-tools 'tape' 'sorcerer'
                    ;;
                38)
                    aux_castool_mame-tools 'cas' 'sordm5'
                    ;;
                39)
                    aux_castool_mame-tools 'tap|cas' 'spc1000'
                    ;;
                40)
                    aux_castool_mame-tools 'cas' 'svi'
                    ;;
                41)
                    aux_castool_mame-tools 'k7' 'to7'
                    ;;
                42)
                    aux_castool_mame-tools 'cas' 'trs80l2'
                    ;;
                43)
                    aux_castool_mame-tools 'cas' 'tvc64'
                    ;;
                44)
                    aux_castool_mame-tools 'tzx|tap|blk' 'tzx'
                    ;;
                45)
                    aux_castool_mame-tools 'k7' 'vg5k'
                    ;;
                46)
                    aux_castool_mame-tools 'cas' 'vtech1'
                    ;;
                47)
                    aux_castool_mame-tools 'cas' 'vtech2'
                    ;;
                48)
                    aux_castool_mame-tools 'k7|lst|cas' 'x07'
                    ;;
                49)
                    aux_castool_mame-tools 'tap' 'x1'
                    ;;
                50)
                    aux_castool_mame-tools 'o|80' 'zx80_o'
                    ;;
                51)
                    aux_castool_mame-tools 'p|81' 'zx81_p'
                    ;;
            esac
        else
            break
        fi
    done
}

function listtemplates_chdman_mame-tools(){
    $md_inst/chdman listtemplates > "list_template.txt"
    dialog --stdout --title "List Hard Disk Templates" --clear --textbox list_template.txt 0 0 
    rm -rf "list_template.txt"
}

function dumpmeta_chdman_mame-tools(){
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: $input isn't a CHD file"
    
    local output="none"
    local __output="$output"
    local force="0"
    local tag="none"
    local index="auto"

    if [[ "${input}" = *.chd ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\nOutput file: $__output\n\nOptional parameters (Warning: tag is required):" 22 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(O "Output: ${output##*/}")
            if [[ "$force" -eq 1 ]]; then
            	options+=(F "Overwrite existing files (Enabled)")
            else
            	options+=(F "Overwrite existing files (Disabled)")
            fi
            options+=(1 "tag: $tag")
            options+=(2 "Index ($index)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the 4-character tag for metadata:" 10 60 "$tag")
                    	tag=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the indexed instance of this metadata tag:" 10 60 "$index")
                    	index=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    O)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    	output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output" = "default" ]] || [[ -z "$output" ]]; then
			    __output="none"
			    output="$__output"
			elif  [[ "${output}" = */* ]]; then
			    __output="$output"
			    output="${__output##*/}"
                    	else
                            __output="`dirname $f`/$output"
			    output="${__output##*/}"
                    	fi
                    	;;
                    F)
                    	force="$((force ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	local params=()
    	if [[ -n "$output" ]] && [[ "$output" != "none" ]]; then
            params+=(-o "$__output")
    	fi
    	if [[ "$force" -eq 1 ]]; then
            params+=(-f)
    	fi
    	if [[ -n "$tag" ]] && [[ "$tag" != "none" ]]; then
            params+=(-t "$tag")
    	fi
    	if [[ -n "$index" ]] && [[ "$index" != "auto" ]]; then
            params+=(-ix "$index")
    	fi

        clear
        $md_inst/chdman dumpmeta -i "$f" ${params[@]} > "${f%.*}_info.dumpmeta" 2> "${f%.*}.dumpmeta"
	if [ `awk 'NR == 1{print $1}' ${f%.*}.dumpmeta` = "Error" ]; then
	    m=`sed 's/([^>]*)/'$input'/g' ${f%.*}.dumpmeta`	    	
        elif [ `awk 'NR == 1{print $1}' ${f%.*}.dumpmeta` = "Error:" ]; then
	    m=`cat ${f%.*}.dumpmeta`	
	else
	    sed '1d' ${f%.*}_info.dumpmeta > "${f%.*}-info.dumpmeta"
	    n=`sed 's/([^>]*)/'$input'/g' ${f%.*}-info.dumpmeta`
	    dialog --stdout --clear --msgbox "$n" 8 53
	    if [[ -f $__output ]]; then
		m="Metadata dumped for $input"
		dialog --stdout --defaultno --yesno "Would you like to save the ${__output##*/} file?" 8 50
            	if [[ $? = 0 ]]; then
	            chown $user:$user "$__output"
		    dialog --stdout --msgbox "${__output##*/} has been saved!" 10 50
            	else
		    rm -rf "$__output"
            	fi	
	    else
		m="Metadata dumped for $input (no 'output' parameters)"	
	    fi
        fi
	rm -rf "${f%.*}.dumpmeta" rm -rf "${f%.*}_info.dumpmeta" "${f%.*}-info.dumpmeta"
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}


function delmeta_chdman_mame-tools(){
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: $input isn't a CHD file"

    local tag="none"
    local index="auto"

    if [[ "${input}" = *.chd ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\n\nOptional parameters (Warning: tag is required)" 22 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(1 "tag: $tag")
            options+=(2 "Index ($index)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the 4-character tag for metadata:" 10 60 "$tag")
                    	tag=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the indexed instance of this metadata tag:" 10 60 "$index")
                    	index=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	local params=()
    	if [[ -n "$tag" ]] && [[ "$tag" != "none" ]]; then
            params+=(-t "$tag")
    	fi
    	if [[ -n "$index" ]] && [[ "$index" != "auto" ]]; then
            params+=(-ix "$index")
    	fi

        clear
        $md_inst/chdman delmeta -i "$f" ${params[@]} 2> "${f%.*}.delmeta"
	if [ `awk 'NR == 1{print $1}' ${f%.*}.delmeta` = "Error" ]; then
	    m=`sed 's/([^>]*)/'$input'/g' ${f%.*}.delmeta`	    	
        elif [ `awk 'NR == 1{print $1}' ${f%.*}.delmeta` = "Error:" ]; then
	    m=`cat ${f%.*}.delmeta`	
	else
	    m="Metadata deleted for $input"
        fi
	rm -rf "${f%.*}.delmeta"
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 10 50

    clear
    return 1
}


function addmeta_chdman_mame-tools(){
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: $input isn't a CHD file"

    local tag="none"
    local index="auto"
    local value_text="none"
    local value_file="none"
    local __value_file="$value_file"
    local no_checksum="0"

    if [[ "${input}" = *.chd ]]; then
	local default
	while true
	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\nMetadata value file: $__value_file\nMetadata value text: $value_text\n\nOptional parameters (Warning: tag is required)" 22 76 16)
            local options=()

	    options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(1 "Metadata value file: ${value_file##*/}")
            options+=(2 "Metadata value text: $value_text")
            options+=(3 "tag: $tag")
            options+=(4 "Index ($index)")
            if [[ "$no_checksum" -eq 1 ]]; then
            	options+=(5 "Don't include in SHA-1 check-sum (Enabled)")
            else
            	options+=(5 "Don't include in SHA-1 check-sum (Disabled)")
            fi

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file containing data to add:" 10 60 "$value_file")
                    	value_file=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$value_file" = "none" ]] || [[ -z "$value_file" ]]; then
                            __value_file="none"
			    value_file="$__value_file"
			elif  [[ "${value_file}" = */* ]]; then
			    __value_file="$value_file"
                    	else
                            __value_file="`dirname $f`/$value_file"
                    	fi
                    	;;

                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the text for the metadata:" 10 60 "$value_text")
                    	value_text=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    3)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the 4-character tag for metadata:" 10 60 "$tag")
                    	tag=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    4)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the indexed instance of this metadata tag:" 10 60 "$index")
                    	index=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    5)
                    	no_checksum="$((no_checksum ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	local params=()
    	if [[ -n "$value_file" ]] && [[ "$value_file" != "none" ]]; then
            params+=(-vf "$__value_file")
    	fi
    	if [[ -n "$value_text" ]] && [[ "$value_text" != "none" ]]; then
            params+=(-vt "$value_text")
    	fi
    	if [[ -n "$tag" ]] && [[ "$tag" != "none" ]]; then
            params+=(-t "$tag")
    	fi
    	if [[ -n "$index" ]] && [[ "$index" != "auto" ]]; then
            params+=(-ix "$index")
    	fi
    	if [[ "$no_checksum" -eq 1 ]]; then
            params+=(-nocs)
    	fi
   
        clear
        $md_inst/chdman addmeta -i "$f" ${params[@]} 2> "${f%.*}.addmeta"
	if [ `awk 'NR == 1{print $1}' ${f%.*}.addmeta` = "Error" ]; then
	    m=`sed 's/([^>]*)/'$input'/g' ${f%.*}.addmeta`	    	
        elif [ `awk 'NR == 1{print $1}' ${f%.*}.addmeta` = "Error:" ]; then
	    m=`cat ${f%.*}.addmeta`	
	else
	    m="Metadata added for $input"
        fi
	rm -rf "${f%.*}.addmeta"
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 10 50

    clear
    return 1
}

function copy_chdman_mame-tools(){
    local f="$1"
    local f_2="$2"
    local f_3="$3"
    local input="${f##*/}"
    local m="ERROR: $input isn't a CHD file"

    local output="${f%.*} (copy).chd"
    local __output="$output"
    local input_parent="none"
    local __input_parent="$input_parent"
    local output_parent="none"
    local __output_parent="$output_parent"
    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"
    local hunk_size="auto"
    local compression="0"
    local num_processors="`nproc`"

    if [[ "${input}" = *.chd ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\nOutput file: $__output\nParent input file: $__input_parent\nParent output file: $__output_parent\n\nOptional parameters:" 25 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(O "Output file: ${output##*/}")
            options+=(Y "Parent input file: ${input_parent##*/}")
            options+=(X "Parent output file: ${output_parent##*/}")
            if [[ "$force" -eq 1 ]]; then
            	options+=(F "Overwrite existing files (Enabled)")
            else
            	options+=(F "Overwrite existing files (Disabled)")
            fi
            options+=(1 "Input start byte ($input_start_byte)")
            options+=(2 "Input start hunk ($input_start_hunk)")
            options+=(3 "Input bytes ($input_bytes)")
            options+=(4 "Input hunks ($input_hunks)")
            options+=(5 "Hunk size ($hunk_size)")
            if [[ "$compression" -eq 0 ]]; then
            	compr="default"
            	options+=(6 "Compression: $compr")
            elif [[ "$compression" -eq 1 ]]; then
            	compr="none"
            	options+=(6 "Compression: $compr")
            elif [[ "$compression" -eq 2 ]]; then
            	compr="avhu"
            	options+=(6 "Compression: $compr (A/V Huffman)")
            elif [[ "$compression" -eq 3 ]]; then
            	compr="cdfl"
            	options+=(6 "Compression: $compr (CD FLAC)")
            elif [[ "$compression" -eq 4 ]]; then
            	compr="cdlz"
            	options+=(6 "Compression: $compr (CD LZMA)")
            elif [[ "$compression" -eq 5 ]]; then
            	compr="cdzl"
            	options+=(6 "Compression: $compr (CD Deflate)")
            elif [[ "$compression" -eq 6 ]]; then
            	compr="flac"
            	options+=(6 "Compression: $compr (FLAC)")
            elif [[ "$compression" -eq 7 ]]; then
            	compr="huff"
            	options+=(6 "Compression: $compr (Huffman)")
            elif [[ "$compression" -eq 8 ]]; then
            	compr="lzma"
            	options+=(6 "Compression: $compr (LZMA)")
            elif [[ "$compression" -eq 9 ]]; then
            	compr="zlib"
            	options+=(6 "Compression: $compr (Deflate)")
            fi
            options+=(7 "Number of CPUs ($num_processors)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    	input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    	input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    3)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    	input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    4)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    	input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    5)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    	hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    6)
                    	compression="$((( compression + 1 ) % 10))"
                    	;;
                    7)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    	num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    O)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    	output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output" = "${f%.*} (copy).chd" ]] || [[ -z "$output" ]]; then
                            __output="${f%.*} (copy).chd"
			    output="$__output"
			elif  [[ "${output}" = */* ]]; then
			    __output="$output"
                    	else
                            __output="`dirname $f`/$output"
                    	fi
                    	;;
                    Y)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for input CHD:" 10 60 "$input_parent")
                    	input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$input_parent" = "none" ]] || [[ -z "$input_parent" ]]; then
                            __input_parent="none"
			    input_parent="$__input_parent"
			elif  [[ "${input_parent}" = */* ]]; then
			    __input_parent="$input_parent"
                    	else
                            __input_parent="`dirname $f`/$input_parent"
                    	fi
                    	;;
                    X)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$output_parent")
                    	output_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output_parent" = "none" ]] || [[ -z "$output_parent" ]]; then
                            __output_parent="none"
			    output_parent="$__output_parent"
			elif  [[ "${output_parent}" = */* ]]; then
			    __output_parent="$output_parent"
                    	else
                            __output_parent="`dirname $f`/$output_parent"
                    	fi
                    	;;
                    F)
                    	force="$((force ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	local params=()
    	if [[ "$force" -eq 1 ]]; then
	    params+=(-f)
    	fi
    	if [[ -n "$output" ]]; then
            params+=(-o "$__output")
    	fi
    	if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$__input_parent")
    	fi
    	if [[ -n "$output_parent" ]] && [[ "$output_parent" != "none" ]]; then
            params+=(-op "$__output_parent")
    	fi
    	if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
    	fi
    	if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
    	fi
    	if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
    	fi
    	if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
    	fi
    	if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
    	fi
    	if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
    	fi
    	if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
    	fi

	clear
        echo $'Copying file ...\n'
        $md_inst/chdman copy -i "$f" ${params[@]}
	chown $user:$user "$__output"
        if [[ -f "$__output" ]]; then
            m="Copy completed. ${__output##*/} have been created."
        else
	    m="ERROR: Copy Failed."
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_extractld_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local input_start_frame="auto"
    local input_frames="auto"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.chd (zip|7z)\nOutput dir: ${d%/}/*.avi\n\nOptional parameters" 22 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start frame ($input_start_frame)")
        options+=(2 "Input frames ($input_frames)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting frame within the input:" 10 60 "$input_start_frame")
                    input_start_frame=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_start_frame" "$input_start_frame"
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in frames:" 10 60 "$input_frames")
                    input_frames=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_frames" "$input_frames"
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_frame" ]] && [[ "$input_start_frame" != "auto" ]]; then
            params+=(-isf "$input_start_frame")
        fi
        if [[ -n "$input_frames" ]] && [[ "$input_frames" != "auto" ]]; then
            params+=(-if "$input_frames")
	fi

	extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman extracthd -i "$j" -o "${j%.*}.avi" ${params[@]}
 	        chown $user:$user *".avi"
	    done    	  
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`

	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete CHD files and keep only AVI files?" 8 50
            if [[ $? = 0 ]]; then
	        if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
	        rm -rf $extensions
	        dialog --stdout --msgbox "CHDs files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="CHDs to AVI LaserDiscs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
        
    clear
    return 1
}

function extractld_chdman_mame-tools(){
    local f="$1" 
    local __f="$f"
    local input="${f##*/}"
    local m="ERROR: $input isn't a CHD file"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
 	if [[ "$f" = *.[zZ][iI][pP] ]]; then
	    aux_input=`zipinfo -1 $f *.chd`
 	elif [[ "$f" = *.7[zZ] ]]; then
	    7z l -ba $f *.chd -r- > out.txt 
	    out=`cat out.txt | awk '{s=""; for (i=6; i<=NF; i++) s = s $i " "; print s}'`
	    rm -rf "out.txt"
	    aux_input="$out"
	fi

	if [[ -z $aux_input ]]; then
	    m="ERROR: $input haven't a compressed CHD file" 
	fi
	input="$input#$aux_input"
	__f="$__f#$aux_input"
    fi
    local DIR=`dirname $f`

    local output="${f%.*}.avi"
    local __output="$output"
    local input_parent="none"
    local __input_parent="$input_parent"
    local force="0"
    local input_start_frame="auto"
    local input_frames="auto"

    if [[ ! -z $aux_input ]] || [[ "${input}" = *.[cC][hH][dD] ]]; then
	local default
	while true
	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $__f\nOutput file: $__output\nParent input file: $__input_parent\n\nOptional parameters:" 22 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(O "Output file: ${output##*/}")
            options+=(Y "Parent input file: ${input_parent##*/}")
            if [[ "$force" -eq 1 ]]; then
		options+=(F "Overwrite existing files (Enabled)")
            else
		options+=(F "Overwrite existing files (Disabled)")
            fi
            options+=(1 "Input start frame ($input_start_frame)")
            options+=(2 "Input frames ($input_frames)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
		default="$choice"
		case "$choice" in
                    1)
			cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting frame within the input:" 10 60 "$input_start_frame")
                    	input_start_frame=$("${cmd[@]}" 2>&1 >/dev/tty)   
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in frames:" 10 60 "$input_frames")
                    	input_frames=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    O)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output AVI:" 10 60 "$output")
                    	output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output" = "${f%.*}.avi" ]] || [[ -z "$output" ]]; then
                            __output="${f%.*}.avi"
			    output="$__output"
			elif  [[ "${output}" = */* ]]; then
			    __output="$output"
                    	else
                            __output="$DIR/$output"
                    	fi
                    	;;
                    Y)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for input CHD:" 10 60 "$input_parent")
                    	input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$input_parent" = "none" ]] || [[ -z "$input_parent" ]]; then
                            __input_parent="none"
			    input_parent="$__input_parent"
			elif  [[ "${input_parent}" = */* ]]; then
			    __input_parent="$input_parent"
                    	else
                            __input_parent="$DIR/$input_parent"
                    	fi
                    	;;
                    F)
                    	force="$((force ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

        clear
	cd && cd "$DIR"
	if [[ -n `find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
	if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	    enter="$DIR/$aux_input"
	    params+=(-i "$enter")
	else
	    params+=(-i "$f")
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$__input_parent")
        fi
        if [[ -n "$input_start_frame" ]] && [[ "$input_start_frame" != "auto" ]]; then
            params+=(-isf "$input_start_frame")
        fi
        if [[ -n "$input_frames" ]] && [[ "$input_frames" != "auto" ]]; then
            params+=(-if "$input_frames")
	fi

	echo $'Converting files ...\n'
	$md_inst/chdman extractld ${params[@]}
	chown $user:$user "$__output" 
	if [[ -f "$__input_parent" ]]; then
	    chown $user:$user "$__input_parent"
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$input to ${__output##*/} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}?" 10 50
	    else
		m="$input to ${__output##*/} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
                if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	            rm -rf "$enter" && rm -rf "$f"
		    dialog --stdout --msgbox "$input have been deleted!" 10 50
	        else
	            rm -rf "$f"
		    dialog --stdout --msgbox "$input has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed."
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_extractcd_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local form="0"
    local exts="cue"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.chd (zip|7z)\nOutput dir: ${d%/}/*.$exts\nBinary output dir: ${d%/}/*.bin|raw\n\nOptional parameters" 22 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
	if [[ "$form" -eq 0 ]]; then
	    ext="cue"
	    exts="gdi"
            options+=(E "Output extension ($ext)")
        elif [[ "$form" -eq 1 ]]; then
	    ext="gdi"
	    exts="toc"
            options+=(E "Output extension ($ext)")
        else
	    ext="toc"
	    exts="cue"
            options+=(E "Output extension ($ext)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                E)
                    form="$((( form + 1) % 3))"
                    ;;
                F)
                    force="$((force ^ 1))"
		    exts=$ext
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *
	
	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi

	extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman extractcd -i "$j" -o "${j%.*}.$ext" -ob "${j%.*}.bin" ${params[@]}
 	        chown $user:$user *".$ext" *.bin
            if [[ "$ext" = "gdi" ]]; then
		chown $user:$user *.raw
		r="/raw"
	    else
		r=""
	    fi
	    done    	  
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`

	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete CHD files and keep only *.$ext/bin${r} files?" 8 50
            if [[ $? = 0 ]]; then
	        if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
	        rm -rf $extensions
	        dialog --stdout --msgbox "CHDs files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="CHDs to CDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function extractcd_chdman_mame-tools(){
    local f="$1"
    local f_bn_ext="${f##*/}"
    local f_bn="${f_bn_ext%.*}"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
	if [[ "$f" = *.[zZ][iI][pP] ]]; then
	    aux_input=`zipinfo -1 $f *.chd`
	elif [[ "$f" = *.7[zZ] ]]; then
	    7z l -ba $f *.chd -r- > out.txt 
	    out=`cat out.txt | awk '{s=""; for (i=6; i<=NF; i++) s = s $i " "; print s}'`
	    rm -rf "out.txt"
	    aux_input="$out"
	fi
	input="$f_bn_ext#$aux_input"
    else 
	input="$f_bn_ext"
    fi
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local form="0"
    local exts="cue"

    local output="default"
    local binary="default"
    local __binary="${f%.*}.bin"
    local input_parent="none"
    local force="0"

    local default
    while true
    do
	if [[ "$output" = "default" ]]; then
            __output="${f%.*}.$exts"
        else
            __output="$output.$exts"
        fi

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $input\nOutput file: ${__output##*/}\nBinary output file: ${__binary##*/}\nParent input file: $input_parent\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(X "Output file: $output")
        options+=(Y "Binary Output file: $binary")
        options+=(I "Parent input file: $input_parent")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
	if [[ "$form" -eq 0 ]]; then
	    ext="cue"
	    exts="gdi"
            options+=(E "Output extension ($ext)")
        elif [[ "$form" -eq 1 ]]; then
	    ext="gdi"
	    exts="toc"
            options+=(E "Output extension ($ext)")
        else
	    ext="toc"
	    exts="cue"
            options+=(E "Output extension ($ext)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                E)
                    form="$((( form + 1) % 3))"
                    ;;
                I)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for input CHD:" 10 60 "$input_parent")
                    input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
		    exts=$ext
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output $ext:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        __output="${f%.*}.$exts"
                    else
                        __output="$output"
                    fi
		    exts=$ext
                    ;;
                Y)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output binary:" 10 60 "$binary")
                    binary=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$binary" = "default" ]]; then
                        __binary="${f%.*}.bin"
                    else
                        __binary="$binary"
                    fi
		    exts=$ext
                    ;;
                F)
                    force="$((force ^ 1))"
		    exts=$ext
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
            echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$binary" ]]; then
            params+=(-ob "$__binary")  
	    b="/bin"
        fi
        if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$input_parent")
        fi

	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'` ]]; then
	    echo $'Converting files ...\n'
	    _ext="chd"
	    $md_inst/chdman extractcd -i "${f%.*}.$_ext" ${params[@]}
 	    chown $user:$user "$__output" "${__binary%.*}"*bin 
            if [[ "$ext" = "gdi" ]]; then
		chown $user:$user "${f%.*}"*raw
		r="/raw"
	    else
		r=""
	    fi
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$input to ${__output##*/}${b}${r} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}${b}${r}?" 10 50
	    else
		m="$f_bn_ext to ${__output##*/}${b}${r} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext and keep only ${__output##*/}${b}${r}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
                if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	            rm -rf "${f%.*}.chd" && rm -rf "$f"
		    dialog --stdout --msgbox "$input have been deleted!" 10 50
	        else
	            rm -rf "$f"
		    dialog --stdout --msgbox "$f_bn_ext has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_extracthd_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.chd (zip|7z)\nOutput dir: ${d%/}/*.img\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input byte ($input_bytes)")
        options+=(4 "Input hunk ($input_hunks)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi

	extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman extracthd -i "$j" -o "${j%.*}.img" ${params[@]}
 	        chown $user:$user *".img"
	    done    	  
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`

	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete CHD files and keep only HD files?" 8 50
            if [[ $? = 0 ]]; then
	        if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
	        rm -rf $extensions
	        dialog --stdout --msgbox "CHDs files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="CHDs to HDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
        
    clear
    return 1
}

function extracthd_chdman_mame-tools(){
    local f="$1"
    local f_bn_ext="${f##*/}"
    local f_bn="${f_bn_ext%.*}"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
	if [[ "$f" = *.[zZ][iI][pP] ]]; then
	    aux_input=`zipinfo -1 $f *.chd`
	elif [[ "$f" = *.7[zZ] ]]; then
	    7z l -ba $f *.chd -r- > out.txt 
	    out=`cat out.txt | awk '{s=""; for (i=6; i<=NF; i++) s = s $i " "; print s}'`
	    rm -rf "out.txt"
	    aux_input="$out"
	fi
	input="$f_bn_ext#$aux_input"
    else 
	input="$f_bn_ext"
    fi
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local output="default"
    local __output="${f%.*}.img"
    local input_parent="none"
    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $input\nOutput file: ${__output##*/}\nParent input file: $input_parent\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(X "Output file: $output")
        options+=(I "Parent input file: $input_parent")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input byte ($input_bytes)")
        options+=(4 "Input hunk ($input_hunks)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output RAW:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        __output="${f%.*}.img"
                    else
                        __output="$output"
                    fi
                    ;;
                I)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$input_parent")
                    input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$input_parent")
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi

	if [[ -n `find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'` ]]; then
	    echo $'Converting files ...\n'
	    ext="chd"
	    $md_inst/chdman extracthd -i "${f%.*}.$ext" ${params[@]}
 	    chown $user:$user "$__output" 
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$input to ${__output##*/} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}?" 10 50
	    else
		m="$f_bn_ext to ${__output##*/} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext and keep only ${__output##*/}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
                if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	            rm -rf "${f%.*}.chd" && rm -rf "$f"
		    dialog --stdout --msgbox "$input have been deleted!" 10 50
	        else
	            rm -rf "$f"
		    dialog --stdout --msgbox "$f_bn_ext has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_extractraw_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.chd (zip|7z)\nOutput dir: ${d%/}/*.raw\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input bytes ($input_bytes)")
        options+=(4 "Input hunks ($input_hunks)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi

	extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman extractraw -i "$j" -o "${j%.*}.raw" ${params[@]}
 	        chown $user:$user *".raw"
	    done    	  
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`
        
	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete CHD files and keep only RAW files?" 8 50
            if [[ $? = 0 ]]; then
	        if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
	        rm -rf $extensions
	        dialog --stdout --msgbox "CHDs files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="CHDs to RAWs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function extractraw_chdman_mame-tools(){
    local f="$1"
    local f_bn_ext="${f##*/}"
    local f_bn="${f_bn_ext%.*}"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
	if [[ "$f" = *.[zZ][iI][pP] ]]; then
	    aux_input=`zipinfo -1 $f *.chd`
	elif [[ "$f" = *.7[zZ] ]]; then
	    7z l -ba $f *.chd -r- > out.txt 
	    out=`cat out.txt | awk '{s=""; for (i=6; i<=NF; i++) s = s $i " "; print s}'`
	    rm -rf "out.txt"
	    aux_input="$out"
	fi
	input="$f_bn_ext#$aux_input"
    else 
	input="$f_bn_ext"
    fi
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local output="default"
    local __output="${f%.*}.raw"
    local input_parent="none"
    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $input\nOutput file: ${__output##*/}\nParent input file: $input_parent\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(X "Output file: $output")
	options+=(I "Parent input file: $input_parent")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input bytes ($input_bytes)")
        options+=(4 "Input hunks ($input_hunks)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output RAW:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        __output="${f%.*}.raw"
                    else
                        __output="$output"
                    fi
                    ;;
                I)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for input CHD:" 10 60 "$input_parent")
                    input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$input_parent")
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi

	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.chd'` ]]; then
	    echo $'Converting files ...\n'
	    ext="chd"
	    $md_inst/chdman extractraw -i "${f%.*}.$ext" ${params[@]}
 	    chown $user:$user "$__output"    
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$input to ${__output##*/} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}?" 10 50
	    else
		m="$f_bn_ext to ${__output##*/} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext and keep only ${__output##*/}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
                if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	            rm -rf "${f%.*}.chd" && rm -rf "$f"
		    dialog --stdout --msgbox "$input have been deleted!" 10 50
	        else
	            rm -rf "$f"
		    dialog --stdout --msgbox "$f_bn_ext has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}


function batch_createld_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local input_start_frame="auto"
    local input_frames="auto"
    local hunk_size="auto"
    local compression="0"
    local num_processors="`nproc`"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.avi (zip|7z)\nOutput dir: ${d%/}/*.chd\n\nOptional parameters:" 25 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start frame ($input_start_frame)")
        options+=(2 "Input frames ($input_frames)")
        options+=(3 "Hunk size ($hunk_size)")
        if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(4 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(4 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(4 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(4 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(4 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(4 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(4 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(4 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(4 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(4 "Compression: $compr (Deflate)")
        fi
        options+=(5 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting frame within the input:" 10 60 "$input_start_frame")
                    input_start_frame=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_start_frame" "$input_start_frame"
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in frames:" 10 60 "$input_frames")
                    input_frames=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_frames" "$input_frames"
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    compression="$((( compression + 1) % 10))"
                    ;;
                5)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_frame" ]] && [[ "$input_start_frame" != "auto" ]]; then
            params+=(-isf "$input_start_frame")
        fi
        if [[ -n "$input_frames" ]] && [[ "$input_frames" != "auto" ]]; then
            params+=(-if "$input_frames")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi
	
	extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.avi'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman createld -i "$j" -o "${j%.*}.chd" ${params[@]}
 	        chown $user:$user *".chd"
	    done    	  
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`

	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete all original files in this directory and keep only CHD files?" 8 50
            if [[ $? = 0 ]]; then
                if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
		rm -rf $extensions
	        dialog --stdout --msgbox "All original files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="LaserDiscs to CHDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function createld_chdman_mame-tools(){
    local f="$1"
    local f_bn_ext="${f##*/}"
    local f_bn="${f_bn_ext%.*}"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
	input="$f_bn_ext#$f_bn.avi"
    else 
	input="$f_bn_ext"
    fi
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local output="default"
    local __output="${f%.*}.chd"
    local output_parent="none"
    local force="0"
    local input_start_frame="auto"
    local input_frames="auto"
    local hunk_size="auto"
    local compression="0"
    local num_processors="`nproc`"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $input\nOutput file: ${__output##*/}\nParent output file: $output_parent\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(X "Output file: $output")
        options+=(O "Parent output file: $output_parent")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start frame ($input_start_frame)")
        options+=(2 "Input frames ($input_frames)")
        options+=(3 "Hunk size ($hunk_size)")
        if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(4 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(4 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(4 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(4 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(4 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(4 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(4 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(4 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(4 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(4 "Compression: $compr (Deflate)")
        fi
        options+=(5 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting frame within the input:" 10 60 "$input_start_frame")
                    input_start_frame=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_start_frame" "$input_start_frame"
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in frames:" 10 60 "$input_frames")
                    input_frames=$("${cmd[@]}" 2>&1 >/dev/tty)
                    iniSet "input_frames" "$input_frames"
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    compression="$((( compression + 1 ) % 10))"
                    ;;
                5)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        __output="${f%.*}.chd"
                    else
                        __output="$output"
                    fi
                    ;;
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$output_parent")
                    output_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$output_parent" ]] && [[ "$output_parent" != "none" ]]; then
            params+=(-op "$output_parent")
        fi
        if [[ -n "$input_start_frame" ]] && [[ "$input_start_frame" != "auto" ]]; then
            params+=(-isf "$input_start_frame")
        fi
        if [[ -n "$input_frames" ]] && [[ "$input_frames" != "auto" ]]; then
            params+=(-if "$input_frames")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi

	if [[ -n `find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.avi'` ]]; then
	    echo $'Converting files ...\n'
	    ext="avi"
	    $md_inst/chdman createld -i "${f%.*}.$ext" ${params[@]}
 	    chown $user:$user "$__output" 
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$f_bn_ext#$f_bn.$ext to ${__output##*/} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext#$f_bn.$ext and keep only ${__output##*/}?" 10 50
	    else
		m="$f_bn_ext to ${__output##*/} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext and keep only ${__output##*/}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
                if [[ "${x}" = *.[zZ][iI][pP] ]] || [[ "${x}" = *.7[zZ] ]]; then
	            rm -rf "${f%.*}.avi" && rm -rf "$x"
		    dialog --stdout --msgbox "$f_bn_ext#$f_bn.$ext have been deleted!" 10 50
	        else
	            rm -rf "${f%.*}.avi"
		    dialog --stdout --msgbox "$f_bn_ext has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_createcd_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local hunk_size="auto"
    local compression="0"
    local num_processors=`nproc`

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.toc|cue|gdi (zip|7z)\nOutput dir: ${d%/}/*.chd\n\nOptional parameters:" 25 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Hunk size ($hunk_size)")
        if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(2 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(2 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(2 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(2 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(2 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(2 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(2 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(2 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(2 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(2 "Compression: $compr (Deflate)")
        fi
        options+=(3 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    compression="$((( compression + 1) % 10))"
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *
	
	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi

        extensions=`find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.(gdi|cue|toc)'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
            for j in $extensions; do
      	        $md_inst/chdman createcd -i "$j" -o "${j%.*}.chd" ${params[@]}
 	        chown $user:$user *".chd"
	    done     
	fi
	ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`
        
	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete all original files in this directory keeping only CHD files?" 8 50
            if [[ $? = 0 ]]; then
                if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
		rm -rf $extensions && rm -rf *.{bin,raw,BIN,RAW}
	        dialog --stdout --msgbox "All original files have been deleted!" 8 50
            fi
	    rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="CDs to CHDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function createcd_chdman_mame-tools(){
    local f="$1"
    local f_bn_ext="${f##*/}"
    local f_bn="${f_bn_ext%.*}"
    if [[ "$f" = *.[zZ][iI][pP] ]] || [[ "$f" = *.7[zZ] ]]; then
	input="$f_bn_ext#$f_bn.{cue|gdi|toc}"
    else 
	input="$f_bn_ext"
    fi
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local output="default"
    local __output="${f%.*}.chd"
    local output_parent="none"
    local force="0"
    local hunk_size="auto"
    local compression="0"
    local num_processors="`nproc`"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $input\nOutput file: ${__output##*/}\nParent output file: $output_parent\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(X "Output file: $output")
        options+=(O "Parent output file: $output_parent")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Hunk size ($hunk_size)")
        if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(2 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(2 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(2 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(2 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(2 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(2 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(2 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(2 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(2 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(2 "Compression: $compr (Deflate)")
        fi
        options+=(3 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    compression="$((( compression + 1) % 10))"
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        __output="${f%.*}.chd"
                    else
                        __output="$output"
                    fi
                    ;;
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$output_parent")
                    output_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
            echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$output_parent" ]] && [[ "$output_parent" != "none" ]]; then
            params+=(-op "$output_parent")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi

	if [[ -n `find . -maxdepth 1 -regextype posix-egrep -iregex '.*\.(gdi|cue|toc)'` ]]; then
	    echo $'Converting file ...\n'
	    if [[ -f "${f%.*}.gdi" ]]; then
	        ext="gdi"
	    elif [[ -f "${f%.*}.cue" ]]; then
	        ext="cue"
	    elif [[ -f "${f%.*}.toc" ]]; then
	        ext="toc"
	    fi
      	    $md_inst/chdman createcd -i "${f%.*}.$ext" ${params[@]}
 	    chown $user:$user "$__output"     
	fi

	if [[ -f "$__output" ]]; then
	    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		m="$f_bn_ext#$f_bn.$ext to ${__output##*/} successfully converted."
                dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext#$f_bn.$ext and keep only ${__output##*/}?" 10 50
	    else
		m="$f_bn_ext to ${__output##*/} successfully converted."
		dialog --stdout --defaultno --yesno "Would you like to delete $f_bn_ext and keep only ${__output##*/}?" 10 50
	    fi
            if [[ $? = 0 ]]; then
		if [ -f "${f%.*}"*.raw ]; then
		    rm -rf "${f%.*}"*.raw
		fi
                if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	            rm -rf "${f%.*}.$ext" && rm -rf "${f%.*}"*.bin && rm -rf "$f"
		    dialog --stdout --msgbox "$f_bn_ext#$f_bn.$ext have been deleted!" 10 50
	        else
	            rm -rf "$f" && rm -rf "${f%.*}"*.bin
		    dialog --stdout --msgbox "$f_bn_ext has been deleted!" 10 50
	        fi
            fi
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_createhd_chdman_mame-tools() {
    d="$1"
    local m="ERROR: Input invalid !!!"

    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"
    local hunk_size="auto"
    local template="5"
    local ident="none"
    local c="auto" # cyls (CHS)
    local h="auto" # heads (CHS)
    local s="auto" # sectors (CHS)
    local chs="$c,$h,$s"
    local size="auto"
    local sector_size="auto"
    local compression="0"
    local num_processors=`nproc`

    local default
    while true
    do

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.*\nOutput dir: ${d%/}/*.chd\nIdent File: $ident\n\nOptional parameters:" 25 76 16)
        local options=()

        options+=(- "Exit")
        options+=(I "Ident File: $ident")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input byte ($input_bytes)")
        options+=(4 "Input hunk ($input_hunks)")
        options+=(5 "Hunk size ($hunk_size)")
	if [[ "$template" -eq 0 ]]; then
            templ="Conner CFA170A"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 1 ]]; then
            templ="Rodime R0201"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 2 ]]; then
            templ="Rodime R0202"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 3 ]]; then
            templ="Rodime R0203"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 4 ]]; then
            templ="Rodime R0204"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 5 ]]; then
	    templ="none"
            options+=(6 "Template: $templ")
        fi
        options+=(7 "Cyls ($c) heads ($h) sectors ($s)")
        options+=(8 "Size ($size)")
        options+=(9 "Sector size ($sector_size)")
	if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(10 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(10 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(10 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(10 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(10 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(10 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(10 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(10 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(10 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(10 "Compression: $compr (Deflate)")
        fi
        options+=(11 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                5)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                6)
                    template="$((( template + 1) % 6))"
                    ;;
                7)
                    cmd_1=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Cylinders values directly:" 10 60 "$c")
                    c=$("${cmd_1[@]}" 2>&1 >/dev/tty)

   		    cmd_2=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Heads values directly:" 10 60 "$h")
                    h=$("${cmd_2[@]}" 2>&1 >/dev/tty)

		    cmd_3=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Sectors values directly:" 10 60 "$s")
                    s=$("${cmd_3[@]}" 2>&1 >/dev/tty)
                
		    if [[ -n $c ]] && [[ $c != "auto" ]]; then
			if [[ -z $h ]] || [[ $h = "auto" ]]; then
			    h="1"
			fi 
                        if [[ -z $s ]] || [[ $s = "auto" ]]; then
			    s="1"
			fi
                    fi
		    if [[ -n $h ]] && [[ $h != "auto" ]]; then
			if [[ -z $c ]] || [[ $c = "auto" ]]; then
			    c="1"
			fi 
                        if [[ -z $s ]] || [[ $s = "auto" ]]; then
			    s="1"
			fi
                    fi
		    if [[ -n $s ]] && [[ $s != "auto" ]]; then
			if [[ -z $c ]] || [[ $c = "auto" ]]; then
			    c="1"
			fi 
                        if [[ -z $h ]] || [[ $h = "auto" ]]; then
			    h="1"
			fi
                    fi

                    chs="$c,$h,$s"
                    ;;
                8)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of the output file in bytes:" 10 60 "$size")
                    size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                9)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hard disk sector in bytes:" 10 60 "$sector_size")
                    sector_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                10)
                    compression="$((( compression + 1) % 10))"
                    ;;
                11)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                I)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the name of ident file to provide CHS information:" 10 60 "$ident")
                    ident=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
	if [[ -n $(find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)') ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in *.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in *.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$template" -ne 5 ]]; then
            params+=(-tp "$template")
        fi
        if [[ -n "$ident" ]] && [[ "$ident" != "none" ]]; then
            params+=(-id "$ident")
        fi
        if [[ "$chs" != ",," ]] && [[ "$chs" != "auto,auto,auto" ]]; then
            params+=(-chs "$chs")
        fi
        if [[ -n "$size" ]] && [[ "$size" != "auto" ]]; then
            params+=(-s "$size")
        fi
        if [[ -n "$sector_size" ]] && [[ "$sector_size" != "auto" ]]; then
            params+=(-ss "$sector_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi
	
        extensions=`find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(dmg|img|2mg|h0|h1|h2|h3|h4|hdd|hdf|hds)'`
	if [[ -n $extensions ]]; then
            ls -1 > "$HOME/dir_1.txt"
	    echo $'Converting files ...\n'
	    for j in $extensions; do
      	        $md_inst/chdman createhd -i "$j" -o "${j%.*}.chd" ${params[@]}
 	        chown $user:$user *".chd"
	    done   
	fi
        ls -1 > "$HOME/dir_2.txt"
	DIFF=`diff "$HOME/dir_1.txt" "$HOME/dir_2.txt"`

	if [[ "$DIFF" != "" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete all original files in this directory and keep only CHD files?" 8 50
            if [[ $? = 0 ]]; then
	        if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; 			then
		    rm -rf *.[zZ][iI][pP]; rm -rf *.7[zZ]
	        fi
	        rm -rf $extensions
	        dialog --stdout --msgbox "All original files have been deleted!" 8 50
            fi
            rm -rf "$HOME/dir_1.txt" "$HOME/dir_2.txt"
	    m="HDs to CHDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function createhd_chdman_mame-tools(){
    local f="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local output="default"
    if [[ -z "$f" ]]; then
        local input="default"
        local __input="none"
	local __output="$romdir/blank.chd"
    else
        local __input="$f"
	local __output="${f%.*}.chd"
    fi
    local __input_bn_ext="${__input##*/}"
    local __input_bn="${__input_bn_ext%.*}"

    local output_parent="none"
    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"
    local hunk_size="auto"
    local template="5"
    local ident="none"
    if [[ -z "$f" ]]; then
        local c="none" # cyls (CHS)
        local h="none" # heads (CHS)
        local s="none" # sectors (CHS)
    else
        local c="auto" # cyls (CHS)
        local h="auto" # heads (CHS)
        local s="auto" # sectors (CHS)
    fi
    local chs="$c,$h,$s"
    local size="auto"
    local sector_size="auto"
    local compression="0"
    local num_processors=`nproc`

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $__input_bn_ext\nOutput file: ${__output##*/}\nParent output file: $output_parent\nIdent File: $ident\n\nOptional parameters (Warning: CHS is required):" 28 76 16)
        local options=()

        options+=(- "Exit")
        if [[ -z "$f" ]]; then
            options+=(Y "Input file: $input")
        fi   
        options+=(X "Output file: $output")
        options+=(O "Parent output file: $output_parent")
        options+=(I "Ident File: $ident")
        if [[ "$force" -eq 1 ]]; then
            options+=(F "Overwrite existing files (Enabled)")
        else
            options+=(F "Overwrite existing files (Disabled)")
        fi
        options+=(1 "Input start byte ($input_start_byte)")
        options+=(2 "Input start hunk ($input_start_hunk)")
        options+=(3 "Input byte ($input_bytes)")
        options+=(4 "Input hunk ($input_hunks)")
        options+=(5 "Hunk size ($hunk_size)")
	if [[ "$template" -eq 0 ]]; then
            templ="Conner CFA170A"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 1 ]]; then
            templ="Rodime R0201"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 2 ]]; then
            templ="Rodime R0202"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 3 ]]; then
            templ="Rodime R0203"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 4 ]]; then
            templ="Rodime R0204"
            options+=(6 "Template: $templ")
        elif [[ "$template" -eq 5 ]]; then
	    templ="none"
            options+=(6 "Template: $templ")
        fi
        options+=(7 "Cyls ($c) Heads ($h) Sectors ($s)")
        options+=(8 "Size ($size)")
        options+=(9 "Sector size ($sector_size)")
	if [[ "$compression" -eq 0 ]]; then
            compr="default"
            options+=(10 "Compression: $compr")
        elif [[ "$compression" -eq 1 ]]; then
            compr="none"
            options+=(10 "Compression: $compr")
        elif [[ "$compression" -eq 2 ]]; then
            compr="avhu"
            options+=(10 "Compression: $compr (A/V Huffman)")
        elif [[ "$compression" -eq 3 ]]; then
            compr="cdfl"
            options+=(10 "Compression: $compr (CD FLAC)")
        elif [[ "$compression" -eq 4 ]]; then
            compr="cdlz"
            options+=(10 "Compression: $compr (CD LZMA)")
        elif [[ "$compression" -eq 5 ]]; then
            compr="cdzl"
            options+=(10 "Compression: $compr (CD Deflate)")
        elif [[ "$compression" -eq 6 ]]; then
            compr="flac"
            options+=(10 "Compression: $compr (FLAC)")
        elif [[ "$compression" -eq 7 ]]; then
            compr="huff"
            options+=(10 "Compression: $compr (Huffman)")
        elif [[ "$compression" -eq 8 ]]; then
            compr="lzma"
            options+=(10 "Compression: $compr (LZMA)")
        elif [[ "$compression" -eq 9 ]]; then
            compr="zlib"
            options+=(10 "Compression: $compr (Deflate)")
        fi
        options+=(11 "Number of CPUs ($num_processors)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                4)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                5)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                6)
                    template="$((( template + 1) % 6))"
                    ;;
                7)
                    cmd_1=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Cylinders values directly:" 10 60 "$c")
                    c=$("${cmd_1[@]}" 2>&1 >/dev/tty)

   		    cmd_2=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Heads values directly:" 10 60 "$h")
                    h=$("${cmd_2[@]}" 2>&1 >/dev/tty)

		    cmd_3=(dialog --backtitle "$__backtitle" --inputbox "Please type the specifies Sectors values directly:" 10 60 "$s")
                    s=$("${cmd_3[@]}" 2>&1 >/dev/tty)
                
		    if [[ -n $c ]] && [[ $c != "auto" ]]; then
			if [[ -z $h ]] || [[ $h = "auto" ]]; then
			    h="1"
			fi 
                        if [[ -z $s ]] || [[ $s = "auto" ]]; then
			    s="1"
			fi
                    fi
		    if [[ -n $h ]] && [[ $h != "auto" ]]; then
			if [[ -z $c ]] || [[ $c = "auto" ]]; then
			    c="1"
			fi 
                        if [[ -z $s ]] || [[ $s = "auto" ]]; then
			    s="1"
			fi
                    fi
		    if [[ -n $s ]] && [[ $s != "auto" ]]; then
			if [[ -z $c ]] || [[ $c = "auto" ]]; then
			    c="1"
			fi 
                        if [[ -z $h ]] || [[ $h = "auto" ]]; then
			    h="1"
			fi
                    fi

                    chs="$c,$h,$s"
                    ;;
                8)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of the output file in bytes:" 10 60 "$size")
                    size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                9)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hard disk sector in bytes:" 10 60 "$sector_size")
                    sector_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                10)
                    compression="$((( compression + 1) % 10))"
                    ;;
                11)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                I)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the name of ident file to provide CHS information:" 10 60 "$ident")
                    ident=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                Y)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for input CHD:" 10 60 "$input")
                    input=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$input" = "default" ]]; then
                        __input="none"
                    else
                        __input="$input"
                    fi
                    ;;
                X)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output" = "default" ]]; then
                        if [[ -z "$f" ]]; then
			    __output="$romdir/blank.chd"
		        else
                            __output="${f%.*}.chd"
			fi
                    else
                        __output="$output"
                    fi
                    ;;
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$output_parent")
                    output_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                F)
                    force="$((force ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ] || [ -z "$f" ]; then
        clear
	cd && cd "$DIR"
	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.(zip|7z)'` ]]; then
	    echo $'Extracting files ...\nThis may take several minutes ...\n'
	    for i in ${f%.*}.[zZ][iI][pP]; do 
		unzip "$i"
	    done 2>/dev/null >/dev/null
 	    for i in ${f%.*}.7[zZ]; do 
		7z e "$i"
	    done 2>/dev/null >/dev/null
	fi
        chown $user:$user *

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -z "$f" ]]; then
            if [[ -n "$input" ]] && [[ "$input" != "default" ]]; then
                params+=(-i "$__input")
            fi
        fi
        if [[ -n "$output" ]]; then
            params+=(-o "$__output")
        fi
        if [[ -n "$output_parent" ]] && [[ "$output_parent" != "none" ]]; then
            params+=(-op "$output_parent")
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "auto" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ "$template" -lt 5 ]]; then
            params+=(-tp "$template")
        fi
        if [[ -n "$ident" ]] && [[ "$ident" != "none" ]]; then
            params+=(-id "$ident")
        fi
        if [[ "$chs" != ",," ]] && [[ "$chs" != "auto,auto,auto" ]]; then
            params+=(-chs "$chs")
        fi
        if [[ -n "$size" ]] && [[ "$size" != "auto" ]]; then
            params+=(-s "$size")
        fi
        if [[ -n "$sector_size" ]] && [[ "$sector_size" != "auto" ]]; then
            params+=(-ss "$sector_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi

	if [[ -n `find -maxdepth 1 -regextype posix-egrep -iregex '.*\.*'` ]]; then
	    echo $'Converting file ...\n'
	    # raw disk image (*.img)
	    if [[ -f "${f%.*}.img" ]]; then 
	        ext="img"
	    # Mac disk image (*.dmg)
	    elif [[ -f "${f%.*}.dmg" ]]; then 
	        ext="dmg"
	    # Apple IIgs disk image (*.2mg)
	    elif [[ -f "${f%.*}.2mg" ]]; then  
	        ext="2mg"
	    # FM-Towns disk image (*.h[0,1,2,3,4])
	    elif [[ -f "${f%.*}.h0" ]]; then
	        ext="h0"
	    elif [[ -f "${f%.*}.h1" ]]; then
	        ext="h1"
	    elif [[ -f "${f%.*}.h2" ]]; then
	        ext="h2"
	    elif [[ -f "${f%.*}.h3" ]]; then
	        ext="h3"
	    elif [[ -f "${f%.*}.h4" ]]; then
	        ext="h4"
	    # IDE64 disk image (*.hdd)
	    elif [[ -f "${f%.*}.hdd" ]]; then
	        ext="hdd"
	    # X68k SASI disk image (*.hdf)
	    elif [[ -f "${f%.*}.hdf" ]]; then
	        ext="hdf"
	    # X68k SCSI disk image (*.hds)
	    elif [[ -f "${f%.*}.hds" ]]; then
	        ext="hds"
	    fi
            if [[ -z "$f" ]]; then
		$md_inst/chdman createhd ${params[@]}
	    else
	        $md_inst/chdman createhd -i "${f%.*}.$ext" ${params[@]}
	    fi
 	    chown $user:$user "$__output"  
	fi

	if [[ -f "$__output" ]]; then
            if [[ -n "$f" ]]; then
		if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
		    m="$__input_bn_ext#$__input_bn.$ext to ${__output##*/} successfully converted."
                    dialog --stdout --defaultno --yesno "Would you like to delete $__input_bn_ext#$__input_bn.$ext and keep only ${__output##*/}?" 8 50
		else
	  	    m="$__input_bn_ext to ${__output##*/} successfully converted."
		    dialog --stdout --defaultno --yesno "Would you like to delete $__input_bn_ext and keep only ${__output##*/}?" 8 50
		fi
                if [[ $? = 0 ]]; then
                    if [[ "${f}" = *.[zZ][iI][pP] ]] || [[ "${f}" = *.7[zZ] ]]; then
	                rm -rf "${f%.*}".{dmg,img,2mg,hdd,h0,h1,h2,h3,h4,hdf,hds} && rm -rf "$f"
	                dialog --stdout --msgbox "$__input_bn_ext#$__input_bn.$ext have been deleted!" 10 50
	            else
	                rm -rf "$f"
	                dialog --stdout --msgbox "$__input_bn_ext has been deleted!" 12 50
	            fi
                fi
	    else
		m="${__output##*/} successfully created."
	    fi  
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function batch_createraw_chdman_mame-tools() {
    d="$1"
    local m="ERROR: There aren't valid extensions in ${d%/} directory."

    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"
    local hunk_size="required"
    local unit_size="required"
    local compression="0"
    local num_processors=`nproc`

    if [[ -n `find $d -mindepth 1 -prune -name '*.*'` ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input dir: ${d%/}/*.*\nOutput dir: ${d%/}/*.chd\n\nOptional parameters\n(Warning: Hunk size and Unit size are required):" 25 76 16)
            local options=()

            options+=(- "Exit")
            if [[ "$force" -eq 1 ]]; then
            	options+=(F "Overwrite existing files (Enabled)")
            else
            	options+=(F "Overwrite existing files (Disabled)")
            fi
            options+=(1 "Input start byte ($input_start_byte)")
            options+=(2 "Input start hunk ($input_start_hunk)")
            options+=(3 "Input bytes ($input_bytes)")
            options+=(4 "Input hunks ($input_hunks)")
            options+=(5 "Hunk size ($hunk_size)")
            options+=(6 "Unit size ($unit_size)")
	    if [[ "$compression" -eq 0 ]]; then
            	compr="default"
            	options+=(7 "Compression: $compr")
            elif [[ "$compression" -eq 1 ]]; then
            	compr="none"
            	options+=(7 "Compression: $compr")
            elif [[ "$compression" -eq 2 ]]; then
            	compr="avhu"
            	options+=(7 "Compression: $compr (A/V Huffman)")
            elif [[ "$compression" -eq 3 ]]; then
            	compr="cdfl"
            	options+=(7 "Compression: $compr (CD FLAC)")
            elif [[ "$compression" -eq 4 ]]; then
            	compr="cdlz"
            	options+=(7 "Compression: $compr (CD LZMA)")
            elif [[ "$compression" -eq 5 ]]; then
            	compr="cdzl"
            	options+=(7 "Compression: $compr (CD Deflate)")
            elif [[ "$compression" -eq 6 ]]; then
            	compr="flac"
            	options+=(7 "Compression: $compr (FLAC)")
            elif [[ "$compression" -eq 7 ]]; then
            	compr="huff"
            	options+=(7 "Compression: $compr (Huffman)")
            elif [[ "$compression" -eq 8 ]]; then
            	compr="lzma"
            	options+=(7 "Compression: $compr (LZMA)")
            elif [[ "$compression" -eq 9 ]]; then
            	compr="zlib"
            	options+=(7 "Compression: $compr (Deflate)")
            fi
            options+=(8 "Number of CPUs ($num_processors)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    	input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    	input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    3)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    	input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    4)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    	input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    5)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    	hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    6)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each unit, in bytes:" 10 60 "$unit_size")
                    	unit_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    7)
		    	compression="$((( compression + 1) % 10))"
                    	;;
                    8)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    	num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    F)
                    	force="$((force ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

        clear
	cd && cd "$d"
	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi
        if [[ -n "$hunk_size" ]]; then
            params+=(-hs "$hunk_size")
        fi
        if [[ -n "$unit_size" ]]; then
            params+=(-us "$unit_size")
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi
	
	echo $'Converting files ...\n'
	for j in `find $d -mindepth 1 -prune -name '*.*'`; do
	    if [[ "$j" = *.chd ]]; then
		$md_inst/chdman createraw -i "$j" -o "${j%.*} (1).chd" ${params[@]}
		chown $user:$user "${j%.*} (1).chd"
	    else
		$md_inst/chdman createraw -i "$j" -o "${j%.*}.chd" ${params[@]}
		chown $user:$user "${j%.*}.chd"
	    fi
	    if [[ -f "${j%.*} (1).chd" ]] || [[ -f "${j%.*}.chd" ]]; then
		echo $j >> "$HOME/list.txt"
	    fi
	done  	  
        
	if [[ -e "list.txt" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete 'all' files in this directory, keeping only CHD files?" 8 50
            if [[ $? = 0 ]]; then
		xargs -i rm -f {} < "$HOME/list.txt"
	        dialog --stdout --msgbox "All original files have been deleted!" 8 50
            fi
            rm -rf "$HOME/list.txt"
	    m="All files to CHDs successfully converted."
	else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 10 50

    clear
    return 1
}

function createraw_chdman_mame-tools(){
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: Invalid extension to $input"

    local output="${f%.*}.chd"
    local __output="$output"
    local output_parent="none"
    local __output_parent="$output_parent"
    local force="0"
    local input_start_byte="auto"
    local input_start_hunk="auto"
    local input_bytes="auto"
    local input_hunks="auto"
    local hunk_size="required"
    local unit_size="required"
    local compression="0"
    local num_processors=`nproc`

    if [[ "${input}" = *.* ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\nOutput file: $__output\nParent output file: $__output_parent\n\nOptional parameters\n(Warning: Hunk size and Unit size are required):" 25 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(O "Output file: ${output##*/}")
            options+=(X "Parent output file: ${output_parent##*/}")
            if [[ "$force" -eq 1 ]]; then
            	options+=(F "Overwrite existing files (Enabled)")
            else
            	options+=(F "Overwrite existing files (Disabled)")
            fi
            options+=(1 "Input start byte ($input_start_byte)")
            options+=(2 "Input start hunk ($input_start_hunk)")
            options+=(3 "Input bytes ($input_bytes)")
            options+=(4 "Input hunks ($input_hunks)")
            options+=(5 "Hunk size ($hunk_size)")
            options+=(6 "Unit size ($unit_size)")
	    if [[ "$compression" -eq 0 ]]; then
            	compr="default"
            	options+=(7 "Compression: $compr")
            elif [[ "$compression" -eq 1 ]]; then
            	compr="none"
            	options+=(7 "Compression: $compr")
            elif [[ "$compression" -eq 2 ]]; then
            	compr="avhu"
            	options+=(7 "Compression: $compr (A/V Huffman)")
            elif [[ "$compression" -eq 3 ]]; then
            	compr="cdfl"
            	options+=(7 "Compression: $compr (CD FLAC)")
            elif [[ "$compression" -eq 4 ]]; then
            	compr="cdlz"
            	options+=(7 "Compression: $compr (CD LZMA)")
            elif [[ "$compression" -eq 5 ]]; then
            	compr="cdzl"
            	options+=(7 "Compression: $compr (CD Deflate)")
            elif [[ "$compression" -eq 6 ]]; then
            	compr="flac"
            	options+=(7 "Compression: $compr (FLAC)")
            elif [[ "$compression" -eq 7 ]]; then
            	compr="huff"
            	options+=(7 "Compression: $compr (Huffman)")
            elif [[ "$compression" -eq 8 ]]; then
            	compr="lzma"
            	options+=(7 "Compression: $compr (LZMA)")
            elif [[ "$compression" -eq 9 ]]; then
            	compr="zlib"
            	options+=(7 "Compression: $compr (Deflate)")
            fi
            options+=(8 "Number of CPUs ($num_processors)")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    1)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting byte offset within the input:" 10 60 "$input_start_byte")
                    	input_start_byte=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    2)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the starting hunk offset within the input:" 10 60 "$input_start_hunk")
                    	input_start_hunk=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    3)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in bytes:" 10 60 "$input_bytes")
                    	input_bytes=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    4)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the effective length of input in hunks:" 10 60 "$input_hunks")
                    	input_hunks=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    5)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each hunk, in bytes:" 10 60 "$hunk_size")
                    	hunk_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    6)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the size of each unit, in bytes:" 10 60 "$unit_size")
                    	unit_size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    7)
		    	compression="$((( compression + 1) % 10))"
                    	;;
                    8)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the number of processors to use during compression:" 10 60 "$num_processors")
                    	num_processors=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	;;
                    F)
                    	force="$((force ^ 1))"
                    	;;
                    O)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the file name for output CHD:" 10 60 "$output")
                    	output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output" = "${f%.*}.chd" ]] || [[ -z "$output" ]]; then
                            __output="${f%.*}.chd"
			    output="$__output"
			elif  [[ "${output}" = */* ]]; then
			    __output="$output"
                    	else
                            __output="`dirname $f`/$output"
                    	fi
                    	;;
                    X)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for output CHD:" 10 60 "$output_parent")
                    	output_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$output_parent" = "none" ]] || [[ -z "$output_parent" ]]; then
                            __output_parent="none"
			    output_parent="$__output_parent"
			elif  [[ "${output_parent}" = */* ]]; then
			    __output_parent="$output_parent"
                    	else
                            __output_parent="`dirname $f`/$output_parent"
                    	fi
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

	local params=()
        if [[ "$force" -eq 1 ]]; then
            params+=(-f)
        fi
        if [[ -n "$output" ]]; then
	    if [[ "$__output" = "$f" ]]; then
	        __output="${f%.*} (1).chd"
	    fi
            params+=(-o "$__output")
        fi
        if [[ -n "$output_parent" ]] && [[ "$output_parent" != "none" ]]; then
            params+=(-op "$__output_parent")
        fi
        if [[ -n "$input_start_byte" ]] && [[ "$input_start_byte" != "auto" ]]; then
            params+=(-isb "$input_start_byte")
        fi
        if [[ -n "$input_start_hunk" ]] && [[ "$input_start_hunk" != "auto" ]]; then
            params+=(-ish "$input_start_hunk")
        fi
        if [[ -n "$input_bytes" ]] && [[ "$input_bytes" != "auto" ]]; then
            params+=(-ib "$input_bytes")
        fi
        if [[ -n "$input_hunks" ]] && [[ "$input_hunks" != "auto" ]]; then
            params+=(-ih "$input_hunks")
        fi
        if [[ -n "$hunk_size" ]] && [[ "$hunk_size" != "none" ]]; then
            params+=(-hs "$hunk_size")
	else
	    dialog --stdout --msgbox "Required Parameters missing (Hunk size)" 10 50
        fi
        if [[ -n "$unit_size" ]] && [[ "$unit_size" != "none" ]]; then
            params+=(-us "$unit_size")
	else
	    dialog --stdout --msgbox "Required Parameters missing (Unit size)" 10 50
        fi
        if [[ "$compression" -ne 0 ]]; then
            params+=(-c "$compr")        
        fi
        if [[ -n "$num_processors" ]]; then
            params+=(-np "$num_processors")
        fi

	clear
	echo $'Converting file ...\n'
	$md_inst/chdman createraw -i "$f" ${params[@]}
	chown $user:$user "$__output"   
	if [[ -f "$__output_parent" ]]; then
	    chown $user:$user "$__output_parent"
	fi

	if [[ -f "$__output" ]]; then
            dialog --stdout --defaultno --yesno "Would you like to delete $input and keep only ${__output##*/}?" 8 50
            if [[ $? = 0 ]]; then
                rm -rf "$f"
	        dialog --stdout --msgbox "$input has been deleted!" 10 50
            fi
            m="$input to ${__output##*/} successfully converted."
        else
	    m="ERROR: Conversion Failed !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function verify_chdman_mame-tools(){
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: Invalid extension to $input"

    local input_parent="none"
    local __input_parent="$input_parent"

    if [[ "${input}" = *.chd ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\nParent input file: $__input_parent\n\nOptional parameters:" 22 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            options+=(Y "Parent input file: ${input_parent##*/}")

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    Y)
                    	cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the parent file name for input CHD:" 10 60 "$input_parent")
                    	input_parent=$("${cmd[@]}" 2>&1 >/dev/tty)
                    	if [[ "$input_parent" = "none" ]] || [[ -z "$input_parent" ]]; then
                            __input_parent="none"
			    input_parent="$__input_parent"
			elif  [[ "${input_parent}" = */* ]]; then
			    __input_parent="$input_parent"
                    	else
                            __input_parent="`dirname $f`/$input_parent"
                    	fi
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	if [[ -n "$input_parent" ]] && [[ "$input_parent" != "none" ]]; then
            params+=(-ip "$__input_parent")
    	fi

	clear
	echo "File: $f"
	$md_inst/chdman verify -i "$f" ${params[@]} > "${f%.*}._verify"
	awk '/SHA1/ {print}' ${f%.*}._verify > "${f%.*}.verify" 
	rm -rf "${f%.*}._verify"
	dialog --stdout --clear --textbox ${f%.*}.verify 10 52 
	rm -rf "${f%.*}.verify"
	m="Verification completed for $input"
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function info_chdman_mame-tools(){
    local info
    local f="$1"
    local input="${f##*/}"
    local m="ERROR: Invalid extension to $input"

    local verbose="0"

    if [[ "${input}" = *.chd ]]; then
    	local default
    	while true
    	do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Input file: $f\n\nOptional parameters:" 22 76 16)
            local options=()

            options+=(- "Exit")
            options+=(I "Input file: $input")
            if [[ "$verbose" -eq 1 ]]; then
            	options+=(V "Verbose output (Enabled)")
            else
            	options+=(V "Verbose output (Disabled)")
            fi

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
            	default="$choice"
            	case "$choice" in
                    V)
                    	verbose="$((verbose ^ 1))"
                    	;;
		    -)
		    	return 0
		    	;;
            	esac
            else
            	break
            fi
    	done

    	if [[ "$verbose" -eq 1 ]]; then
            params+=(-v)
    	fi

	clear
	$md_inst/chdman info -i "$f" ${params[@]} > "${f%.*}.info"
	dialog --stdout --title "$f" --clear --textbox ${f%.*}.info 0 0 
	dialog --stdout --defaultno --yesno "Would you like to save ${input%.*}.info?" 8 50
	if [[ $? = 0 ]]; then
            chown $user:$user "${f%.*}.info"
	    dialog --stdout --msgbox "${input%.*}.info have been saved!" 10 50
	else
	    rm -rf "${f%.*}.info"
	fi
	m="Information completed for $input"
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50

    clear
    return 1
}

function __aux_chdman_mame-tools(){
    local opt="$1"
    local format="$2"
    local manager=`$md_inst/chdman | awk '/manager/' | awk '{print $10}'`
    local ver="v$manager"
    export IFS='
'
    __DIR=$(dialog --stdout --title "CHDMAN $ver: ${opt^} - Choose a ROM Directory" --dselect "$romdir/" 10 70)
    [ ! -z $__DIR ] && batch_"$opt"_chdman_mame-tools "$__DIR"
}

function _aux_chdman_mame-tools(){
    local cmd_1="$1"
    local cmd_2="$2"
    local default
    local manager=`$md_inst/chdman | awk '/manager/' | awk '{print $10}'`
    local ver="v$manager"
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --title "CHDMAN $ver: ${cmd_1^}" --menu "CHDMAN $ver - Choose a option" 22 76 16)
        local options=(
            1 "single conversion"
            2 "batch conversion"
	)
	
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		1)
		    aux_chdman_mame-tools "$cmd_1" "$cmd_2"
		    ;;
		2)
	            __aux_chdman_mame-tools "$cmd_1" "$cmd_2"
		    ;;
            esac
        else
            break
        fi
    done
}

function aux_chdman_mame-tools() {
    local opt="$1"
    local format="$2"
    local manager=`$md_inst/chdman | awk '/manager/' | awk '{print $10}'`
    local ver="v$manager"

    export IFS='
'

    if [[ "$opt" = "createhd" ]]; then
	FILE=$(dialog --stdout --cancel-label "No input" --extra-button --extra-label "Back" --title "CHDMAN $ver: ${opt^} - ROM supported ($format)" --fselect "$romdir/" 13 105)
    
        [ -z $FILE ] || [ -f "$FILE" ] && "$opt"_chdman_mame-tools "$FILE"
    else
        FILE=$(dialog --stdout --title "CHDMAN $ver: ${opt^} - ROM supported ($format)" --fselect "$romdir/" 13 105)
    
        [ ! -z $FILE ] && [ -f "$FILE" ] && "$opt"_chdman_mame-tools "$FILE"
    fi
}

function chdman_mame-tools() {
    if [[ ! -d $configdir/all/chdman.cfg ]]; then
        mkdir -p "$configdir/all/chdman.cfg"
	chown $user:$user "$configdir/all/chdman.cfg"
    fi
    local default
    while true; do
	local manager=`$md_inst/chdman | awk '/manager/' | awk '{print $10}'`
	local ver="v$manager"
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "CHDMAN $ver (CHD v5) - Choose a option" 22 76 16)
        local options=(
            S "see manual"
            1 "info - displays information about a CHD"
            2 "verify - verifies a CHD's integrity"
            3 "createraw - create a raw CHD from the input file"
	    4 "createhd - create a hard disk CHD from the input file"
	    5 "createcd - create a CD CHD from the input file"
	    6 "createld - create a laserdisc CHD from the input file"
	    7 "extractraw - extract raw file from a CHD input file"
	    8 "extracthd - extract raw hard disk file from a CHD input file"
	    9 "extractcd - extract CD file from a CHD input file"
	    10 "extractld - extract laserdisc AVI from a CHD input file"
	    11 "copy - copy data from one CHD to another of the same type"
	    12 "addmeta - add metadata to the CHD"
	    13 "delmeta - remove metadata from the CHD"
	    14 "dumpmeta - dump metadata from the CHD to stdout or to a file"
	    15 "listtemplates - list hard disk templates"
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)  
                    man "$md_inst/man/chdman.1" > man.txt
 		    dialog --stdout --title "CHDMAN - MANUAL" --clear --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                1)
                    aux_chdman_mame-tools "info" "chd"
                    ;;
                2)
                    aux_chdman_mame-tools "verify" "chd"
                    ;;
                3)
                    _aux_chdman_mame-tools "createraw" "any file"
                    ;;
                4)
                    _aux_chdman_mame-tools "createhd" "any image disk|zip|7z|no input file"
                    ;;
                5)
                    _aux_chdman_mame-tools "createcd" "cue|gdi|toc|zip|7z"
                    ;;
                6)
                    _aux_chdman_mame-tools "createld" "avi|zip|7z" 
                    ;;
                7)
                    _aux_chdman_mame-tools "extractraw" "chd"
                    ;;
                8)
                    _aux_chdman_mame-tools "extracthd" "chd"
                    ;;
                9)
                    _aux_chdman_mame-tools "extractcd" "chd"
                    ;;
                10)
                    _aux_chdman_mame-tools "extractld" "chd"
                    ;;
                11)
                    aux_chdman_mame-tools "copy" "chd"
                    ;;
                12)
                    aux_chdman_mame-tools "addmeta" "chd"
                    ;;
                13)
                    aux_chdman_mame-tools "delmeta" "chd"
                    ;;
                14)
                    aux_chdman_mame-tools "dumpmeta" "chd"
                    ;;
                15)
                    listtemplates_chdman_mame-tools
                    ;;
            esac
        else
            break
        fi
    done
}

function batch_convert_floptool_mame-tools() {
    d="$1"
    local sys="$2"
    local form="$3"

    if [[ "$sys" = d88 ]] || [[ "$sys" = cqm ]] || [[ "$sys" = a2_16sect ]] || [[ "$sys" = ssd ]] || [[ "$sys" = xdf ]] || [[ "$sys" = atom ]] || [[ "$sys" = os9 ]] || [[ "$sys" = adfs_o ]] || [[ "$sys" = pc ]]; then
        local default
        while true; do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Choose a output extension:" 22 76 16)
            local options=()

	    options+=(- "Exit")
            if [[ "$sys" = d88 ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".d77"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".d88"
                    options+=(E "Output extension ($form)")
                else
		    form=".1dd"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = cqm ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".cqm"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".cqi"
                    options+=(E "Output extension ($form)")
                else
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = pc ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".ima"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 2 ]]; then
		    form=".img"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 3 ]]; then
		    form=".ufi"
                    options+=(E "Output extension ($form)")
                else
		    form=".360"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = xdf ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".xdf"
                    options+=(E "Output extension ($form)")
                else
		    form=".img"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = a2_16sect ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"		    
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".do"	
                    options+=(E "Output extension ($form)")
                else
		    form=".po"	
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = atom ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".40t"
                    options+=(E "Output extension ($form)")
                else
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = ssd ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".ssd"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".bbc"
                    options+=(E "Output extension ($form)")
                else
		    form=".img"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = adfs_o ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".adf"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".ads"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 2 ]]; then
		    form=".adm"
                    options+=(E "Output extension ($form)")
                else
		    form=".adl"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = os9 ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                else
		    form=".os9"
                    options+=(E "Console Source ($form)")
                fi
            fi

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
                default="$choice"
                case "$choice" in
		    E)
		        if [ "$sys" = d88 ] || [ "$sys" = cqm ] || [ "$sys" = a2_16sect ] || [ "$sys" = ssd ]; then		      
                            ext="$((( ext + 1) % 3))"
		        elif [ "$sys" = xdf ] || [ "$sys" = atom ] || [ "$sys" = os9 ]; then
                            ext="$((ext ^ 1))"
		        elif [ "$sys" = adfs_o ]; then
                            ext="$((( ext + 1) % 4))"
		        elif [ "$sys" = pc ]; then
                            ext="$((( ext + 1) % 5))"	    
		        fi
			;;
		    -)
		        return 0
		        ;;
                esac
            else
                break
            fi
        done
    fi

    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
        mkdir -p floptool.rp
        ls -1 > floptool.rp/1.rp
        for j in *.*; do
	    $md_inst/floptool convert auto $sys "$j" "${j%.*}$form" 
	    if [[ ! -s "${j%.*}$form" ]]; then
		rm -rf "${j%.*}$form" 
	    fi
        done
        chown $user:$user *"$form"
        ls -1 > floptool.rp/2.rp

        DIF=`diff floptool.rp/1.rp floptool.rp/2.rp`

	if [ "$DIF" = "" ]; then
	    dialog --stdout --clear --msgbox "File(s) not converted" 13 50
	else
	    dialog --stdout --clear --msgbox "There is(are) file(s) successfully converted to *$form" 13 50         
	fi
	rm -rf *.rp
    else
        dialog --stdout --clear --msgbox "ERROR: Conversion Failed !!!" 8 50
    fi
    
}

function convert_floptool_mame-tools(){
    local f="$1"
    local sys="$2"
    local form="$3"
    local m="ERROR: Input invalid !!!"

    if [[ "$sys" = d88 ]] || [[ "$sys" = cqm ]] || [[ "$sys" = a2_16sect ]] || [[ "$sys" = ssd ]] || [[ "$sys" = xdf ]] || [[ "$sys" = atom ]] || [[ "$sys" = os9 ]] || [[ "$sys" = adfs_o ]] || [[ "$sys" = pc ]]; then
        local default
        while true; do
            local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "Choose a output extension:" 22 76 16)
            local options=()

	    options+=(- "Exit")
            if [[ "$sys" = d88 ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".d77"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".d88"
                    options+=(E "Output extension ($form)")
                else
		    form=".1dd"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = cqm ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".cqm"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".cqi"
                    options+=(E "Output extension ($form)")
                else
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = pc ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".ima"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 2 ]]; then
		    form=".img"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 3 ]]; then
		    form=".ufi"
                    options+=(E "Output extension ($form)")
                else
		    form=".360"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = xdf ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".xdf"
                    options+=(E "Output extension ($form)")
                else
		    form=".img"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = a2_16sect ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"		    
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".do"	
                    options+=(E "Output extension ($form)")
                else
		    form=".po"	
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = atom ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".40t"
                    options+=(E "Output extension ($form)")
                else
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = ssd ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".ssd"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".bbc"
                    options+=(E "Output extension ($form)")
                else
		    form=".img"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = adfs_o ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".adf"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 1 ]]; then
		    form=".ads"
                    options+=(E "Output extension ($form)")
                elif [[ "$ext" -eq 2 ]]; then
		    form=".adm"
                    options+=(E "Output extension ($form)")
                else
		    form=".adl"
                    options+=(E "Output extension ($form)")
                fi
            elif [[ "$sys" = os9 ]]; then
	        if [[ "$ext" -eq 0 ]]; then
		    form=".dsk"
                    options+=(E "Output extension ($form)")
                else
		    form=".os9"
                    options+=(E "Console Source ($form)")
                fi
            fi

            local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
            if [[ -n "$choice" ]]; then
                default="$choice"
                case "$choice" in
		    E)
		        if [ "$sys" = d88 ] || [ "$sys" = cqm ] || [ "$sys" = a2_16sect ] || [ "$sys" = ssd ]; then		      
                            ext="$((( ext + 1) % 3))"
		        elif [ "$sys" = xdf ] || [ "$sys" = atom ] || [ "$sys" = os9 ]; then
                            ext="$((ext ^ 1))"
		        elif [ "$sys" = adfs_o ]; then
                            ext="$((( ext + 1) % 4))"
		        elif [ "$sys" = pc ]; then
                            ext="$((( ext + 1) % 5))"	    
		        fi
			;;
		    -)
		        return 0
		        ;;
                esac
            else
                break
            fi
        done
    fi

    if [ -f "$f" ]; then
        $md_inst/floptool convert auto "$sys" "$f" "${f%.*}$form"
        cd && cd `dirname "$f"`
        if [[ -s "${f%.*}$form" ]]; then
            m="input: $f\n\noutput: ${f%.*}$form\n\nFile successfully converted."
        else
	    if [[ -e "${f%.*}$form" ]] && [[ ! -s "${f%.*}$form" ]]; then
		dialog --stdout --title "Floptool - convert to *$form" --clear --msgbox "input: $f\n\noutput: ${f%.*}$form is a empty file (0kB).\n\nOutput invalid!!" 10 50
		rm -rf "${f%.*}$form"
	    fi 
	    m="Error: saving to format '*$form' unsupported to input $f"
        fi
        chown $user:$user "${f%.*}$form"
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 13 50
}

function __aux_floptool_mame-tools(){
    local format="$1"
    local system="$2"
    export IFS='
'
    __DIR=$(dialog --stdout --title "Choose a directory to batch convert to $format" --inputbox 'type a directory:' 0 0 "$HOME/RetroPie/roms/")
    [ ! -z $__DIR ] && batch_convert_floptool_mame-tools "$__DIR" "$system" "$format"
}

function _aux_floptool_mame-tools() {
    local format="$1"
    local system="$2"
    export IFS='
'
    FILE=$(dialog --stdout --title "Choose a floppy to convert to $format" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && convert_floptool_mame-tools "$FILE" "$system" "$format"
}

function aux_floptool_mame-tools(){
    local cmd_1="$1"
    local cmd_2="$2"
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Floptool - Choose a option" 22 76 16)
        local options=(
            1 "single conversion"
            2 "batch conversion"
	)
	
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		1)
		    _aux_floptool_mame-tools "$cmd_1" "$cmd_2"
		    ;;
		2)
	            __aux_floptool_mame-tools "$cmd_1" "$cmd_2"
		    ;;
            esac
        else
            break
        fi
    done
}

function batch_identify_floptool_mame-tools(){
    d="$1"
    local m="ERROR: Input invalid !!!"
    if [ -d "$d" ]; then
        clear
	cd && cd "$d"
        $md_inst/floptool identify *.* > all.ident
	if [[ -f "all.ident" ]]; then
	    dialog --stdout --title "Floptool - identify" --clear --textbox all.ident 0 0
            m="Identifications completed."
            rm -rf all.ident
        else
	    m="$m"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
}

function _identify_floptool_mame-tools(){
    local f="$1"
    local m="ERROR: Input invalid !!!"
    if [ -f "$f" ]; then
        cd && cd `dirname "$f"`
        $md_inst/floptool identify "$f" > ${f%.*}.ident
        if [[ -f "${f%.*}.ident" ]]; then
	    dialog --stdout --title "Floptool - identify" --clear --textbox ${f%.*}.ident 0 0
            m="Identification completed."
            rm -rf ${f%.*}.ident
        else
	    m="$m"
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function __aux_identify_floptool_mame-tools(){
    export IFS='
'
    __DIR=$(dialog --stdout --title "Floptool - identify" --inputbox 'type a directory:' 0 0 "$HOME/RetroPie/roms/")
    [ ! -z $__DIR ] && batch_identify_floptool_mame-tools "$__DIR"
}

function _aux_identify_floptool_mame-tools() {
    export IFS='
'
    FILE=$(dialog --stdout --title "Floptool - identify" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && _identify_floptool_mame-tools "$FILE" 
}

function identify_floptool_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Floptool - Choose a option" 22 76 16)
        local options=(
            1 "one identification"
            2 "batch identification"
	)
	
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		1)
		    _aux_identify_floptool_mame-tools
		    ;;
		2)
	            __aux_identify_floptool_mame-tools
		    ;;
            esac
        else
            break
        fi
    done
}

function floptool_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Floptool - Choose a system" 22 76 16)
        local options=(
            S "see manual"
            I "identifier (floppy/system)"
            1 "mfi - MESS floppy image"
            2 "dfi - DiscFerret flux dump format"
	    3 "ipf - SPS floppy disk image"
	    4 "mfm - HxC Floppy Emulator floppy disk image"
	    5 "adf - Amiga ADF floppy disk image"
	    6 "st - Atari ST floppy disk image"
	    7 "msa - Atari MSA floppy disk image"
	    8 "pasti - Atari PASTI floppy disk image"
	    9 "dsk - CPC DSK Format"
	    10 "d88 - D88 disk image"
	    11 "imd - IMD disk image"
	    12 "td0 - Teledisk disk image"
	    13 "cqm - CopyQM disk image"
	    14 "pc - PC floppy disk image"
	    15 "NASLite - NASLite disk image"
	    16 "xdf - IBM XDF disk image"
	    17 "dc42 - DiskCopy 4.2 image"
	    18 "a2_16sect - Apple II 16-sector dsk image"
	    19 "a2_rwts18 - Apple II RWTS18-type Image"
	    20 "a2_edd - Apple II EDD Image"
	    21 "a2_woz - Apple II WOZ Image"
	    22 "atom - Acorn Atom disk image"
	    23 "ssd - Acorn SSD disk image"
            24 "dsd - Acorn DSD disk image"
            25 "dos - Acorn DOS disk image"
            26 "adfs_o - Acorn ADFS (OldMap) disk image"
            27 "adfs_n - Acorn ADFS (NewMap) disk image"
            28 "oric_dsk - Oric disk image"
            29 "applix - Applix disk image"
            30 "hpi - HP9895A floppy disk image"
            31 "img - MDS-II floppy disk image"
            32 "mx - DVK MX: floppy image"
            33 "aim - AIM disk image"
            34 "m20 - M20 disk image"
            35 "os9 - OS-9 floppy disk image"
            36 "flex - FLEX compatible disk image"
            37 "uniflex - UniFLEX compatible disk image"
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/floptool.1" > man.txt
 		    dialog --stdout --title "FLOPTOOL - MANUAL" --clear --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                I)
                    identify_floptool_mame-tools
                    ;;
                1)
                    aux_floptool_mame-tools '.mfi' 'mfi'
                    ;;
                2)
                    aux_floptool_mame-tools '.dfi' 'dfi'
                    ;;
                3)
                    aux_floptool_mame-tools '.ipf' 'ipf'
                    ;;
                4)
                    aux_floptool_mame-tools '.mfm' 'mfm'
                    ;;
                5)
                    aux_floptool_mame-tools '.adf' 'adf'
                    ;;
                6)
                    aux_floptool_mame-tools '.st' 'st'
                    ;;
                7)
                    aux_floptool_mame-tools '.msa' 'msa'
                    ;;
                8)
                    aux_floptool_mame-tools '.stx' 'pasti'
                    ;;
                9)
                    aux_floptool_mame-tools '.dsk' 'dsk'
                    ;;
                10)
                    aux_floptool_mame-tools '.d77 .d88 .1dd' 'd88'
                    ;;
                11)
                    aux_floptool_mame-tools '.imd' 'imd'
                    ;;
                12)
                    aux_floptool_mame-tools '.td0' 'td0'
                    ;;
                13)
                    aux_floptool_mame-tools '.cqm .cqi .dsk' 'cqm'
                    ;;
                14)
                    aux_floptool_mame-tools '.dsk .ima .img .ufi .360' 'pc'
                    ;;
                15)
                    aux_floptool_mame-tools '.img' 'NASLite'
                    ;;
                16)
                    aux_floptool_mame-tools '.xdf .img' 'xdf'
                    ;;
                17)
                    aux_floptool_mame-tools '.dc42' 'dc42'
                    ;;
                18)
                    aux_floptool_mame-tools '.dsk .do .po' 'a2_16sect'
                    ;;
                19)
                    aux_floptool_mame-tools '.rti' 'a2_rwts18'
                    ;;
                20)
                    aux_floptool_mame-tools '.edd' 'a2_edd'
                    ;;
                21)
                    aux_floptool_mame-tools '.woz' 'a2_woz'
                    ;;
                22)
                    aux_floptool_mame-tools '.40t .dsk' 'atom'
                    ;;
                23)
                    aux_floptool_mame-tools '.ssd .bbc .img' 'ssd'
                    ;;
                24)
                    aux_floptool_mame-tools '.dsd' 'dsd'
                    ;;
                25)
                    aux_floptool_mame-tools '.img' 'dos'
                    ;;
                26)
                    aux_floptool_mame-tools '.adf .ads .adm .adl' 'adfs_o'
                    ;;
                27)
                    aux_floptool_mame-tools '.adf' 'adfs_n'
                    ;;
                28)
                    aux_floptool_mame-tools '.dsk' 'oric_dsk'
                    ;;
                29)
                    aux_floptool_mame-tools '.raw' 'applix'
                    ;;
                30)
                    aux_floptool_mame-tools '.hpi' 'hpi'
                    ;;
                31)
                    aux_floptool_mame-tools '.img' 'img'
                    ;;
                32)
                    aux_floptool_mame-tools '.mx' 'mx'
                    ;;
                33)
                    aux_floptool_mame-tools '.aim' 'aim'
                    ;;
                34)
                    aux_floptool_mame-tools '.img' 'm20'
                    ;;
                35)
                    aux_floptool_mame-tools '.dsk .os9' 'os9'
                    ;;
                36)
                    aux_floptool_mame-tools '.dsk' 'flex'
                    ;;
                37)
                    aux_floptool_mame-tools '.dsk' 'uniflex'
                    ;;
            esac
        else
            break
        fi
    done
}

function imgtool_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Imgtool - Choose a option" 22 76 16)
        local options=(
            S "see manual"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/imgtool.1" > man.txt
 		    dialog --stdout --title "IMGTOOL - MANUAL" --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
            esac
        else
            break
        fi
    done
}

function aux_jedutil_dump_mame-tools() {
    f="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $f_bn_ext\n\nRequired parameters (1 of 53 devices):" 22 76 16)
        local options=()

	options+=(- "Exit")
	if [[ "$device" -eq 0 ]]; then
            options+=(D "Device (PAL10L8)")
        elif [[ "$device" -eq 1 ]]; then
            options+=(D "Device (PAL10H8)")
        elif [[ "$device" -eq 2 ]]; then
            options+=(D "Device (PAL12H6)")
        elif [[ "$device" -eq 3 ]]; then
            options+=(D "Device (PAL14H4)")
        elif [[ "$device" -eq 4 ]]; then
            options+=(D "Device (PAL16H2)")
        elif [[ "$device" -eq 5 ]]; then
            options+=(D "Device (PAL16C1)")
        elif [[ "$device" -eq 6 ]]; then
            options+=(D "Device (PAL12L6)")
        elif [[ "$device" -eq 7 ]]; then
            options+=(D "Device (PAL14L4)")
        elif [[ "$device" -eq 8 ]]; then
            options+=(D "Device (PAL16L2)")
        elif [[ "$device" -eq 9 ]]; then
            options+=(D "Device (PAL16L8)")
        elif [[ "$device" -eq 10 ]]; then
            options+=(D "Device (PAL16R4)")
        elif [[ "$device" -eq 11 ]]; then
            options+=(D "Device (PAL16R6)")
        elif [[ "$device" -eq 12 ]]; then
            options+=(D "Device (PAL16R8)")
        elif [[ "$device" -eq 13 ]]; then
            options+=(D "Device (PALCE16V8)")
        elif [[ "$device" -eq 14 ]]; then
            options+=(D "Device (GAL16V8)")
        elif [[ "$device" -eq 15 ]]; then
            options+=(D "Device (18CV8)")
        elif [[ "$device" -eq 16 ]]; then
            options+=(D "Device (AMPAL18P8)")
        elif [[ "$device" -eq 17 ]]; then
            options+=(D "Device (GAL18V10)")
        elif [[ "$device" -eq 18 ]]; then
            options+=(D "Device (PAL20L8)")
        elif [[ "$device" -eq 19 ]]; then
            options+=(D "Device (PAL20L10)")
        elif [[ "$device" -eq 20 ]]; then
            options+=(D "Device (PAL20R4)")
        elif [[ "$device" -eq 21 ]]; then
            options+=(D "Device (PAL20R6)")
        elif [[ "$device" -eq 22 ]]; then
            options+=(D "Device (PAL20R8)")
        elif [[ "$device" -eq 23 ]]; then
            options+=(D "Device (PAL20RA10)")
        elif [[ "$device" -eq 24 ]]; then
            options+=(D "Device (PAL20X4)")
        elif [[ "$device" -eq 25 ]]; then
            options+=(D "Device (PAL20X8)")
        elif [[ "$device" -eq 26 ]]; then
            options+=(D "Device (PAL20X10)")
        elif [[ "$device" -eq 27 ]]; then
            options+=(D "Device (82S153)")
        elif [[ "$device" -eq 28 ]]; then
            options+=(D "Device (PLS153)")
        elif [[ "$device" -eq 29 ]]; then
            options+=(D "Device (CK2605)")
        elif [[ "$device" -eq 30 ]]; then
            options+=(D "Device (PAL10P8)")
        elif [[ "$device" -eq 31 ]]; then
            options+=(D "Device (PAL12P6)")
        elif [[ "$device" -eq 32 ]]; then
            options+=(D "Device (PAL14P4)")
        elif [[ "$device" -eq 33 ]]; then
            options+=(D "Device (PAL16P2)")
        elif [[ "$device" -eq 34 ]]; then
            options+=(D "Device (PAL16P8)")
        elif [[ "$device" -eq 35 ]]; then
            options+=(D "Device (PAL16RP4)")
        elif [[ "$device" -eq 36 ]]; then
            options+=(D "Device (PAL16RP6)")
        elif [[ "$device" -eq 37 ]]; then
            options+=(D "Device (PAL16RP8)")
        elif [[ "$device" -eq 38 ]]; then
            options+=(D "Device (PAL6L16)")
        elif [[ "$device" -eq 39 ]]; then
            options+=(D "Device (PAL8L14)")
        elif [[ "$device" -eq 40 ]]; then
            options+=(D "Device (PAL12H10)")
        elif [[ "$device" -eq 41 ]]; then
            options+=(D "Device (PAL12L10)")
        elif [[ "$device" -eq 42 ]]; then
            options+=(D "Device (PAL14H8)")
        elif [[ "$device" -eq 43 ]]; then
            options+=(D "Device (PAL14L8)")
        elif [[ "$device" -eq 44 ]]; then
            options+=(D "Device (PAL16H6)")
        elif [[ "$device" -eq 45 ]]; then
            options+=(D "Device (PAL16L6)")
        elif [[ "$device" -eq 46 ]]; then
            options+=(D "Device (PAL18H4)")
        elif [[ "$device" -eq 47 ]]; then
            options+=(D "Device (PAL18L4)")
        elif [[ "$device" -eq 48 ]]; then
            options+=(D "Device (PAL20C1)")
        elif [[ "$device" -eq 49 ]]; then
            options+=(D "Device (PAL20L2)")
        elif [[ "$device" -eq 50 ]]; then
            options+=(D "Device (82S100)")
        elif [[ "$device" -eq 51 ]]; then
            options+=(D "Device (PLS100)")
        elif [[ "$device" -eq 52 ]]; then
            options+=(D "Device (82S101)")
        elif [[ "$device" -eq 53 ]]; then
            options+=(D "Device (PLS101)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		D)  
                    device="$((( device + 1) % 53))"
		    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ "$device" -eq 0 ]]; then
	params+=(PAL10L8)
    elif [[ "$device" -eq 1 ]]; then
        params+=(PAL10H8)
    elif [[ "$device" -eq 2 ]]; then
        params+=(PAL12H6)
    elif [[ "$device" -eq 3 ]]; then
        params+=(PAL14H4)
    elif [[ "$device" -eq 4 ]]; then
        params+=(PAL16H2)
    elif [[ "$device" -eq 5 ]]; then
        params+=(PAL16C1)
    elif [[ "$device" -eq 6 ]]; then
        params+=(PAL12L6)
    elif [[ "$device" -eq 7 ]]; then
        params+=(PAL14L4)
    elif [[ "$device" -eq 8 ]]; then
        params+=(PAL16L2)
    elif [[ "$device" -eq 9 ]]; then
        params+=(PAL16L8)
    elif [[ "$device" -eq 10 ]]; then
        params+=(PAL16R4)
    elif [[ "$device" -eq 11 ]]; then
        params+=(PAL16R6)
    elif [[ "$device" -eq 12 ]]; then
        params+=(PAL16R8)
    elif [[ "$device" -eq 13 ]]; then
        params+=(PALCE16V8)
    elif [[ "$device" -eq 14 ]]; then
        params+=(GAL16V8)
    elif [[ "$device" -eq 15 ]]; then
        params+=(18CV8)
    elif [[ "$device" -eq 16 ]]; then
        params+=(AMPAL18P8)
    elif [[ "$device" -eq 17 ]]; then
        params+=(GAL18V10)
    elif [[ "$device" -eq 18 ]]; then
        params+=(PAL20L8)
    elif [[ "$device" -eq 19 ]]; then
        params+=(PAL20L10)
    elif [[ "$device" -eq 20 ]]; then
        params+=(PAL20R4)
    elif [[ "$device" -eq 21 ]]; then
        params+=(PAL20R6)
    elif [[ "$device" -eq 22 ]]; then
        params+=(PAL20R8)
    elif [[ "$device" -eq 23 ]]; then
        params+=(PAL20RA10)
    elif [[ "$device" -eq 24 ]]; then
        params+=(PAL20X4)
    elif [[ "$device" -eq 25 ]]; then
        params+=(PAL20X8)
    elif [[ "$device" -eq 26 ]]; then
        params+=(PAL20X10)
    elif [[ "$device" -eq 27 ]]; then
        params+=(82S153)
    elif [[ "$device" -eq 28 ]]; then
        params+=(PLS153)
    elif [[ "$device" -eq 29 ]]; then
        params+=(CK2605)
    elif [[ "$device" -eq 30 ]]; then
        params+=(PAL10P8)
    elif [[ "$device" -eq 31 ]]; then
        params+=(PAL12P6)
    elif [[ "$device" -eq 32 ]]; then
        params+=(PAL14P4)
    elif [[ "$device" -eq 33 ]]; then
        params+=(PAL16P2)
    elif [[ "$device" -eq 34 ]]; then
        params+=(PAL16P8)
    elif [[ "$device" -eq 35 ]]; then
        params+=(PAL16RP4)
    elif [[ "$device" -eq 36 ]]; then
        params+=(PAL16RP6)
    elif [[ "$device" -eq 37 ]]; then
        params+=(PAL16RP8)
    elif [[ "$device" -eq 38 ]]; then
        params+=(PAL6L16)
    elif [[ "$device" -eq 39 ]]; then
        params+=(PAL8L14)
    elif [[ "$device" -eq 40 ]]; then
        params+=(PAL12H10)
    elif [[ "$device" -eq 41 ]]; then
        params+=(PAL12L10)
    elif [[ "$device" -eq 42 ]]; then
        params+=(PAL14H8)
    elif [[ "$device" -eq 43 ]]; then
        params+=(PAL14L8)
    elif [[ "$device" -eq 44 ]]; then
        params+=(PAL16H6)
    elif [[ "$device" -eq 45 ]]; then
        params+=(PAL16L6)
    elif [[ "$device" -eq 46 ]]; then
        params+=(PAL18H4)
    elif [[ "$device" -eq 47 ]]; then
        params+=(PAL18L4)
    elif [[ "$device" -eq 48 ]]; then
        params+=(PAL20C1)
    elif [[ "$device" -eq 49 ]]; then
        params+=(PAL20L2)
    elif [[ "$device" -eq 50 ]]; then
        params+=(82S100)
    elif [[ "$device" -eq 51 ]]; then
        params+=(PLS100)
    elif [[ "$device" -eq 52 ]]; then
        params+=(82S101)
    elif [[ "$device" -eq 53 ]]; then
        params+=(PLS101)
    fi

    if [ -f "$f" ]; then
        clear
        cd && cd `dirname "$f"`
        $md_inst/jedutil -view "$f" ${params[@]} &> dump.info
        dialog --stdout --title "Jedutil" --textbox dump.info 22 60

        chown $user:$user "dump.info"

        if [[ -f "dump.info" ]]; then
	    m="dump info completed"
            dialog --stdout --defaultno --yesno "Would you like to save dump info file to "$f"?" 13 50
            if [[ $? = 0 ]]; then
                dialog --stdout --msgbox "The dump.info file has been save!" 10 50
            else
                rm -rf "dump.info"
                dialog --stdout --msgbox "The dump.info file have been deleted!" 10 50
            fi
        else
	    m="ERROR: Conversion failed. Try again."
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_jedutil_convert_bin_mame-tools() {
    local f="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $f_bn_ext\noutput: ${f%.*}.jed" 10 60 16)
        local options=()

        options+=(- "Exit")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    if [ -f "$f" ]; then
        clear
        cd && cd `dirname "$f"`
        $md_inst/jedutil -convert "$f" "${f%.*}.jed" > convert_jed.info
        dialog --stdout --title "Jedutil" --textbox convert_jed.info 0 0

        chown $user:$user "convert_jed.info" "${f%.*}.jed"

        if [[ -f "${f%.*}.jed" ]]; then
            dialog --stdout --title "Jedutil - ${f%.*}.jed map" --textbox ${f%.*}.jed 0 0
	    m="conversion completed"
            dialog --stdout --defaultno --yesno "Would you like to delete $f file and keep only ${f%.*}.jed?" 13 50
            if [[ $? = 0 ]]; then
                rm -rf "$f"
                dialog --stdout --msgbox "$f has been deleted!" 10 50
            fi
            dialog --stdout --defaultno --yesno "Would you like to save the conversion infos?" 13 50
            if [[ $? = 1 ]]; then
                rm -rf "convert_jed.info"
                dialog --stdout --msgbox "The convert_jed.info file have been deleted!" 10 50
            fi
        else
	    m="ERROR: Conversion failed. Try again."
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_jedutil_convert_jedec_mame-tools() {
    local f="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $f`

    local fuses="none"
    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $f_bn_ext\noutput: ${f%.*}.bin\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(F "Fuses: $fuses")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                F)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the fuse:" 10 60 "$fuses")
                    fuses=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ -n "$fuses" ]] && [[ "$fuses" != "none" ]]; then
        params+=("$fuses")
    fi

    if [ -f "$f" ]; then
        clear
        cd && cd `dirname "$f"`
        $md_inst/jedutil -convert "$f" "${f%.*}.bin" ${params[@]} > convert_bin.info
        dialog --stdout --title "Jedutil" --textbox convert_bin.info 0 0

        chown $user:$user "convert_bin.info" "${f%.*}.bin"

        if [[ -f "${f%.*}.bin" ]]; then
	    m="conversion completed"
            dialog --stdout --defaultno --yesno "Would you like to delete $f file and keep only ${f%.*}.bin?" 13 50
            if [[ $? = 0 ]]; then
                rm -rf "$f"
                dialog --stdout --msgbox "$f has been deleted!" 10 50
            fi
            dialog --stdout --defaultno --yesno "Would you like to save the conversion infos?" 13 50
            if [[ $? = 1 ]]; then
                rm -rf "convert_bin.info"
                dialog --stdout --msgbox "The convert_bin.info file have been deleted!" 10 50
            fi
        else
	    m="ERROR: Conversion failed. Try again."
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_jedutil_mame-tools() {
    cmd_1="$1"
    cmd_2="$2"
    export IFS='
'
    FILE=$(dialog --stdout --title "Jedutil - $cmd_1" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && aux_jedutil_"$cmd_2"_mame-tools "$FILE" 
}

function viewlist_jedutil_mame-tools() {
    $md_inst/jedutil -viewlist > "viewlist.info"
    dialog --stdout --title "Jedutil - supported devices" --textbox viewlist.info 22 50
    dialog --stdout --defaultno --yesno "Would you like to save the device list?" 13 50
    if [[ $? = 1 ]]; then
	rm -rf "viewlist.info"
	dialog --stdout --msgbox "The viewlist.info file have been deleted!" 10 50
    else
        chown $user:$user "viewlist.info"
        mv viewlist.info "$HOME/"
	dialog --stdout --msgbox "The file have been saved in $HOME/viewlist.info!" 10 50
    fi
}

function jedutil_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Jedutil - Choose a option" 22 76 16)
        local options=(
            S "see manual"
            1 "convert Berkeley standard PLA/JEDEC to binary form"
            2 "convert binary to JEDEC form"
            3 "dump JED/binary logic equations"
            4 "view list of supported devices"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/jedutil.1" > man.txt
 		    dialog --stdout --title "JEDUTIL - MANUAL" --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                1)
                    aux_jedutil_mame-tools "Choose a *jed or *.pla file" "convert_jedec"
                    ;;
                2)
                    aux_jedutil_mame-tools "Choose a *.bin file" "convert_bin"
                    ;;
                3)
                    aux_jedutil_mame-tools "Choose a *.jed or *.bin file" "dump"
                    ;;
                4)
                    viewlist_jedutil_mame-tools
                    ;;
            esac
        else
            break
        fi
    done
}

function _aux_ldresample_mame-tools() {
    local f="$1"
    local m="Error during manipulation. Try again!"
    local default

    local output="none"
    local offset="none"
    local slope="none"
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $f_bn_ext\noutput: $output\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(O "Output file: $output")
        options+=(1 "Offset ($offset)")
        options+=(2 "slope ($slope)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type a value for offset:" 10 60 "$offset")
                    offset=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ $output = "" ]] || [[ $output = "none" ]]; then
                        output="$f-output.chd"
                    fi
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type a value for slope:" 10 60 "$slope")
                    slope=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ $offset = "" ]] || [[ $offset = "none" ]]; then
                        offset="0"
                    fi
                    ;;
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Type a name to output CHD file:\n(this file is only created, case you use offset/slope)" 10 60 "$output")
                    output=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ -n "$output" ]] && [[ "$output" != "none" ]]; then
        params+=("$output")
    fi
    if [[ -n "$offset" ]] && [[ "$offset" != "none" ]]; then
        params+=("$offset")
    fi
    if [[ -n "$slope" ]] && [[ "$slope" != "none" ]]; then
        params+=("$slope")
    fi

    if [ -f "$f" ]; then
        clear
        cd && cd `dirname "$f"`
        echo "Processing $f ..."
        $md_inst/ldresample "$f" ${params[@]} > resample.info
        dialog --stdout --title "ldresample - informations" --textbox resample.info 0 0
        if [ ${params[@]} != "" ]; then
	    dialog --stdout --msgbox "$output has been created!" 10 50
        fi
        if [[ -f "resample.info" ]]; then
	    m="manipulation completed"
            dialog --stdout --defaultno --yesno "Would you like to save info file?" 13 50
            if [[ $? = 0 ]]; then
                chown $user:$user "resample.info"
            else
	        rm -rf "resample.info"
		dialog --stdout --msgbox "Info file have been deleted!" 10 50
            fi
        else
	    m="ERROR: Input invalid !!!"
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_ldresample_mame-tools() {
    export IFS='
'
    FILE=$(dialog --stdout --title "Choose a CHD (LD) file" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && _aux_ldresample_mame-tools "$FILE" 
}

function ldresample_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Ldresample - Choose a option" 22 76 16)
        local options=(
            S "see manual"
	    M "Manipulate CHD audio"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/ldresample.1" > man.txt
 		    dialog --stdout --title "LDRESAMPLE - MANUAL" --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                M)
                    aux_ldresample_mame-tools
                    ;;
            esac
        else
            break
        fi
    done
}

function _aux_ldverify_mame-tools() {
    local f="$1"
    local m="Error during verification. Try again!"
    if [ -f "$f" ]; then
        clear
        cd && cd `dirname "$f"`
        echo "Processing file: $f ..."
        $md_inst/ldverify "$f" > verify.info
        dialog --stdout --title "ldverify - informations" --textbox verify.info 0 0
        if [[ -f "verify.info" ]]; then
	    m="Verification completed"
            dialog --stdout --defaultno --yesno "Would you like to save info file?" 13 50
            if [[ $? = 0 ]]; then
                chown $user:$user "verify.info"
            else
	        rm -rf "verify.info"
		dialog --stdout --msgbox "Info file have been deleted!" 10 50
            fi
        else
	    m="ERROR: Input invalid !!!"
        fi
    else
	m="$m"
    fi 
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_ldverify_mame-tools() {
    export IFS='
'
    FILE=$(dialog --stdout --title "Choose a AVI or CHD file" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && _aux_ldverify_mame-tools "$FILE" 
}

function ldverify_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Ldverify - Choose a option" 22 76 16)
        local options=(
            S "see manual"
            V "verify AVI/CHD"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/ldverify.1" > man.txt
 		    dialog --stdout --title "LDRVERIFY - MANUAL" --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                V)
		    aux_ldverify_mame-tools
		    ;;
            esac
        else
            break
        fi
    done
}

function pngcmp_mame-tools() {
    printMsgs "dialog" "This tool is used in regression testing to compare PNG screenshot results with the 'runtest.cmd' script found in the source archive. This script works only on Microsoft Windows.\n:(\n\nWe use LINUX!!!\n:)"
}

function regrep_mame-tools() {
    printMsgs "dialog" "not implemented yet."
}

function aux_romcmp_mame-tools() {
    local cmd_1="$1"
    local input_1="none"
    local input_2="none"
    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "$1 1: $input_1\n$1 2: $input_2\n\nInputs:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(1 "$1 1: $input_1")
        options+=(2 "$1 2: $input_2")
        if [[ "$slower" -eq 1 ]]; then
            options+=(3 "Enables a slower, more comprehensive comparison (Enabled)")
        else
            options+=(3 "Enables a slower, more comprehensive comparison (Disabled)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the 1st directory name:" 10 60 "$input_1")
                    input_1=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the 2nd directory name:" 10 60 "$input_2")
                    input_2=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
                3)
                    slower="$((slower ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ -n "$input_1" ]] && [[ "$input_1" != "none" ]]; then
        params+=("$input_1")
    fi
    if [[ -n "$input_2" ]] && [[ "$input_2" != "none" ]]; then
        params+=("$input_2")
    fi
    if [[ "$slower" -eq 1 ]]; then
        params+=(-d)
    fi

    clear
    if [[ $input_1 = $input_2 ]] && [[ -z $input_1 ]] || [[ "$input_1" = "none" ]]; then
	dialog --stdout --clear --msgbox "There is(are) input file(s) to analyze." 8 50
    else
        $md_inst/romcmp ${params[@]} > romcmp.info
        chown $user:$user "romcmp.info"
        if [[ -f "romcmp.info" ]]; then
            dialog --stdout --title "ROMCMP - INFO" --textbox romcmp.info 0 0
	    dialog --stdout --defaultno --yesno "Would you like to save that informations?" 13 50
            if [[ $? = 1 ]]; then
	        rm -rf "romcmp.info"
            else
                mv "romcmp.info" "$HOME/"
	        dialog --stdout --clear --msgbox "File has been saved in $HOME/romcmp.info" 8 50
            fi
        else
        dialog --stdout --clear --msgbox "ERROR: Romcmp failed. Try again." 8 50
        fi
    fi
}

function romcmp_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Romcmp - Choose a option" 22 76 16)
        local options=(
            S "see manual"
            1 "compare directories"
	    2 "compare compress files"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    man "$md_inst/man/romcmp.1" > man.txt
 		    dialog --stdout --title "ROMCMP - MANUAL" --textbox man.txt 0 0
                    rm -rf man.txt
                    ;;
                1)  
		    aux_romcmp_mame-tools "Directory"
                    ;;
                2)  
		    aux_romcmp_mame-tools "Compress file"
                    ;;
            esac
        else
            break
        fi
    done
}

function _aux_split_verify_mame-tools() {
    local verify_file="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $verify_file`

    if [[ "$verify_file" = *.split ]]; then
        clear
        cd && cd "$DIR"
        $md_inst/split -verify "$verify_file" >  "$verify_file.verify"
        if [[ -f "$verify_file.verify" ]]; then
            dialog --stdout --title "Split - verify" --clear --textbox $verify_file.verify 0 0
	    rm -rf "$verify_file.verify" 
        fi
    else
        dialog --stdout --clear --msgbox "$m" 8 50
    fi
    
}

function _aux_split_join_mame-tools() {
    local split_file="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $split_file`

    output_file="default"
    if [[ "$output_file" = "default" ]]; then
	outfile="${split_file%.split}"
    fi

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $split_file\noutput: $outfile\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(O "Output: $output_file")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the output file:" 10 60 "$output_file")
                    output_file=$("${cmd[@]}" 2>&1 >/dev/tty)
                    if [[ "$output_file" = "default" ]] || [[ -z "$output_file" ]]; then
			outfile="${split_file%.split}"
   		    else
			outfile="$output_file" 
    		    fi
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ -n "$output_file" ]] && [[ "$output_file" != "default" ]]; then
        params+=("$output_file")
    else
        output_file="$outfile"
	params+=("$output_file")
    fi

    if [ -f "$split_file" ]; then
        clear
        cd && cd "$DIR"
        $md_inst/split -join "$split_file" ${params[@]}
        chown $user:$user "$output_file"
        if [[ -f "$output_file" ]]; then
            m="${split_file%.split} re-created successfully!"
	    dialog --stdout --defaultno --yesno "Would you like to delete all split files and keeping only $output_file?" 13 50
            if [[ $? = 0 ]]; then
	        rm -rf "${split_file%.split}."*
		dialog --stdout --msgbox "Split files have been deleted!" 8 50
            fi
        else
	    m="ERROR: File has not been re-created !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
}

function _aux_split_mame-tools() {
    local bigfile="$1"
    local m="ERROR: Input invalid !!!"
    local DIR
    DIR=`dirname $bigfile`
    basename="default"
    if [[ "$basename" = "default" ]]; then
	b_name="$bigfile" 
    fi
    size="100"

    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $bigfile\noutput: $b_name.split\n\nOptional parameters:" 22 76 16)
        local options=()

        options+=(- "Exit")
        options+=(O "Output: $basename")
        options+=(S "Size ($size MB)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                O)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the name for output file:" 10 60 "$basename")
                    basename=$("${cmd[@]}" 2>&1 >/dev/tty)
    		    if [[ "$basename" = "default" ]] || [[ -z "$basename" ]]; then
			b_name="$bigfile"
    		    else
			b_name="$basename" 
    		    fi
                    ;;
                S)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the maximum size of each division:" 10 60 "$size")
                    size=$("${cmd[@]}" 2>&1 >/dev/tty)
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ -n "$basename" ]] && [[ "$basename" != "default" ]]; then
        params+=("$basename")
    else
        basename="$b_name"
	params+=("$basename")
    fi
    if [[ -n "$size" ]]; then
        params+=("$size")
    fi

    if [ -f "$bigfile" ]; then
        clear
        cd && cd "$DIR"
        $md_inst/split -split "$bigfile" ${params[@]}
        chown $user:$user "$basename"*
        if [[ -f "$basename.split" ]]; then
            m="$bigfile split successfully!"
	    dialog --stdout --defaultno --yesno "Would you like to delete $bigfile and keeping only the split files?" 13 50
            if [[ $? = 0 ]]; then
	        rm -rf "$bigfile"
		dialog --stdout --msgbox "$bigfile has been deleted!" 10 50
            fi
        else
	    m="ERROR: File has not been split !!!"
        fi
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
}

function aux_split_mame-tools() {
    local opt="$1"
    local cmd="$2"
    export IFS='
'
    FILE=$(dialog --stdout --title "$opt" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && _aux_$2_mame-tools "$FILE" 
}

function split_mame-tools() {
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Split - Choose a option" 22 76 16)
        local options=(
            S "split"
            J "join"
            V "verify"
      	)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                S)
                    aux_split_mame-tools "Choose any file to split" "split"
                    ;;
                J)
                    aux_split_mame-tools "Choose a file *.split to join" "split_join"
                    ;;
                V)
                    aux_split_mame-tools "Choose a file *.split to verify" "split_verify"
                    ;;
            esac
        else
            break
        fi
    done
}

function aux_srcclean_mame-tools() {
    f="$1"
    local m="ERROR: Input invalid !!!"
    local DIR=`dirname $f`
    
    TAM=`du -h $f`
    keep_backup="1"
    dry_run="0"
    nwcb_mac="0"
    nwcb_unix="0"
    nwcb_dos="0"
    local default
    while true
    do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "size/input: ~$TAM\n\nOptional parameters:\n(Use this tool at your own risk. Just to be safe, keep the 'Keep backup' option enabled)" 22 76 16)
        local options=()

        options+=(- "Exit")
        if [[ "$keep_backup" -eq 1 ]]; then
            options+=(K "Keep backup (Enabled)")
        else
            options+=(K "Keep backup (Disabled)")
        fi
        if [[ "$dry_run" -eq 1 ]]; then
            options+=(D "Dry run (Enabled)")
        else
            options+=(D "Dry run (Disabled)")
        fi
        if [[ "$nwcb_mac" -eq 1 ]]; then
            options+=(M "Newline mode/cleaner base - Macintosh (Enabled)")
        else
            options+=(M "Newline mode/cleaner base - Macintosh (Disabled)")
        fi
        if [[ "$nwcb_unix" -eq 1 ]]; then
            options+=(U "Newline mode/cleaner base - Unix (Enabled)")
        else
            options+=(U "Newline mode/cleaner base - Unix (Disabled)")
        fi
        if [[ "$nwcb_dos" -eq 1 ]]; then
            options+=(W "Newline mode/cleaner base - DOS (Enabled)")
        else
            options+=(W "Newline mode/cleaner base - DOS (Disabled)")
        fi


        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                K)
                    keep_backup="$((keep_backup ^ 1))"
                    ;;
                D)
                    dry_run="$((dry_run ^ 1))"
                    ;;
                M)
                    nwcb_mac="$((nwcb_mac ^ 1))"
                    ;;
                U)
                    nwcb_unix="$((nwcb_unix ^ 1))"
                    ;;
                W)
                    nwcb_dos="$((nwcb_dos ^ 1))"
                    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ "$keep_backup" -eq 1 ]]; then
        params+=(-b)
    fi
    if [[ "$dry_run" -eq 1 ]]; then
        params+=(-d)
    fi
    if [[ "$nwcb_mac" -eq 1 ]]; then
        params+=(-m)
    fi
    if [[ "$nwcb_unix" -eq 1 ]]; then
        params+=(-u)
    fi
    if [[ "$nwcb_dos" -eq 1 ]]; then
        params+=(-w)
    fi

    if [ -f "$f" ]; then
        clear
        cd && cd "$DIR"
        $md_inst/srcclean ${params[@]} "$f" 2> srcclean.info
        if [[ -f "$f.orig" ]]; then
            chown $user:$user "$f.orig"
        fi
        chown $user:$user "$f"
        dialog --stdout --title 'Srcclean: output info' --textbox srcclean.info 0 0
        du -h "${f%.*}"* > tam.info
        dialog --stdout --title 'Srclean: Output file(s) size (in Bytes)' --textbox tam.info 13 76 
        rm -rf "srcclean.info" "tam.info" 
        m="Cleaning completed"  
    else
        m="$m"
    fi
    dialog --stdout --clear --msgbox "$m" 8 50
}

function srcclean_mame-tools() {
    export IFS='
'
    FILE=$(dialog --stdout --title "Choose a ROM" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && aux_srcclean_mame-tools "$FILE" 
}

function testkeys_mame-tools() {
    local file="$md_inst/man/testkeys.1"
    if [[ ! -f "$file" ]]; then
        cat >"$file" << _EOF_
.\"  -*- nroff -*-
.\"
.\" testkeys.1
.\"
.\" Man page created from source and usage information
.\" Cesare Falco <c.falco@ubuntu.com>, February 2007
.\"
.TH TESTKEYS 1 2016-07-21 0.176 "MAME SDL keycode scanner"
.\"
.\" NAME chapter
.SH NAME
testkeys \- MAME SDL keycode scanner
.\"
.\" SYNOPSIS chapter
.SH SYNOPSIS
.B testkeys
.\"
.\" DESCRIPTION chapter
.SH DESCRIPTION
Since 0.113 (SDL)MAME introduced keymap files to handle keyboards
with non\-us layouts.
.PP
This simple utility helps determining which SDL keycode is bound
to each key, thus making the process of compiling keymap files a
bit easier.
.SH SEE ALSO
mame(6), mess(6)
_EOF_
        chown $user:$user "$file"
        chmod +x "$file"
    fi
    man "$file" > man.txt
    
    dialog --stdout --title 'Testkeys - MAME SDL keycode scanner' --textbox man.txt 0 0 --and-widget --stdout --title 'Testkeys' --defaultno --yesno '\n   Do you wanna start testkeys?' 10 40
    if [[ $? = 0 ]]; then
	$md_inst/testkeys
    fi
    rm -rf man.txt
}

function aux_unidasm_mame-tools() {
    f="$1"
    local DIR
    DIR=`dirname $f`

    basepc="none"
    mode="none"
    skip="none"
    count="none"
    local default
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Continue" --default-item "$default" --menu "input: $f_bn_ext\n\nParameters:" 22 76 16)
        local options=()

	options+=(- "Exit")
	if [[ "$arch" -eq 0 ]]; then
            options+=(1 "Architecture (8x300)")
        elif [[ "$arch" -eq 1 ]]; then
            options+=(1 "Architecture (adsp21xx)")
        elif [[ "$arch" -eq 2 ]]; then
            options+=(1 "Architecture (alpha)")
        elif [[ "$arch" -eq 3 ]]; then
            options+=(1 "Architecture (alpha_nt)")
        elif [[ "$arch" -eq 4 ]]; then
            options+=(1 "Architecture (alpha_unix)")
        elif [[ "$arch" -eq 5 ]]; then
            options+=(1 "Architecture (alpha_vms)")
        elif [[ "$arch" -eq 6 ]]; then
            options+=(1 "Architecture (alpha8201)")
        elif [[ "$arch" -eq 7 ]]; then
            options+=(1 "Architecture (alto2)")
        elif [[ "$arch" -eq 8 ]]; then
            options+=(1 "Architecture (am29000)")
        elif [[ "$arch" -eq 9 ]]; then
            options+=(1 "Architecture (amis2000)")
        elif [[ "$arch" -eq 10 ]]; then
            options+=(1 "Architecture (apexc)")
        elif [[ "$arch" -eq 11 ]]; then
            options+=(1 "Architecture (arc)")
        elif [[ "$arch" -eq 12 ]]; then
            options+=(1 "Architecture (arcompact)")
        elif [[ "$arch" -eq 13 ]]; then
            options+=(1 "Architecture (arm)")
        elif [[ "$arch" -eq 14 ]]; then
            options+=(1 "Architecture (arm_be)")
        elif [[ "$arch" -eq 15 ]]; then
            options+=(1 "Architecture (arm7)")
        elif [[ "$arch" -eq 16 ]]; then
            options+=(1 "Architecture (arm7_be)")
        elif [[ "$arch" -eq 17 ]]; then
            options+=(1 "Architecture (arm7thumb)")
        elif [[ "$arch" -eq 18 ]]; then
            options+=(1 "Architecture (arm7thumbb)")
        elif [[ "$arch" -eq 19 ]]; then
            options+=(1 "Architecture (asap)")
        elif [[ "$arch" -eq 20 ]]; then
            options+=(1 "Architecture (avr8)")
        elif [[ "$arch" -eq 21 ]]; then
            options+=(1 "Architecture (axc51core)")
        elif [[ "$arch" -eq 22 ]]; then
            options+=(1 "Architecture (axc208)")
        elif [[ "$arch" -eq 23 ]]; then
            options+=(1 "Architecture (capricorn)")
        elif [[ "$arch" -eq 24 ]]; then
            options+=(1 "Architecture (ccpu)")
        elif [[ "$arch" -eq 25 ]]; then
            options+=(1 "Architecture (cdp1801)")
        elif [[ "$arch" -eq 26 ]]; then
            options+=(1 "Architecture (cdp1802)")
        elif [[ "$arch" -eq 27 ]]; then
            options+=(1 "Architecture (cdp1805)")
        elif [[ "$arch" -eq 28 ]]; then
            options+=(1 "Architecture (clipper)")
        elif [[ "$arch" -eq 29 ]]; then
            options+=(1 "Architecture (coldfire)")
        elif [[ "$arch" -eq 30 ]]; then
            options+=(1 "Architecture (cop410)")
        elif [[ "$arch" -eq 31 ]]; then
            options+=(1 "Architecture (cop420)")
        elif [[ "$arch" -eq 32 ]]; then
            options+=(1 "Architecture (cop444)")
        elif [[ "$arch" -eq 33 ]]; then
            options+=(1 "Architecture (cop424)")
        elif [[ "$arch" -eq 34 ]]; then
            options+=(1 "Architecture (cp1610)")
        elif [[ "$arch" -eq 35 ]]; then
            options+=(1 "Architecture (cr16a)")
        elif [[ "$arch" -eq 36 ]]; then
            options+=(1 "Architecture (cr16b)")
        elif [[ "$arch" -eq 37 ]]; then
            options+=(1 "Architecture (cquestlin)")
        elif [[ "$arch" -eq 38 ]]; then
            options+=(1 "Architecture (cquestrot)")
        elif [[ "$arch" -eq 39 ]]; then
            options+=(1 "Architecture (cquestsnd)")
        elif [[ "$arch" -eq 40 ]]; then
            options+=(1 "Architecture (dp8344)")
        elif [[ "$arch" -eq 41 ]]; then
            options+=(1 "Architecture (ds5002fp)")
        elif [[ "$arch" -eq 42 ]]; then
            options+=(1 "Architecture (dsp16)")
        elif [[ "$arch" -eq 43 ]]; then
            options+=(1 "Architecture (dsp32c)")
        elif [[ "$arch" -eq 44 ]]; then
            options+=(1 "Architecture (dsp56000)")
        elif [[ "$arch" -eq 45 ]]; then
            options+=(1 "Architecture (dsp56156)")
        elif [[ "$arch" -eq 46 ]]; then
            options+=(1 "Architecture (e0c6200)")
        elif [[ "$arch" -eq 47 ]]; then
            options+=(1 "Architecture (epg3231)")
        elif [[ "$arch" -eq 48 ]]; then
            options+=(1 "Architecture (esrip)")
        elif [[ "$arch" -eq 49 ]]; then
            options+=(1 "Architecture (f2mc16)")
        elif [[ "$arch" -eq 50 ]]; then
            options+=(1 "Architecture (f8)")
        elif [[ "$arch" -eq 51 ]]; then
            options+=(1 "Architecture (fr)")
    	elif [[ "$arch" -eq 52 ]]; then
	    options+=(1 "Architecture (g65816)")
    	elif [[ "$arch" -eq 53 ]]; then
	    options+=(1 "Architecture (gigatron)")
    	elif [[ "$arch" -eq 54 ]]; then
	    options+=(1 "Architecture (h6280)")
    	elif [[ "$arch" -eq 55 ]]; then
	    options+=(1 "Architecture (h8)")
    	elif [[ "$arch" -eq 56 ]]; then
	    options+=(1 "Architecture (h8h)")
    	elif [[ "$arch" -eq 57 ]]; then
	    options+=(1 "Architecture (h8s2000)")
    	elif [[ "$arch" -eq 58 ]]; then
	    options+=(1 "Architecture (h8s2600)")
    	elif [[ "$arch" -eq 59 ]]; then
	    options+=(1 "Architecture (hc11)")
    	elif [[ "$arch" -eq 60 ]]; then
	    options+=(1 "Architecture (hcd62121)")
    	elif [[ "$arch" -eq 61 ]]; then
	    options+=(1 "Architecture (hd61700)")
    	elif [[ "$arch" -eq 62 ]]; then
	    options+=(1 "Architecture (hd6301)")
    	elif [[ "$arch" -eq 63 ]]; then
	    options+=(1 "Architecture (hd6309)")
    	elif [[ "$arch" -eq 64 ]]; then
	    options+=(1 "Architecture (hd63701)")
    	elif [[ "$arch" -eq 65 ]]; then
	    options+=(1 "Architecture (hmcs40)")
    	elif [[ "$arch" -eq 66 ]]; then
	    options+=(1 "Architecture (hp_5061_3001)")
    	elif [[ "$arch" -eq 67 ]]; then
	    options+=(1 "Architecture (hp_5061_3011)")
    	elif [[ "$arch" -eq 68 ]]; then
	    options+=(1 "Architecture (hp_09825_67907)")
    	elif [[ "$arch" -eq 69 ]]; then
	    options+=(1 "Architecture (hpc16083)")
    	elif [[ "$arch" -eq 70 ]]; then
	    options+=(1 "Architecture (hpc16164)")
    	elif [[ "$arch" -eq 71 ]]; then
	    options+=(1 "Architecture (hyperstone)")
    	elif [[ "$arch" -eq 72 ]]; then
	    options+=(1 "Architecture (i4004)")
    	elif [[ "$arch" -eq 73 ]]; then
	    options+=(1 "Architecture (i4040)")
    	elif [[ "$arch" -eq 74 ]]; then
	    options+=(1 "Architecture (i8008)")
    	elif [[ "$arch" -eq 75 ]]; then
	    options+=(1 "Architecture (i802x)")
    	elif [[ "$arch" -eq 76 ]]; then
	    options+=(1 "Architecture (i8051)")
    	elif [[ "$arch" -eq 77 ]]; then
	    options+=(1 "Architecture (i8052)")
    	elif [[ "$arch" -eq 78 ]]; then
	    options+=(1 "Architecture (i8085)")
    	elif [[ "$arch" -eq 79 ]]; then
	    options+=(1 "Architecture (i8089)")
    	elif [[ "$arch" -eq 80 ]]; then
	    options+=(1 "Architecture (i80c52)")
    	elif [[ "$arch" -eq 81 ]]; then
	    options+=(1 "Architecture (i860)")
    	elif [[ "$arch" -eq 82 ]]; then
	    options+=(1 "Architecture (i8x9x)")
    	elif [[ "$arch" -eq 83 ]]; then
	    options+=(1 "Architecture (i8xc196)")
    	elif [[ "$arch" -eq 84 ]]; then
	    options+=(1 "Architecture (i8xc51fx)")
    	elif [[ "$arch" -eq 85 ]]; then
	    options+=(1 "Architecture (i8xc51gb)")
    	elif [[ "$arch" -eq 86 ]]; then
	    options+=(1 "Architecture (i960)")
    	elif [[ "$arch" -eq 87 ]]; then
	    options+=(1 "Architecture (ie15)")
    	elif [[ "$arch" -eq 88 ]]; then
	    options+=(1 "Architecture (jaguardsp)")
    	elif [[ "$arch" -eq 89 ]]; then
	    options+=(1 "Architecture (jaguargpu)")
    	elif [[ "$arch" -eq 90 ]]; then
	    options+=(1 "Architecture (konami)")
    	elif [[ "$arch" -eq 91 ]]; then
	    options+=(1 "Architecture (ks0164)")
    	elif [[ "$arch" -eq 92 ]]; then
	    options+=(1 "Architecture (lc8670)")
    	elif [[ "$arch" -eq 93 ]]; then
	    options+=(1 "Architecture (lh5801)")
    	elif [[ "$arch" -eq 94 ]]; then
	    options+=(1 "Architecture (lr35902)")
    	elif [[ "$arch" -eq 95 ]]; then
	    options+=(1 "Architecture (m146805)")
    	elif [[ "$arch" -eq 96 ]]; then
	    options+=(1 "Architecture (m37710)")
    	elif [[ "$arch" -eq 97 ]]; then
	    options+=(1 "Architecture (m4510)")
    	elif [[ "$arch" -eq 98 ]]; then
	    options+=(1 "Architecture (m58846)")
    	elif [[ "$arch" -eq 98 ]]; then
	    options+=(1 "Architecture (m6502)")
    	elif [[ "$arch" -eq 99 ]]; then
	    options+=(1 "Architecture (m6509)")
    	elif [[ "$arch" -eq 100 ]]; then
	    options+=(1 "Architecture (m6510)")
    	elif [[ "$arch" -eq 101 ]]; then
	    options+=(1 "Architecture (m65c02)")
    	elif [[ "$arch" -eq 102 ]]; then
	    options+=(1 "Architecture (m65ce02)")
    	elif [[ "$arch" -eq 103 ]]; then
	    options+=(1 "Architecture (m6800)")
    	elif [[ "$arch" -eq 104 ]]; then
	    options+=(1 "Architecture (m68000)")
    	elif [[ "$arch" -eq 105 ]]; then
	    options+=(1 "Architecture (m68008)")
    	elif [[ "$arch" -eq 106 ]]; then
	    options+=(1 "Architecture (m6801)")
    	elif [[ "$arch" -eq 107 ]]; then
	    options+=(1 "Architecture (m68010)")
    	elif [[ "$arch" -eq 108 ]]; then
	    options+=(1 "Architecture (m6802)")
    	elif [[ "$arch" -eq 109 ]]; then
	    options+=(1 "Architecture (m68020)")
    	elif [[ "$arch" -eq 110 ]]; then
	    options+=(1 "Architecture (m6803)")
    	elif [[ "$arch" -eq 111 ]]; then
	    options+=(1 "Architecture (m68030)")
    	elif [[ "$arch" -eq 112 ]]; then
	    options+=(1 "Architecture (m68040)")
    	elif [[ "$arch" -eq 113 ]]; then
	    options+=(1 "Architecture (m6805)")
    	elif [[ "$arch" -eq 114 ]]; then
	    options+=(1 "Architecture (m6808)")
    	elif [[ "$arch" -eq 115 ]]; then
	    options+=(1 "Architecture (m6809)")
    	elif [[ "$arch" -eq 116 ]]; then
	    options+=(1 "Architecture (m68340)")
    	elif [[ "$arch" -eq 117 ]]; then
	    options+=(1 "Architecture (m68hc05)")
    	elif [[ "$arch" -eq 118 ]]; then
	    options+=(1 "Architecture (m740)")
    	elif [[ "$arch" -eq 119 ]]; then
	    options+=(1 "Architecture (mb86233)")
    	elif [[ "$arch" -eq 120 ]]; then
	    options+=(1 "Architecture (mb86235)")
    	elif [[ "$arch" -eq 121 ]]; then
	    options+=(1 "Architecture (mb88)")
    	elif [[ "$arch" -eq 122 ]]; then
	    options+=(1 "Architecture (mc88100)")
    	elif [[ "$arch" -eq 123 ]]; then
	    options+=(1 "Architecture (mc88110)")
    	elif [[ "$arch" -eq 124 ]]; then
	    options+=(1 "Architecture (mcs48)")
    	elif [[ "$arch" -eq 125 ]]; then
	    options+=(1 "Architecture (minx)")
    	elif [[ "$arch" -eq 126 ]]; then
	    options+=(1 "Architecture (mips1be)")
    	elif [[ "$arch" -eq 127 ]]; then
	    options+=(1 "Architecture (mips1le)")
    	elif [[ "$arch" -eq 128 ]]; then
	    options+=(1 "Architecture (mips3be)")
    	elif [[ "$arch" -eq 129 ]]; then
	    options+=(1 "Architecture (mips3le)")
    	elif [[ "$arch" -eq 130 ]]; then
	    options+=(1 "Architecture (mn10200)")
    	elif [[ "$arch" -eq 131 ]]; then
	    options+=(1 "Architecture (nanoprocessor)")
    	elif [[ "$arch" -eq 132 ]]; then
	    options+=(1 "Architecture (nec)")
    	elif [[ "$arch" -eq 133 ]]; then
	    options+=(1 "Architecture (ns32000)")
	elif [[ "$arch" -eq 134 ]]; then
	    options+=(1 "Architecture (nuon)")
	elif [[ "$arch" -eq 135 ]]; then
	    options+=(1 "Architecture (nsc8105)")
    	elif [[ "$arch" -eq 136 ]]; then
	    options+=(1 "Architecture (pace)")
    	elif [[ "$arch" -eq 137 ]]; then
	    options+=(1 "Architecture (patinho_feio)")
    	elif [[ "$arch" -eq 138 ]]; then
	    options+=(1 "Architecture (pdp1)")
    	elif [[ "$arch" -eq 139 ]]; then
	    options+=(1 "Architecture (pdp8)")
    	elif [[ "$arch" -eq 140 ]]; then
	    options+=(1 "Architecture (pic16c5x)")
    	elif [[ "$arch" -eq 141 ]]; then
	    options+=(1 "Architecture (pic16c62x)")
    	elif [[ "$arch" -eq 142 ]]; then
	    options+=(1 "Architecture (powerpc)")
    	elif [[ "$arch" -eq 143 ]]; then
	    options+=(1 "Architecture (pps4)")
    	elif [[ "$arch" -eq 144 ]]; then
	    options+=(1 "Architecture (psxcpu)")
    	elif [[ "$arch" -eq 145 ]]; then
	    options+=(1 "Architecture (r65c02)")
    	elif [[ "$arch" -eq 146 ]]; then
	    options+=(1 "Architecture (r65c19)")
    	elif [[ "$arch" -eq 147 ]]; then
	    options+=(1 "Architecture (romp)")
    	elif [[ "$arch" -eq 148 ]]; then
	    options+=(1 "Architecture (rsp)")
    	elif [[ "$arch" -eq 149 ]]; then
	    options+=(1 "Architecture (rx01)")
    	elif [[ "$arch" -eq 150 ]]; then
	    options+=(1 "Architecture (s2650)")
    	elif [[ "$arch" -eq 151 ]]; then
	    options+=(1 "Architecture (saturn)")
    	elif [[ "$arch" -eq 152 ]]; then
	    options+=(1 "Architecture (sc61860)")
    	elif [[ "$arch" -eq 153 ]]; then
	    options+=(1 "Architecture (scmp)")
    	elif [[ "$arch" -eq 154 ]]; then
	    options+=(1 "Architecture (score7)")
    	elif [[ "$arch" -eq 155 ]]; then
	    options+=(1 "Architecture (scudsp)")
    	elif [[ "$arch" -eq 156 ]]; then
	    options+=(1 "Architecture (se3208)")
    	elif [[ "$arch" -eq 157 ]]; then
	    options+=(1 "Architecture (sh2)")
    	elif [[ "$arch" -eq 158 ]]; then
	    options+=(1 "Architecture (sh4)")
    	elif [[ "$arch" -eq 159 ]]; then
	    options+=(1 "Architecture (sh4be)")
    	elif [[ "$arch" -eq 160 ]]; then
	    options+=(1 "Architecture (sharc)")
    	elif [[ "$arch" -eq 161 ]]; then
	    options+=(1 "Architecture (sm500)")
    	elif [[ "$arch" -eq 162 ]]; then
	    options+=(1 "Architecture (sm510)")
    	elif [[ "$arch" -eq 163 ]]; then
	    options+=(1 "Architecture (sm511)")
    	elif [[ "$arch" -eq 164 ]]; then
	    options+=(1 "Architecture (sm530)")
    	elif [[ "$arch" -eq 165 ]]; then
	    options+=(1 "Architecture (sm590)")
    	elif [[ "$arch" -eq 166 ]]; then
	    options+=(1 "Architecture (sm5a)")
    	elif [[ "$arch" -eq 167 ]]; then
	    options+=(1 "Architecture (sm8500)")
    	elif [[ "$arch" -eq 168 ]]; then
	    options+=(1 "Architecture (sparcv7)")
    	elif [[ "$arch" -eq 169 ]]; then
	    options+=(1 "Architecture (sparcv8)")
    	elif [[ "$arch" -eq 170 ]]; then
	    options+=(1 "Architecture (sparcv9)")
    	elif [[ "$arch" -eq 171 ]]; then
	    options+=(1 "Architecture (sparcv9vis1)")
    	elif [[ "$arch" -eq 172 ]]; then
	    options+=(1 "Architecture (sparcv9vis2)")
    	elif [[ "$arch" -eq 173 ]]; then
	    options+=(1 "Architecture (sparcv9vis2p)")
    	elif [[ "$arch" -eq 174 ]]; then
	    options+=(1 "Architecture (sparcv9vis3)")
    	elif [[ "$arch" -eq 175 ]]; then
	    options+=(1 "Architecture (sparcv9vis3b)")
    	elif [[ "$arch" -eq 176 ]]; then
	    options+=(1 "Architecture (spc700)")
    	elif [[ "$arch" -eq 177 ]]; then
	    options+=(1 "Architecture (ssem)")
    	elif [[ "$arch" -eq 178 ]]; then
	    options+=(1 "Architecture (ssp1601)")
    	elif [[ "$arch" -eq 179 ]]; then
	    options+=(1 "Architecture (st62xx)")
    	elif [[ "$arch" -eq 180 ]]; then
	    options+=(1 "Architecture (superfx)")
    	elif [[ "$arch" -eq 181 ]]; then
	    options+=(1 "Architecture (t11)")
    	elif [[ "$arch" -eq 182 ]]; then
	    options+=(1 "Architecture (tlcs870)")
    	elif [[ "$arch" -eq 183 ]]; then
	    options+=(1 "Architecture (tlcs900)")
    	elif [[ "$arch" -eq 184 ]]; then
	    options+=(1 "Architecture (tmp90840)")
    	elif [[ "$arch" -eq 185 ]]; then
	    options+=(1 "Architecture (tmp90844)")
    	elif [[ "$arch" -eq 186 ]]; then
	    options+=(1 "Architecture (tms0980)")
    	elif [[ "$arch" -eq 187 ]]; then
	    options+=(1 "Architecture (tms1000)")
    	elif [[ "$arch" -eq 188 ]]; then
	    options+=(1 "Architecture (tms1100)")
    	elif [[ "$arch" -eq 189 ]]; then
	    options+=(1 "Architecture (tms32010)")
    	elif [[ "$arch" -eq 190 ]]; then
	    options+=(1 "Architecture (tms32025)")
    	elif [[ "$arch" -eq 191 ]]; then
	    options+=(1 "Architecture (tms32031)")
    	elif [[ "$arch" -eq 192 ]]; then
	    options+=(1 "Architecture (tms32051)")
    	elif [[ "$arch" -eq 193 ]]; then
	    options+=(1 "Architecture (tms32082_mp)")
    	elif [[ "$arch" -eq 194 ]]; then
	    options+=(1 "Architecture (tms32082_pp)")
    	elif [[ "$arch" -eq 195 ]]; then
	    options+=(1 "Architecture (tms34010)")
    	elif [[ "$arch" -eq 196 ]]; then
	    options+=(1 "Architecture (tms34020)")
    	elif [[ "$arch" -eq 197 ]]; then
	    options+=(1 "Architecture (tms57002)")
    	elif [[ "$arch" -eq 198 ]]; then
	    options+=(1 "Architecture (tms7000)")
    	elif [[ "$arch" -eq 199 ]]; then
	    options+=(1 "Architecture (tms9900)")
    	elif [[ "$arch" -eq 200 ]]; then
	    options+=(1 "Architecture (tms9980)")
    	elif [[ "$arch" -eq 201 ]]; then
	    options+=(1 "Architecture (tms9995)")
    	elif [[ "$arch" -eq 202 ]]; then
	    options+=(1 "Architecture (tp0320)")
    	elif [[ "$arch" -eq 203 ]]; then
	    options+=(1 "Architecture (tx0_64kw)")
    	elif [[ "$arch" -eq 204 ]]; then
	    options+=(1 "Architecture (tx0_8kw)")
    	elif [[ "$arch" -eq 205 ]]; then
	    options+=(1 "Architecture (ucom4)")
    	elif [[ "$arch" -eq 206 ]]; then
	    options+=(1 "Architecture (unsp10)")
    	elif [[ "$arch" -eq 207 ]]; then
	    options+=(1 "Architecture (unsp12)")
    	elif [[ "$arch" -eq 208 ]]; then
	    options+=(1 "Architecture (unsp20)")
    	elif [[ "$arch" -eq 209 ]]; then
	    options+=(1 "Architecture (upd7725)")
    	elif [[ "$arch" -eq 210 ]]; then
	    options+=(1 "Architecture (upd7801)")
    	elif [[ "$arch" -eq 211 ]]; then
	    options+=(1 "Architecture (upd78c05)")
    	elif [[ "$arch" -eq 212 ]]; then
	    options+=(1 "Architecture (upd7807)")
    	elif [[ "$arch" -eq 213 ]]; then
	    options+=(1 "Architecture (upd7810)")
    	elif [[ "$arch" -eq 214 ]]; then
	    options+=(1 "Architecture (upd78014)")
    	elif [[ "$arch" -eq 215 ]]; then
	    options+=(1 "Architecture (upd78024)")
    	elif [[ "$arch" -eq 216 ]]; then
	    options+=(1 "Architecture (upd78044a)")
    	elif [[ "$arch" -eq 217 ]]; then
	    options+=(1 "Architecture (upd78054)")
    	elif [[ "$arch" -eq 218 ]]; then
	    options+=(1 "Architecture (upd78064)")
    	elif [[ "$arch" -eq 219 ]]; then
	    options+=(1 "Architecture (upd78078)")
    	elif [[ "$arch" -eq 220 ]]; then
	    options+=(1 "Architecture (upd78083)")
    	elif [[ "$arch" -eq 221 ]]; then
	    options+=(1 "Architecture (upd78138)")
    	elif [[ "$arch" -eq 222 ]]; then
	    options+=(1 "Architecture (upd78148)")
    	elif [[ "$arch" -eq 223 ]]; then
	    options+=(1 "Architecture (upd78214)")
    	elif [[ "$arch" -eq 224 ]]; then
	    options+=(1 "Architecture (upd78218a)")
    	elif [[ "$arch" -eq 225 ]]; then
	    options+=(1 "Architecture (upd78224)")
    	elif [[ "$arch" -eq 226 ]]; then
	    options+=(1 "Architecture (upd78234)")
    	elif [[ "$arch" -eq 227 ]]; then
	    options+=(1 "Architecture (upd78244)")
    	elif [[ "$arch" -eq 228 ]]; then
	    options+=(1 "Architecture (upd780024a)")
    	elif [[ "$arch" -eq 229 ]]; then
	    options+=(1 "Architecture (upd78312)")
    	elif [[ "$arch" -eq 230 ]]; then
	    options+=(1 "Architecture (upd78322)")
    	elif [[ "$arch" -eq 231 ]]; then
	    options+=(1 "Architecture (upd78328)")
    	elif [[ "$arch" -eq 232 ]]; then
	    options+=(1 "Architecture (upd78334)")
    	elif [[ "$arch" -eq 233 ]]; then
	    options+=(1 "Architecture (upd78352)")
    	elif [[ "$arch" -eq 234 ]]; then
	    options+=(1 "Architecture (upd78356)")
    	elif [[ "$arch" -eq 235 ]]; then
	    options+=(1 "Architecture (upd78366a)")
    	elif [[ "$arch" -eq 236 ]]; then
	    options+=(1 "Architecture (upd78372)")
    	elif [[ "$arch" -eq 237 ]]; then
	    options+=(1 "Architecture (upd780065)")
    	elif [[ "$arch" -eq 238 ]]; then
	    options+=(1 "Architecture (upd780988)")
    	elif [[ "$arch" -eq 239 ]]; then
	    options+=(1 "Architecture (upd78k0kx1)")
    	elif [[ "$arch" -eq 240 ]]; then
	    options+=(1 "Architecture (upd78k0kx2)")
    	elif [[ "$arch" -eq 241 ]]; then
	    options+=(1 "Architecture (upi41)")
    	elif [[ "$arch" -eq 242 ]]; then
	    options+=(1 "Architecture (v60)")
    	elif [[ "$arch" -eq 243 ]]; then
	    options+=(1 "Architecture (v810)")
    	elif [[ "$arch" -eq 244 ]]; then
	    options+=(1 "Architecture (vt50)")
    	elif [[ "$arch" -eq 245 ]]; then
	    options+=(1 "Architecture (vt52)")
    	elif [[ "$arch" -eq 246 ]]; then
	    options+=(1 "Architecture (vt61)")
    	elif [[ "$arch" -eq 247 ]]; then
	    options+=(1 "Architecture (we32100)")
    	elif [[ "$arch" -eq 248 ]]; then
	    options+=(1 "Architecture (x86_16)")
    	elif [[ "$arch" -eq 249 ]]; then
	    options+=(1 "Architecture (x86_32)")
    	elif [[ "$arch" -eq 250 ]]; then
	    options+=(1 "Architecture (x86_64)")
    	elif [[ "$arch" -eq 251 ]]; then
	    options+=(1 "Architecture (xavix)")
    	elif [[ "$arch" -eq 252 ]]; then
	    options+=(1 "Architecture (xavix2000)")
    	elif [[ "$arch" -eq 253 ]]; then
	    options+=(1 "Architecture (xavix2)")
    	elif [[ "$arch" -eq 254 ]]; then
	    options+=(1 "Architecture (z180)")  
    	elif [[ "$arch" -eq 255 ]]; then
	    options+=(1 "Architecture (z8)")  
    	elif [[ "$arch" -eq 256 ]]; then
	    options+=(1 "Architecture (z80)")  
    	elif [[ "$arch" -eq 257 ]]; then
	    options+=(1 "Architecture (z8000)")            
        fi
	options+=(2 "Base PC: $basepc")
	options+=(3 "Mode: $mode")
        if [[ "$norawbytes" -eq 1 ]]; then
            options+=(4 "No raw bytes (Enabled)")
        else
            options+=(4 "No raw bytes (Disabled)")
        fi
        if [[ "$xchbytes" -eq 1 ]]; then
            options+=(5 "Xch bytes (Enabled)")
        else
            options+=(5 "Xch bytes (Disabled)")
        fi
        if [[ "$flipped" -eq 1 ]]; then
            options+=(6 "Flipped (Enabled)")
        else
            options+=(6 "Flipped (Disabled)")
        fi
        if [[ "$upper" -eq 1 ]]; then
            options+=(7 "Upper (Enabled)")
        else
            options+=(7 "Upper (Disabled)")
        fi
        if [[ "$lower" -eq 1 ]]; then
            options+=(8 "Lower (Enabled)")
        else
            options+=(8 "Lower (Disabled)")
        fi
	options+=(9 "Skip ($skip)")
	options+=(10 "Counter ($count)")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
		1)  
                    arch="$((( arch + 1) % 258))"
 		    ;;
		2)
                    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the base PC:" 10 60 "$basepc")
                    basepc=$("${cmd[@]}" 2>&1 >/dev/tty)		    
		    ;;
		3)
		    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the mode:" 10 60 "$mode")
                    mode=$("${cmd[@]}" 2>&1 >/dev/tty)
		    ;;
		4)
		    norawbytes="$((norawbytes ^ 1))"
		    ;;
		5)
		    xchbytes="$((xchbytes ^ 1))"
		    ;;
		6)
		    flipped="$((flipped ^ 1))"
		    ;;
		7)
		    upper="$((upper ^ 1))"
		    ;;
		8)
		    lower="$((lower ^ 1))"
		    ;;
		9)
		    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the skip:" 10 60 "$skip")
                    skip=$("${cmd[@]}" 2>&1 >/dev/tty)
		    ;;
		10)
		    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please type the count:" 10 60 "$count")
                    count=$("${cmd[@]}" 2>&1 >/dev/tty)
		    ;;
		-)
		    return 0
		    ;;
            esac
        else
            break
        fi
    done

    local params=()
    if [[ "$arch" -eq 0 ]]; then
        params+=(-arch 8x300)
    elif [[ "$arch" -eq 1 ]]; then
        params+=(-arch adsp21xx)
    elif [[ "$arch" -eq 2 ]]; then
        params+=(-arch alpha)
    elif [[ "$arch" -eq 3 ]]; then
        params+=(-arch alpha_nt)
    elif [[ "$arch" -eq 4 ]]; then
        params+=(-arch alpha_unix)
    elif [[ "$arch" -eq 5 ]]; then
        params+=(-arch alpha_vms)
    elif [[ "$arch" -eq 6 ]]; then
        params+=(-arch alpha8201)
    elif [[ "$arch" -eq 7 ]]; then
        params+=(-arch alto2)
    elif [[ "$arch" -eq 8 ]]; then
        params+=(-arch am29000)
    elif [[ "$arch" -eq 9 ]]; then
        params+=(-arch amis2000)
    elif [[ "$arch" -eq 10 ]]; then
        params+=(-arch apexc)
    elif [[ "$arch" -eq 11 ]]; then
        params+=(-arch arc)
    elif [[ "$arch" -eq 12 ]]; then
        params+=(-arch arcompact)
    elif [[ "$arch" -eq 13 ]]; then
        params+=(-arch arm)
    elif [[ "$arch" -eq 14 ]]; then
        params+=(-arch arm_be)
    elif [[ "$arch" -eq 15 ]]; then
        params+=(-arch arm7)
    elif [[ "$arch" -eq 16 ]]; then
        params+=(-arch arm7_be)
    elif [[ "$arch" -eq 17 ]]; then
        params+=(-arch arm7thumb)
    elif [[ "$arch" -eq 18 ]]; then
        params+=(-arch arm7thumbb)
    elif [[ "$arch" -eq 19 ]]; then
        params+=(-arch asap)
    elif [[ "$arch" -eq 20 ]]; then
        params+=(-arch avr8)
    elif [[ "$arch" -eq 21 ]]; then
        params+=(-arch axc51core)
    elif [[ "$arch" -eq 22 ]]; then
        params+=(-arch axc208)
    elif [[ "$arch" -eq 23 ]]; then
        params+=(-arch capricorn)
    elif [[ "$arch" -eq 24 ]]; then
        params+=(-arch ccpu)
    elif [[ "$arch" -eq 25 ]]; then
        params+=(-arch cdp1801)
    elif [[ "$arch" -eq 26 ]]; then
        params+=(-arch cdp1802)
    elif [[ "$arch" -eq 27 ]]; then
        params+=(-arch cdp1805)
    elif [[ "$arch" -eq 28 ]]; then
        params+=(-arch clipper)
    elif [[ "$arch" -eq 29 ]]; then
        params+=(-arch coldfire)
    elif [[ "$arch" -eq 30 ]]; then
        params+=(-arch cop410)
    elif [[ "$arch" -eq 31 ]]; then
        params+=(-arch cop420)
    elif [[ "$arch" -eq 32 ]]; then
        params+=(-arch cop444)
    elif [[ "$arch" -eq 33 ]]; then
        params+=(-arch cop424)
    elif [[ "$arch" -eq 34 ]]; then
        params+=(-arch cp1610)
    elif [[ "$arch" -eq 35 ]]; then
        params+=(-arch cr16a)
    elif [[ "$arch" -eq 36 ]]; then
        params+=(-arch cr16b)
    elif [[ "$arch" -eq 37 ]]; then
        params+=(-arch cquestlin)
    elif [[ "$arch" -eq 38 ]]; then
        params+=(-arch cquestrot)
    elif [[ "$arch" -eq 39 ]]; then
        params+=(-arch cquestsnd)
    elif [[ "$arch" -eq 40 ]]; then
        params+=(-arch dp8344)
    elif [[ "$arch" -eq 41 ]]; then
        params+=(-arch ds5002fp)
    elif [[ "$arch" -eq 42 ]]; then
        params+=(-arch dsp16)
    elif [[ "$arch" -eq 43 ]]; then
        params+=(-arch dsp32c)
    elif [[ "$arch" -eq 44 ]]; then
        params+=(-arch dsp56000)
    elif [[ "$arch" -eq 45 ]]; then
        params+=(-arch dsp56156)
    elif [[ "$arch" -eq 46 ]]; then
        params+=(-arch e0c6200)
    elif [[ "$arch" -eq 47 ]]; then
        params+=(-arch epg3231)
    elif [[ "$arch" -eq 48 ]]; then
        params+=(-arch esrip)
    elif [[ "$arch" -eq 49 ]]; then
        params+=(-arch f2mc16)
    elif [[ "$arch" -eq 50 ]]; then
        params+=(-arch f8)
    elif [[ "$arch" -eq 51 ]]; then
        params+=(-arch fr)
    elif [[ "$arch" -eq 52 ]]; then
        params+=(-arch g65816)
    elif [[ "$arch" -eq 53 ]]; then
        params+=(-arch gigatron)
    elif [[ "$arch" -eq 54 ]]; then
        params+=(-arch h6280)
    elif [[ "$arch" -eq 55 ]]; then
        params+=(-arch h8)
    elif [[ "$arch" -eq 56 ]]; then
        params+=(-arch h8h)
    elif [[ "$arch" -eq 57 ]]; then
        params+=(-arch h8s2000)
    elif [[ "$arch" -eq 58 ]]; then
        params+=(-arch h8s2600)
    elif [[ "$arch" -eq 59 ]]; then
        params+=(-arch hc11)
    elif [[ "$arch" -eq 60 ]]; then
        params+=(-arch hcd62121)
    elif [[ "$arch" -eq 61 ]]; then
        params+=(-arch hd61700)
    elif [[ "$arch" -eq 62 ]]; then
        params+=(-arch hd6301)
    elif [[ "$arch" -eq 63 ]]; then
        params+=(-arch hd6309)
    elif [[ "$arch" -eq 64 ]]; then
        params+=(-arch hd63701)
    elif [[ "$arch" -eq 65 ]]; then
        params+=(-arch hmcs40)
    elif [[ "$arch" -eq 66 ]]; then
        params+=(-arch hp_5061_3001)
    elif [[ "$arch" -eq 67 ]]; then
        params+=(-arch hp_5061_3011)
    elif [[ "$arch" -eq 68 ]]; then
        params+=(-arch hp_09825_67907)
    elif [[ "$arch" -eq 69 ]]; then
        params+=(-arch hpc16083)
    elif [[ "$arch" -eq 70 ]]; then
        params+=(-arch hpc16164)
    elif [[ "$arch" -eq 71 ]]; then
        params+=(-arch hyperstone)
    elif [[ "$arch" -eq 72 ]]; then
        params+=(-arch i4004)
    elif [[ "$arch" -eq 73 ]]; then
        params+=(-arch i4040)
    elif [[ "$arch" -eq 74 ]]; then
        params+=(-arch i8008)
    elif [[ "$arch" -eq 75 ]]; then
        params+=(-arch i802x)
    elif [[ "$arch" -eq 76 ]]; then
        params+=(-arch i8051)
    elif [[ "$arch" -eq 77 ]]; then
        params+=(-arch i8052)
    elif [[ "$arch" -eq 78 ]]; then
        params+=(-arch i8085)
    elif [[ "$arch" -eq 79 ]]; then
        params+=(-arch i8089)
    elif [[ "$arch" -eq 80 ]]; then
        params+=(-arch i80c52)
    elif [[ "$arch" -eq 81 ]]; then
        params+=(-arch i860)
    elif [[ "$arch" -eq 82 ]]; then
        params+=(-arch i8x9x)
    elif [[ "$arch" -eq 83 ]]; then
        params+=(-arch i8xc196)
    elif [[ "$arch" -eq 84 ]]; then
        params+=(-arch i8xc51fx)
    elif [[ "$arch" -eq 85 ]]; then
        params+=(-arch i8xc51gb)
    elif [[ "$arch" -eq 86 ]]; then
        params+=(-arch i960)
    elif [[ "$arch" -eq 87 ]]; then
        params+=(-arch ie15)
    elif [[ "$arch" -eq 88 ]]; then
        params+=(-arch jaguardsp)
    elif [[ "$arch" -eq 89 ]]; then
        params+=(-arch jaguargpu)
    elif [[ "$arch" -eq 90 ]]; then
        params+=(-arch konami)
    elif [[ "$arch" -eq 91 ]]; then
        params+=(-arch ks0164)
    elif [[ "$arch" -eq 92 ]]; then
        params+=(-arch lc8670)
    elif [[ "$arch" -eq 93 ]]; then
        params+=(-arch lh5801)
    elif [[ "$arch" -eq 94 ]]; then
        params+=(-arch lr35902)
    elif [[ "$arch" -eq 95 ]]; then
        params+=(-arch m146805)
    elif [[ "$arch" -eq 96 ]]; then
        params+=(-arch m37710)
    elif [[ "$arch" -eq 97 ]]; then
        params+=(-arch m4510)
    elif [[ "$arch" -eq 98 ]]; then
        params+=(-arch m58846)
    elif [[ "$arch" -eq 98 ]]; then
        params+=(-arch m6502)
    elif [[ "$arch" -eq 99 ]]; then
        params+=(-arch m6509)
    elif [[ "$arch" -eq 100 ]]; then
        params+=(-arch m6510)
    elif [[ "$arch" -eq 101 ]]; then
        params+=(-arch m65c02)
    elif [[ "$arch" -eq 102 ]]; then
        params+=(-arch m65ce02) 
    elif [[ "$arch" -eq 103 ]]; then
	params+=(-arch m6800)
    elif [[ "$arch" -eq 104 ]]; then
	params+=(-arch m68000)
    elif [[ "$arch" -eq 105 ]]; then
	params+=(-arch m68008)
    elif [[ "$arch" -eq 106 ]]; then
	params+=(-arch m6801)
    elif [[ "$arch" -eq 107 ]]; then
	params+=(-arch m68010)
    elif [[ "$arch" -eq 108 ]]; then
	params+=(-arch m6802)
    elif [[ "$arch" -eq 109 ]]; then
	params+=(-arch m68020)
    elif [[ "$arch" -eq 110 ]]; then
	params+=(-arch m6803)
    elif [[ "$arch" -eq 111 ]]; then
	params+=(-arch m68030)
    elif [[ "$arch" -eq 112 ]]; then
	params+=(-arch m68040)
    elif [[ "$arch" -eq 113 ]]; then
	params+=(-arch m6805)
    elif [[ "$arch" -eq 114 ]]; then
	params+=(-arch m6808)
    elif [[ "$arch" -eq 115 ]]; then
	params+=(-arch m6809)
    elif [[ "$arch" -eq 116 ]]; then
	params+=(-arch m68340)
    elif [[ "$arch" -eq 117 ]]; then
	params+=(-arch m68hc05)
    elif [[ "$arch" -eq 118 ]]; then
	params+=(-arch m740)
    elif [[ "$arch" -eq 119 ]]; then
	params+=(-arch mb86233)
    elif [[ "$arch" -eq 120 ]]; then
	params+=(-arch mb86235)
    elif [[ "$arch" -eq 121 ]]; then
	params+=(-arch mb88)
    elif [[ "$arch" -eq 122 ]]; then
	params+=(-arch mc88100)
    elif [[ "$arch" -eq 123 ]]; then
	params+=(-arch mc88110)
    elif [[ "$arch" -eq 124 ]]; then
	params+=(-arch mcs48)
    elif [[ "$arch" -eq 125 ]]; then
	params+=(-arch minx)
    elif [[ "$arch" -eq 126 ]]; then
	params+=(-arch mips1be)
    elif [[ "$arch" -eq 127 ]]; then
	params+=(-arch mips1le)
    elif [[ "$arch" -eq 128 ]]; then
	params+=(-arch mips3be)
    elif [[ "$arch" -eq 129 ]]; then
	params+=(-arch mips3le)
    elif [[ "$arch" -eq 130 ]]; then
	params+=(-arch mn10200)
    elif [[ "$arch" -eq 131 ]]; then
	params+=(-arch nanoprocessor)
    elif [[ "$arch" -eq 132 ]]; then
	params+=(-arch nec)
    elif [[ "$arch" -eq 133 ]]; then
	params+=(-arch ns32000)
    elif [[ "$arch" -eq 134 ]]; then
	params+=(-arch nuon)
    elif [[ "$arch" -eq 135 ]]; then
	params+=(-arch nsc8105)
    elif [[ "$arch" -eq 136 ]]; then
	params+=(-arch pace)
    elif [[ "$arch" -eq 137 ]]; then
	params+=(-arch patinho_feio)
    elif [[ "$arch" -eq 138 ]]; then
	params+=(-arch pdp1)
    elif [[ "$arch" -eq 139 ]]; then
	params+=(-arch pdp8)
    elif [[ "$arch" -eq 140 ]]; then
	params+=(-arch pic16c5x)
    elif [[ "$arch" -eq 141 ]]; then
	params+=(-arch pic16c62x)
    elif [[ "$arch" -eq 142 ]]; then
	params+=(-arch powerpc)
    elif [[ "$arch" -eq 143 ]]; then
	params+=(-arch pps4)
    elif [[ "$arch" -eq 144 ]]; then
	params+=(-arch psxcpu)
    elif [[ "$arch" -eq 145 ]]; then
	params+=(-arch r65c02)
    elif [[ "$arch" -eq 146 ]]; then
	params+=(-arch r65c19)
    elif [[ "$arch" -eq 147 ]]; then
	params+=(-arch romp)
    elif [[ "$arch" -eq 148 ]]; then
	params+=(-arch rsp)
    elif [[ "$arch" -eq 149 ]]; then
	params+=(-arch rx01)
    elif [[ "$arch" -eq 150 ]]; then
	params+=(-arch s2650)
    elif [[ "$arch" -eq 151 ]]; then
	params+=(-arch saturn)
    elif [[ "$arch" -eq 152 ]]; then
	params+=(-arch sc61860)
    elif [[ "$arch" -eq 153 ]]; then
	params+=(-arch scmp)
    elif [[ "$arch" -eq 154 ]]; then
	params+=(-arch score7)  
    elif [[ "$arch" -eq 155 ]]; then
	params+=(-arch scudsp)
    elif [[ "$arch" -eq 156 ]]; then
	params+=(-arch se3208)
    elif [[ "$arch" -eq 157 ]]; then
	params+=(-arch sh2)
    elif [[ "$arch" -eq 158 ]]; then
	params+=(-arch sh4)
    elif [[ "$arch" -eq 159 ]]; then
	params+=(-arch sh4be)
    elif [[ "$arch" -eq 160 ]]; then
	params+=(-arch sharc)
    elif [[ "$arch" -eq 161 ]]; then
	params+=(-arch sm500)
    elif [[ "$arch" -eq 162 ]]; then
	params+=(-arch sm510)
    elif [[ "$arch" -eq 163 ]]; then
	params+=(-arch sm511)
    elif [[ "$arch" -eq 164 ]]; then
	params+=(-arch sm530)
    elif [[ "$arch" -eq 165 ]]; then
	params+=(-arch sm590)
    elif [[ "$arch" -eq 166 ]]; then
	params+=(-arch sm5a)
    elif [[ "$arch" -eq 167 ]]; then
	params+=(-arch sm8500)
    elif [[ "$arch" -eq 168 ]]; then
	params+=(-arch sparcv7)
    elif [[ "$arch" -eq 169 ]]; then
	params+=(-arch sparcv8)
    elif [[ "$arch" -eq 170 ]]; then
	params+=(-arch sparcv9)
    elif [[ "$arch" -eq 171 ]]; then
	params+=(-arch sparcv9vis1)
    elif [[ "$arch" -eq 172 ]]; then
	params+=(-arch sparcv9vis2)
    elif [[ "$arch" -eq 173 ]]; then
	params+=(-arch sparcv9vis2p)
    elif [[ "$arch" -eq 174 ]]; then
	params+=(-arch sparcv9vis3)
    elif [[ "$arch" -eq 175 ]]; then
	params+=(-arch sparcv9vis3b)
    elif [[ "$arch" -eq 176 ]]; then
	params+=(-arch spc700)
    elif [[ "$arch" -eq 177 ]]; then
	params+=(-arch ssem)
    elif [[ "$arch" -eq 178 ]]; then
	params+=(-arch ssp1601)
    elif [[ "$arch" -eq 179 ]]; then
	params+=(-arch st62xx)
    elif [[ "$arch" -eq 180 ]]; then
	params+=(-arch superfx)
    elif [[ "$arch" -eq 181 ]]; then
	params+=(-arch t11)
    elif [[ "$arch" -eq 182 ]]; then
	params+=(-arch tlcs870)
    elif [[ "$arch" -eq 183 ]]; then
	params+=(-arch tlcs900)
    elif [[ "$arch" -eq 184 ]]; then
	params+=(-arch tmp90840)
    elif [[ "$arch" -eq 185 ]]; then
	params+=(-arch tmp90844)
    elif [[ "$arch" -eq 186 ]]; then
	params+=(-arch tms0980)
    elif [[ "$arch" -eq 187 ]]; then
	params+=(-arch tms1000)
    elif [[ "$arch" -eq 188 ]]; then
	params+=(-arch tms1100)
    elif [[ "$arch" -eq 189 ]]; then
	params+=(-arch tms32010)
    elif [[ "$arch" -eq 190 ]]; then
	params+=(-arch tms32025)
    elif [[ "$arch" -eq 191 ]]; then
	params+=(-arch tms32031)
    elif [[ "$arch" -eq 192 ]]; then
	params+=(-arch tms32051)
    elif [[ "$arch" -eq 193 ]]; then
	params+=(-arch tms32082_mp)
    elif [[ "$arch" -eq 194 ]]; then
	params+=(-arch tms32082_pp)
    elif [[ "$arch" -eq 195 ]]; then
	params+=(-arch tms34010)
    elif [[ "$arch" -eq 196 ]]; then
	params+=(-arch tms34020)
    elif [[ "$arch" -eq 197 ]]; then
	params+=(-arch tms57002)
    elif [[ "$arch" -eq 198 ]]; then
	params+=(-arch tms7000)
    elif [[ "$arch" -eq 199 ]]; then
	params+=(-arch tms9900)
    elif [[ "$arch" -eq 200 ]]; then
	params+=(-arch tms9980)
    elif [[ "$arch" -eq 201 ]]; then
	params+=(-arch tms9995)
    elif [[ "$arch" -eq 202 ]]; then
	params+=(-arch tp0320)
    elif [[ "$arch" -eq 203 ]]; then
	params+=(-arch tx0_64kw)
    elif [[ "$arch" -eq 204 ]]; then
	params+=(-arch tx0_8kw)
    elif [[ "$arch" -eq 205 ]]; then
	params+=(-arch ucom4)
    elif [[ "$arch" -eq 206 ]]; then
	params+=(-arch unsp10)           
    elif [[ "$arch" -eq 207 ]]; then
	params+=(-arch unsp12)
    elif [[ "$arch" -eq 208 ]]; then
	params+=(-arch unsp20)
    elif [[ "$arch" -eq 209 ]]; then
	params+=(-arch upd7725)
    elif [[ "$arch" -eq 210 ]]; then
	params+=(-arch upd7801)
    elif [[ "$arch" -eq 211 ]]; then
	params+=(-arch upd78c05)
    elif [[ "$arch" -eq 212 ]]; then
	params+=(-arch upd7807)
    elif [[ "$arch" -eq 213 ]]; then
	params+=(-arch upd7810)
    elif [[ "$arch" -eq 214 ]]; then
	params+=(-arch upd78014)
    elif [[ "$arch" -eq 215 ]]; then
	params+=(-arch upd78024)
    elif [[ "$arch" -eq 216 ]]; then
	params+=(-arch upd78044a)
    elif [[ "$arch" -eq 217 ]]; then
	params+=(-arch upd78054)
    elif [[ "$arch" -eq 218 ]]; then
	params+=(-arch upd78064)
    elif [[ "$arch" -eq 219 ]]; then
	params+=(-arch upd78078)
    elif [[ "$arch" -eq 220 ]]; then
	params+=(-arch upd78083)
    elif [[ "$arch" -eq 221 ]]; then
	params+=(-arch upd78138)
    elif [[ "$arch" -eq 222 ]]; then
	params+=(-arch upd78148)
    elif [[ "$arch" -eq 223 ]]; then
	params+=(-arch upd78214)
    elif [[ "$arch" -eq 224 ]]; then
	params+=(-arch upd78218a)
    elif [[ "$arch" -eq 225 ]]; then
	params+=(-arch upd78224)
    elif [[ "$arch" -eq 226 ]]; then
	params+=(-arch upd78234)
    elif [[ "$arch" -eq 227 ]]; then
	params+=(-arch upd78244)
    elif [[ "$arch" -eq 228 ]]; then
	params+=(-arch upd780024a)
    elif [[ "$arch" -eq 229 ]]; then
	params+=(-arch upd78312)
    elif [[ "$arch" -eq 230 ]]; then
	params+=(-arch upd78322)
    elif [[ "$arch" -eq 231 ]]; then
	params+=(-arch upd78328)
    elif [[ "$arch" -eq 232 ]]; then
	params+=(-arch upd78334)
    elif [[ "$arch" -eq 233 ]]; then
	params+=(-arch upd78352)
    elif [[ "$arch" -eq 234 ]]; then
	params+=(-arch upd78356)
    elif [[ "$arch" -eq 235 ]]; then
	params+=(-arch upd78366a)
    elif [[ "$arch" -eq 236 ]]; then
	params+=(-arch upd78372)
    elif [[ "$arch" -eq 237 ]]; then
	params+=(-arch upd780065)
    elif [[ "$arch" -eq 238 ]]; then
	params+=(-arch upd780988)
    elif [[ "$arch" -eq 239 ]]; then
	params+=(-arch upd78k0kx1)
    elif [[ "$arch" -eq 240 ]]; then
	params+=(-arch upd78k0kx2)
    elif [[ "$arch" -eq 241 ]]; then
	params+=(-arch upi41)
    elif [[ "$arch" -eq 242 ]]; then
	params+=(-arch v60)
    elif [[ "$arch" -eq 243 ]]; then
	params+=(-arch v810)
    elif [[ "$arch" -eq 244 ]]; then
	params+=(-arch vt50)
    elif [[ "$arch" -eq 245 ]]; then
	params+=(-arch vt52)
    elif [[ "$arch" -eq 246 ]]; then
	params+=(-arch vt61)
    elif [[ "$arch" -eq 247 ]]; then
	params+=(-arch we32100)
    elif [[ "$arch" -eq 248 ]]; then
	params+=(-arch x86_16)
    elif [[ "$arch" -eq 249 ]]; then
	params+=(-arch x86_32)
    elif [[ "$arch" -eq 250 ]]; then
	params+=(-arch x86_64)
    elif [[ "$arch" -eq 251 ]]; then
	params+=(-arch xavix)
    elif [[ "$arch" -eq 252 ]]; then
	params+=(-arch xavix2000)
    elif [[ "$arch" -eq 253 ]]; then
	params+=(-arch xavix2)
    elif [[ "$arch" -eq 254 ]]; then
	params+=(-arch z180)  
    elif [[ "$arch" -eq 255 ]]; then
	params+=(-arch z8)  
    elif [[ "$arch" -eq 256 ]]; then
	params+=(-arch z80)  
    elif [[ "$arch" -eq 257 ]]; then
	params+=(-arch z8000)              
    fi
    if [[ -n "$basepc" ]] && [[ "$basepc" != "none" ]]; then
        params+=(-basepc "$basepc")
    fi
    if [[ -n "$mode" ]] && [[ "$mode" != "none" ]]; then
        params+=(-mode "$mode")
    fi
    if [[ "$norawbytes" -eq 1 ]]; then
        params+=(-norawbytes)
    fi
    if [[ "$xchbytes" -eq 1 ]]; then
        params+=(-xchbytes)
    fi
    if [[ "$flipped" -eq 1 ]]; then
        params+=(-flipped)
    fi
    if [[ "$upper" -eq 1 ]]; then
        params+=(-upper)
    fi
    if [[ "$lower" -eq 1 ]]; then
        params+=(-lower)
    fi
    if [[ -n "$skip" ]] && [[ "$skip" != "none" ]]; then
        params+=(-skip "$skip")
    fi
    if [[ -n "$count" ]] && [[ "$count" != "none" ]]; then
        params+=(-count "$count")
    fi

    if [ -f "$f" ]; then
        clear
        cd && cd "$DIR"
        $md_inst/unidasm "$f" ${params[@]} > unidasm.info
        chown $user:$user "$f"
        dialog --stdout --title "Disassembly to $f" --clear --textbox unidasm.info 23 60
        rm -rf "unidasm.info"
        m="Disassembly completed"  
    else
        m="$m"
    fi
}

function unidasm_mame-tools() {
    export IFS='
'
    FILE=$(dialog --stdout --title "Unidasm - Choose a ROM" --fselect "$romdir/" 13 105)
    [ ! -z $FILE ] && aux_unidasm_mame-tools "$FILE" 
}

function gui_mame-tools() {
    local default
    while true; do
	local manager=`$md_inst/chdman | awk '/manager/' | awk '{print $10}'`
        local ver="v$manager"
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "MAME Tools $ver" 22 76 16)
        local options=(
            1 "castool - Generic cassette manipulation tool" # done
            2 "chdman - Compressed Hunks of Data (CHD) manager" # done
	    3 "floptool - Generic floppy image manipulation tool" # done
	    4 "imgtool - Generic image manipulation tool"
	    5 "jedutil - Binary to/from JEDEC file converter" # done
	    6 "ldresample - Laserdisc audio synchronizer and resampler" # done
	    7 "ldverify - Laserdisc AVI/CHD verifier" # done
	    8 "pngcmp - PNG comparison utility program" # done
	    9 "regrep - Regression test report generator"
	    10 "romcmp - ROM and ROMsets check and comparison" # done
	    11 "split - Simple file splitter/joiner with hashes" # done
	    12 "srcclean - Basic source code cleanear" # done
	    13 "testkeys - Keyboard code viewer (SDL keycode scanner)" # done
	    14 "unidasm - Universal disassembler for several systems supported" # done
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            default="$choice"
            case "$choice" in
                1)
                    castool_mame-tools
                    ;;
                2)
                    chdman_mame-tools
                    ;;
                3)
                    floptool_mame-tools
                    ;;
                4)
                    imgtool_mame-tools
                    ;;
                5)
                    jedutil_mame-tools
                    ;;
                6)
                    ldresample_mame-tools
                    ;;
                7)
                    ldverify_mame-tools
                    ;;
                8)
                    pngcmp_mame-tools
                    ;;
                9)
                    regrep_mame-tools
                    ;;
                10)
                    romcmp_mame-tools
                    ;;
                11)
                    split_mame-tools
                    ;;
                12)
                    srcclean_mame-tools
                    ;;
                13)
                    testkeys_mame-tools
                    ;;
                14)
                    unidasm_mame-tools
                    ;;
            esac
        else
            break
        fi
    done
}