#!/usr/bin/env bash
export RESET='\033[0m'

export GREEN='\033[38;5;2m'
export RED='\033[38;5;1m'
export YELLOW2='\033[38;5;3m'
export BLACK='\033[30m'
export GREEN='\033[32m'
export YELLOW='\033[33m'
export BLUE='\033[34m'
export MAGENTA='\033[35m'
export CYAN='\033[36m'
export WHITE='\033[37m'

export BRIGHT_BLACK='\033[90m'
export BRIGHT_RED='\033[91m'
export BRIGHT_GREEN='\033[92m'
export BRIGHT_YELLOW='\033[93m'
export BRIGHT_BLUE='\033[94m'
export BRIGHT_MAGENTA='\033[95m'
export BRIGHT_CYAN='\033[96m'
export BRIGHT_WHITE='\033[97m'

export BOLD='\033[1m'
export NO_BOLD='\033[21m'
export DIM='\033[2m'
export NO_DIM='\033[22m'
export ITALIC='\033[3m'
export NO_ITALIC='\033[23m'
export STRIKE='\033[9m'
export NO_STRIKE='\033[29m'
export REVERSE='\033[7m'
export NO_REVERSE='\033[27m'

export BG_BLACK='\033[40m'
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'
export BG_MAGENTA='\033[45m'
export BG_CYAN='\033[46m'
export BG_WHITE='\033[47m'

export BG_BRIGHT_BLACK='\033[100m'
export BG_BRIGHT_RED='\033[101m'
export BG_BRIGHT_GREEN='\033[102m'
export BG_BRIGHT_YELLOW='\033[103m'
export BG_BRIGHT_BLUE='\033[104m'
export BG_BRIGHT_MAGENTA='\033[105m'
export BG_BRIGHT_CYAN='\033[106m'
export BG_BRIGHT_WHITE='\033[107m'

export LIST_DELIMITER="${LIST_DELIMITER:-|*|}"
export LIST_PREFIX="list::["
export LIST_SUFFIX="]"
export OBJECT_PREFIX="${OBJECT_PREFIX:-object::{ }"
export OBJECT_SUFFIX="${OBJECT_SUFFIX:- \}::object}"
export OBJECT_DELIMITER="${OBJECT_DELIMITER:-|,|}"
export KV_PREFIX="${KV_PREFIX:-kv\(}"
export KV_SUFFIX="${KV_SUFFIX:-\)}"
export KV_DELIMITER="${KV_DELIMITER:-→}"

export CANCELLED="CANCELLED"



# log
function log() {
    printf "%b\\n" "${*}" >&2
}

# info <msg>
function info() {
    log "${GREEN}INFO ${RESET} ==> ${*}"
}

# lc() <str>
function lc() {
    local -r str="${1-}"
    echo "${str}" | tr '[:upper:]' '[:lower:]'
}

# uc() <str>
function uc() {
    local -r str="${1-}"
    echo "${str}" | tr '[:lower:]' '[:upper:]'
}

# warn <msg>
function warn() {
    log "${YELLOW}${BOLD}WARN ${RESET} ==> ${*}"
}

