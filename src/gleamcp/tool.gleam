pub type Tool

pub type InputSchema

pub type Property

pub fn new(name: String) -> Tool {
  todo
}

pub fn description(tool: Tool, description: String) -> Tool {
  todo
}

pub fn annotations(tool: Tool, annotations) -> Tool {
  todo
}

pub fn add_input_schema(tool: Tool, input_schema: InputSchema) -> Tool {
  todo
}

pub fn input_schema() -> InputSchema {
  todo
}

pub fn add_property(schema: InputSchema, property: Property) -> InputSchema {
  todo
}

pub fn string(name: String) -> Property {
  todo
}

pub fn boolean(name: String) -> Property {
  todo
}

pub fn integer(name: String) -> Property {
  todo
}

pub fn number(name: String) -> Property {
  todo
}

pub fn array(name: String) -> Property {
  todo
}

pub fn object(name: String, schema: InputSchema) -> Property {
  todo
}

pub fn null(name: String) -> Property {
  todo
}

pub fn enum(name: String, variants: List(String)) -> Property {
  todo
}

pub fn nullable(property: Property) -> Property {
  todo
}

pub fn add_description(property: Property, description: String) -> Property {
  add_metadata(property, "description", description)
}

pub fn add_metadata(property: Property, name: String, value: String) -> Property {
  todo
}

pub fn required(property: Property) -> Property {
  todo
}
