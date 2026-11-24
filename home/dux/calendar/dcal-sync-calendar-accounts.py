#!/usr/bin/env python3
"""Sync calendar accounts from a SOPS secret file into the dcal CLI.

Reads the secret file referenced by SECRET_PATH and creates ical accounts
via the DCAL executable. Idempotent: accounts whose name or url already
exist are skipped.
"""

import json
import os
import re
import subprocess
import sys

PROG = "dcal-sync-calendar-accounts"
URL_RE = re.compile(r'(https?|webcal)://[^"\'\r\n <>]+')


def log(msg):
    print("%s: %s" % (PROG, msg))


def warn(msg):
    print("%s: %s" % (PROG, msg), file=sys.stderr)


def dcal_bin():
    return os.environ.get("DCAL") or "dcal"


def secret_path():
    return os.environ.get("SECRET_PATH") or ""


def list_accounts():
    """Return the list of existing dcal accounts, or [] on any problem."""
    try:
        result = subprocess.run(
            [dcal_bin(), "account", "list", "--json"],
            capture_output=True,
            text=True,
        )
    except OSError:
        return []

    if result.returncode != 0:
        return []

    try:
        accounts = json.loads(result.stdout)
    except (ValueError, TypeError):
        return []

    if not isinstance(accounts, list):
        return []

    return accounts


def parse_json_list(data):
    """Yield (name, url) from a JSON list of malformed-ish account dicts."""
    for item in data:
        if not isinstance(item, dict):
            continue
        name = item.get("name")
        if name is None:
            name = "Personal"
        url = item.get("url")
        if url is None:
            url = ""
        yield (name, url)


def parse_json_object(data):
    """Yield (name, url) from a JSON object mapping name -> url."""
    for name, url in data.items():
        if isinstance(url, str):
            yield (name, url)
        else:
            yield (name, "")


def parse_plain_text(text):
    """Yield ("Personal", url) for the first URL found on each line."""
    for line in text.splitlines():
        match = URL_RE.search(line)
        if match:
            yield ("Personal", match.group(0))


def parse_feeds(text):
    """Parse secret file contents into a list of (name, url) tuples."""
    try:
        data = json.loads(text)
    except (ValueError, TypeError):
        return list(parse_plain_text(text))

    if isinstance(data, list):
        return list(parse_json_list(data))

    if isinstance(data, dict):
        return list(parse_json_object(data))

    return list(parse_plain_text(text))


def account_exists(accounts, name, url):
    for account in accounts:
        if not isinstance(account, dict):
            continue
        settings = account.get("settings") or {}
        if settings.get("url") == url:
            return True
        if account.get("displayName") == name:
            return True
    return False


def add_feed(url, name):
    """Add an ical account. Returns True on success."""
    try:
        result = subprocess.run(
            [dcal_bin(), "account", "add", "ical", url, "--name", name],
            capture_output=True,
            text=True,
        )
    except OSError:
        return False

    return result.returncode == 0


def main():
    path = secret_path()

    if not path or not os.access(path, os.R_OK):
        log("secret file '%s' not readable yet. Skipping." % path)
        return 0

    try:
        with open(path, "r", encoding="utf-8") as handle:
            text = handle.read()
    except OSError:
        log("secret file '%s' not readable yet. Skipping." % path)
        return 0

    accounts = list_accounts()
    feeds = parse_feeds(text)

    for name, url in feeds:
        if not url:
            continue

        if account_exists(accounts, name, url):
            log("account for '%s' (%s) already exists. Skipping." % (name, url))
            continue

        log("adding ical account '%s' (%s)..." % (name, url))

        if add_feed(url, name):
            log("successfully added '%s'." % name)
        else:
            warn("warning: failed to add '%s' (network offline?)." % url)

    return 0


if __name__ == "__main__":
    sys.exit(main())
