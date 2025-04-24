import gleam/option.{type Option}

pub type Tool {
  Tool(name: String, description: Option(String), input_schema: Nil)
}
