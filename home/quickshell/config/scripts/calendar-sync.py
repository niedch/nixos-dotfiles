#!/usr/bin/env python3
"""calendar-sync — fetch ICS feeds and emit events as JSON for the quickshell calendar popup.

Usage:
  calendar-sync.py list --from YYYY-MM-DD --to YYYY-MM-DD [--json]

Reads ICS feed URLs from ~/.config/quickshell/calendars.txt, one per line.
Optional comment tags directly above a URL:
    # name: Work
    # colour: #3b82f6
    https://calendar.google.com/calendar/ical/.../basic.ics

Feeds are fetched and cached under ~/.cache/quickshell-calendar/ with a
5-minute TTL so frequent popup refreshes don't hammer the server.
"""

import argparse
import datetime as dt
import hashlib
import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

try:
    from dateutil.rrule import rrulestr
except ImportError:
    sys.exit("calendar-sync: python-dateutil required (python3Packages.python-dateutil)")

CONFIG_DIR = Path.home() / ".config" / "quickshell"
CALENDARS_FILE = CONFIG_DIR / "calendars.txt"
CACHE_DIR = Path.home() / ".cache" / "quickshell-calendar"
CACHE_MAX_AGE = 300  # seconds


# ---------- config ----------

_TAG_RE = re.compile(r"^([a-zA-Z_]+)\s*[:=]\s*(.+?)\s*$")


def load_calendars():
    """Parse calendars.txt into [{label, color, url}, ...]."""
    if not CALENDARS_FILE.exists():
        return []
    out = []
    pending = {"label": None, "color": None}
    fallback_label = None
    n = 0
    for raw in CALENDARS_FILE.read_text().splitlines():
        line = raw.strip()
        if not line:
            pending = {"label": None, "color": None}
            fallback_label = None
            continue
        if line.startswith("#"):
            m = _TAG_RE.match(line.lstrip("#").strip())
            if m:
                key = m.group(1).lower()
                if key in ("name", "label", "title"):
                    pending["label"] = m.group(2)
                elif key in ("colour", "color"):
                    pending["color"] = m.group(2)
            else:
                fallback_label = line.lstrip("#").strip()
            continue
        url = line
        if url.startswith("webcal://"):
            url = "https://" + url[9:]
        n += 1
        out.append({
            "label": pending["label"] or fallback_label or f"Calendar {n}",
            "url": url,
            "color": pending["color"],
        })
        pending = {"label": None, "color": None}
        fallback_label = None
    return out


# ---------- fetching ----------


def url_to_cache_path(url):
    h = hashlib.sha256(url.encode()).hexdigest()[:16]
    return CACHE_DIR / f"{h}.ics"


def fetch_ics(url, force_refresh=False, max_age=CACHE_MAX_AGE):
    """Fetch an ICS file, using the cache when fresh enough."""
    cache_path = url_to_cache_path(url)

    if not force_refresh and cache_path.exists():
        age = dt.datetime.now().timestamp() - cache_path.stat().st_mtime
        if age < max_age:
            return cache_path.read_text()

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "calendar-sync/1.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            content = resp.read().decode("utf-8", errors="replace")
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(content)
        return content
    except (urllib.error.URLError, OSError) as e:
        print(f"calendar-sync: failed to fetch {url}: {e}", file=sys.stderr)
        if cache_path.exists():
            return cache_path.read_text()
        return None


# ---------- ICS parsing ----------


def unfold_ics(content):
    lines = []
    for line in content.replace("\r\n", "\n").split("\n"):
        if line.startswith((" ", "\t")) and lines:
            lines[-1] += line[1:]
        else:
            lines.append(line)
    return lines


def parse_ics_line(line):
    if ":" not in line:
        return None, {}, line
    name_params, value = line.split(":", 1)
    if ";" in name_params:
        parts = name_params.split(";")
        name = parts[0]
        params = {}
        for p in parts[1:]:
            if "=" in p:
                k, v = p.split("=", 1)
                params[k.upper()] = v
        return name.upper(), params, value
    return name_params.upper(), {}, value


