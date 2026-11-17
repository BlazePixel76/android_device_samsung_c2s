# Secret command: blaze --nproc
blaze() {
    if [ "$1" != "--nproc" ]; then
        echo "blaze: nothing to see here 👀"
        return 0
    fi

    # Colours
    local C=$'\033[1;36m' B=$'\033[1m' D=$'\033[2m' R=$'\033[0m'

    local threads ram_gb jobs target disk
    threads=$(nproc --all)
    ram_gb=$(awk '/^MemTotal:/ {printf "%d", $2/1024/1024}' /proc/meminfo)
    # Rough guide: about 2 GB of RAM per compile job, never more than the CPU threads
    jobs=$(( ram_gb / 2 ))
    [ "$jobs" -lt 1 ] && jobs=1
    [ "$jobs" -gt "$threads" ] && jobs=$threads

    if [ -n "$TARGET_PRODUCT" ]; then
        target="$TARGET_PRODUCT-$TARGET_BUILD_VARIANT"
    else
        target="${D}not set (run breakfast c2s)${R}"
    fi
    disk=$(df -h "$(gettop)" | awk 'NR==2 {print $4 " free"}')

    local -a lines=(
        "${C} ____  _          _  ___  ____${R}"
        "${C}|  _ \\(_)_  _____| |/ _ \\/ ___|${R}"
        "${C}| |_) | \\ \\/ / _ \\ | | | \\___ \\\\${R}"
        "${C}|  __/| |>  <  __/ | |_| |___) |${R}"
        "${C}|_|   |_/_/\\_\\___|_|\\___/|____/${R}"
        ""
        "${B}Device      :${R} Samsung Galaxy Note 20 Ultra (c2s)"
        "${B}Maintainer  :${R} BlazePixel"
        "${B}Target      :${R} $target"
        "${B}CPU threads :${R} $threads"
        "${B}RAM         :${R} $(free -h | awk '/^Mem:/ {print $2}')"
        "${B}Swap / zram :${R} $(free -h | awk '/^Swap:/ {print $2}')"
        "${B}Disk        :${R} $disk"
        "${B}Host kernel :${R} $(uname -r)"
        "${B}Suggested   :${R} m pixelos -j$jobs"
    )

    local logo rows=${#lines[@]} logo_rows=10 col=22 line top
    logo="$(gettop)/device/samsung/c2s/blaze/pixelos.png"

    if command -v chafa >/dev/null 2>&1 && [ -f "$logo" ]; then
        # 1. Text first, in the right-hand column
        for line in "${lines[@]}"; do
            printf '\033[%dG%s\n' "$col" "$line"
        done
        # 2. Remember where we are (below the text)
        printf '\0337'
        # 3. Jump up so the logo is vertically centred next to the text
        top=$(( (rows - logo_rows) / 2 ))
        printf '\033[%dA\033[1G' "$(( rows - top ))"
        chafa --size=18x${logo_rows} "$logo"
        # 4. Go back below the text
        printf '\0338'
    else
        for line in "${lines[@]}"; do
            printf '%s\n' "$line"
        done
    fi
}