# debug <fn> <msg> <...>
# 
# Logs to STDERR when the DEBUG env variable is set
# and not equal to "false".
function debug() {
    local -r DEBUG=$(lc "${DEBUG:-}")
    if [[ "${DEBUG}" != "false" ]]; then
        if (( $# > 1 )); then
            local fn="$1"

            shift
            local regex=""
            local lower_fn="" 
            lower_fn=$(lc "$fn")
            regex="(.*[^a-z]+|^)$lower_fn($|[^a-z]+.*)"

            if [[ "${DEBUG}" == "true" || "${DEBUG}" =~ $regex ]]; then
                log "       ${GREEN}◦${RESET} ${BOLD}${fn}()${RESET} → ${*}"
            fi
        else
            log "       ${GREEN}DEBUG: ${RESET} → ${*}"
        fi
    fi
}


# is_bound <var>
function is_bound() {
    allow_errors
    local -n __test_by_ref=$1 2>/dev/null || { log "is_bound: unbounded ref"; return 1; }
    local name="${!__test_by_ref}" 
    local -r arithmetic='→+-=><%'
    if has_characters "${arithmetic}" "$1"; then
        return 1
    else
        local idx=${!1} 2>/dev/null 
        local a="${__test_by_ref@a}" 

        if [[ -z "${idx}${a}" ]]; then
            catch_errors
            return 1
        else 
            catch_errors
            return 0
        fi
    fi
}


# error_path
function error_path() {
    local -r path="$1"
    allow_errors
    local -r delimiter=$(os_path_delimiter)
    local -r start=$(strip_after_last "$delimiter" "$path")
    local -r end=$(strip_before_last "$delimiter" "$path")

    printf "%s" "${start}/${RED}${end}${RESET}"
}

# panic <msg> <code>
function panic() {
    local -r msg="${1:?no message passed to error()!}"
    local -ri code=$(( "${2:-1}" ))

    log "\n  [${RED}x${RESET}] ${BOLD}ERROR ${DIM}${RED}$code${RESET}${BOLD} →${RESET} ${msg}" 
    log ""
    for i in "${!BASH_SOURCE[@]}"; do
        if ! contains "errors.sh" "${BASH_SOURCE[$i]}"; then
            log "    - ${FUNCNAME[$i]}() ${ITALIC}${DIM}at line${RESET} ${BASH_LINENO[$i-1]} ${ITALIC}${DIM}in${RESET} $(error_path "${BASH_SOURCE[$i]}")"
        fi
    done
    log ""
    exit $code
}

# error <msg> <code>
function error() {
    local -r msg="${1:?no message passed to error()!}"
    local -ri code=$(( "${2:-1}" ))

    log "\n  [${RED}x${RESET}] ${BOLD}ERROR ${DIM}${RED}$code${RESET}${BOLD} →${RESET} ${msg}" && return ${code}
}

# not_empty() <test>
function not_empty() {
    if [ -z "$1" ] || [[ "$1" == "" ]]; then
        return 1
    else
        return 0
    fi
}

# is_empty() <test | ref:test>
function is_empty() {

    if [ -z "$1" ] || [[ "$1" == "" ]]; then
        return 0
    else
        return 1
    fi
}

# is_function <any>
function is_function() {
    local to_check=${1:?nothing was passed to is_function to check}

    # shellcheck disable=SC2086
    if [[ -n "$(LC_ALL=C type -t ${to_check})" && "$(LC_ALL=C type -t ${to_check})" == "function" ]]; then
        return 0
    else
        return 1
    fi
}

# strip_leading <avoid-str> <content>
function strip_leading() {
    local -r avoid="${1:?No avoid string provided to ensure_starting}"
    local -r content="${2:-}"

    echo "${content#"$avoid"}"

    return 0
}

# strip_trailing <avoid> <content>
function strip_trailing() {
    local -r avoid="${1:?No avoid string provided to ensure_starting}"
    local -r content="${2:-}"

    echo "${content%"$avoid"}"

    return 0
}

# strip_after <find> <content>
function strip_after() {
    local -r find="${1:?strip_after() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    if not_empty "content"; then
        echo "${content%%"${find}"*}"
    else 
        echo ""
    fi
}

# strip_after_last <find> <content>
function strip_after_last() {
    local -r find="${1:?strip_after_last() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    if not_empty "content"; then
        echo "${content%"${find}"*}"
    else 
        echo ""
    fi
}

# strip_before <find> <content>
function strip_before() {
    local -r find="${1:?strip_before() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    echo "${content#*"${find}"}"
}

# strip_before_last <find> <content>
function strip_before_last() {
    local -r find="${1:?strip_before_last() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    echo "${content##*"${find}"}"
}

# starts_with <look-for> <content>
function starts_with() {
    local -r look_for="${1:?No look-for string provided to starts_with}"
    local -r content="${2:-}"

    if is_empty "${content}"; then
        return 1;
    fi

    if [[ "${content}" == "${content#"$look_for"}" ]]; then
        return 1; # was not present
    else
        return 0; #: found "look_for"
    fi
}
# length() <subject>
#
# returns the length of <subject> where <subject> can be
# a "array", "object", "list", or string
function length() {
    local -r container="${1:-empty}"
    local -i count=0

    if is_list "$container"; then
        count=${#$(as_array "$container")}
    elif is_object "$container"; then
        count=${#$(keys "$container")}
    elif [[ "$container" == "empty" ]]; then
        count=0
    else
        count=${#container}
    fi

    echo ${count}
    return 0
}

# ends_with <look-for> <content>
function ends_with() {
    local -r look_for="${1:?No look-for string provided to ends_with}"
    local -r content="${2}"
    local -r no_suffix="${content%"${look_for}"}"

    if is_empty "${content}"; then
        return 1;
    fi

    if [[ "${content}" == "${no_suffix}" ]]; then
        return 1;
    else
        return 0;
    fi
}


function is_list() {
    allow_errors
    local -n __var__=$1 2>/dev/null
    local -r by_val="$1"

    if is_bound __var__; then

        if  starts_with "${LIST_PREFIX}" "${__var__}" && ends_with "${LIST_SUFFIX}" "${__var__}"; then
            catch_errors
            return 0
        else
            catch_errors
            return 1
        fi
    else
        if  starts_with "${LIST_PREFIX}" "${by_val}" && ends_with "${LIST_SUFFIX}" "${by_val}"; then
            catch_errors
            return 0
        else
            catch_errors
            return 1
        fi
    fi
}


# is_object() <candidate>
# 
# tests whether <candidate> is an object and returns 0/1
function is_object() {
    allow_errors
    local -n candidate=$1 2>/dev/null
    catch_errors

    if is_bound candidate; then
        if not_empty "$candidate" && starts_with  "${OBJECT_PREFIX}" "${candidate}" ; then
            if not_empty "$candidate" && ends_with "${OBJECT_SUFFIX}" "${candidate}"; then
                return 0
            fi
        fi
    else
        local var="$1"
        if not_empty "$var" && starts_with  "${OBJECT_PREFIX}" "${var}" ; then
            if not_empty "$var" && ends_with "${OBJECT_SUFFIX}" "${var}"; then
                return 0
            fi
        fi
    fi

    return 1
}


# distro_version() <[vmid]>
function distro_version() {
    local -r vm_id="$1:-"

    if [[ $(os "$vm_id") == "linux" ]]; then
        if file_exists "/etc/os-release"; then
            local -r id="$(find_in_file "VERSION_ID=" "/etc/os-release")"
            local -r codename="$(find_in_file "VERSION_CODENAME=" "/etc/os-release")"
            echo "${id}/${codename}"
            return 0
        fi
    else
        error "Called distro() on a non-linux OS [$(os "$vm_id")]!"
    fi
}

# find_in_file <filepath> <key>
function find_in_file() {
    local -r filepath="${1:?find_in_file() called but no filepath passed in!}"
    local -r key="${2:?find_in_file() called but key value passed in!}"

    if file_exists "${filepath}"; then
        local found=""

        while read -r line; do
            if not_empty "${line}" && contains "${key}" "${line}"; then
                if starts_with "${key}=" "${line}"; then
                    found="$(strip_leading "${key}=" "${line}")"
                else
                    found="${line}"
                fi
                break
            fi
        done < "$filepath"

        if not_empty "$found"; then
            printf "%s" "$found"
            return 0
        else
            echo ""
            return 0
        fi
    else
        return 1
    fi
}

# find_key_in_file() <filepath> <key>
function find_key_in_file() {
    local -r filepath="${1:?find_in_file() called but no filepath passed in!}"
    local -r key="${2:?find_in_file() called but key value passed in!}"

    if file_exists "${filepath}"; then
        local found=""

        while read -r line; do
            if not_empty "${line}" && contains "${key}=" "${line}"; then
                if starts_with "${key}=" "${line}"; then
                    found="$(strip_leading "${key}=" "${line}")"
                    break
                fi
            fi
        done < "$filepath"

        if not_empty "$found"; then
            printf "%s" "$found"
            return 0
        else
            echo ""
            return 0
        fi
    else
        return 1
    fi
}

# distro() <[vmid]>
function distro() {
    local -r vm_id="${1:-}"

    if [[ $(os "$vm_id") == "linux" ]]; then
        if file_exists "/etc/os-release"; then
            local -r name="$(find_in_file "ID=" "/etc/os-release")" || "$(find_in_file "NAME=" "/etc/os-release")"
            echo "${name}"
            return 0
        fi
    else
        error "Called distro() on a non-linux OS [$(os "$vm_id")]!"
    fi
}

# os() <[vmid]>
function os() {
    local -r vm_id="${1-}"
    local -r os_type=$(lc "${OSTYPE}") || "$(lc "$(uname)")" || "unknown"

    if is_empty "${vm_id}"; then
        case "${os_type}" in
            'linux'*)
                if distro "$vm_id"; then 
                    echo "linux/$(distro "${vm_id}")/$(distro_version "$vm_id")"
                else
                    echo "linux"
                fi
                ;;
            'freebsd'*)
                echo "freebsd"
                ;;
            'windowsnt'*)
                echo "windows"
                ;;
            'darwin'*) 
                echo "macos/$(strip_before "darwin" "${OSTYPE}")"
                ;;
            'sunos'*)
                echo "solaris"
                ;;
            'aix'*) 
                echo "aix"
                ;;
            *) echo "unknown/${os_type}"
        esac
    fi
}

