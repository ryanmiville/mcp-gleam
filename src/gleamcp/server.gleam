import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Dynamic}
import gleam/json
import gleam/list
import gleam/result
import gleamcp/method
import jsonrpc

import gleam/option.{type Option, None, Some}
import gleamcp/mcp
import gleamcp/prompt.{type Prompt}
import gleamcp/resource.{type Resource, type ResourceTemplate}
import gleamcp/tool.{type Tool}

pub type Builder {
  Builder(
    name: String,
    version: String,
    description: Option(String),
    instructions: Option(String),
    resources: Dict(String, ServerResource),
    resource_templates: Dict(String, ServerResourceTemplate),
    tools: Dict(String, ServerTool),
    prompts: Dict(String, ServerPrompt),
    capabilities: mcp.ServerCapabilities,
    page_limit: Option(Int),
  )
}

pub fn new(name name: String, version version: String) -> Builder {
  Builder(
    name:,
    version:,
    description: None,
    instructions: None,
    resources: dict.new(),
    resource_templates: dict.new(),
    tools: dict.new(),
    prompts: dict.new(),
    capabilities: mcp.ServerCapabilities(None, None, None, None, None, None),
    page_limit: None,
  )
}

pub fn description(builder: Builder, description: String) -> Builder {
  Builder(..builder, description: Some(description))
}

pub fn add_resource(
  builder: Builder,
  resource: mcp.Resource,
  handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
) -> Builder {
  let capabilities = case builder.capabilities.resources {
    None ->
      mcp.ServerCapabilities(
        ..builder.capabilities,
        resources: Some(mcp.ResourceCapabilities(False, False)),
      )
    Some(_) -> builder.capabilities
  }

  Builder(
    ..builder,
    resources: dict.insert(
      builder.resources,
      resource.name,
      ServerResource(resource, handler),
    ),
    capabilities:,
  )
}

pub fn add_resource_template(
  builder: Builder,
  template: mcp.ResourceTemplate,
  handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
) -> Builder {
  let capabilities = case builder.capabilities.resources {
    None ->
      mcp.ServerCapabilities(
        ..builder.capabilities,
        resources: Some(mcp.ResourceCapabilities(False, False)),
      )
    Some(_) -> builder.capabilities
  }

  Builder(
    ..builder,
    resource_templates: dict.insert(
      builder.resource_templates,
      template.name,
      ServerResourceTemplate(template, handler),
    ),
    capabilities:,
  )
}

pub fn add_tool(
  builder: Builder,
  tool: mcp.Tool,
  handler: fn(mcp.CallToolRequest) -> Result(mcp.CallToolResult, Nil),
) -> Builder {
  let capabilities = case builder.capabilities.tools {
    None ->
      mcp.ServerCapabilities(
        ..builder.capabilities,
        tools: Some(mcp.ToolCapabilities(False)),
      )
    Some(_) -> builder.capabilities
  }
  Builder(
    ..builder,
    tools: dict.insert(builder.tools, tool.name, ServerTool(tool, handler)),
    capabilities:,
  )
}

pub fn add_prompt(
  builder: Builder,
  prompt: mcp.Prompt,
  handler: fn(mcp.GetPromptRequest) -> Result(mcp.GetPromptResult, Nil),
) -> Builder {
  let capabilities = case builder.capabilities.prompts {
    None ->
      mcp.ServerCapabilities(
        ..builder.capabilities,
        prompts: Some(mcp.PromptCapabilities(False)),
      )
    Some(_) -> builder.capabilities
  }
  Builder(
    ..builder,
    prompts: dict.insert(
      builder.prompts,
      prompt.name,
      ServerPrompt(prompt, handler),
    ),
    capabilities:,
  )
}

pub fn resource_capabilities(
  builder: Builder,
  subscribe: Bool,
  list_changed: Bool,
) {
  let capabilities =
    mcp.ServerCapabilities(
      ..builder.capabilities,
      resources: Some(mcp.ResourceCapabilities(subscribe, list_changed)),
    )
  Builder(..builder, capabilities: capabilities)
}

pub fn prompt_capabilities(builder: Builder, list_changed: Bool) {
  let capabilities =
    mcp.ServerCapabilities(
      ..builder.capabilities,
      prompts: Some(mcp.PromptCapabilities(list_changed)),
    )
  Builder(..builder, capabilities: capabilities)
}

pub fn tool_capabilities(builder: Builder, list_changed: Bool) {
  let capabilities =
    mcp.ServerCapabilities(
      ..builder.capabilities,
      tools: Some(mcp.ToolCapabilities(list_changed)),
    )
  Builder(..builder, capabilities: capabilities)
}

pub fn page_limit(builder: Builder, page_limit: Int) -> Builder {
  Builder(..builder, page_limit: Some(page_limit))
}

