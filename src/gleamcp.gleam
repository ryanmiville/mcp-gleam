import gleam/json
import gleam/result
import gleam/string
import gleamcp/server

pub fn main() {
  let server = server.new("test", "1.0.0") |> server.build
  let message =
    "{'jsonrpc':'2.0','method':'ping','id':1}"
    |> string.replace("'", "\"")
  server.handle_message(server, message)
  |> result.map(json.to_string)
  |> echo
}
// fn loop() {
//   let line = stdio.read_message()
//   echo line
//   loop()
// }
