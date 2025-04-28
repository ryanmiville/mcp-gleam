//// This module defines types for the Model Context Protocol (MCP) based on the JSON specification.
//// It provides a complete set of types for client-server communication in the protocol.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder, type Dynamic}
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

/// The type of content in a message (text, image, audio, resource)
pub type ContentType {
  ContentTypeText
  ContentTypeImage
  ContentTypeAudio
  ContentTypeResource
}

fn content_type_decoder() -> Decoder(ContentType) {
  use variant <- decode.then(decode.string)
  case variant {
    "text" -> decode.success(ContentTypeText)
    "image" -> decode.success(ContentTypeImage)
    "audio" -> decode.success(ContentTypeAudio)
    "resource" -> decode.success(ContentTypeResource)
    _ -> decode.failure(ContentTypeText, "ContentType")
  }
}

fn encode_content_type(content_type: ContentType) -> Json {
  case content_type {
    ContentTypeText -> json.string("text")
    ContentTypeImage -> json.string("image")
    ContentTypeAudio -> json.string("audio")
    ContentTypeResource -> json.string("resource")
  }
}

/// Roles representing participants in a conversation
pub type Role {
  User
  Assistant
}

fn role_decoder() -> Decoder(Role) {
  use variant <- decode.then(decode.string)
  case variant {
    "user" -> decode.success(User)
    "assistant" -> decode.success(Assistant)
    _ -> decode.failure(User, "Role")
  }
}

fn encode_role(role: Role) -> Json {
  case role {
    User -> json.string("user")
    Assistant -> json.string("assistant")
  }
}

/// Used for tracking progress of operations
pub type ProgressToken {
  ProgressTokenString(String)
  ProgressTokenInt(Int)
}

