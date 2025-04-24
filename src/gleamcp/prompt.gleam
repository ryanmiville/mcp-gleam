import gleam/option.{type Option}

pub type Prompt {
  Prompt(name: String, description: Option(String), arguments: List(Argument))
}

pub type Argument {
  Argument(name: String, description: Option(String), required: Option(Bool))
}