def parse_ics_datetime(value, params):
    """Parse an ICS datetime into an aware datetime, or None."""
    try:
        if len(value) == 8:  # all-day DATE
            return dt.datetime.strptime(value, "%Y%m%d").replace(tzinfo=dt.timezone.utc)
        is_utc = value.endswith("Z")
        value = value.rstrip("Z")
        naive = dt.datetime.strptime(value, "%Y%m%dT%H%M%S")
        if is_utc:
            return naive.replace(tzinfo=dt.timezone.utc)
        tzid = params.get("TZID")
        if tzid:
            try:
                from zoneinfo import ZoneInfo
                return naive.replace(tzinfo=ZoneInfo(tzid))
            except Exception:
                pass
        return naive.replace(tzinfo=dt.timezone.utc)
    except Exception:
        return None


def parse_vevent(lines):
    event = {
        "uid": None,
        "summary": "(untitled)",
        "dtstart": None,
        "dtend": None,
        "all_day": False,
        "rrule": None,
        "exdates": [],
        "location": "",
        "status": "CONFIRMED",
    }
    rrule_lines = []
    for line in lines:
        name, params, value = parse_ics_line(line)
        if name == "UID":
            event["uid"] = value
        elif name == "SUMMARY":
            event["summary"] = value.replace("\\,", ",").replace("\\n", "\n").strip()
        elif name == "DTSTART":
            event["dtstart"] = parse_ics_datetime(value, params)
            if params.get("VALUE") == "DATE" or len(value) == 8:
                event["all_day"] = True
        elif name == "DTEND":
            event["dtend"] = parse_ics_datetime(value, params)
        elif name == "RRULE":
            rrule_lines.append(f"RRULE:{value}")
        elif name == "EXDATE":
            exdt = parse_ics_datetime(value, params)
            if exdt:
                event["exdates"].append(exdt)
        elif name == "LOCATION":
            event["location"] = value.replace("\\,", ",").replace("\\n", "\n")
        elif name == "STATUS":
            event["status"] = value
    if rrule_lines:
        event["rrule"] = "\n".join(rrule_lines)
    return event


def parse_ics(content):
    if not content:
        return
    lines = unfold_ics(content)
    in_vevent = False
    vevent_lines = []
    for line in lines:
        name, _params, value = parse_ics_line(line)
        if name == "BEGIN" and value == "VEVENT":
            in_vevent = True
            vevent_lines = []
        elif name == "END" and value == "VEVENT":
            in_vevent = False
            event = parse_vevent(vevent_lines)
            if event["dtstart"] and event["status"] != "CANCELLED":
                yield event
        elif in_vevent:
            vevent_lines.append(line)


# ---------- recurrence ----------


def _event_duration(ev):
    if ev.get("dtend") and ev.get("dtstart"):
        return ev["dtend"] - ev["dtstart"]
    if ev.get("all_day"):
        return dt.timedelta(days=1)
    return dt.timedelta(hours=1)


def _expand_rrule(rrule_str, exdates, dtstart, window_lo, window_hi):
    if not rrule_str:
        return []
    block = rrule_str.strip()
    dtstart_utc = dtstart.astimezone(dt.timezone.utc)
    win_lo_utc = window_lo.astimezone(dt.timezone.utc)
    win_hi_utc = window_hi.astimezone(dt.timezone.utc)
    exdate_lines = ""
    for exdt in exdates:
        exdt_utc = exdt.astimezone(dt.timezone.utc)
        exdate_lines += f"\nEXDATE:{exdt_utc.strftime('%Y%m%dT%H%M%SZ')}"
    aware = f"DTSTART:{dtstart_utc.strftime('%Y%m%dT%H%M%SZ')}\n{block}{exdate_lines}"
    try:
        rule = rrulestr(aware, forceset=True)
        return list(rule.between(win_lo_utc, win_hi_utc, inc=True))
    except (TypeError, ValueError):
        pass
    naive_block = re.sub(r";TZID=[^:]+:", ":", block)
    naive = f"DTSTART:{dtstart_utc.strftime('%Y%m%dT%H%M%S')}\n{naive_block}"
    try:
        rule = rrulestr(naive, forceset=True)
        occs = rule.between(
            win_lo_utc.replace(tzinfo=None),
            win_hi_utc.replace(tzinfo=None),
            inc=True,
        )
        return [o.replace(tzinfo=dt.timezone.utc) for o in occs]
    except Exception:
        return []


