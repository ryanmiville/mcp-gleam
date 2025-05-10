import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleamcp/internal

pub type Resource {
  Resource(
    uri: String,
    name: String,
    description: Option(String),
    mime_type: Option(String),
    size: Option(Int),
  )
}

pub type Content

pub fn new(uri: String, name: String) -> Resource {
  Resource(uri:, name:, description: None, mime_type: None, size: None)
}

pub fn description(resource: Resource, description: String) -> Resource {
  Resource(..resource, description: Some(description))
}

pub fn mime_type(resource: Resource, mime_type: String) -> Resource {
  Resource(..resource, mime_type: Some(mime_type))
}

pub fn size(resource: Resource, size: Int) -> Resource {
  Resource(..resource, size: Some(size))
}

pub fn content(uri: String) -> Content {
  todo
}

pub fn blob(content: Content, blob: String) -> Content {
  todo
}

pub fn text(content: Content, text: String) -> Content {
  todo
}

pub fn content_mime_type(content: Content, mime_type: String) -> Content {
  todo
}

pub fn decoder() -> Decoder(Resource) {
  use uri <- decode.field("uri", decode.string)
  use name <- decode.field("name", decode.string)
  use description <- internal.omittable_field("description", decode.string)
  use mime_type <- internal.omittable_field("mime_type", decode.string)
  use size <- internal.omittable_field("size", decode.int)
  decode.success(Resource(uri:, name:, description:, mime_type:, size:))
}

pub fn to_json(resource: Resource) -> Json {
  let Resource(uri:, name:, description:, mime_type:, size:) = resource
  [#("uri", json.string(uri)), #("name", json.string(name))]
  |> internal.omittable_to_json("description", description, json.string)
  |> internal.omittable_to_json("mimeType", mime_type, json.string)
  |> internal.omittable_to_json("size", size, json.int)
  |> json.object
}
