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
import jsonrpc

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

// pub fn json_rpc_request(
//   id: Int,
//   method: String,
//   params: Option(Json),
// ) -> BitArray {
//   jsonrpc.request(id: jsonrpc.id(id), method:)
//   |> mcp.encode_json_rpc_request
//   |> json.to_string
//   |> bit_array.from_string
// }

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
) -> Result(jsonrpc.Response(a), mcp.McpError) {
  json.parse_bits(bits, jsonrpc.response_decoder(decoder))
  |> result.map_error(mcp.UnexpectedJsonError)
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