# os_path_delimiter
function os_path_delimiter() {
    if starts_with "windows" "$(os)"; then
        echo "\\"
    else
        echo "/"
    fi
}

# contains <find> <content>
function contains() {
    local -r find="${1}"
    local -r content="${2}"

    if is_empty "$find"; then
        error "contains("", ${content}) function did not receive a FIND string! This is an invalid call!" 1
    fi

    if is_empty "$content"; then
        return 1;
    fi

    if [[ "${content}" =~ ${find} ]]; then
        return 0 # successful match
    fi

    return 1
}

# error_handler
function error_handler() {
    local -r exit_code="$?"
    local -r _line_number="$1"
    local -r command="$2"

        log "  [${RED}x${RESET}] ${BOLD}ERROR ${DIM}${RED}$exit_code${RESET}${BOLD} → ${command}${RESET} "
    # if is_bound command && [[ "$command" != "$code" ]]; then
    # fi
    log ""

    for i in "${!BASH_SOURCE[@]}"; do
        if ! contains "errors.sh" "${BASH_SOURCE[$i]:-unknown}"; then
            log "    - ${FUNCNAME[$i]:-unknown}() ${ITALIC}${DIM}at line${RESET} ${BASH_LINENO[$i-1]:-unknown} ${ITALIC}${DIM}in${RESET} $(error_path "${BASH_SOURCE[$i]:-unknown}")"
        fi
    done
    log ""
}

