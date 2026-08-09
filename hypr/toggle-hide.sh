#!/usr/bin/env bash
# Toggles the focused window between its current workspace and the special
# scratchpad workspace, so one key both hides and un-hides.

workspace=$(hyprctl activewindow -j | python3 -c "import json,sys; print(json.load(sys.stdin)['workspace']['name'])")

if [ "$workspace" = "special:magic" ]; then
    active=$(hyprctl monitors -j | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['activeWorkspace']['id'])")
    hyprctl dispatch "hl.dsp.window.move({ workspace = $active })"
else
    hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:magic" })'
fi
