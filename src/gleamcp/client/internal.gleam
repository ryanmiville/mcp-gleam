import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request, Request}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleamcp/mcp

pub fn request(
  headers headers: List(#(String, String)),
  body body: BitArray,
) -> Request(BitArray) {
  Request(
    method: http.Post,
    headers:,
    body:,
    scheme: http.Https,
    host: "localhost",
    port: option.None,
    path: "",
    query: option.None,
  )
}

pub fn json_rpc_request(
  id: Int,
  method: String,
  params: Option(Json),
) -> BitArray {
  mcp.JsonRpcRequest(jsonrpc: "2.0", id:, method:, params:)
  |> mcp.encode_json_rpc_request
  |> json.to_string
  |> bit_array.from_string
}

pub fn json_pagination(cursor: Option(String)) -> Option(List(#(String, Json))) {
  option.map(cursor, fn(cursor) { [#("cursor", json.string(cursor))] })
}

pub fn json_meta(meta: Dict(String, Json)) -> Option(List(#(String, Json))) {
  case dict.is_empty(meta) {
    True -> None
    _ -> Some(dict.to_list(meta))
  }
}

pub fn json_rpc_response(
  bits: BitArray,
  decoder: Decoder(a),
) -> Result(mcp.JsonRpcResponse(a), mcp.McpError) {
  json.parse_bits(bits, json_rpc_response_decoder(decoder))
  |> result.map_error(mcp.UnexpectedJsonError)
}

fn json_rpc_response_decoder(
  inner: Decoder(a),
) -> Decoder(mcp.JsonRpcResponse(a)) {
  use jsonrpc <- decode.field("jsonrpc", decode.string)
  use id <- decode.field("id", decode.int)
  use result <- decode.field("result", inner)
  decode.success(mcp.JsonRpcResponse(jsonrpc:, id:, result:))
  // let error_decoder = {
  //   use jsonrpc <- decode.field("jsonrpc", decode.string)
  //   use id <- decode.field("id", decode.int)
  //   use error <- decode.field("error", mcp.error_decoder())
  //   decode.success(mcp.JsonRpcResponseError(jsonrpc:, id:, error:))
  // }

  // decode.one_of(result_decoder, [error_decoder])
}

pub fn merge_params(params: List(Option(List(#(String, Json))))) -> Option(Json) {
  let params =
    params
    |> option.values
    |> list.flatten

  case params {
    [] -> None
    _ -> Some(json.object(params))
  }
}

// pub fn mcp_error(response: Response(BitArray)) -> Result(a, McpError) {
//   todo
// }

pub fn optional_field(
  key: name,
  inner_decoder: Decoder(t),
  next: fn(Option(t)) -> Decoder(final),
) -> Decoder(final) {
  decode.optional_field(key, None, decode.optional(inner_decoder), next)
}