pub opaque type Server {
  Server(
    name: String,
    version: String,
    description: Option(String),
    instructions: Option(String),
    resources: Dict(String, ServerResource),
    resource_templates: Dict(String, ServerResourceTemplate),
    tools: Dict(String, ServerTool),
    prompts: Dict(String, ServerPrompt),
    capabilities: mcp.ServerCapabilities,
    page_limit: Option(Int),
  )
}

pub fn build(builder: Builder) -> Server {
  Server(
    name: builder.name,
    version: builder.version,
    description: builder.description,
    instructions: builder.instructions,
    resources: builder.resources,
    resource_templates: builder.resource_templates,
    tools: builder.tools,
    prompts: builder.prompts,
    capabilities: builder.capabilities,
    page_limit: builder.page_limit,
  )
}

pub opaque type ServerPrompt {
  ServerPrompt(
    prompt: mcp.Prompt,
    handler: fn(mcp.GetPromptRequest) -> Result(mcp.GetPromptResult, Nil),
  )
}

pub opaque type ServerResource {
  ServerResource(
    resource: mcp.Resource,
    handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
  )
}

pub opaque type ServerResourceTemplate {
  ServerResourceTemplate(
    template: mcp.ResourceTemplate,
    handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
  )
}

pub opaque type ServerTool {
  ServerTool(
    tool: mcp.Tool,
    handler: fn(mcp.CallToolRequest) -> Result(mcp.CallToolResult, Nil),
  )
}

pub fn handle_message(
  server: Server,
  message: String,
) -> Result(json.Json, mcp.McpError) {
  let result =
    json.parse(message, jsonrpc.message_decoder())
    |> result.map_error(mcp.UnexpectedJsonError)

  use msg <- result.try(result)
  case msg {
    jsonrpc.RequestMessage(request) -> handle_request(server, request)

    jsonrpc.NotificationMessage(notification) ->
      handle_notification(server, notification)

    _ -> Error(mcp.ReceivedResponse)
  }
}

fn handle_request(
  server: Server,
  request: jsonrpc.Request(Dynamic),
) -> Result(json.Json, mcp.McpError) {
  case request.method {
    m if m == method.initialize -> {
      require_params(
        server,
        request,
        initialize,
        mcp.initialize_request_decoder(),
        mcp.encode_initialize_result,
      )
    }

    m if m == method.ping -> {
      case request.params {
        None ->
          ping(server, mcp.PingRequest)
          |> result.map(jsonrpc.response(_, request.id))
          |> result.map(jsonrpc.encode_response(_, mcp.encode_empty_result))
        _ ->
          jsonrpc.invalid_params
          |> jsonrpc.error_response(request.id)
          |> jsonrpc.encode_error_response(jsonrpc.encode_nothing)
          |> Ok
      }
    }

    m if m == method.resources_list -> {
      paginated_params(
        server,
        request,
        list_resources,
        mcp.encode_list_resources_result,
      )
    }

    m if m == method.resources_read -> {
      require_params(
        server,
        request,
        read_resource,
        mcp.read_resource_request_decoder(),
        mcp.encode_read_resource_result,
      )
    }

    m if m == method.resources_templates_list -> {
      paginated_params(
        server,
        request,
        list_resources,
        mcp.encode_list_resources_result,
      )
    }

    m if m == method.prompts_list -> {
      paginated_params(
        server,
        request,
        list_prompts,
        mcp.encode_list_prompts_result,
      )
    }

    m if m == method.prompts_get -> {
      require_params(
        server,
        request,
        get_prompt,
        mcp.get_prompt_request_decoder(),
        mcp.encode_get_prompt_result,
      )
    }

    m if m == method.tools_list -> {
      paginated_params(
        server,
        request,
        list_tools,
        mcp.encode_list_tools_result,
      )
    }

    m if m == method.tools_call -> {
      require_params(
        server,
        request,
        call_tool,
        mcp.call_tool_request_decoder(),
        mcp.encode_call_tool_result,
      )
    }
    _ ->
      jsonrpc.method_not_found
      |> jsonrpc.error_response(request.id)
      |> jsonrpc.encode_error_response(jsonrpc.encode_nothing)
      |> Ok
  }
}

fn require_params(
  server: Server,
  request: jsonrpc.Request(Dynamic),
  handler: fn(Server, a) -> Result(b, mcp.McpError),
  params_decoder: decode.Decoder(a),
  result_encoder: fn(b) -> json.Json,
) -> Result(json.Json, mcp.McpError) {
  case request.params {
    None ->
      jsonrpc.invalid_params
      |> jsonrpc.error_response(request.id)
      |> jsonrpc.encode_error_response(jsonrpc.encode_nothing)
      |> Ok
    Some(params) ->
      decode.run(params, params_decoder)
      |> result.map_error(mcp.DecodeError)
      |> result.try(handler(server, _))
      |> result.map(jsonrpc.response(_, request.id))
      |> result.map(jsonrpc.encode_response(_, result_encoder))
  }
}

