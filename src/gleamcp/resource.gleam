import gleam/option.{type Option}

pub type Resource {
  Resource(
    uri: String,
    name: String,
    description: Option(String),
    mime_type: Option(String),
    annotations: Option(Annotations),
    size: Option(Int),
  )
}

pub type Annotations {
  Annotations(audience: Option(List(Role)), priority: Option(Float))
}

pub type Role {
  User
  Assistant
}

pub type ResourceTemplate {
  ResourceTemplate(
    uri_template: String,
    name: String,
    description: Option(String),
    mime_type: Option(String),
    annotations: Option(Annotations),
  )
}
