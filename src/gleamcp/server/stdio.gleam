import gleam/io
import gleam/json
import gleam/result
import gleamcp/server

pub fn server(server: server.Server) -> Result(Nil, Nil) {
  serve_loop(server)
}

fn serve_loop(server) {
  use msg <- result.try(read_message())
  let result = server.handle_message(server, msg) |> result.replace_error(Nil)
  use json <- result.try(result)
  json |> json.to_string |> io.println
  serve_loop(server)
}

pub fn read_message() -> Result(String, Nil) {
  case read_line() {
    Error(_) -> Error(Nil)
    Ok("[") -> batch_loop("[")
    Ok(msg) -> Ok(msg)
  }
}

fn batch_loop(acc: String) {
  case read_line() {
    Ok("]") -> Ok(acc <> "]")
    Ok(line) -> batch_loop(acc <> line)
    Error(_) -> Error(Nil)
  }
}

@external(erlang, "mcp_ffi", "read_line")
@external(javascript, "../../mcp_ffi.mjs", "read_line")
fn read_line() -> Result(String, Nil)
