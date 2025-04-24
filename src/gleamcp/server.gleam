import gleam/dict.{type Dict}

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
    resources: Dict(String, Resource),
    resource_templates: Dict(String, ResourceTemplate),
    tools: Dict(String, Tool),
    prompts: Dict(String, Prompt),
  )
}

pub fn new(name: String, version: String) -> Builder {
  Builder(
    name:,
    version:,
    description: None,
    resources: dict.new(),
    resource_templates: dict.new(),
    tools: dict.new(),
    prompts: dict.new(),
  )
}

pub fn description(builder: Builder, description: String) -> Builder {
  Builder(..builder, description: Some(description))
}

pub fn add_resource(
  builder: Builder,
  resource: Resource,
  _handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
) -> Builder {
  Builder(
    ..builder,
    resources: dict.insert(builder.resources, resource.name, resource),
  )
}

pub fn add_resource_template(
  builder: Builder,
  template: ResourceTemplate,
  _handler: fn(mcp.ReadResourceRequest) -> Result(mcp.ReadResourceResult, Nil),
) -> Builder {
  Builder(
    ..builder,
    resource_templates: dict.insert(
      builder.resource_templates,
      template.name,
      template,
    ),
  )
}

pub fn add_tool(
  builder: Builder,
  tool: Tool,
  _handler: fn(mcp.CallToolRequest) -> Result(mcp.CallToolResult, Nil),
) -> Builder {
  Builder(..builder, tools: dict.insert(builder.tools, tool.name, tool))
}

pub fn add_prompt(
  builder: Builder,
  prompt: Prompt,
  _handler: fn(mcp.CallToolRequest) -> Result(mcp.CallToolResult, Nil),
) -> Builder {
  Builder(..builder, prompts: dict.insert(builder.prompts, prompt.name, prompt))
}

pub opaque type Server {
  Server(
    name: String,
    version: String,
    description: Option(String),
    resources: Dict(String, Resource),
    resource_templates: Dict(String, ResourceTemplate),
    tools: Dict(String, Tool),
    prompts: Dict(String, Prompt),
  )
}

pub fn build(builder: Builder) -> Server {
  Server(
    name: builder.name,
    version: builder.version,
    description: builder.description,
    resources: builder.resources,
    resource_templates: builder.resource_templates,
    tools: builder.tools,
    prompts: builder.prompts,
  )
}
// pub fn handle_message(
//   server: Server,
//   message: mcp.JsonRpcMessage(a),
// ) -> mcp.JsonRpcMessage(b) {
//   todo
// }
