#!/usr/bin/env bash
# Current weather as JSON for waybar's custom module, from Open-Meteo (no key).
# Location comes from the public IP (ip-api.com), cached for a day, so each
# machine shows its own city. Prints empty text when offline so the module hides.

CACHE="$HOME/.cache/waybar-weather-location.json"

if [ ! -s "$CACHE" ] || [ -n "$(find "$CACHE" -mmin +1440 2>/dev/null)" ]; then
    mkdir -p "$(dirname "$CACHE")"
    loc=$(curl -sf -m 10 'http://ip-api.com/json/?fields=status,city,lat,lon') || loc=""
    if [ -n "$loc" ] && [[ "$loc" == *'"success"'* ]]; then
        printf '%s' "$loc" > "$CACHE"
    fi
fi

if [ ! -s "$CACHE" ]; then
    printf '{"text": "", "tooltip": ""}\n'
    exit 0
fi

read -r lat lon < <(python3 -I -c '
import json, sys
d = json.load(open(sys.argv[1]))
print(d["lat"], d["lon"])' "$CACHE")

weather=$(curl -sf -m 10 "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1") || weather=""

if [ -z "$weather" ]; then
    printf '{"text": "", "tooltip": ""}\n'
    exit 0
fi

python3 -I -c '
import json, sys

loc = json.load(open(sys.argv[1]))
w = json.loads(sys.argv[2])
c, d = w["current"], w["daily"]
code, day = c["weather_code"], c["is_day"]

# WMO weather codes -> (icon, description, class)
if code == 0:
    icon, desc, cls = ("" if day else ""), "Clear", "clear"
elif code in (1, 2):
    icon, desc, cls = ("" if day else ""), "Partly cloudy", "cloudy"
elif code == 3:
    icon, desc, cls = "", "Overcast", "cloudy"
elif code in (45, 48):
    icon, desc, cls = "", "Fog", "fog"
elif code in (51, 53, 55, 56, 57, 61, 63, 66, 80, 81):
    icon, desc, cls = "", "Rain", "rain"
elif code in (65, 67, 82):
    icon, desc, cls = "", "Heavy rain", "rain"
elif code in (71, 73, 75, 77, 85, 86):
    icon, desc, cls = "", "Snow", "snow"
elif code in (95, 96, 99):
    icon, desc, cls = "", "Thunderstorm", "storm"
else:
    icon, desc, cls = "", "Cloudy", "cloudy"

temp = round(c["temperature_2m"])
city = loc.get("city", "")
feels = round(c["apparent_temperature"])
high = round(d["temperature_2m_max"][0])
low = round(d["temperature_2m_min"][0])
humidity = c["relative_humidity_2m"]
wind = round(c["wind_speed_10m"])
tooltip = (
    f"{city}: {desc}\n"
    f"Feels like {feels}°\n"
    f"High {high}° / Low {low}°\n"
    f"Humidity {humidity}%  Wind {wind} km/h"
)
print(json.dumps({"text": f"<span font_family=\"lucide\">{icon}</span> {temp}°", "tooltip": tooltip, "class": cls}, ensure_ascii=False))
' "$CACHE" "$weather"