# catch_errors()
function catch_errors() {
    set -Eeuo pipefail
    trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
}

# allow_errors()
function allow_errors() {
    set +Eeuo pipefail
    trap - ERR
}

# has_command <cmd>
function has_command() {
    local -r cmd="${1:?cmd is missing}"

    if command -v "${cmd}" &> /dev/null; then
        return 0
    else 
        return 1
    fi
}

# is_pve_node
function is_pve_node() {
    if has_command "pveversion"; then
        return 0
    else
        return 1
    fi
}


# text_confirm() <question> <default>
function text_confirm() {
    local -r question="${1:?text_confirm() did not get the question passed to it}"
    local -r default="${2:-y}"
    local response

    if [[ $(lc "${default}") == "y" ]]; then
        read -rp "${question} (Y/n)" response >/dev/null
    else
        read -rp "${question} (y/N)" response >/dev/null
    fi

    if [[ $(lc "$default") == "y" ]];then
        local -i resp
        if [[ $(lc "$response") == "n" ]] || [[ $(lc "$response") == "no" ]]; then
            resp=1
        else
            resp=0
        fi        

        return $resp
    else
        local -i resp
        if [[ $(lc "$response" == "y") ]] || [[ $(lc "$response") == "yes" ]]; then
            resp=0
        else
            resp=1
        fi

        return $resp
    fi
}

# ask
function ask() {
    if has_command "whiptail"; then
        whiptail "${@}"
    elif has_command "dialog"; then
        display "${@}"
    fi
}

function tui() {
    local var

    if has_command "whiptail"; then
        var="whiptail"
    elif has_command "dialog"; then
        var="dialog"
    else 
        var="none"
    fi

    echo "${var}"
}

# ask_radiolist() <ref:data>
function ask_radiolist() {
    local -n data=$1
    local response

    if ! is_bound data; then
        panic "Called for a radiolist dialog and didn't bind a configuration object to the request!"
    fi

    local -r title="${data["title"]}"
    local -r backmsg="${data["backmsg"]:-Moxy}"
    local -r height="${data["height"]:-23}"
    local -r width="${data["width"]:-60}" 
    local -r radio_height="${data["radio_height"]:-12}"
    local -ra choices="${data["choices"]}"
    local -r exit_msg="${data["exit_msg"]:-Goodbye}"
    local -ra params=(
        "--backtitle \"${backmsg}\""
        "--radiolist \"${title}\" ${height} ${width} ${radio_height}"
        "${choices[*]} 3>&2 2>&1 1>&3"
    )

    local -r tool="$(tui)"

    if [[ "$tool" == "dialog" ]]; then 
        cmd="dialog ${params[*]} || echo \"${CANCELLED}\""
    elif [[ "$tool" == "whiptail" ]]; then
        cmd="whiptail ${params[*]} || echo \"${CANCELLED}\""
    else
        error "can't ask for password as no TUI is available [${tool}]"
        exit 1
    fi
   
    response=$(eval "${cmd}")
    echo "${response}"

    return 0;
}

