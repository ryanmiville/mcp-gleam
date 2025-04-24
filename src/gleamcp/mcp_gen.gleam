//// This module defines types for the Model Context Protocol (MCP) based on the JSON specification.
//// It provides a complete set of types for client-server communication in the protocol.

import gleam/dict.{type Dict}
import gleam/option.{type Option}

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
    logging: Option(Dict(String, Dynamic)),
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

/// Base type for JSON-RPC requests, responses, and notifications
pub type JSONRPCMessage {
  JsonRpcMessageRequest(JSONRPCRequest)
  JsonRpcMessageNotification(JSONRPCNotification)
  JsonRpcMessageResponse(JSONRPCResponse)
  JsonRpcMessageError(JSONRPCError)
  JsonRpcMessageBatchRequest(List(JSONRPCBatchRequestItem))
  JsonRpcMessageBatchResponse(List(JSONRPCBatchResponseItem))
}

/// Items in a JSON-RPC batch request
pub type JSONRPCBatchRequestItem {
  BatchRequest(JSONRPCRequest)
  BatchNotification(JSONRPCNotification)
}

/// Items in a JSON-RPC batch response
pub type JSONRPCBatchResponseItem {
  BatchResponse(JSONRPCResponse)
  BatchError(JSONRPCError)
}

/// A JSON-RPC request
pub type JSONRPCRequest {
  JSONRPCRequest(
    jsonrpc: String,
    id: RequestId,
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// A JSON-RPC notification
pub type JSONRPCNotification {
  JSONRPCNotification(
    jsonrpc: String,
    method: String,
    params: Option(Dict(String, Dynamic)),
  )
}

/// A successful JSON-RPC response
pub type JSONRPCResponse {
  JSONRPCResponse(jsonrpc: String, id: RequestId, result: Result)
}

/// A JSON-RPC error response
pub type JSONRPCError {
  JSONRPCError(jsonrpc: String, id: RequestId, error: ErrorInfo)
}

/// Error information in a JSON-RPC error
pub type ErrorInfo {
  ErrorInfo(code: Int, message: String, data: Option(Dynamic))
}

/// Base result type for all responses
pub type Result {
  Result(meta: Option(Dict(String, Dynamic)))
}

/// Dynamic type for arbitrary JSON values
pub type Dynamic

/// Request types
/// Initialize request from client to server
pub type InitializeRequest {
  InitializeRequest(method: String, params: InitializeParams)
}

/// Parameters for initialize request
pub type InitializeParams {
  InitializeParams(
    capabilities: ClientCapabilities,
    client_info: Implementation,
    protocol_version: String,
  )
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

/// Ping request for keepalive
pub type PingRequest {
  PingRequest(method: String, params: Option(Dict(String, Dynamic)))
}

/// List resources request
pub type ListResourcesRequest {
  ListResourcesRequest(method: String, params: Option(PaginationParams))
}

/// Pagination parameters
pub type PaginationParams {
  PaginationParams(cursor: Option(Cursor))
}

/// List resources result
pub type ListResourcesResult {
  ListResourcesResult(
    resources: List(Resource),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// List resource templates request
pub type ListResourceTemplatesRequest {
  ListResourceTemplatesRequest(method: String, params: Option(PaginationParams))
}

/// List resource templates result
pub type ListResourceTemplatesResult {
  ListResourceTemplatesResult(
    resource_templates: List(ResourceTemplate),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// Read resource request
pub type ReadResourceRequest {
  ReadResourceRequest(method: String, params: ReadResourceParams)
}

/// Read resource parameters
pub type ReadResourceParams {
  ReadResourceParams(uri: String)
}

/// Read resource result
pub type ReadResourceResult {
  ReadResourceResult(
    contents: List(ResourceContents),
    meta: Option(Dict(String, Dynamic)),
  )
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

/// List prompts request
pub type ListPromptsRequest {
  ListPromptsRequest(method: String, params: Option(PaginationParams))
}

/// List prompts result
pub type ListPromptsResult {
  ListPromptsResult(
    prompts: List(Prompt),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// Get prompt request
pub type GetPromptRequest {
  GetPromptRequest(method: String, params: GetPromptParams)
}

/// Get prompt parameters
pub type GetPromptParams {
  GetPromptParams(name: String, arguments: Option(Dict(String, String)))
}

/// Get prompt result
pub type GetPromptResult {
  GetPromptResult(
    messages: List(PromptMessage),
    description: Option(String),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// List tools request
pub type ListToolsRequest {
  ListToolsRequest(method: String, params: Option(PaginationParams))
}

/// List tools result
pub type ListToolsResult {
  ListToolsResult(
    tools: List(Tool),
    next_cursor: Option(Cursor),
    meta: Option(Dict(String, Dynamic)),
  )
}

/// Call tool request
pub type CallToolRequest {
  CallToolRequest(method: String, params: CallToolParams)
}

/// Call tool parameters
pub type CallToolParams {
  CallToolParams(name: String, arguments: Option(Dict(String, Dynamic)))
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

/// Client request types
pub type ClientRequest {
  Initialize(InitializeRequest)
  ClientRequestPing(PingRequest)
  ListResources(ListResourcesRequest)
  ListResourceTemplates(ListResourceTemplatesRequest)
  ReadResource(ReadResourceRequest)
  Subscribe(SubscribeRequest)
  Unsubscribe(UnsubscribeRequest)
  ListPrompts(ListPromptsRequest)
  GetPrompt(GetPromptRequest)
  ListTools(ListToolsRequest)
  CallTool(CallToolRequest)
  SetLevel(SetLevelRequest)
  Complete(CompleteRequest)
}

/// Server request types
pub type ServerRequest {
  ServerRequestPing(PingRequest)
  CreateMessage(CreateMessageRequest)
  ListRoots(ListRootsRequest)
}

/// Client notification types
pub type ClientNotification {
  ClientCancelled(CancelledNotification)
  Initialized(InitializedNotification)
  ClientProgress(ProgressNotification)
  RootsListChanged(RootsListChangedNotification)
}

/// Server notification types
pub type ServerNotification {
  ServerCancelled(CancelledNotification)
  ServerProgress(ProgressNotification)
  ResourceListChanged(ResourceListChangedNotification)
  ResourceUpdated(ResourceUpdatedNotification)
  PromptListChanged(PromptListChangedNotification)
  ToolListChanged(ToolListChangedNotification)
  LoggingMessage(LoggingMessageNotification)
}

/// Client result types
pub type ClientResult {
  ClientEmptyResult(Result)
  CreateMessageRes(CreateMessageResult)
  ListRootsRes(ListRootsResult)
}

/// Server result types
pub type ServerResult {
  ServerEmptyResult(Result)
  InitializeRes(InitializeResult)
  ListResourcesRes(ListResourcesResult)
  ListResourceTemplatesRes(ListResourceTemplatesResult)
  ReadResourceRes(ReadResourceResult)
  ListPromptsRes(ListPromptsResult)
  GetPromptRes(GetPromptResult)
  ListToolsRes(ListToolsResult)
  CallToolRes(CallToolResult)
  CompleteRes(CompleteResult)
}
