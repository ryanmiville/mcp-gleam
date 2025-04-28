//// This module defines types for the Model Context Protocol (MCP) based on the JSON specification.
//// It provides a complete set of types for client-server communication in the protocol.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/http/response.{type Response}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import jsonrpc

pub const protocol_version = "2025-03-26"

pub type McpError {
  UnexpectedJsonError(json.DecodeError)
  JsonRpcError(jsonrpc.JsonRpcError)
  DecodeError(List(decode.DecodeError))
  ReceivedResponse
  UnsupportedNotification(method: String)
}

// pub type Prompt {
//   Prompt(name: String, description: Option(String), arguments: List(Argument))
// }

// pub fn prompt_decoder() -> Decoder(Prompt) {
//   use name <- decode.field("name", decode.string)
//   use description <- decode.field("description", decode.optional(decode.string))
//   use arguments <- decode.field(
//     "arguments",
//     decode.list(todo as "Decoder for Argument"),
//   )
//   decode.success(Prompt(name:, description:, arguments:))
// }

// pub type Argument {
//   Argument(name: String, description: Option(String), required: Option(Bool))
// }

// pub type ReadResourceRequest

// pub type ReadResourceResult

// pub type CallToolRequest

// pub type CallToolResult

// pub type GetPromptRequest

// pub type GetPromptResult

// pub type InitializeRequest {
//   InitializeRequest(method: String, params: InitializeParams)
// }

// /// Initialize result from server to client
// pub type InitializeResult {
//   InitializeResult(
//     capabilities: ServerCapabilities,
//     protocol_version: String,
//     server_info: Implementation,
//     instructions: Option(String),
//     meta: Option(Dict(String, Dynamic)),
//   )
// }

// pub type ServerCapabilities

// /// Parameters for initialize request
// pub type InitializeParams {
//   InitializeParams(
//     capabilities: ClientCapabilities,
//     client_info: Implementation,
//     protocol_version: String,
//   )
// }

// /// Implementation details for MCP clients and servers
// pub type Implementation {
//   Implementation(name: String, version: String)
// }

// pub type ClientCapabilities {
//   ClientCapabilities(
//     roots: Option(RootCapabilities),
//     sampling: Option(Dict(String, Dynamic)),
//     experimental: Option(Dict(String, Dict(String, Dynamic))),
//   )
// }

// /// Root capabilities for a client
// pub type RootCapabilities {
//   RootCapabilities(list_changed: Bool)
// }

// pub type PingRequest

// pub type PingResult

// pub type ListResourcesRequest

// pub type ListResourcesResult

// pub type ListPromptsRequest

// pub type ListPromptsResult

// pub type ListToolsRequest

// pub type ListToolsResult

