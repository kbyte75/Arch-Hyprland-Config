#!/usr/bin/env python3

from pyquery import PyQuery
import json
import sys

location_id = "f370fc9f1e5d07401a72fab32be4e1abe8f8f9df412cbaef3110e44cbf45cc56"
unit = "metric"
forecast_type = "Daily"


#   
weather_icons = {
    "haze": "󰖞",
    "clearNight": "󰖔",
    "cloudyFoggyDay": "",
    "cloudyFoggyNight": "",
    "rainyDay": "",
    "rainyNight": "",
    "snowyIcyDay": "",
    "snowyIcyNight": "",
    "severe": "󰙾",
    "default": "",
}

_l = "en-IN" if unit == "metric" else "en-US"
url = f"https://weather.com/{_l}/weather/today/l/{location_id}"

try:
    html = PyQuery(url=url, headers={"User-Agent": "curl/7.68.0"})

    temp = html("span[data-testid='TemperatureValue']").eq(0).text() or "–"

    status = html("div[data-testid='wxPhrase']").text()
    status = status[:16] + ".." if len(status) > 17 else status

    cls = html("#regionHeader").attr("class") or ""
    parts = cls.split()
    status_code = "default"
    if len(parts) > 2:
        code_part = parts[2]
        code_parts = code_part.split("-")
        if len(code_parts) > 2:
            status_code = code_parts[2]

    icon = weather_icons.get(status.lower(), weather_icons["default"])

    temp_feel = (
        html(
            "div[data-testid='FeelsLikeSection'] span[data-testid='TemperatureValue']"
        ).text()
        or "–"
    )
    temp_feel_text = f"Feels like {temp_feel}°{'C' if unit == 'metric' else 'F'}"

    temp_max = (
        html("div[data-testid='wxData'] span[data-testid='TemperatureValue']")
        .eq(0)
        .text()
        or "–"
    )
    temp_min = (
        html("div[data-testid='wxData'] span[data-testid='TemperatureValue']")
        .eq(1)
        .text()
        or "–"
    )
    temp_min_max = f" {temp_min}°   {temp_max}°"

    wind = html("span[data-testid='Wind']").text()
    wind_speed = wind.split()[-2] if wind and ("mph" in wind or "km/h" in wind) else "–"
    wind_text = f"風 {wind_speed}"

    humidity = html("span[data-testid='PercentageValue']").eq(0).text() or "–"
    humidity_text = f" {humidity}"

    vis = html("span[data-testid='VisibilityValue']").text()
    visibility = vis.split()[0] if vis else "–"
    visibility_text = f" {visibility}"

    aqi = html("text[data-testid='DonutChartValue']").text() or "–"

    precip = html(
        f"section[aria-label='{forecast_type} Forecast'] div[data-testid='SegmentPrecipPercentage'] span"
    ).text()
    precip = precip.replace("Chance of Rain", "").strip() if precip else ""
    r_prediction = f"  ({forecast_type}) {precip}" if precip else ""

    t_pred = html(
        f"section[aria-label='{forecast_type} Forecast'] div[data-testid='SegmentHighTemp'] span"
    ).text()
    t_pred = t_pred.replace(" /", "/").strip() if t_pred else ""
    t_prediction = f" 晴 ({forecast_type}) {t_pred}" if t_pred else ""

    tooltip = (
        f'\t\t<span size="xx-large">{temp}°</span>\t\t\n'
        f"<big>{icon}</big>\n"
        f"<big>{status}</big>\n"
        f"<small>{temp_feel_text}</small>\n\n"
        f"<big>{temp_min_max}</big>\n"
        f"{wind_text}\t{humidity_text}\n"
        f"{visibility_text}\tAQI {aqi}\n\n"
        f"<i>{r_prediction}</i>\n"
        f"<i>{t_prediction}</i>"
    )

    out = {
        "text": f"{icon} {temp}", #{icon}
        "alt": status,
        "tooltip": tooltip,
        # "class": [status_code],  # List for CSS
    }

    print(json.dumps(out, ensure_ascii=False))
except Exception as e:
    print(
        json.dumps({"text": " –", "tooltip": "Error", "class": "error"}),
        file=sys.stderr,
    )
    sys.exit(1)
