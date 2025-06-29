is_valid_ipv6() {
    local ip="$1"
    local segments=()
    local seg=""
    local double_colon=0
    local count=0

    # ---------------------------------------------------------------------------
    # Reject if the address contains an interface identifier (e.g. fe80::1%eth0)
    # ---------------------------------------------------------------------------
    [[ "$ip" == *%* ]] && return 1

    # ---------------------------------------------------------------------------
    # Accept IPv4-mapped IPv6 forms like ::ffff:192.0.2.128
    # ---------------------------------------------------------------------------
    if [[ "$ip" =~ ^([0-9a-fA-F]{1,4}:){6}([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    fi
    if [[ "$ip" =~ ::[fF]{4}:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    fi

    # ---------------------------------------------------------------------------
    # Count occurrences of "::" — must be 0 or 1
    # ---------------------------------------------------------------------------
    if [[ "$ip" == *"::"* ]]; then
        # Using Bash native string replacement to count occurrences
        local temp="${ip//[^:]}"
        local colons=${#temp}
        # "::" counts as 2 colons in a row
        local dc_count=$(( (colons - ${#ip//::}) / 2 ))
        (( dc_count > 1 )) && return 1
        double_colon=1
    fi

    # ---------------------------------------------------------------------------
    # Split the address by ":" into segments
    # ---------------------------------------------------------------------------
    IFS=':' read -ra segments <<< "$ip"

    # If starts with "::", ignore empty leading segment
    [[ "$ip" == ::* && -z "${segments[0]}" ]] && segments=("${segments[@]:1}")

    # If ends with "::", ignore empty trailing segment
    [[ "$ip" == *:: && -z "${segments[-1]}" ]] && unset "segments[${#segments[@]}-1]"

    count=${#segments[@]}

    # ---------------------------------------------------------------------------
    # Validate block count:
    #  - if double colon, must be <= 7 segments
    #  - if no double colon, must be exactly 8 segments
    # ---------------------------------------------------------------------------
    if (( double_colon )); then
        (( count <= 7 )) || return 1
    else
        (( count == 8 )) || return 1
    fi

    # ---------------------------------------------------------------------------
    # Validate each segment: must be 1–4 hex digits (case-insensitive)
    # ---------------------------------------------------------------------------
    for seg in "${segments[@]}"; do
        [[ -z "$seg" ]] && continue  # Allow empty parts only when '::' used
        [[ "$seg" =~ ^[0-9a-fA-F]{1,4}$ ]] || return 1
    done

    return 0
}
