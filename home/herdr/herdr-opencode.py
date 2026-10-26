#!/usr/bin/env python3
"""
herdr-opencode: Starts or connects to a Herdr session running OpenCode.
Ensures 100% parity with the original herdr-opencode shell script.
"""

import json
import os
import re
import stat
import subprocess
import sys
import time
from typing import Optional


def get_session_name(cli_arg: Optional[str] = None) -> str:
    """Resolve session name from CLI argument, git root, or current directory."""
    if cli_arg:
        session = cli_arg
    else:
        git_root = None
        try:
            res = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                capture_output=True,
                text=True,
                check=False,
            )
            if res.returncode == 0 and res.stdout.strip():
                git_root = res.stdout.strip()
        except OSError:
            git_root = None

        if git_root:
            session = os.path.basename(git_root)
        else:
            session = os.path.basename(os.getcwd())

    session = session.replace("\n", "")
    session = re.sub(r"[^a-zA-Z0-9_-]", "-", session)
    return session


def get_socket_path(session: str) -> str:
    """Resolve herdr session socket path using XDG_CONFIG_HOME or ~/.config."""
    xdg_config = os.environ.get("XDG_CONFIG_HOME")
    if not xdg_config:
        home = os.environ.get("HOME", os.path.expanduser("~"))
        xdg_config = os.path.join(home, ".config")
    return os.path.join(xdg_config, "herdr", "sessions", session, "herdr.sock")


def is_socket(path: str) -> bool:
    """Check if the path exists and is a Unix domain socket."""
    try:
        return stat.S_ISSOCK(os.stat(path).st_mode)
    except OSError:
        return False


def run_herdr_cmd(session: str, *args: str) -> subprocess.CompletedProcess:
    """Execute a herdr command with the session flag and return completed process."""
    cmd = ["herdr", "--session", session, *args]
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=False,
    )


def extract_pane_id_from_workspace_json(raw_json: str) -> Optional[str]:
    """Parse workspace create output: .result.root_pane.pane_id // .root_pane_id // .pane_id."""
    try:
        data = json.loads(raw_json)
        if isinstance(data, dict):
            result = data.get("result")
            if isinstance(result, dict):
                root_pane = result.get("root_pane")
                if isinstance(root_pane, dict) and root_pane.get("pane_id"):
                    return str(root_pane["pane_id"])
                if result.get("root_pane_id"):
                    return str(result["root_pane_id"])
                if result.get("pane_id"):
                    return str(result["pane_id"])
            if data.get("root_pane_id"):
                return str(data["root_pane_id"])
            if data.get("pane_id"):
                return str(data["pane_id"])
    except (json.JSONDecodeError, TypeError):
        pass
    return None


def create_workspace(session: str) -> Optional[str]:
    """Create a workspace in the current working directory and return root pane ID."""
    res = subprocess.run(
        ["herdr", "--session", session, "workspace", "create", "--cwd", os.getcwd()],
        capture_output=True,
        text=True,
        check=False,
    )
    if res.returncode == 0 and res.stdout.strip():
        return extract_pane_id_from_workspace_json(res.stdout)
    return None


def has_running_agent(session: str) -> bool:
    """Check whether any agent is currently registered in the session."""
    res = run_herdr_cmd(session, "agent", "list")
    if res.returncode != 0 or not res.stdout.strip():
        return False
    try:
        data = json.loads(res.stdout)
        if isinstance(data, dict):
            agents = None
            result = data.get("result")
            if isinstance(result, dict) and "agents" in result:
                agents = result["agents"]
            elif "agents" in data:
                agents = data["agents"]
            if isinstance(agents, list) and len(agents) > 0:
                return True
    except (json.JSONDecodeError, TypeError):
        pass
    return False


def get_first_pane_id(session: str) -> Optional[str]:
    """Retrieve first pane ID: .result.panes[0].pane_id // .panes[0].id."""
    res = run_herdr_cmd(session, "pane", "list")
    if res.returncode != 0 or not res.stdout.strip():
        return None
    try:
        data = json.loads(res.stdout)
        if isinstance(data, dict):
            panes = None
            result = data.get("result")
            if isinstance(result, dict) and isinstance(result.get("panes"), list):
                panes = result["panes"]
            elif isinstance(data.get("panes"), list):
                panes = data["panes"]

            if panes and len(panes) > 0 and isinstance(panes[0], dict):
                pane_id = panes[0].get("pane_id") or panes[0].get("id")
                if pane_id:
                    return str(pane_id)
    except (json.JSONDecodeError, TypeError):
        pass
    return None


def start_opencode_agent(session: str, pane_id: str) -> None:
    """Attempt to start opencode agent via agent start, fallback to pane run."""
    res = subprocess.run(
        [
            "herdr",
            "--session",
            session,
            "agent",
            "start",
            "opencode",
            "--kind",
            "opencode",
            "--pane",
            pane_id,
            "--timeout",
            "15000",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if res.returncode != 0:
        subprocess.run(
            ["herdr", "--session", session, "pane", "run", pane_id, "opencode"],
            check=False,
        )


def main() -> None:
    cli_arg = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
    session = get_session_name(cli_arg)
    socket_path = get_socket_path(session)

    if not is_socket(socket_path):
        subprocess.Popen(
            ["herdr", "--session", session, "server"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

        for _ in range(30):
            if is_socket(socket_path):
                break
            time.sleep(0.1)

        pane_id = create_workspace(session)
        if not pane_id:
            pane_id = "w1:p1"

        time.sleep(1)
        start_opencode_agent(session, pane_id)
    else:
        if not has_running_agent(session):
            pane_id = get_first_pane_id(session)
            if not pane_id:
                pane_id = create_workspace(session)
                if not pane_id:
                    pane_id = "w1:p1"
                time.sleep(1)

            start_opencode_agent(session, pane_id)

    try:
        os.execvp("herdr", ["herdr", "--session", session])
    except FileNotFoundError:
        sys.stderr.write("error: 'herdr' executable not found in PATH\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