# ask_yes_no() <ref:data>
function ask_yes_no() {
    local -n data=$1
    local -r title="${data["title"]}"
    local -r backmsg="${data["backmsg"]}"
    local -r height="${data["height"]}"
    local -r width="${data["width"]}" 
    local -r yes="${data["yes"]}"
    local -r no="${data["no"]}"
    local -r exit_msg="${data["exit_msg"]:-Goodbye}"
    local -ra params=(
        "--backtitle \"${backmsg}\""
        "--yesno \"${title}\" ${height} ${width}"
        "3>&2 2>&1 1>&3"
    )

    local -r tool="$(tui)"

    if [[ "$tool" == "dialog" ]]; then 
        cmd="dialog ${params[*]}"
    elif [[ "$tool" == "whiptail" ]]; then
        cmd="whiptail ${params[*]}" 
    else
        error "can't ask for password as no TUI is available [${tool}]"
        exit 1
    fi
    eval "$cmd"

    return $?
}

# ask_password <title> <height> <width> <ok> <cancel> <exit>
function ask_password() {
    local -r title="${1:?No title provided to ask_yes_no()}"
    local -r height="${2:?No height provided to ask_yes_no()}"
    local -r width="${3:?No width provided to ask_yes_no()}"
    local -r ok_btn="${4:-Ok}"
    local -r cancel_btn="${5:-Cancel}"
    local -r exit_msg="${6:-Goodbye}"
    local -r tool="$(tui)"
    local choice

    if [[ "$tool" == "dialog" ]]; then 
        choice=$(
            dialog --ok-label "${ok_btn}" --cancel-label "${cancel_btn}" --passwordbox "${title}" "${height}" "${width}"  3>&2 2>&1 1>&3
        ) || exit_ask "${exit_msg}" "false"
    elif [[ "$tool" == "whiptail" ]]; then 
        choice=$(
            whiptail --ok-btn "${ok_btn}" --cancel-btn "${cancel_btn}" --passwordbox "${title}" "${height}" "${width}"  3>&2 2>&1 1>&3
        ) || exit_ask "${exit_msg}" "false"
    else
        error "can't ask for password as no TUI is available [${tool}]"
        exit 1
    fi

    if [ "${#choice}" -lt 8 ]; then
        log ""
        log ""
        error "The key you passed in was too short [${#choice}], please refer to the Promox docs for how to generate the key and test it out with Postman or equivalent if you're unsure if it's right"
        log ""
        exit 1
    else 
        echo "${choice}"
    fi
}

# was_cancelled() <outcome>
function was_cancelled() {
    local -r outcome="$1"

    if not_empty "$outcome" && [[ "$outcome" == "${CANCELLED}" ]]; then
        return 0
    else 
        return 1
    fi
}


