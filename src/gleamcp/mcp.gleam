//// This module defines types for the Model Context Protocol (MCP) based on the JSON specification.
//// It provides a complete set of types for client-server communication in the protocol.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/http/response.{type Response}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type McpError {
  UnexpectedJsonError(json.DecodeError)
  UnexpectedResponseError(Response(BitArray))
  McpErrorResponse(JsonRpcError(Dynamic))
}

pub type JsonRpcMessage(a) {
  JsonRpcMessageRequest(JsonRpcRequest(a))
  JsonRpcMessageResponse(JsonRpcResponse(a))
  JsonRpcMessageError(JsonRpcError(a))
  JsonRpcMessageNotification(JsonRpcNotification(a))
}

pub type JsonRpcRequest(params) {
  JsonRpcRequest(
    jsonrpc: String,
    id: Int,
    method: String,
    params: Option(params),
  )
}

pub fn json_rpc_request_decoder(
  inner: Decoder(params),
) -> Decoder(JsonRpcRequest(params)) {
  use jsonrpc <- decode.field("jsonrpc", decode.string)
  use id <- decode.field("id", decode.int)
  use method <- decode.field("method", decode.string)
  use params <- optional_field("params", inner)
  decode.success(JsonRpcRequest(jsonrpc:, id:, method:, params:))
}

pub fn encode_json_rpc_request(json_rpc_request: JsonRpcRequest(Json)) -> Json {
  let JsonRpcRequest(jsonrpc:, id:, method:, params:) = json_rpc_request
  let params = case params {
    None -> []
    Some(p) -> [#("params", p)]
  }
  json.object([
    #("jsonrpc", json.string(jsonrpc)),
    #("id", json.int(id)),
    #("method", json.string(method)),
    ..params
  ])
}

pub type JsonRpcResponse(result) {
  JsonRpcResponse(jsonrpc: String, id: Int, result: result)
}

pub fn json_rpc_response_decoder(
  inner: Decoder(a),
) -> Decoder(JsonRpcResponse(a)) {
  use jsonrpc <- decode.field("jsonrpc", decode.string)
  use id <- decode.field("id", decode.int)
  use result <- decode.field("result", inner)
  decode.success(JsonRpcResponse(jsonrpc:, id:, result:))
}

pub type JsonRpcErrorBody(data) {
  JsonRpcErrorBody(code: Int, message: String, data: Option(data))
}

pub fn json_rpc_error_body_decoder(
  inner: Decoder(data),
) -> Decoder(JsonRpcErrorBody(data)) {
  use code <- decode.field("code", decode.int)
  use message <- decode.field("message", decode.string)
  use data <- optional_field("data", inner)
  decode.success(JsonRpcErrorBody(code:, message:, data:))
}

pub type JsonRpcError(data) {
  JsonRpcError(jsonrpc: String, id: Int, error: JsonRpcErrorBody(data))
}

pub fn json_rpc_error_decoder(
  inner: Decoder(data),
) -> Decoder(JsonRpcError(data)) {
  use jsonrpc <- decode.field("jsonrpc", decode.string)
  use id <- decode.field("id", decode.int)
  use error <- decode.field("error", json_rpc_error_body_decoder(inner))
  decode.success(JsonRpcError(jsonrpc:, id:, error:))
}

pub type JsonRpcNotification(params) {
  JsonRpcNotification(jsonrpc: String, method: String, params: Option(params))
}

/// Roles representing participants in a conversation
pub type Role {
  User
  Assistant
}

/// Reference to a specific request
pub type RequestId {
  RequestIdString(String)
  RequestIdInt(Int)
}

/// Used for tracking progress of operations
pub type ProgressToken {
  ProgressTokenString(String)
  ProgressTokenInt(Int)
}

/// The severity levels for logging messages
pub type LoggingLevel {
  Emergency
  Alert
  Critical
  Error
  Warning
  Notice
  Info
  Debug
}

/// Optional annotations for clients about content
pub type Annotations {
  Annotations(audience: Option(List(Role)), priority: Option(Float))
}

/// A resource available through the server
pub type Resource {
  Resource(
    name: String,
    uri: String,
    description: Option(String),
    mime_type: Option(String),
    size: Option(Int),
    annotations: Option(Annotations),
  )
}

/// A template for creating resources
pub type ResourceTemplate {
  ResourceTemplate(
    name: String,
    uri_template: String,
    description: Option(String),
    mime_type: Option(String),
    annotations: Option(Annotations),
  )
}

/// A tool that can be invoked by clients
pub type Tool {
  Tool(
    name: String,
    input_schema: ToolInputSchema,
    description: Option(String),
    annotations: Option(ToolAnnotations),
  )
}

/// Schema for tool inputs
pub type ToolInputSchema {
  ToolInputSchema(
    type_: String,
    properties: Option(Dict(String, Dynamic)),
    required: Option(List(String)),
  )
}

/// Annotations for tools
pub type ToolAnnotations {
  ToolAnnotations(
    title: Option(String),
    read_only_hint: Option(Bool),
    destructive_hint: Option(Bool),
    idempotent_hint: Option(Bool),
    open_world_hint: Option(Bool),
  )
}

/// A prompt or prompt template
pub type Prompt {
  Prompt(
    name: String,
    description: Option(String),
    arguments: List(PromptArgument),
  )
}

pub fn prompt_decoder() -> decode.Decoder(Prompt) {
  use name <- decode.field("name", decode.string)
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use arguments <- decode.optional_field(
    "arguments",
    [],
    decode.list(prompt_argument_decoder()),
  )
  decode.success(Prompt(name:, description:, arguments:))
}

/// An argument for a prompt template
pub type PromptArgument {
  PromptArgument(name: String, description: Option(String), required: Bool)
}

fn prompt_argument_decoder() -> decode.Decoder(PromptArgument) {
  use name <- decode.field("name", decode.string)
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use required <- decode.optional_field("required", False, decode.bool)
  decode.success(PromptArgument(name:, description:, required:))
}

pub type ReadResourceRequest

pub type ReadResourceResult

pub type CallToolRequest

pub type CallToolResult

pub type GetPromptRequest

pub type GetPromptResult

fn optional_field(
  key: name,
  inner_decoder: Decoder(t),
  next: fn(Option(t)) -> Decoder(final),
) -> Decoder(final) {
  decode.optional_field(key, None, decode.optional(inner_decoder), next)
}
