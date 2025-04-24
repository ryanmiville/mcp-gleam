import gleam/option.{type Option}

pub type Resource {
  Resource(
    uri: String,
    name: String,
    description: Option(String),
    mime_type: Option(String),
    annotations: Option(List(Annotation)),
  )
}

pub type Annotation {
  Annotation(audience: Option(List(Role)), priority: Option(Float))
}

pub type Role {
  User
  Assistant
}

pub type ResourceTemplate {
  ResourceTemplate(name: String)
}
