pub type Request

pub type Response

pub type Message

pub type Role

pub type Body

pub fn request(name: String) -> Request {
  todo
}

pub fn arguments(request: Request, arguments: Body) -> Request {
  todo
}

pub fn response() -> Response {
  todo
}

pub fn description(response: Response, description: String) -> Response {
  todo
}

pub fn add_message(response: Response, message: Message) -> Response {
  todo
}

pub fn message(role: Role) -> Message {
  todo
}

pub fn annotations(message: Message, annotations) -> Message {
  todo
}

pub fn text(message: Message, text: String) -> Message {
  todo
}

pub fn image_data(message: Message, data: String) -> Message {
  todo
}

pub fn audio_data(message: Message, data: String) -> Message {
  todo
}

pub fn mime_type(message: Message, mime_type: String) -> Message {
  todo
}

pub fn resource_content(message: Message, content) -> Message {
  todo
}