fn paginated_params(
  server: Server,
  request: jsonrpc.Request(Dynamic),
  handler: fn(Server, mcp.ListRequest) -> Result(a, mcp.McpError),
  encoder: fn(a) -> json.Json,
) -> Result(json.Json, mcp.McpError) {
  case request.params {
    None ->
      handler(server, mcp.ListRequest(None))
      |> result.map(jsonrpc.response(_, request.id))
      |> result.map(jsonrpc.encode_response(_, encoder))

    Some(params) ->
      decode.run(params, mcp.list_request_decoder())
      |> result.map_error(mcp.DecodeError)
      |> result.try(handler(server, _))
      |> result.map(jsonrpc.response(_, request.id))
      |> result.map(jsonrpc.encode_response(_, encoder))
  }
}

fn handle_notification(
  _server: Server,
  notification: jsonrpc.Notification(Dynamic),
) -> Result(json.Json, mcp.McpError) {
  case notification.method {
    // m if m == method.notification_resources_list_changed -> todo
    // m if m == method.notification_resource_updated -> todo
    // m if m == method.notification_prompts_list_changed -> todo
    // m if m == method.notification_tools_list_changed -> todo
    _ -> Error(mcp.UnsupportedNotification(notification.method))
  }
}

pub fn initialize(
  server: Server,
  _request: mcp.InitializeRequest,
) -> Result(mcp.InitializeResult, mcp.McpError) {
  Ok(mcp.InitializeResult(
    capabilities: server.capabilities,
    protocol_version: mcp.protocol_version,
    server_info: mcp.Implementation(server.name, server.version),
    instructions: server.instructions,
    meta: None,
  ))
}

pub fn ping(
  _server: Server,
  _request: mcp.PingRequest,
) -> Result(mcp.EmptyResult, mcp.McpError) {
  Ok(mcp.EmptyResult)
}

pub fn list_resources(
  server: Server,
  request: mcp.ListResourcesRequest,
) -> Result(mcp.ListResourcesResult, mcp.McpError) {
  let resources =
    dict.values(server.resources)
    |> list.map(fn(r) { r.resource })
  Ok(mcp.ListResourcesResult(resources:, next_cursor: None, meta: None))
}

pub fn list_resource_templates(
  server: Server,
  request: mcp.ListResourceTemplatesRequest,
) -> Result(mcp.ListResourceTemplatesResult, mcp.McpError) {
  let resource_templates =
    dict.values(server.resource_templates)
    |> list.map(fn(r) { r.template })
  Ok(mcp.ListResourceTemplatesResult(
    resource_templates:,
    next_cursor: None,
    meta: None,
  ))
}

pub fn read_resource(
  server: Server,
  request: mcp.ReadResourceRequest,
) -> Result(mcp.ReadResourceResult, mcp.McpError) {
  todo
}

pub fn list_prompts(
  server: Server,
  request: mcp.ListPromptsRequest,
) -> Result(mcp.ListPromptsResult, mcp.McpError) {
  let prompts =
    dict.values(server.prompts)
    |> list.map(fn(p) { p.prompt })
  Ok(mcp.ListPromptsResult(prompts:, next_cursor: None, meta: None))
}

pub fn get_prompt(
  server: Server,
  request: mcp.GetPromptRequest,
) -> Result(mcp.GetPromptResult, mcp.McpError) {
  todo
}

pub fn list_tools(
  server: Server,
  request: mcp.ListToolsRequest,
) -> Result(mcp.ListToolsResult, mcp.McpError) {
  let tools =
    dict.values(server.tools)
    |> list.map(fn(t) { t.tool })
  Ok(mcp.ListToolsResult(tools:, next_cursor: None, meta: None))
}

pub fn call_tool(
  server: Server,
  request: mcp.CallToolRequest,
) -> Result(mcp.CallToolResult, mcp.McpError) {
  todo
}
// pub fn notification_resources_list_changed(
//   server: Server,
//   request: request,
// ) -> Result(result, mcp.McpError) {
//   todo
// }

// pub fn notification_resource_updated(
//   server: Server,
//   request: request,
// ) -> Result(result, mcp.McpError) {
//   todo
// }

// pub fn notification_prompts_list_changed(
//   server: Server,
//   request: request,
// ) -> Result(result, mcp.McpError) {
//   todo
// }

// pub fn notification_tools_list_changed(
//   server: Server,
//   request: request,
// ) -> Result(result, mcp.McpError) {
//   todo
// }