def scan_events(window_lo, window_hi, force_refresh=False):
    """Yield event dicts for occurrences in [window_lo, window_hi]."""
    calendars = load_calendars()
    if not calendars:
        return

    for cal in calendars:
        content = fetch_ics(cal["url"], force_refresh=force_refresh)
        if not content:
            continue

        events_by_uid = {}
        for event in parse_ics(content):
            key = (cal["url"], event["uid"] or id(event))
            if key not in events_by_uid:
                events_by_uid[key] = {"master": None, "calendar": cal}
            if event["rrule"]:
                events_by_uid[key]["master"] = event
            elif events_by_uid[key]["master"] is None:
                events_by_uid[key]["master"] = event

        for group in events_by_uid.values():
            master = group["master"]
            cal_cfg = group["calendar"]
            if not master or not master["dtstart"]:
                continue
            duration = _event_duration(master)
            starts = []
            if master["rrule"]:
                starts = _expand_rrule(
                    master["rrule"], master.get("exdates", []),
                    master["dtstart"], window_lo, window_hi,
                )
            else:
                if window_lo <= master["dtstart"] <= window_hi:
                    starts = [master["dtstart"]]
            for start in starts:
                yield {
                    "uid": str(master["uid"] or id(master)),
                    "summary": master["summary"],
                    "start": start.isoformat(),
                    "end": (start + duration).isoformat(),
                    "all_day": master.get("all_day", False),
                    "location": master.get("location", ""),
                    "calendar_label": cal_cfg["label"],
                    "calendar_color": cal_cfg["color"] or "",
                }


# ---------- CLI ----------


def main():
    parser = argparse.ArgumentParser(description="Fetch ICS feeds and list events as JSON.")
    sub = parser.add_subparsers(dest="command", required=True)

    list_p = sub.add_parser("list", help="list events in a window")
    list_p.add_argument("--from", dest="from_date", required=True,
                        help="window start YYYY-MM-DD")
    list_p.add_argument("--to", dest="to_date", required=True,
                        help="window end YYYY-MM-DD (exclusive)")
    list_p.add_argument("--json", action="store_true", help="emit JSON to stdout")
    list_p.add_argument("--refresh", action="store_true", help="force re-fetch")

    args = parser.parse_args()

    if args.command == "list":
        fmt = "%Y-%m-%d"
        try:
            window_lo = dt.datetime.strptime(args.from_date, fmt).replace(
                tzinfo=dt.timezone.utc)
            window_hi = dt.datetime.strptime(args.to_date, fmt).replace(
                tzinfo=dt.timezone.utc)
        except ValueError:
            sys.exit("calendar-sync: dates must be YYYY-MM-DD")
        events = sorted(
            scan_events(window_lo, window_hi, force_refresh=args.refresh),
            key=lambda e: e["start"],
        )
        if args.json:
            payload = {
                "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
                "events": events,
            }
            json.dump(payload, sys.stdout)
            sys.stdout.write("\n")
        else:
            for ev in events:
                start = dt.datetime.fromisoformat(ev["start"]).astimezone()
                print(f"{start.strftime('%Y-%m-%d %H:%M')}  "
                      f"[{ev['calendar_label']}] {ev['summary']}")
            if not events:
                print("(no events in window)")


if __name__ == "__main__":
    main()