# has_characters <str> <content>
function has_characters() {
    local -r char_str="${1:?has_characters() did not receive a CHARS string!}"
    local -r content="${2:?content expression not passed to has_characters()}"

    # Check each character in char_str
    for (( i=0; i<${#char_str}; i++ )); do
        char="${char_str:i:1}"
        if [[ "$content" == *"$char"* ]]; then
            return 0
        fi
    done

    return 1
}

# is_assoc_array() <ref:var>
function is_assoc_array() {
    local -r var="$1"
    # if has_characters '!@#$%^&()_+' "$var"; then
    #     error "invalid characters"
    #     return 1; 
    # fi
    allow_errors
    local -n __var__=$1 2>/dev/null

    if [[ ${__var__@a} = A ]] || [[ ${__var__@a} = Ar ]]; then
        catch_errors
        return 0; # true
    else
        catch_errors
        return 1; # false
    fi
}

# is_array() <ref:var>
function is_array() {
    allow_errors
    local -n __var__=$1 2>/dev/null
    local -r test=${__var__@a} 2>/dev/null
    catch_errors

    if is_bound __var__; then
        if not_empty "$test" && [[ $test = a ]]; then
            return 0; # true
        else
            return 1; # false
        fi
    else
        return 1
    fi
}

# is_numeric() <candidate>
function is_numeric() {
    allow_errors
    local -n __var__=$1 2>/dev/null
    local by_val="$1"

    if is_bound __var__; then
        local -r by_ref="${__var__:-}"
        if  ! [[ "$by_ref" =~ ^[0-9]+$ ]]; then
            catch_errors
            return 1
        else
            catch_errors
            return 0
        fi
    else
        if ! [[ "$by_val" =~ ^[0-9]+$ ]]; then
            catch_errors
            return 1
        else
            catch_errors
            return 0
        fi
    fi 
}


# is_kv_pair() <test | ref:test>
function is_kv_pair() {
    allow_errors
    local -n test_by_ref=$1 2>/dev/null
    local -r test_by_val="$1"

    if is_bound test_by_ref; then
        if starts_with "${KV_PREFIX}" "${test_by_ref}" && ends_with "${KV_SUFFIX}" "${test_by_ref}"; then
            catch_errors
            return 0
        fi
    else
        if starts_with "${KV_PREFIX}" "${test_by_val}" && ends_with "${KV_SUFFIX}" "${test_by_val}"; then
            catch_errors
            return 0
        fi
    fi 2>/dev/null

    catch_errors
    return 1
}

# is_keyword() <keyword>
function is_keyword() {
    allow_errors
    local _var=${1:?no parameter passed into is_array}
    local declaration=""
    # shellcheck disable=SC2086
    declaration=$(LC_ALL=C type -t $1)

    if [[ "$declaration" == "keyword" ]]; then
        catch_errors
        return 0
    else
        catch_errors
        return 1
    fi
}

# is_shell_alias() <candidate>
function is_shell_alias() {
    local candidate="${1:?no parameter passed into is_shell_alias}"
    local -r state=$(manage_err)
    alias "$candidate" 1>/dev/null 2>/dev/null
    local -r error_state="$?"
    set "-${state}" # reset error handling to whatever it had been

    if [[ "${error_state}" == "0" ]]; then
        echo "$declaration"
        return 0
    else
        return 1
    fi
}

# typeof <var>
function typeof() {
    allow_errors
    local -n _var_type=$1 2>/dev/null
    catch_errors

    if is_bound _var_type; then
        if is_array _var_type; then
            echo "array"
        elif is_assoc_array _var_type; then
            echo "assoc-array"
        elif is_numeric _var_type; then
            echo "number"
        elif is_function _var_type; then
            echo "function"
        elif is_empty _var_type; then
            echo "empty"
        else
            echo "string"
        fi
    else
        if is_numeric "$1"; then
            echo "number"
        elif is_function "$1"; then
            echo "function"
        elif is_empty "${1}"; then
            echo "empty"
        else
            echo "string"
        fi
    fi
}

# ask_inputbox {title|height|width|ok|cancel|exit}
function ask_inputbox() {
    allow_errors
    local -n data=$1
    catch_errors

    if ! is_bound data; then
        panic "Call to ask_inputbox() received without any parameter configuration passed in!" 1
    elif is_not_typeof data "assoc-array"; then
        panic "ask_inputbox() expects an associative array to be passed in for configuration purposes but got '$(typeof data)' instead!"
    fi

    local -r title="${data["title"]}"
    local -r backmsg="${data["backmsg"]}"
    local -r height="${data["height"]}"
    local -r width="${data["width"]}" 
    local -r ok="${data["ok"]}"
    local -r cancel="${data["cancel"]}"
    local response=""
    
    local -r tool="$(tui)"
    catch_errors

    local buttons
    if [[ "${tool}" == "dialog" ]]; then
        buttons="--ok-label \"${ok}\" --cancel-label \"${cancel}\""
    else
        buttons="--ok-button \"${ok}\" --cancel-button \"${cancel}\""
    fi
    local -ra params=(
        "--backtitle \"${backmsg}\""
        "${buttons}"
        "--inputbox \"${title}\" ${height} ${width}"
        "3>&2 2>&1 1>&3"
    )


    if [[ "$tool" == "dialog" ]]; then 
        cmd="dialog ${params[*]} || echo \"${CANCELLED}\""
    elif [[ "$tool" == "whiptail" ]]; then
        cmd="whiptail ${params[*]} || echo \"${CANCELLED}\""
    else
        error "can't ask for password as no TUI is available [${tool}]"
        exit 1
    fi

    response=$(eval "${cmd}")
    echo "${response}"

    return 0;
}

# nbsp()
#
# prints a non-breaking space to STDOUT
function nbsp() {
    printf '\xc2\xa0'
}

# space_to_nbsp <content>
#
# converts all normal spaces in the content into
# non-breaking spaces.
function space_to_nbsp() {
    local -r input="${1}"

    if not_empty "$input"; then
        printf "%s" "${input// /$(nbsp)}"
    else
        echo ""
    fi
}

# safe <content>
#
# just proxies to space_to_nbsp
function safe() {
    local -r input="${1}"
    printf "%s" "$(space_to_nbsp "$@")"
}

# is_not_typeof() <var> <type>
function is_not_typeof() {
    allow_errors
    local -n _var_reference_=$1
    local -r test="${2:-is_not_typeof(var,type) did not provide a type!}"
    catch_errors

    if is_bound _var_reference_; then
        if [[ "$test" != "$(typeof _var_reference_)" ]]; then
            return 0
        else
            return 1
        fi
    else
        local val="$1"

        if is_empty "$val"; then
            error "nothing was passed into the first parameter of is_not_typeof()"
        else
            local -r val_type="$(typeof val)"
            if [[ "$val_type" == "$test" ]]; then
                return 1
            else
                return 0
            fi
        fi
    fi
}

# is_typeof() <var> <type>
function is_typeof() {
    allow_errors
    local -n _var_reference_=$1
    local -r test="$2"

    if is_empty "$test"; then
        panic "Empty value passed in as type to test for in is_typeof(var,test)!"
    fi

    catch_errors

    if is_bound _var_reference_; then
        if [[ "$test" == "$(typeof _var_reference_)" ]]; then
            return 0
        else
            return 1
        fi
    else
        local val="$1"

        if is_empty "$val"; then
            error "nothing was passed into the first parameter of is_not_typeof()"
        else
            local -r val_type="$(typeof "$val")"
            if [[ "$val_type" == "$test" ]]; then
                return 0
            else
                return 1
            fi
        fi
    fi
}


# split_on <delimiter> <content> <ref:array>
#
# splits string content on a given delimiter and returns
# an array
function split_on() {
    local -r delimiter="${1:-not-specified}"
    local content="${2:-no-content}"
    local retain="${3:-false}"
    local -a parts=()

    if [ "$delimiter" == "not-specified" ] && [ "$content" == "no-content" ]; then
        error "split_on() called with no parameters provided!" 10
    elif [[ "$delimiter" == "not-specified" ]]; then
        delimiter=" "
    elif [[ "$content" == "no-content" ]]; then
        echo ""
        return 0
    fi

    content="${content}${delimiter}"
    while [[ "$content" ]]; do
        if [[ "$retain" == "true" ]]; then
            parts+=( "${content%%"$delimiter"*}${delimiter}" )
        else
            parts+=( "${content%%"$delimiter"*}" )
        fi
        content=${content#*"$delimiter"}
    done

    printf "%s" "${parts[*]}"
}


# get_pve_url <host> <path>
#
# Combines the base URL, the host and the path
function get_pve_url() {
    local -r host=${1:?$(config_property "DEFAULT_NODE")}

    if is_empty host; then
        panic "Call to get_pve_url() provided no Host information and we were unable to get this from DEFAULT_NODE in your configuration file: ${DIM}${MOXY_CONFIG_FILE}${RESET}"
    fi

    local -r path=${2:-/}
    local -r base="https://${host}:8006/api2/json"

    if starts_with "/" "${path}"; then
        echo "${base}${path}"
    else
        echo "${base}/${path}"
    fi
}

# get_pve <path> <filter> <host> 
#
# Calls the HTTP based API that Proxmox exposes
function get_pve() {
    local -r path=${1:?no path passed to get_pve()}
    local -r filter="${2:-}"
    local -r host="${3:-}"
    local -r url="$(get_pve_url "${host}" "${path}")"

    local response
    response="$(fetch_get "${url}" "$(pve_auth_header)")"

    if not_empty "${response}" && not_empty "${filter}"; then
        response="$(printf "%s" "${response}" | jq --raw-output "${filter}")" || error "Problem using jq with filter '${filter}' on a response [${#response} chars] from the URL ${url}"
        printf "%s" "${response}"
    else 
        echo "${response}"
    fi
}

# json_list <ref:json> <ref:data> <ref: query>
function json_list() {
    allow_errors
    local -n __json=$1
    local -n __data=$2
    local -n __query=$3 2>/dev/null # sorting, filtering, etc.
    local -n __fn=$4 2>/dev/null
    catch_errors
    local -A record

    if is_not_typeof __json "string"; then
        error "Invalid JSON passed into json_list_data(); expected a reference to string data but instead got $(typeof __json)"
    fi

    if is_not_typeof __data "array"; then
        error "Invalid data structure passed into json_list_data() for data array. Expected an array got $(typeof data)"
    else
        # start with empty dataset
        __data=()
    fi

    local json_array
    mapfile -t json_array < <(jq -c '.[]' <<<"$__json")

    for json_obj in "${json_array[@]}"; do
        record=()
        while IFS= read -r -d '' key && IFS= read -r -d '' value; do
            record["$key"]="$value"
        done < <(jq -j 'to_entries[] | (.key, "\u0000", .value, "\u0000")' <<<"$json_obj")

        __data+=("$(declare -p record | sed 's/^declare -A record=//')")
    done
}



# keys <object>
#
# Returns an array of keys for a given object
function keys() {
    local obj="${1:?no parameters passed into keys()}"
    local -a items=()
    if ! is_object "${obj}"; then
        debug "keys" "invalid object: ${DIM}${obj}${RESET}"
        return 1
    else
        # shellcheck disable=SC2207
        local -ra kvs=( $(object_to_kv_array "$obj") )

        for kv in "${kvs[@]}"; do
            local -a key=""
            key=$(first "$kv")
            debug "keys" "kv: ${kv}, key: ${key}"
            items+=( "${key}" )
        done

        debug "keys" "${items[*]}"
        printf "%s\n" "${items[@]}"
        return 0
    fi
}

# get_pvesh <path> <[filter]> <[flags]>
#
# Uses the Proxmox API via the pvesh CLI
function get_pvesh() {
    local -r path=${1:?no path provided to get_pvesh())}
    local -r filter=${2:-}
    local -r flags=${3:-}

    local -r request="pvesh get ${path} --output-format=json"

    local response
    # unfiltered response
    response="$(eval "$request")"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]] || is_empty "$1"; then
        error "CLI call to ${BOLD}${request}${RESET} failed to return successfully (or returned nothing)"
    fi
    # jq filtering applied
    local filtered
    if not_empty "$filter"; then
        filtered="$(printf "%s" "${response}" | jq --raw-output "${flags}" "${filter}")" || error "Problem using jq filter.\n\n${BOLD}Request:${RESET} ${request} | jq --raw-output ${flags} '${filter}'\n\nThe JSON payload was ${#response} chars:\n\n---- PAYLOAD ----\n${response}\n---- END PAYLOAD ----\n"
    else
        filtered="${response}"
    fi
    
    printf "%s" "${filtered}"
}

# pve_template_storage
#
# returns JSON string 
function pve_template_storage() {
    local -r storage="$(get_pvesh 'storage' '. | map(select(.content | contains("vztmpl")) | { storage, type })' '-c')"
    # local -r storage="$(get_pvesh 'storage' '. | map(select(.content | contains("vztmpl")).storage)' '-c')"

    printf "%s" "${storage}"
}

function pve_lxc_containers() {
    local -r path="/cluster/resources"
    local resources
    if is_pve_node; then
        resources="$(get_pvesh "${path}" '. | map(select(.type == "lxc"))')"
    else 
        resources="$(get_pve "${path}" '.data | map(select(.type == "lxc"))')"
    fi

    printf "%s" "${resources}"
}


function ensure_jq() {
    if ! has_command "jq"; then
        log "- your system does not have 'jq' installed"
        log "- in order to parse out JSON data we will need that to be installed"
        log "- the good news?"
        log "  - it's VERY easy to install"
        log "  - it's a VERY stable and useful utility which you may find yourself using in other places"
        log ""

        # shellcheck disable=SC2034
        local -rA yn=(
            [title]="Your system does not have 'jq' installed. This is necessary to parse JSON from API responses and is a great utility for any system. Can I install it for you?"
            [backmsg]="JQ Required"
            [width]=60
            [height]=23
            [yes]="Yes"
            [no]="No"
        )

        if ask_yes_no "yn"; then 
            local -r user="$(whoami)"
            if [[ "$user" == "root" ]]; then
                apt install jq -y
            else
                sudo apt install jq -y
            fi
        else 
            log ""
            log "- no problem; please install it at your leisure and rerun this script afterward"
            log ""
            exit 0;
        fi
    fi
}
