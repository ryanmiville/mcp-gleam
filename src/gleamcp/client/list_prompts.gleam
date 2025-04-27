import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/result
import gleamcp/client/internal
import gleamcp/mcp.{type McpError, type Prompt}
import jsonrpc

const method = "prompts/list"

pub type ListPromptsResult {
  ListPromptsResult(prompts: List(Prompt), next_cursor: Option(String))
}

fn list_prompts_result_decoder() -> decode.Decoder(ListPromptsResult) {
  use prompts <- decode.field("prompts", decode.list(mcp.prompt_decoder()))
  use next_cursor <- internal.optional_field("next_cursor", decode.string)
  decode.success(ListPromptsResult(prompts:, next_cursor:))
}

pub type RequestBuilder {
  RequestBuilder(meta: Dict(String, Json), cursor: Option(String))
}

pub fn request() -> RequestBuilder {
  RequestBuilder(dict.new(), None)
}

pub fn cursor(builder: RequestBuilder, cursor: String) -> RequestBuilder {
  RequestBuilder(..builder, cursor: Some(cursor))
}

pub fn add_meta(
  builder: RequestBuilder,
  key: String,
  value: Json,
) -> RequestBuilder {
  let meta = builder.meta |> dict.insert(key, value)
  RequestBuilder(..builder, meta:)
}

pub fn progress_token(builder: RequestBuilder, token: String) {
  add_meta(builder, "progressToken", json.string(token))
}

pub fn build(builder: RequestBuilder) -> Request(BitArray) {
  // TODO
  let id = 1
  let req = jsonrpc.request(method, jsonrpc.id(id))

  let body =
    internal.merge_params([
      internal.json_pagination(builder.cursor),
      internal.json_meta(builder.meta),
    ])
    |> option.map(jsonrpc.request_params(req, _))
    |> option.unwrap(req)
    |> jsonrpc.encode_request(function.identity)
    |> json.to_string
    |> bit_array.from_string

  internal.request(headers: [], body:)
}

pub fn response(
  response: Response(BitArray),
) -> Result(ListPromptsResult, McpError) {
  let decoder = jsonrpc.response_decoder(list_prompts_result_decoder())
  response.body
  |> json.parse_bits(decoder)
  |> result.map(fn(res) { res.result })
  |> result.map_error(mcp.UnexpectedJsonError)
}
