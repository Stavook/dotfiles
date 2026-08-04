#!/usr/bin/env bash
# Streams the current Spotify track (via MPRIS/playerctl) as JSON for waybar's custom module.
# Spotify-only: always targets `playerctl -p spotify`, never generic MPRIS/playerctld,
# so other players (browsers, VLC, etc.) never leak into this module.

PLAYER="spotify"
MAX_LEN=40
ELLIPSIS="…"
ICON_PLAYING="󰝚"
ICON_PAUSED="󰝛"

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/ }"
    s="${s//$'\r'/}"
    printf '%s' "$s"
}

print_status() {
    if ! playerctl -p "$PLAYER" status &>/dev/null; then
        printf '{"text": "", "tooltip": ""}\n'
        return
    fi

    local status title artist full label
    status=$(playerctl -p "$PLAYER" status 2>/dev/null)
    title=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)
    artist=$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null)

    if [[ -z "$title" ]]; then
        printf '{"text": "", "tooltip": ""}\n'
        return
    fi

    if [[ -n "$artist" ]]; then
        full="$title - $artist"
    else
        full="$title"
    fi

    label="$full"
    if (( ${#full} > MAX_LEN )); then
        label="${full:0:MAX_LEN}${ELLIPSIS}"
    fi

    local class="playing"
    local icon="$ICON_PLAYING"
    if [[ "$status" == "Paused" ]]; then
        class="paused"
        icon="$ICON_PAUSED"
    fi
    label="$icon $label"

    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$(json_escape "$label")" "$(json_escape "$full")" "$class"
}

print_status

dbus-monitor --session \
    "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/mpris/MediaPlayer2',sender='org.mpris.MediaPlayer2.$PLAYER'" \
    "type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.mpris.MediaPlayer2.$PLAYER'" 2>/dev/null |
while read -r line; do
    case "$line" in
        *"member=PropertiesChanged"*|*"member=NameOwnerChanged"*)
            print_status
            ;;
    esac
done
