{pkgs, ...}: let
  python = pkgs.python3.withPackages (ps: [ps.fastapi ps.uvicorn]);

  mainScript = pkgs.writeTextFile {
    name = "message-board-main.py";
    executable = false;
    destination = "/main.py";
    text = ''
      import json
      import os
      from datetime import datetime, timezone
      from typing import Optional

      from fastapi import FastAPI
      from fastapi.responses import JSONResponse
      from pydantic import BaseModel

      DATA_FILE = "/var/lib/message-board/messages.json"
      MAX_MESSAGES = 50

      app = FastAPI(title="Message Board", docs_url=None, redoc_url=None)


      def load_messages():
          if not os.path.exists(DATA_FILE):
              return []
          try:
              with open(DATA_FILE) as f:
                  data = json.load(f)
              return data if isinstance(data, list) else []
          except (json.JSONDecodeError, OSError):
              return []


      def save_messages(messages):
          with open(DATA_FILE, "w") as f:
              json.dump(messages, f, indent=2)


      class PostMessage(BaseModel):
          message: str
          host: Optional[str] = ""
          type: Optional[str] = "info"


      @app.get("/")
      def get_messages():
          messages = load_messages()
          result = []
          TYPE_EMOJI = {
              "info": "\U0001f6c8\ufe0f ",
              "success": "\u2705 ",
              "warning": "\u26a0\ufe0f ",
              "error": "\u274c ",
          }


          def widget_item(m):
              ts = m.get("timestamp", "")
              try:
                  ts_display = datetime.fromisoformat(ts).strftime("%Y-%m-%d %H:%M")
              except ValueError:
                  ts_display = ts
              emoji = TYPE_EMOJI.get(m.get("type", "").lower(), "")
              result.append({
                  "name": emoji + m.get("message", ""),
                  "label": m.get("host", "") + " \u00b7 " + ts_display,
                  **m,
              })
          for m in messages:
              widget_item(m)
          return JSONResponse(content=list(reversed(result)))


      @app.post("/")
      def post_message(body: PostMessage):
          message = body.message.strip()
          if not message:
              return JSONResponse(
                  content={"error": "message is required"}, status_code=400
              )

          messages = load_messages()
          messages.append({
              "message": message,
              "host": (body.host or "").strip(),
              "timestamp": datetime.now(timezone.utc)
              .replace(microsecond=0)
              .isoformat(),
              "type": (body.type or "info").strip(),
          })
          save_messages(messages[-MAX_MESSAGES:])
          return JSONResponse(content={"status": "ok"}, status_code=201)
    '';
  };
in {
  users.users.message-board = {
    isSystemUser = true;
    group = "message-board";
    home = "/var/lib/message-board";
    createHome = true;
  };
  users.groups.message-board = {};

  systemd.services.message-board = {
    description = "Message board HTTP server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = "message-board";
      Group = "message-board";
      ExecStart = "${python}/bin/uvicorn --app-dir ${mainScript} main:app --host 0.0.0.0 --port 8090";
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  networking.firewall.allowedTCPPorts = [8090];
}