fn progress_token_decoder() -> Decoder(ProgressToken) {
  let string = decode.string |> decode.map(ProgressTokenString)
  let int = decode.int |> decode.map(ProgressTokenInt)
  decode.one_of(string, [int])
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

fn encode_logging_level(logging_level: LoggingLevel) -> Json {
  case logging_level {
    Emergency -> json.string("emergency")
    Alert -> json.string("alert")
    Critical -> json.string("critical")
    Error -> json.string("error")
    Warning -> json.string("warning")
    Notice -> json.string("notice")
    Info -> json.string("info")
    Debug -> json.string("debug")
  }
}

fn logging_level_decoder() -> Decoder(LoggingLevel) {
  use variant <- decode.then(decode.string)
  case variant {
    "emergency" -> decode.success(Emergency)
    "alert" -> decode.success(Alert)
    "critical" -> decode.success(Critical)
    "error" -> decode.success(Error)
    "warning" -> decode.success(Warning)
    "notice" -> decode.success(Notice)
    "info" -> decode.success(Info)
    "debug" -> decode.success(Debug)
    _ -> decode.failure(Error, "LoggingLevel")
  }
}

/// Optional annotations for clients about content
pub type Annotations {
  Annotations(audience: Option(List(Role)), priority: Option(Float))
}

fn encode_annotations(annotations: Annotations) -> Json {
  let Annotations(audience:, priority:) = annotations
  json.object(
    [
      option.map(audience, fn(a) { #("audience", json.array(a, encode_role)) }),
      option.map(priority, fn(p) { #("priority", json.float(p)) }),
    ]
    |> option.values,
  )
}

fn annotations_decoder() -> Decoder(Annotations) {
  use audience <- decode.optional_field(
    "audience",
    None,
    decode.optional(decode.list(role_decoder())),
  )
  use priority <- decode.optional_field(
    "priority",
    None,
    decode.optional(decode.float),
  )
  decode.success(Annotations(audience:, priority:))
}

/// Implementation details for MCP clients and servers
pub type Implementation {
  Implementation(name: String, version: String)
}

fn encode_implementation(implementation: Implementation) -> Json {
  let Implementation(name:, version:) = implementation
  json.object([#("name", json.string(name)), #("version", json.string(version))])
}

fn implementation_decoder() -> Decoder(Implementation) {
  use name <- decode.field("name", decode.string)
  use version <- decode.field("version", decode.string)
  decode.success(Implementation(name:, version:))
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

fn encode_root_capabilities(root_capabilities: RootCapabilities) -> Json {
  let RootCapabilities(list_changed:) = root_capabilities
  json.object([#("list_changed", json.bool(list_changed))])
}

fn root_capabilities_decoder() -> Decoder(RootCapabilities) {
  use list_changed <- decode.field("list_changed", decode.bool)
  decode.success(RootCapabilities(list_changed:))
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

fn encode_resource_capabilities(
  resource_capabilities: ResourceCapabilities,
) -> Json {
  let ResourceCapabilities(list_changed:, subscribe:) = resource_capabilities
  json.object([
    #("list_changed", json.bool(list_changed)),
    #("subscribe", json.bool(subscribe)),
  ])
}

fn resource_capabilities_decoder() -> Decoder(ResourceCapabilities) {
  use list_changed <- decode.field("list_changed", decode.bool)
  use subscribe <- decode.field("subscribe", decode.bool)
  decode.success(ResourceCapabilities(list_changed:, subscribe:))
}

/// Prompt capabilities of a server
pub type PromptCapabilities {
  PromptCapabilities(list_changed: Bool)
}

fn encode_prompt_capabilities(prompt_capabilities: PromptCapabilities) -> Json {
  let PromptCapabilities(list_changed:) = prompt_capabilities
  json.object([#("list_changed", json.bool(list_changed))])
}

fn prompt_capabilities_decoder() -> Decoder(PromptCapabilities) {
  use list_changed <- decode.field("list_changed", decode.bool)
  decode.success(PromptCapabilities(list_changed:))
}

/// Tool capabilities of a server
pub type ToolCapabilities {
  ToolCapabilities(list_changed: Bool)
}

fn encode_tool_capabilities(tool_capabilities: ToolCapabilities) -> Json {
  let ToolCapabilities(list_changed:) = tool_capabilities
  json.object([#("list_changed", json.bool(list_changed))])
}

fn tool_capabilities_decoder() -> Decoder(ToolCapabilities) {
  use list_changed <- decode.field("list_changed", decode.bool)
  decode.success(ToolCapabilities(list_changed:))
}

pub type LoggingCapabilities {
  LoggingCapabilities
}

fn encode_logging_capabilities(
  logging_capabilities: LoggingCapabilities,
) -> Json {
  json.object([])
}

fn logging_capabilities_decoder() -> Decoder(LoggingCapabilities) {
  decode.success(LoggingCapabilities)
}

/// Content types that can be sent or received
/// Text content in a message
pub type TextContent {
  TextContent(
    type_: ContentType,
    text: String,
    annotations: Option(Annotations),
  )
}

fn text_content_decoder() -> Decoder(TextContent) {
  use type_ <- decode.field("type", content_type_decoder())
  use text <- decode.field("text", decode.string)
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(annotations_decoder()),
  )
  decode.success(TextContent(type_:, text:, annotations:))
}

/// Image content in a message
pub type ImageContent {
  ImageContent(
    type_: ContentType,
    data: String,
    mime_type: String,
    annotations: Option(Annotations),
  )
}

fn image_content_decoder() -> Decoder(ImageContent) {
  use type_ <- decode.field("type", content_type_decoder())
  use data <- decode.field("data", decode.string)
  use mime_type <- decode.field("mimeType", decode.string)
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(annotations_decoder()),
  )
  decode.success(ImageContent(type_:, data:, mime_type:, annotations:))
}

/// Audio content in a message
pub type AudioContent {
  AudioContent(
    type_: ContentType,
    data: String,
    mime_type: String,
    annotations: Option(Annotations),
  )
}

fn audio_content_decoder() -> Decoder(AudioContent) {
  use type_ <- decode.field("type", content_type_decoder())
  use data <- decode.field("data", decode.string)
  use mime_type <- decode.field("mimeType", decode.string)
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(annotations_decoder()),
  )
  decode.success(AudioContent(type_:, data:, mime_type:, annotations:))
}

/// Contents of a text resource
pub type TextResourceContents {
  TextResourceContents(uri: String, text: String, mime_type: Option(String))
}

fn text_resource_contents_decoder() -> Decoder(TextResourceContents) {
  use uri <- decode.field("uri", decode.string)
  use text <- decode.field("text", decode.string)
  use mime_type <- decode.optional_field(
    "mimeType",
    None,
    decode.optional(decode.string),
  )
  decode.success(TextResourceContents(uri:, text:, mime_type:))
}

/// Contents of a blob resource
pub type BlobResourceContents {
  BlobResourceContents(uri: String, blob: String, mime_type: Option(String))
}

fn blob_resource_contents_decoder() -> Decoder(BlobResourceContents) {
  use uri <- decode.field("uri", decode.string)
  use blob <- decode.field("blob", decode.string)
  use mime_type <- decode.optional_field(
    "mimeType",
    None,
    decode.optional(decode.string),
  )
  decode.success(BlobResourceContents(uri:, blob:, mime_type:))
}

/// An embedded resource in a message
pub type EmbeddedResource {
  EmbeddedResource(
    type_: ContentType,
    resource: ResourceContents,
    annotations: Option(Annotations),
  )
}

fn embedded_resource_decoder() -> Decoder(EmbeddedResource) {
  use type_ <- decode.field("type", content_type_decoder())
  use resource <- decode.field("resource", resource_contents_decoder())
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(annotations_decoder()),
  )
  decode.success(EmbeddedResource(type_:, resource:, annotations:))
}

/// Resource contents (either text or blob)
pub type ResourceContents {
  TextResource(TextResourceContents)
  BlobResource(BlobResourceContents)
}

fn resource_contents_decoder() -> Decoder(ResourceContents) {
  let text = text_resource_contents_decoder() |> decode.map(TextResource)
  let blob = blob_resource_contents_decoder() |> decode.map(BlobResource)
  decode.one_of(text, [blob])
}

fn encode_resource_contents(resource_contents: ResourceContents) -> Json {
  case resource_contents {
    BlobResource(res) -> encode_blob_resource_contents(res)
    TextResource(res) -> encode_text_resource_contents(res)
  }
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

fn message_content_decoder() -> Decoder(MessageContent) {
  let text = text_content_decoder() |> decode.map(TextMessageContent)
  let image = image_content_decoder() |> decode.map(ImageMessageContent)
  let audio = audio_content_decoder() |> decode.map(AudioMessageContent)
  decode.one_of(text, [image, audio])
}

fn encode_message_content(message_content: MessageContent) {
  case message_content {
    AudioMessageContent(msg) -> encode_audio_content(msg)
    ImageMessageContent(msg) -> encode_image_content(msg)
    TextMessageContent(msg) -> encode_text_content(msg)
  }
}

/// A prompt message with resource support
pub type PromptMessage {
  PromptMessage(role: Role, content: PromptMessageContent)
}

fn encode_prompt_message(prompt_message: PromptMessage) -> Json {
  let PromptMessage(role:, content:) = prompt_message
  json.object([
    #("role", encode_role(role)),
    #("content", encode_prompt_message_content(content)),
  ])
}

fn prompt_message_decoder() -> Decoder(PromptMessage) {
  use role <- decode.field("role", role_decoder())
  use content <- decode.field("content", prompt_message_content_decoder())
  decode.success(PromptMessage(role:, content:))
}

/// Content types for prompt messages
pub type PromptMessageContent {
  TextPromptContent(TextContent)
  ImagePromptContent(ImageContent)
  AudioPromptContent(AudioContent)
  ResourcePromptContent(EmbeddedResource)
}

fn prompt_message_content_decoder() -> Decoder(PromptMessageContent) {
  let text = text_content_decoder() |> decode.map(TextPromptContent)
  let image = image_content_decoder() |> decode.map(ImagePromptContent)
  let audio = audio_content_decoder() |> decode.map(AudioPromptContent)
  let resource =
    embedded_resource_decoder() |> decode.map(ResourcePromptContent)
  decode.one_of(text, [image, audio, resource])
}

fn encode_prompt_message_content(message_content: PromptMessageContent) {
  case message_content {
    AudioPromptContent(msg) -> encode_audio_content(msg)
    ImagePromptContent(msg) -> encode_image_content(msg)
    TextPromptContent(msg) -> encode_text_content(msg)
    ResourcePromptContent(msg) -> encode_embedded_resource(msg)
  }
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

fn decode_optional(
  name: name,
  decoder: Decoder(a),
  next: fn(Option(a)) -> Decoder(b),
) -> Decoder(b) {
  decode.optional_field(name, None, decode.optional(decoder), next)
}

fn resource_decoder() -> Decoder(Resource) {
  use name <- decode.field("name", decode.string)
  use uri <- decode.field("uri", decode.string)
  use description <- decode_optional("description", decode.string)
  use mime_type <- decode_optional("mime_type", decode.string)
  use size <- decode_optional("size", decode.int)
  use annotations <- decode_optional("annotations", annotations_decoder())

  decode.success(Resource(
    name:,
    uri:,
    description:,
    mime_type:,
    size:,
    annotations:,
  ))
}

fn encode_optional(
  name: String,
  value: Option(a),
  encode: fn(a) -> Json,
) -> Option(#(String, Json)) {
  use value <- option.map(value)
  #("name", encode(value))
}

// Resource encoder and decoder
fn encode_resource(resource: Resource) -> Json {
  let Resource(name:, uri:, description:, mime_type:, size:, annotations:) =
    resource
  let optional_fields =
    [
      encode_optional("description", description, json.string),
      encode_optional("mimeType", mime_type, json.string),
      encode_optional("size", size, json.int),
      encode_optional("annotations", annotations, encode_annotations),
    ]
    |> option.values

  json.object([
    #("name", json.string(name)),
    #("uri", json.string(uri)),
    ..optional_fields
  ])
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

fn encode_prompt(prompt: Prompt) -> Json {
  let Prompt(name:, description:, arguments:) = prompt
  let desc =
    [encode_optional("description", description, json.string)]
    |> option.values
  json.object([
    #("name", json.string(name)),
    #("arguments", json.array(arguments, encode_prompt_argument)),
    ..desc
  ])
}

pub fn prompt_decoder() -> Decoder(Prompt) {
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.optional(decode.string))
  use arguments <- decode.field(
    "arguments",
    decode.list(prompt_argument_decoder()),
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
    client_capabilities_decoder(),
  )
  use client_info <- decode.field("clientInfo", implementation_decoder())
  use protocol_version <- decode.field("protocolVersion", decode.string)
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

fn meta_decoder() -> Decoder(Dict(String, Dynamic)) {
  todo
}

fn encode_meta(meta: Dict(String, Dynamic)) -> Json {
  todo
}

pub fn encode_initialize_result(initialize_result: InitializeResult) -> Json {
  let InitializeResult(
    capabilities:,
    protocol_version:,
    server_info:,
    instructions:,
    meta:,
  ) = initialize_result
  let optional_fields =
    [
      encode_optional("instructions", instructions, json.string),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values
  json.object([
    #("capabilities", encode_server_capabilities(capabilities)),
    #("protocolVersion", json.string(protocol_version)),
    #("serverInfo", encode_implementation(server_info)),
    ..optional_fields
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
  let optional_fields =
    [
      encode_optional("nextCursor", next_cursor, json.string),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values
  json.object([
    #("resources", json.array(resources, encode_resource)),
    ..optional_fields
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
  let optional_fields =
    [encode_optional("_meta", meta, encode_meta)] |> option.values
  json.object([
    #("contents", json.array(contents, encode_resource_contents)),
    ..optional_fields
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
  let optional_fields =
    [
      encode_optional("nextCursor", next_cursor, json.string),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values
  json.object([
    #("prompts", json.array(prompts, encode_prompt)),
    ..optional_fields
  ])
}

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
  let optional_fields =
    [
      encode_optional("description", description, json.string),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values
  json.object([
    #("messages", json.array(messages, encode_prompt_message)),
    ..optional_fields
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
  CancelledParams(request_id: jsonrpc.Id, reason: Option(String))
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

// CLAUDE

// Client capabilities decoder
fn client_capabilities_decoder() -> Decoder(ClientCapabilities) {
  use roots <- decode.optional_field(
    "roots",
    None,
    decode.optional(root_capabilities_decoder()),
  )
  use sampling <- decode.optional_field(
    "sampling",
    None,
    decode.optional(decode.dict(decode.string, decode.dynamic)),
  )
  use experimental <- decode.optional_field(
    "experimental",
    None,
    decode.optional(decode.dict(
      decode.string,
      decode.dict(decode.string, decode.dynamic),
    )),
  )
  decode.success(ClientCapabilities(
    roots: roots,
    sampling: sampling,
    experimental: experimental,
  ))
}

fn encode_client_capabilities(capabilities: ClientCapabilities) -> Json {
  todo
  // let ClientCapabilities(roots:, sampling:, experimental:) = capabilities

  // let optional_fields =
  //   [
  //     option.map(roots, fn(r) { #("roots", encode_root_capabilities(r)) }),
  //     option.map(sampling, fn(s) {
  //       #("sampling", json.dict(s, fn(k) { k }, fn(v) { v }))
  //     }),
  //     option.map(experimental, fn(e) {
  //       #(
  //         "experimental",
  //         json.dict(e, fn(k) { k }, fn(d) {
  //           json.dict(d, fn(k) { k }, fn(v) { v })
  //         }),
  //       )
  //     }),
  //   ]
  //   |> option.values

  // json.object(optional_fields)
}

// Server capabilities encoder
fn encode_server_capabilities(capabilities: ServerCapabilities) -> Json {
  todo
  // let ServerCapabilities(
  //   resources:,
  //   prompts:,
  //   tools:,
  //   logging:,
  //   completions:,
  //   experimental:,
  // ) = capabilities

  // let optional_fields =
  //   [
  //     option.map(resources, fn(r) {
  //       #("resources", encode_resource_capabilities(r))
  //     }),
  //     option.map(prompts, fn(p) { #("prompts", encode_prompt_capabilities(p)) }),
  //     option.map(tools, fn(t) { #("tools", encode_tool_capabilities(t)) }),
  //     option.map(logging, fn(l) { #("logging", encode_logging_capabilities(l)) }),
  //     option.map(completions, fn(c) {
  //       #("completions", json.dict(c, fn(k) { k }, fn(v) { v }))
  //     }),
  //     option.map(experimental, fn(e) {
  //       #(
  //         "experimental",
  //         json.dict(e, fn(k) { k }, fn(d) {
  //           json.dict(d, fn(k) { k }, fn(v) { v })
  //         }),
  //       )
  //     }),
  //   ]
  //   |> option.values

  // json.object(optional_fields)
}

// Server capabilities decoder
fn server_capabilities_decoder() -> Decoder(ServerCapabilities) {
  use resources <- decode.optional_field(
    "resources",
    None,
    decode.optional(resource_capabilities_decoder()),
  )
  use prompts <- decode.optional_field(
    "prompts",
    None,
    decode.optional(prompt_capabilities_decoder()),
  )
  use tools <- decode.optional_field(
    "tools",
    None,
    decode.optional(tool_capabilities_decoder()),
  )
  use logging <- decode.optional_field(
    "logging",
    None,
    decode.optional(logging_capabilities_decoder()),
  )
  use completions <- decode.optional_field(
    "completions",
    None,
    decode.optional(decode.dict(decode.string, decode.dynamic)),
  )
  use experimental <- decode.optional_field(
    "experimental",
    None,
    decode.optional(decode.dict(
      decode.string,
      decode.dict(decode.string, decode.dynamic),
    )),
  )
  decode.success(ServerCapabilities(
    resources: resources,
    prompts: prompts,
    tools: tools,
    logging: logging,
    completions: completions,
    experimental: experimental,
  ))
}

// SamplingMessage encoder and decoder
fn encode_sampling_message(message: SamplingMessage) -> Json {
  let SamplingMessage(role:, content:) = message
  json.object([
    #("role", encode_role(role)),
    #("content", encode_message_content(content)),
  ])
}

fn sampling_message_decoder() -> Decoder(SamplingMessage) {
  use role <- decode.field("role", role_decoder())
  use content <- decode.field("content", message_content_decoder())
  decode.success(SamplingMessage(role:, content:))
}

// ModelHint encoder and decoder
fn encode_model_hint(hint: ModelHint) -> Json {
  let ModelHint(name:) = hint
  let optional_fields =
    [option.map(name, fn(n) { #("name", json.string(n)) })]
    |> option.values

  json.object(optional_fields)
}

fn model_hint_decoder() -> Decoder(ModelHint) {
  use name <- decode.optional_field(
    "name",
    None,
    decode.optional(decode.string),
  )
  decode.success(ModelHint(name:))
}

// ModelPreferences encoder and decoder
fn encode_model_preferences(preferences: ModelPreferences) -> Json {
  let ModelPreferences(
    speed_priority:,
    cost_priority:,
    intelligence_priority:,
    hints:,
  ) = preferences

  let optional_fields =
    [
      option.map(speed_priority, fn(p) { #("speedPriority", json.float(p)) }),
      option.map(cost_priority, fn(p) { #("costPriority", json.float(p)) }),
      option.map(intelligence_priority, fn(p) {
        #("intelligencePriority", json.float(p))
      }),
      option.map(hints, fn(h) { #("hints", json.array(h, encode_model_hint)) }),
    ]
    |> option.values

  json.object(optional_fields)
}

fn model_preferences_decoder() -> Decoder(ModelPreferences) {
  use speed_priority <- decode.optional_field(
    "speedPriority",
    None,
    decode.optional(decode.float),
  )
  use cost_priority <- decode.optional_field(
    "costPriority",
    None,
    decode.optional(decode.float),
  )
  use intelligence_priority <- decode.optional_field(
    "intelligencePriority",
    None,
    decode.optional(decode.float),
  )
  use hints <- decode.optional_field(
    "hints",
    None,
    decode.optional(decode.list(model_hint_decoder())),
  )
  decode.success(ModelPreferences(
    speed_priority: speed_priority,
    cost_priority: cost_priority,
    intelligence_priority: intelligence_priority,
    hints: hints,
  ))
}

// PromptArgument encoder and decoder
fn encode_prompt_argument(arg: PromptArgument) -> Json {
  let PromptArgument(name:, description:, required:) = arg

  let optional_fields =
    [option.map(description, fn(d) { #("description", json.string(d)) })]
    |> option.values

  json.object([
    #("name", json.string(name)),
    #("required", json.bool(required)),
    ..optional_fields
  ])
}

fn prompt_argument_decoder() -> Decoder(PromptArgument) {
  use name <- decode.field("name", decode.string)
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use required <- decode.field("required", decode.bool)
  decode.success(PromptArgument(name:, description:, required:))
}

// ToolInputSchema encoder and decoder
fn encode_tool_input_schema(schema: ToolInputSchema) -> Json {
  todo
  // let ToolInputSchema(type_:, properties:, required:) = schema

  // let optional_fields =
  //   [
  //     option.map(properties, fn(p) {
  //       #("properties", json.dict(p, fn(k) { k }, fn(v) { v }))
  //     }),
  //     option.map(required, fn(r) { #("required", json.array(r, json.string)) }),
  //   ]
  //   |> option.values

  // json.object([#("type", json.string(type_)), ..optional_fields])
}

fn tool_input_schema_decoder() -> Decoder(ToolInputSchema) {
  use type_ <- decode.field("type", decode.string)
  use properties <- decode.optional_field(
    "properties",
    None,
    decode.optional(decode.dict(decode.string, decode.dynamic)),
  )
  use required <- decode.optional_field(
    "required",
    None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(ToolInputSchema(type_:, properties:, required:))
}

// ToolAnnotations encoder and decoder
fn encode_tool_annotations(annotations: ToolAnnotations) -> Json {
  let ToolAnnotations(
    title:,
    read_only_hint:,
    destructive_hint:,
    idempotent_hint:,
    open_world_hint:,
  ) = annotations

  let optional_fields =
    [
      option.map(title, fn(t) { #("title", json.string(t)) }),
      option.map(read_only_hint, fn(h) { #("readOnlyHint", json.bool(h)) }),
      option.map(destructive_hint, fn(h) { #("destructiveHint", json.bool(h)) }),
      option.map(idempotent_hint, fn(h) { #("idempotentHint", json.bool(h)) }),
      option.map(open_world_hint, fn(h) { #("openWorldHint", json.bool(h)) }),
    ]
    |> option.values

  json.object(optional_fields)
}

fn tool_annotations_decoder() -> Decoder(ToolAnnotations) {
  use title <- decode.optional_field(
    "title",
    None,
    decode.optional(decode.string),
  )
  use read_only_hint <- decode.optional_field(
    "readOnlyHint",
    None,
    decode.optional(decode.bool),
  )
  use destructive_hint <- decode.optional_field(
    "destructiveHint",
    None,
    decode.optional(decode.bool),
  )
  use idempotent_hint <- decode.optional_field(
    "idempotentHint",
    None,
    decode.optional(decode.bool),
  )
  use open_world_hint <- decode.optional_field(
    "openWorldHint",
    None,
    decode.optional(decode.bool),
  )
  decode.success(ToolAnnotations(
    title: title,
    read_only_hint: read_only_hint,
    destructive_hint: destructive_hint,
    idempotent_hint: idempotent_hint,
    open_world_hint: open_world_hint,
  ))
}

// Tool encoder and decoder
fn encode_tool(tool: Tool) -> Json {
  let Tool(name:, input_schema:, description:, annotations:) = tool

  let optional_fields =
    [
      option.map(description, fn(d) { #("description", json.string(d)) }),
      option.map(annotations, fn(a) {
        #("annotations", encode_tool_annotations(a))
      }),
    ]
    |> option.values

  json.object([
    #("name", json.string(name)),
    #("inputSchema", encode_tool_input_schema(input_schema)),
    ..optional_fields
  ])
}

fn tool_decoder() -> Decoder(Tool) {
  use name <- decode.field("name", decode.string)
  use input_schema <- decode.field("inputSchema", tool_input_schema_decoder())
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(tool_annotations_decoder()),
  )
  decode.success(Tool(
    name: name,
    input_schema: input_schema,
    description: description,
    annotations: annotations,
  ))
}

// PromptReference encoder and decoder
fn encode_prompt_reference(reference: PromptReference) -> Json {
  let PromptReference(type_:, name:) = reference
  json.object([#("type", json.string(type_)), #("name", json.string(name))])
}

fn prompt_reference_decoder() -> Decoder(PromptReference) {
  use type_ <- decode.field("type", decode.string)
  use name <- decode.field("name", decode.string)
  decode.success(PromptReference(type_:, name:))
}

// ResourceReference encoder and decoder
fn encode_resource_reference(reference: ResourceReference) -> Json {
  let ResourceReference(type_:, uri:) = reference
  json.object([#("type", json.string(type_)), #("uri", json.string(uri))])
}

fn resource_reference_decoder() -> Decoder(ResourceReference) {
  use type_ <- decode.field("type", decode.string)
  use uri <- decode.field("uri", decode.string)
  decode.success(ResourceReference(type_:, uri:))
}

// Reference encoder and decoder
fn encode_reference(reference: Reference) -> Json {
  case reference {
    PromptRef(ref) -> encode_prompt_reference(ref)
    ResourceRef(ref) -> encode_resource_reference(ref)
  }
}

fn reference_decoder() -> Decoder(Reference) {
  use type_ <- decode.field("type", decode.string)
  case type_ {
    "prompt" -> {
      use name <- decode.field("name", decode.string)
      decode.success(PromptRef(PromptReference(type_:, name:)))
    }
    "resource" -> {
      use uri <- decode.field("uri", decode.string)
      decode.success(ResourceRef(ResourceReference(type_:, uri:)))
    }
    _ -> decode.failure(PromptRef(PromptReference("", "")), "Reference")
  }
}

// ResultContent encoder and decoder for tools
fn encode_tool_result_content(content: ToolResultContent) -> Json {
  case content {
    TextToolContent(c) -> encode_text_content(c)
    ImageToolContent(c) -> encode_image_content(c)
    AudioToolContent(c) -> encode_audio_content(c)
    ResourceToolContent(c) -> encode_embedded_resource(c)
  }
}

fn tool_result_content_decoder() -> Decoder(ToolResultContent) {
  use type_ <- decode.field("type", content_type_decoder())
  case type_ {
    ContentTypeText -> {
      use text <- decode.field("text", decode.string)
      use annotations <- decode.optional_field(
        "annotations",
        None,
        decode.optional(annotations_decoder()),
      )
      decode.success(TextToolContent(TextContent(type_:, text:, annotations:)))
    }
    ContentTypeImage -> {
      use data <- decode.field("data", decode.string)
      use mime_type <- decode.field("mimeType", decode.string)
      use annotations <- decode.optional_field(
        "annotations",
        None,
        decode.optional(annotations_decoder()),
      )
      decode.success(
        ImageToolContent(ImageContent(type_:, data:, mime_type:, annotations:)),
      )
    }
    ContentTypeAudio -> {
      use data <- decode.field("data", decode.string)
      use mime_type <- decode.field("mimeType", decode.string)
      use annotations <- decode.optional_field(
        "annotations",
        None,
        decode.optional(annotations_decoder()),
      )
      decode.success(
        AudioToolContent(AudioContent(type_:, data:, mime_type:, annotations:)),
      )
    }
    ContentTypeResource -> {
      use resource <- decode.field("resource", resource_contents_decoder())
      use annotations <- decode.optional_field(
        "annotations",
        None,
        decode.optional(annotations_decoder()),
      )
      decode.success(
        ResourceToolContent(EmbeddedResource(type_:, resource:, annotations:)),
      )
    }
  }
}

// ResourceTemplate encoder and decoder
fn encode_resource_template(template: ResourceTemplate) -> Json {
  let ResourceTemplate(
    name:,
    uri_template:,
    description:,
    mime_type:,
    annotations:,
  ) = template

  let optional_fields =
    [
      option.map(description, fn(d) { #("description", json.string(d)) }),
      option.map(mime_type, fn(m) { #("mimeType", json.string(m)) }),
      option.map(annotations, fn(a) { #("annotations", encode_annotations(a)) }),
    ]
    |> option.values

  json.object([
    #("name", json.string(name)),
    #("uriTemplate", json.string(uri_template)),
    ..optional_fields
  ])
}

fn resource_template_decoder() -> Decoder(ResourceTemplate) {
  use name <- decode.field("name", decode.string)
  use uri_template <- decode.field("uriTemplate", decode.string)
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use mime_type <- decode.optional_field(
    "mimeType",
    None,
    decode.optional(decode.string),
  )
  use annotations <- decode.optional_field(
    "annotations",
    None,
    decode.optional(annotations_decoder()),
  )
  decode.success(ResourceTemplate(
    name: name,
    uri_template: uri_template,
    description: description,
    mime_type: mime_type,
    annotations: annotations,
  ))
}

// Root encoder and decoder
fn encode_root(root: Root) -> Json {
  let Root(uri:, name:) = root

  let optional_fields =
    [option.map(name, fn(n) { #("name", json.string(n)) })]
    |> option.values

  json.object([#("uri", json.string(uri)), ..optional_fields])
}

fn root_decoder() -> Decoder(Root) {
  use uri <- decode.field("uri", decode.string)
  use name <- decode.optional_field(
    "name",
    None,
    decode.optional(decode.string),
  )
  decode.success(Root(uri:, name:))
}

// CompletionInfo encoder and decoder
fn encode_completion_info(info: CompletionInfo) -> Json {
  let CompletionInfo(values:, has_more:, total:) = info

  let optional_fields =
    [
      option.map(has_more, fn(h) { #("hasMore", json.bool(h)) }),
      option.map(total, fn(t) { #("total", json.int(t)) }),
    ]
    |> option.values

  json.object([#("values", json.array(values, json.string)), ..optional_fields])
}

fn completion_info_decoder() -> Decoder(CompletionInfo) {
  use values <- decode.field("values", decode.list(decode.string))
  use has_more <- decode.optional_field(
    "hasMore",
    None,
    decode.optional(decode.bool),
  )
  use total <- decode.optional_field("total", None, decode.optional(decode.int))
  decode.success(CompletionInfo(values:, has_more:, total:))
}

// ArgumentInfo encoder and decoder
fn encode_argument_info(info: ArgumentInfo) -> Json {
  let ArgumentInfo(name:, value:) = info
  json.object([#("name", json.string(name)), #("value", json.string(value))])
}

fn argument_info_decoder() -> Decoder(ArgumentInfo) {
  use name <- decode.field("name", decode.string)
  use value <- decode.field("value", decode.string)
  decode.success(ArgumentInfo(name:, value:))
}

// CompleteParams encoder and decoder
fn encode_complete_params(params: CompleteParams) -> Json {
  let CompleteParams(ref_:, argument:) = params
  json.object([
    #("ref", encode_reference(ref_)),
    #("argument", encode_argument_info(argument)),
  ])
}

fn complete_params_decoder() -> Decoder(CompleteParams) {
  use ref_ <- decode.field("ref", reference_decoder())
  use argument <- decode.field("argument", argument_info_decoder())
  decode.success(CompleteParams(ref_:, argument:))
}

// ProgressParams encoder and decoder
fn encode_progress_token(token: ProgressToken) -> Json {
  case token {
    ProgressTokenString(s) -> json.string(s)
    ProgressTokenInt(i) -> json.int(i)
  }
}

fn encode_progress_params(params: ProgressParams) -> Json {
  let ProgressParams(progress_token:, progress:, total:, message:) = params

  let optional_fields =
    [
      option.map(total, fn(t) { #("total", json.float(t)) }),
      option.map(message, fn(m) { #("message", json.string(m)) }),
    ]
    |> option.values

  json.object([
    #("progressToken", encode_progress_token(progress_token)),
    #("progress", json.float(progress)),
    ..optional_fields
  ])
}

fn progress_params_decoder() -> Decoder(ProgressParams) {
  use progress_token <- decode.field("progressToken", progress_token_decoder())
  use progress <- decode.field("progress", decode.float)
  use total <- decode.optional_field(
    "total",
    None,
    decode.optional(decode.float),
  )
  use message <- decode.optional_field(
    "message",
    None,
    decode.optional(decode.string),
  )
  decode.success(ProgressParams(
    progress_token: progress_token,
    progress: progress,
    total: total,
    message: message,
  ))
}

// CancelledParams encoder and decoder
fn encode_cancelled_params(params: CancelledParams) -> Json {
  let CancelledParams(request_id:, reason:) = params

  let optional_fields =
    [option.map(reason, fn(r) { #("reason", json.string(r)) })]
    |> option.values

  json.object([#("requestId", jsonrpc.encode_id(request_id)), ..optional_fields])
}

fn cancelled_params_decoder() -> Decoder(CancelledParams) {
  use request_id <- decode.field("requestId", jsonrpc.id_decoder())
  use reason <- decode.optional_field(
    "reason",
    None,
    decode.optional(decode.string),
  )
  decode.success(CancelledParams(request_id:, reason:))
}

// LoggingMessageParams encoder and decoder
fn encode_logging_message_params(params: LoggingMessageParams) -> Json {
  todo
  // let LoggingMessageParams(level:, data:, logger:) = params

  // let optional_fields =
  //   [option.map(logger, fn(l) { #("logger", json.string(l)) })]
  //   |> option.values

  // json.object([
  //   #("level", encode_logging_level(level)),
  //   #("data", data),
  //   ..optional_fields
  // ])
}

fn logging_message_params_decoder() -> Decoder(LoggingMessageParams) {
  use level <- decode.field("level", logging_level_decoder())
  use data <- decode.field("data", decode.dynamic)
  use logger <- decode.optional_field(
    "logger",
    None,
    decode.optional(decode.string),
  )
  decode.success(LoggingMessageParams(level:, data:, logger:))
}

// SetLevelParams encoder and decoder
fn encode_set_level_params(params: SetLevelParams) -> Json {
  let SetLevelParams(level:) = params
  json.object([#("level", encode_logging_level(level))])
}

fn set_level_params_decoder() -> Decoder(SetLevelParams) {
  use level <- decode.field("level", logging_level_decoder())
  decode.success(SetLevelParams(level:))
}

// ResourceURIParams encoder and decoder
fn encode_resource_uri_params(params: ResourceURIParams) -> Json {
  let ResourceURIParams(uri:) = params
  json.object([#("uri", json.string(uri))])
}

fn resource_uri_params_decoder() -> Decoder(ResourceURIParams) {
  use uri <- decode.field("uri", decode.string)
  decode.success(ResourceURIParams(uri:))
}

// CreateMessageParams encoder and decoder
fn encode_create_message_params(params: CreateMessageParams) -> Json {
  todo
  // let CreateMessageParams(
  //   messages:,
  //   max_tokens:,
  //   temperature:,
  //   stop_sequences:,
  //   system_prompt:,
  //   model_preferences:,
  //   metadata:,
  //   include_context:,
  // ) = params

  // let optional_fields =
  //   [
  //     option.map(temperature, fn(t) { #("temperature", json.float(t)) }),
  //     option.map(stop_sequences, fn(s) {
  //       #("stop_sequences", json.array(s, json.string))
  //     }),
  //     option.map(system_prompt, fn(s) { #("system_prompt", json.string(s)) }),
  //     option.map(model_preferences, fn(p) {
  //       #("model_preferences", encode_model_preferences(p))
  //     }),
  //     option.map(metadata, fn(m) {
  //       #("metadata", json.dict(m, fn(k) { k }, fn(v) { v }))
  //     }),
  //     option.map(include_context, fn(c) { #("include_context", json.string(c)) }),
  //   ]
  //   |> option.values

  // json.object([
  //   #("messages", json.array(messages, encode_sampling_message)),
  //   #("max_tokens", json.int(max_tokens)),
  //   ..optional_fields
  // ])
}

fn create_message_params_decoder() -> Decoder(CreateMessageParams) {
  use messages <- decode.field(
    "messages",
    decode.list(sampling_message_decoder()),
  )
  use max_tokens <- decode.field("maxTokens", decode.int)
  use temperature <- decode.optional_field(
    "temperature",
    None,
    decode.optional(decode.float),
  )
  use stop_sequences <- decode.optional_field(
    "stopSequences",
    None,
    decode.optional(decode.list(decode.string)),
  )
  use system_prompt <- decode.optional_field(
    "systemPrompt",
    None,
    decode.optional(decode.string),
  )
  use model_preferences <- decode.optional_field(
    "modelPreferences",
    None,
    decode.optional(model_preferences_decoder()),
  )
  use metadata <- decode.optional_field(
    "metadata",
    None,
    decode.optional(decode.dict(decode.string, decode.dynamic)),
  )
  use include_context <- decode.optional_field(
    "includeContext",
    None,
    decode.optional(decode.string),
  )
  decode.success(CreateMessageParams(
    messages: messages,
    max_tokens: max_tokens,
    temperature: temperature,
    stop_sequences: stop_sequences,
    system_prompt: system_prompt,
    model_preferences: model_preferences,
    metadata: metadata,
    include_context: include_context,
  ))
}

// CreateMessageResult encoder
fn encode_create_message_result(result: CreateMessageResult) -> Json {
  todo
  // let CreateMessageResult(content:, model:, role:, stop_reason:, meta:) = result

  // let optional_fields =
  //   [
  //     option.map(stop_reason, fn(r) { #("stop_reason", json.string(r)) }),
  //     option.map(meta, fn(m) {
  //       #("meta", json.dict(m, fn(k) { k }, fn(v) { v }))
  //     }),
  //   ]
  //   |> option.values

  // json.object([
  //   #("content", encode_message_content(content)),
  //   #("model", json.string(model)),
  //   #("role", encode_role(role)),
  //   ..optional_fields
  // ])
}

// ListRootsResult encoder
fn encode_list_roots_result(result: ListRootsResult) -> Json {
  todo
  // let ListRootsResult(roots:, meta:) = result

  // let optional_fields =
  //   [
  //     option.map(meta, fn(m) {
  //       #("meta", json.dict(m, fn(k) { k }, fn(v) { v }))
  //     }),
  //   ]
  //   |> option.values

  // json.object([#("roots", json.array(roots, encode_root)), ..optional_fields])
}

// ListResourceTemplatesResult encoder
fn encode_list_resource_templates_result(
  result: ListResourceTemplatesResult,
) -> Json {
  todo
  // let ListResourceTemplatesResult(resource_templates:, next_cursor:, meta:) =
  //   result

  // let optional_fields =
  //   [
  //     option.map(next_cursor, fn(c) { #("next_cursor", json.string(c)) }),
  //     option.map(meta, fn(m) {
  //       #("meta", json.dict(m, fn(k) { k }, fn(v) { v }))
  //     }),
  //   ]
  //   |> option.values

  // json.object([
  //   #(
  //     "resource_templates",
  //     json.array(resource_templates, encode_resource_template),
  //   ),
  //   ..optional_fields
  // ])
}

// CompleteResult encoder
fn encode_complete_result(result: CompleteResult) -> Json {
  todo
  // let CompleteResult(completion:, meta:) = result

  // let optional_fields =
  //   [
  //     option.map(meta, fn(m) {
  //       #("meta", json.dict(m, fn(k) { k }, fn(v) { v }))
  //     }),
  //   ]
  //   |> option.values

  // json.object([
  //   #("completion", encode_completion_info(completion)),
  //   ..optional_fields
  // ])
}

// REWRITE ENCODERS

fn encode_text_content(text_content: TextContent) -> Json {
  let TextContent(type_:, text:, annotations:) = text_content
  let optional_fields =
    [encode_optional("annotations", annotations, encode_annotations)]
    |> option.values

  json.object([
    #("type", encode_content_type(type_)),
    #("text", json.string(text)),
    ..optional_fields
  ])
}

fn encode_image_content(image_content: ImageContent) -> Json {
  let ImageContent(type_:, data:, mime_type:, annotations:) = image_content
  let optional_fields =
    [encode_optional("annotations", annotations, encode_annotations)]
    |> option.values

  json.object([
    #("type", encode_content_type(type_)),
    #("data", json.string(data)),
    #("mimeType", json.string(mime_type)),
    ..optional_fields
  ])
}

fn encode_audio_content(audio_content: AudioContent) -> Json {
  let AudioContent(type_:, data:, mime_type:, annotations:) = audio_content
  let optional_fields =
    [encode_optional("annotations", annotations, encode_annotations)]
    |> option.values

  json.object([
    #("type", encode_content_type(type_)),
    #("data", json.string(data)),
    #("mimeType", json.string(mime_type)),
    ..optional_fields
  ])
}

fn encode_text_resource_contents(
  text_resource_contents: TextResourceContents,
) -> Json {
  let TextResourceContents(uri:, text:, mime_type:) = text_resource_contents
  let optional_fields =
    [encode_optional("mimeType", mime_type, json.string)]
    |> option.values

  json.object([
    #("uri", json.string(uri)),
    #("text", json.string(text)),
    ..optional_fields
  ])
}

fn encode_blob_resource_contents(
  blob_resource_contents: BlobResourceContents,
) -> Json {
  let BlobResourceContents(uri:, blob:, mime_type:) = blob_resource_contents
  let optional_fields =
    [encode_optional("mimeType", mime_type, json.string)]
    |> option.values

  json.object([
    #("uri", json.string(uri)),
    #("blob", json.string(blob)),
    ..optional_fields
  ])
}

fn encode_embedded_resource(embedded_resource: EmbeddedResource) -> Json {
  let EmbeddedResource(type_:, resource:, annotations:) = embedded_resource
  let optional_fields =
    [encode_optional("annotations", annotations, encode_annotations)]
    |> option.values

  json.object([
    #("type", encode_content_type(type_)),
    #("resource", encode_resource_contents(resource)),
    ..optional_fields
  ])
}

pub fn encode_list_tools_result(list_tools_result: ListToolsResult) -> Json {
  let ListToolsResult(tools:, next_cursor:, meta:) = list_tools_result

  let optional_fields =
    [
      encode_optional("nextCursor", next_cursor, json.string),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values

  json.object([#("tools", json.array(tools, encode_tool)), ..optional_fields])
}

pub fn encode_call_tool_result(call_tool_result: CallToolResult) -> Json {
  let CallToolResult(content:, is_error:, meta:) = call_tool_result

  let optional_fields =
    [
      encode_optional("isError", is_error, json.bool),
      encode_optional("_meta", meta, encode_meta),
    ]
    |> option.values

  json.object([
    #("content", json.array(content, encode_tool_result_content)),
    ..optional_fields
  ])
}