/// The type of content in a message (text, image, audio, resource)
pub type ContentType {
  ContentTypeText
  ContentTypeImage
  ContentTypeAudio
  ContentTypeResource
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

/// An opaque token used for pagination
pub type Cursor =
  String

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

/// Implementation details for MCP clients and servers
pub type Implementation {
  Implementation(name: String, version: String)
}

/// Capabilities supported by a client
pub type ClientCapabilities {
  ClientCapabilities(
    roots: Option(RootCapabilities),
    sampling: Option(Dict(String, Dynamic)),
    experimental: Option(Dict(String, Dict(String, Dynamic))),
  )
}

/// Root capabilities for a client
pub type RootCapabilities {
  RootCapabilities(list_changed: Bool)
}

/// Capabilities supported by a server
pub type ServerCapabilities {
  ServerCapabilities(
    resources: Option(ResourceCapabilities),
    prompts: Option(PromptCapabilities),
    tools: Option(ToolCapabilities),
    logging: Option(LoggingCapabilities),
    completions: Option(Dict(String, Dynamic)),
    experimental: Option(Dict(String, Dict(String, Dynamic))),
  )
}

/// Resource capabilities of a server
pub type ResourceCapabilities {
  ResourceCapabilities(list_changed: Bool, subscribe: Bool)
}

/// Prompt capabilities of a server
pub type PromptCapabilities {
  PromptCapabilities(list_changed: Bool)
}

/// Tool capabilities of a server
pub type ToolCapabilities {
  ToolCapabilities(list_changed: Bool)
}

pub type LoggingCapabilities {
  LoggingCapabilities
}

/// Content types that can be sent or received
/// Text content in a message
pub type TextContent {
  TextContent(type_: String, text: String, annotations: Option(Annotations))
}

/// Image content in a message
pub type ImageContent {
  ImageContent(
    type_: String,
    data: String,
    mime_type: String,
    annotations: Option(Annotations),
  )
}

/// Audio content in a message
pub type AudioContent {
  AudioContent(
    type_: String,
    data: String,
    mime_type: String,
    annotations: Option(Annotations),
  )
}

/// Contents of a text resource
pub type TextResourceContents {
  TextResourceContents(uri: String, text: String, mime_type: Option(String))
}

/// Contents of a blob resource
pub type BlobResourceContents {
  BlobResourceContents(uri: String, blob: String, mime_type: Option(String))
}

/// An embedded resource in a message
pub type EmbeddedResource {
  EmbeddedResource(
    type_: String,
    resource: ResourceContents,
    annotations: Option(Annotations),
  )
}

/// Resource contents (either text or blob)
pub type ResourceContents {
  TextResource(TextResourceContents)
  BlobResource(BlobResourceContents)
}

/// A message used for sampling
pub type SamplingMessage {
  SamplingMessage(role: Role, content: MessageContent)
}

/// Content types for messages
pub type MessageContent {
  TextMessageContent(TextContent)
  ImageMessageContent(ImageContent)
  AudioMessageContent(AudioContent)
}

/// A prompt message with resource support
pub type PromptMessage {
  PromptMessage(role: Role, content: PromptMessageContent)
}

/// Content types for prompt messages
pub type PromptMessageContent {
  TextPromptContent(TextContent)
  ImagePromptContent(ImageContent)
  AudioPromptContent(AudioContent)
  ResourcePromptContent(EmbeddedResource)
}

/// Model preferences for selecting an LLM
pub type ModelPreferences {
  ModelPreferences(
    speed_priority: Option(Float),
    cost_priority: Option(Float),
    intelligence_priority: Option(Float),
    hints: Option(List(ModelHint)),
  )
}

/// Hints for model selection
pub type ModelHint {
  ModelHint(name: Option(String))
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

/// A root location for file operations
pub type Root {
  Root(uri: String, name: Option(String))
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

pub fn prompt_decoder() -> Decoder(Prompt) {
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.optional(decode.string))
  use arguments <- decode.field(
    "arguments",
    decode.list(todo as "Decoder for PromptArgument"),
  )
  decode.success(Prompt(name:, description:, arguments:))
}

/// An argument for a prompt template
pub type PromptArgument {
  PromptArgument(name: String, description: Option(String), required: Bool)
}

/// Reference to a prompt
pub type PromptReference {
  PromptReference(type_: String, name: String)
}

/// Reference to a resource
pub type ResourceReference {
  ResourceReference(type_: String, uri: String)
}

/// A reference to a prompt or resource
pub type Reference {
  PromptRef(PromptReference)
  ResourceRef(ResourceReference)
}

/// Base result type for all responses
pub type Result {
  Result(meta: Option(Dict(String, Dynamic)))
}

pub type EmptyResult {
  EmptyResult
}

pub fn encode_empty_result(_empty_result: EmptyResult) -> Json {
  json.object([])
}

/// Request types
/// Initialize request from client to server
// pub type InitializeRequest {
//   InitializeRequest(method: String, params: InitializeParams)
// }

// pub fn initialize_request_decoder() -> Decoder(InitializeRequest) {
//   use method <- decode.field("method", decode.string)
//   use params <- decode.field("params", todo as "Decoder for InitializeParams")
//   decode.success(InitializeRequest(method:, params:))
// }

/// Parameters for initialize request
pub type InitializeRequest {
  InitializeRequest(
    capabilities: ClientCapabilities,
    client_info: Implementation,
    protocol_version: String,
  )
}

pub fn initialize_request_decoder() -> Decoder(InitializeRequest) {
  use capabilities <- decode.field(
    "capabilities",
    todo as "Decoder for ClientCapabilities",
  )
  use client_info <- decode.field(
    "client_info",
    todo as "Decoder for Implementation",
  )
  use protocol_version <- decode.field("protocol_version", decode.string)
  decode.success(InitializeRequest(
    capabilities:,
    client_info:,
    protocol_version:,
  ))
}

/// Initialize result from server to client
pub type InitializeResult {
  InitializeResult(
    capabilities: ServerCapabilities,
    protocol_version: String,
    server_info: Implementation,
    instructions: Option(String),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_initialize_result(initialize_result: InitializeResult) -> Json {
  let InitializeResult(
    capabilities:,
    protocol_version:,
    server_info:,
    instructions:,
    meta:,
  ) = initialize_result
  json.object([
    #("capabilities", todo as "Encoder for ServerCapabilities"),
    #("protocol_version", json.string(protocol_version)),
    #("server_info", todo as "Encoder for Implementation"),
    #("instructions", case instructions {
      None -> json.null()
      Some(value) -> json.string(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// Ping request for keepalive
pub type PingRequest {
  PingRequest
}

pub type ListRequest {
  ListRequest(cursor: Option(Cursor))
}

pub fn list_request_decoder() -> Decoder(ListRequest) {
  use cursor <- decode.field("cursor", decode.optional(decode.string))
  decode.success(ListRequest(cursor:))
}

/// List resources request
pub type ListResourcesRequest =
  ListRequest

pub type ListPromptsRequest =
  ListRequest

pub type ListToolsRequest =
  ListRequest

// pub fn list_resources_request_decoder() -> Decoder(ListResourcesRequest) {
//   use method <- decode.field("method", decode.string)
//   use params <- decode.field(
//     "params",
//     decode.optional(todo as "Decoder for PaginationParams"),
//   )
//   decode.success(ListResourcesRequest(method:, params:))
// }

/// Pagination parameters
pub type PaginationParams {
  PaginationParams(cursor: Option(Cursor))
}

pub fn pagination_params_decoder() -> Decoder(PaginationParams) {
  use cursor <- decode.field("cursor", decode.optional(decode.string))
  decode.success(PaginationParams(cursor:))
}

/// List resources result
pub type ListResourcesResult {
  ListResourcesResult(
    resources: List(Resource),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_list_resources_result(
  list_resources_result: ListResourcesResult,
) -> Json {
  let ListResourcesResult(resources:, next_cursor:, meta:) =
    list_resources_result
  json.object([
    #("resources", json.array(resources, todo as "Encoder for Resource")),
    #("next_cursor", case next_cursor {
      None -> json.null()
      Some(value) -> json.string(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// List resource templates request
pub type ListResourceTemplatesRequest =
  ListRequest

/// List resource templates result
pub type ListResourceTemplatesResult {
  ListResourceTemplatesResult(
    resource_templates: List(ResourceTemplate),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// Read resource request
// pub type ReadResourceRequest {
//   ReadResourceRequest(method: String, params: ReadResourceParams)
// }

// pub fn read_resource_request_decoder() -> Decoder(ReadResourceRequest) {
//   use method <- decode.field("method", decode.string)
//   use params <- decode.field("params", todo as "Decoder for ReadResourceParams")
//   decode.success(ReadResourceRequest(method:, params:))
// }

/// Read resource parameters
pub type ReadResourceRequest {
  ReadResourceRequest(uri: String)
}

pub fn read_resource_request_decoder() -> Decoder(ReadResourceRequest) {
  use uri <- decode.field("uri", decode.string)
  decode.success(ReadResourceRequest(uri:))
}

/// Read resource result
pub type ReadResourceResult {
  ReadResourceResult(
    contents: List(ResourceContents),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_read_resource_result(
  read_resource_result: ReadResourceResult,
) -> Json {
  let ReadResourceResult(contents:, meta:) = read_resource_result
  json.object([
    #("contents", json.array(contents, todo as "Encoder for ResourceContents")),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// Subscribe to resource updates
pub type SubscribeRequest {
  SubscribeRequest(method: String, params: ResourceURIParams)
}

/// Parameters with a resource URI
pub type ResourceURIParams {
  ResourceURIParams(uri: String)
}

/// Unsubscribe from resource updates
pub type UnsubscribeRequest {
  UnsubscribeRequest(method: String, params: ResourceURIParams)
}

/// List prompts result
pub type ListPromptsResult {
  ListPromptsResult(
    prompts: List(Prompt),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_list_prompts_result(
  list_prompts_result: ListPromptsResult,
) -> Json {
  let ListPromptsResult(prompts:, next_cursor:, meta:) = list_prompts_result
  json.object([
    #("prompts", json.array(prompts, todo as "Encoder for Prompt")),
    #("next_cursor", case next_cursor {
      None -> json.null()
      Some(value) -> json.string(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// Get prompt request
// pub type GetPromptRequest {
//   GetPromptRequest(method: String, params: GetPromptParams)
// }

// pub fn get_prompt_request_decoder() -> Decoder(GetPromptRequest) {
//   use method <- decode.field("method", decode.string)
//   use params <- decode.field("params", todo as "Decoder for GetPromptParams")
//   decode.success(GetPromptRequest(method:, params:))
// }

/// Get prompt parameters
pub type GetPromptRequest {
  GetPromptRequest(name: String, arguments: Option(Dict(String, String)))
}

pub fn get_prompt_request_decoder() -> Decoder(GetPromptRequest) {
  use name <- decode.field("name", decode.string)
  use arguments <- decode.field(
    "arguments",
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(GetPromptRequest(name:, arguments:))
}

/// Get prompt result
pub type GetPromptResult {
  GetPromptResult(
    messages: List(PromptMessage),
    description: Option(String),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_get_prompt_result(get_prompt_result: GetPromptResult) -> Json {
  let GetPromptResult(messages:, description:, meta:) = get_prompt_result
  json.object([
    #("messages", json.array(messages, todo as "Encoder for PromptMessage")),
    #("description", case description {
      None -> json.null()
      Some(value) -> json.string(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// List tools result
pub type ListToolsResult {
  ListToolsResult(
    tools: List(Tool),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_list_tools_result(list_tools_result: ListToolsResult) -> Json {
  let ListToolsResult(tools:, next_cursor:, meta:) = list_tools_result
  json.object([
    #("tools", json.array(tools, todo as "Encoder for Tool")),
    #("next_cursor", case next_cursor {
      None -> json.null()
      Some(value) -> json.string(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// Call tool request
// pub type CallToolRequest {
//   CallToolRequest(method: String, params: CallToolParams)
// }

// pub fn call_tool_request_decoder() -> Decoder(CallToolRequest) {
//   use method <- decode.field("method", decode.string)
//   use params <- decode.field("params", todo as "Decoder for CallToolParams")
//   decode.success(CallToolRequest(method:, params:))
// }

/// Call tool parameters
pub type CallToolRequest {
  CallToolRequest(name: String, arguments: Option(Dict(String, Dynamic)))
}

pub fn call_tool_request_decoder() -> Decoder(CallToolRequest) {
  use name <- decode.field("name", decode.string)
  use arguments <- decode.field(
    "arguments",
    decode.optional(decode.dict(decode.string, decode.dynamic)),
  )
  decode.success(CallToolRequest(name:, arguments:))
}

/// Call tool result
pub type CallToolResult {
  CallToolResult(
    content: List(ToolResultContent),
    is_error: Option(Bool),
    meta: Option(Dict(String, Dynamic)),
  )
}

pub fn encode_call_tool_result(call_tool_result: CallToolResult) -> Json {
  let CallToolResult(content:, is_error:, meta:) = call_tool_result
  json.object([
    #("content", json.array(content, todo as "Encoder for ToolResultContent")),
    #("is_error", case is_error {
      None -> json.null()
      Some(value) -> json.bool(value)
    }),
    #("meta", case meta {
      None -> json.null()
      Some(value) ->
        json.dict(value, fn(string) { string }, todo as "Encoder for Dynamic")
    }),
  ])
}

/// Content types for tool results
pub type ToolResultContent {
  TextToolContent(TextContent)
  ImageToolContent(ImageContent)
  AudioToolContent(AudioContent)
  ResourceToolContent(EmbeddedResource)
}

/// Set logging level request
pub type SetLevelRequest {
  SetLevelRequest(method: String, params: SetLevelParams)
}

/// Set level parameters
pub type SetLevelParams {
  SetLevelParams(level: LoggingLevel)
}

/// Complete request for autocompletion
pub type CompleteRequest {
  CompleteRequest(method: String, params: CompleteParams)
}

/// Complete parameters
pub type CompleteParams {
  CompleteParams(ref_: Reference, argument: ArgumentInfo)
}

/// Argument information for completion
pub type ArgumentInfo {
  ArgumentInfo(name: String, value: String)
}

/// Complete result
pub type CompleteResult {
  CompleteResult(
    completion: CompletionInfo,
    meta: Option(Dict(String, Dynamic)),
  )
}

/// Completion information
pub type CompletionInfo {
  CompletionInfo(
    values: List(String),
    has_more: Option(Bool),
    total: Option(Int),
  )
}

/// Create message request
pub type CreateMessageRequest {
  CreateMessageRequest(method: String, params: CreateMessageParams)
}

/// Create message parameters
pub type CreateMessageParams {
  CreateMessageParams(
    messages: List(SamplingMessage),
    max_tokens: Int,
    temperature: Option(Float),
    stop_sequences: Option(List(String)),
    system_prompt: Option(String),
    model_preferences: Option(ModelPreferences),
    metadata: Option(Dict(String, Dynamic)),
    include_context: Option(String),
  )
}

/// Create message result
pub type CreateMessageResult {
  CreateMessageResult(
    content: MessageContent,
    model: String,
    role: Role,
    stop_reason: Option(String),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// List roots request
pub type ListRootsRequest {
  ListRootsRequest(method: String, params: Option(Dict(String, Dynamic)))
}

/// List roots result
pub type ListRootsResult {
  ListRootsResult(roots: List(Root), meta: Option(Dict(String, Dynamic)))
}

/// Notification types
/// Initialized notification
pub type InitializedNotification {
  InitializedNotification(method: String, params: Option(Dict(String, Dynamic)))
}

/// Progress notification
pub type ProgressNotification {
  ProgressNotification(method: String, params: ProgressParams)
}

/// Progress parameters
pub type ProgressParams {
  ProgressParams(
    progress_token: ProgressToken,
    progress: Float,
    total: Option(Float),
    message: Option(String),
  )
}

/// Cancelled notification
pub type CancelledNotification {
  CancelledNotification(method: String, params: CancelledParams)
}

/// Cancelled parameters
pub type CancelledParams {
  CancelledParams(request_id: RequestId, reason: Option(String))
}

/// Resource list changed notification
pub type ResourceListChangedNotification {
  ResourceListChangedNotification(
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// Resource updated notification
pub type ResourceUpdatedNotification {
  ResourceUpdatedNotification(method: String, params: ResourceURIParams)
}

/// Prompt list changed notification
pub type PromptListChangedNotification {
  PromptListChangedNotification(
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// Tool list changed notification
pub type ToolListChangedNotification {
  ToolListChangedNotification(
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// Roots list changed notification
pub type RootsListChangedNotification {
  RootsListChangedNotification(
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// Logging message notification
pub type LoggingMessageNotification {
  LoggingMessageNotification(method: String, params: LoggingMessageParams)
}

/// Logging message parameters
pub type LoggingMessageParams {
  LoggingMessageParams(
    level: LoggingLevel,
    data: Dynamic,
    logger: Option(String),
  )
}
