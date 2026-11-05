#!/usr/bin/env python3
"""Clock with a month calendar in the tooltip, for waybar's custom module.

No arguments: print the module JSON. `shift N`: move the shown month by N.
`reset`: back to the current month. `date`: swap the bar text between the time
and the date.

Tooltips can't take keyboard input, so Hyprland handles the keys: while the
mouse is on the clock it enters a submap (see "calendar" in hypr/hyprland.lua)
where the arrows and backspace call this script. Colors come from Aether.
"""
import calendar
import datetime as dt
import json
import subprocess
import sys
import tomllib
from pathlib import Path

OFFSET = Path.home() / ".cache/waybar-calendar-offset"
COLORS = Path.home() / ".config/aether/theme/colors.toml"
SHOW_DATE = Path.home() / ".cache/waybar-clock-show-date"

SIGNAL = 10           # must match "signal" in modules/clock.jsonc


def refresh():
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "waybar"], check=False)


def read_offset():
    try:
        return int(OFFSET.read_text())
    except (OSError, ValueError):
        return 0


def write_offset(value):
    OFFSET.parent.mkdir(parents=True, exist_ok=True)
    OFFSET.write_text(str(value))
    refresh()


def toggle_date():
    if SHOW_DATE.exists():
        SHOW_DATE.unlink()
    else:
        SHOW_DATE.parent.mkdir(parents=True, exist_ok=True)
        SHOW_DATE.touch()
    refresh()


def month_after(today, offset):
    index = today.year * 12 + today.month - 1 + offset
    return index // 12, index % 12 + 1


def render(today, year, month, colors):
    accent = colors.get("accent", "")
    muted = colors.get("muted", "")

    def paint(text, color, bold=False):
        inner = f"<b>{text}</b>" if bold else text
        return f"<span color='{color}'>{inner}</span>" if color else inner

    title = f"{calendar.month_name[month]} {year}"
    lines = [paint(title.center(20), accent, bold=True),
             paint("Mo Tu We Th Fr Sa Su", muted)]

    for week in calendar.Calendar(firstweekday=0).monthdayscalendar(year, month):
        cells = []
        for number in week:
            if number == 0:
                cells.append("  ")
                continue
            text = f"{number:2d}"
            if dt.date(year, month, number) == today:
                text = f"<u>{paint(text, accent, bold=True)}</u>"
            cells.append(text)
        lines.append(" ".join(cells))

    lines.append("")
    lines.append(paint("󰧀 󰧂 month  ⌫ today", muted))
    return "<tt>" + "\n".join(lines) + "</tt>"


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "shift":
        write_offset(read_offset() + int(sys.argv[2]))
        return
    if command == "reset":
        write_offset(0)
        return
    if command == "date":
        toggle_date()
        return

    try:
        colors = tomllib.loads(COLORS.read_text())
    except (OSError, tomllib.TOMLDecodeError):
        colors = {}

    now = dt.datetime.now()
    year, month = month_after(now.date(), read_offset())
    print(json.dumps({
        "text": now.strftime("%d-%m-%Y" if SHOW_DATE.exists() else "%H:%M"),
        "tooltip": render(now.date(), year, month, colors),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
