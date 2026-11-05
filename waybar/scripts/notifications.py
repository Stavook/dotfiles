#!/usr/bin/env python3
"""Notification center for waybar's custom module, on top of mako.

No arguments: print the module JSON. `toggle`: switch do-not-disturb.
`scroll N`: page the popup list. `clear`: empty the list.

The list is mako's own in-memory history, so it's gone after a reboot. "Clear"
only hides what's there (mako can't delete history), and that state lives in
$XDG_RUNTIME_DIR, which is also wiped on reboot. Colors come from Aether.
"""
import html
import json
import os
import subprocess
import sys
import tomllib
from pathlib import Path

STATE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "waybar-notifications.json"
COLORS = Path.home() / ".config/aether/theme/colors.toml"
DND = "do-not-disturb"
SIGNAL = 12           # must match "signal" in modules/notifications.jsonc
PAGE = 8
MAX_BODY = 60


def read_state():
    try:
        return json.loads(STATE.read_text())
    except (OSError, ValueError):
        return {"offset": 0, "cleared": 0}


def write_state(state):
    STATE.write_text(json.dumps(state))
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "waybar"], check=False)


def makoctl(*args):
    result = subprocess.run(["makoctl", *args], capture_output=True, text=True, check=False)
    return result.stdout


def notifications():
    """Current and past notifications, newest first."""
    merged = {}
    for command in ("history", "list"):
        try:
            for item in json.loads(makoctl(command, "-j") or "[]"):
                merged[item["id"]] = item
        except ValueError:
            pass
    return [merged[i] for i in sorted(merged, reverse=True)]


def dnd_on():
    return DND in makoctl("mode").split()


def shorten(text):
    text = " ".join((text or "").split())
    return text if len(text) <= MAX_BODY else text[:MAX_BODY - 1] + "…"


def render(items, offset, dnd, colors):
    accent = colors.get("accent", "")
    muted = colors.get("muted", "")

    def paint(text, color, bold=False):
        inner = f"<b>{text}</b>" if bold else text
        return f"<span color='{color}'>{inner}</span>" if color else inner

    state = "on" if dnd else "off"
    lines = [paint(f"Notifications ({len(items)})", accent, bold=True),
             paint(f"Do not disturb: {state}", muted), ""]

    if not items:
        lines.append("Nothing here yet")
    for item in items[offset:offset + PAGE]:
        summary = html.escape(shorten(item.get("summary")))
        app = html.escape(item.get("app_name") or "")
        lines.append(f"<b>{summary}</b>  {paint(app, muted)}")
        body = html.escape(shorten(item.get("body")))
        if body:
            lines.append(body)
        lines.append("")

    if len(items) > PAGE:
        last = min(offset + PAGE, len(items))
        lines.append(paint(f"{offset + 1}-{last}/{len(items)}  scroll for more", muted))
    icon = lambda code: f"<span font_family='lucide'>{chr(code)}</span>"
    lines.append(paint(f"{icon(0xe6bf)} : do not disturb   {icon(0xe6c0)} : clear", muted))
    return "\n".join(lines)


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    state = read_state()
    everything = notifications()

    # Mako restarted and its ids began again, so the old watermark is stale.
    if everything and everything[0]["id"] < state["cleared"]:
        state["cleared"] = 0
    items = [n for n in everything if n["id"] > state["cleared"]]

    if command == "toggle":
        subprocess.run(["makoctl", "mode", "-t", DND], check=False)
        write_state(state)
        return
    if command == "scroll":
        limit = max(len(items) - PAGE, 0)
        state["offset"] = min(max(state["offset"] + int(sys.argv[2]), 0), limit)
        write_state(state)
        return
    if command == "clear":
        if everything:
            state["cleared"] = everything[0]["id"]
        state["offset"] = 0
        write_state(state)
        return

    try:
        colors = tomllib.loads(COLORS.read_text())
    except (OSError, tomllib.TOMLDecodeError):
        colors = {}

    dnd = dnd_on()
    offset = min(state["offset"], max(len(items) - PAGE, 0))
    print(json.dumps({
        "text": f" {len(items)}" if items else "",
        "alt": "dnd" if dnd else "on",
        "class": "dnd" if dnd else "on",
        "tooltip": render(items, offset, dnd, colors),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
