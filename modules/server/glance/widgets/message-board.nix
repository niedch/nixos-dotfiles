{
  type = "custom-api";
  title = "Message Board";
  url = "http://127.0.0.1:8090/";
  cache = "1m";
  template = builtins.readFile ../templates/message-board.html;
}
