import gleam/json.{type Json}
import gleam/option.{type Option}

pub type Tool {
  Tool(
    name: String,
    description: Option(String),
    input_schema: InputSchema,
    annotations: Option(Annotations),
  )
}

pub type InputSchemaType {
  Object
}

pub type InputSchema {
  InputSchema(
    type_: InputSchemaType,
    properties: Option(Json),
    required: Option(List(String)),
  )
}

pub type Annotations {
  Annotations(
    title: Option(String),
    read_only_hint: Option(Bool),
    destructive_hint: Option(Bool),
    idempotent_hint: Option(Bool),
    open_world_hint: Option(Bool),
  )
}
