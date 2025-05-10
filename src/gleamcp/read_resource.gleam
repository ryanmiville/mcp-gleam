pub type Request

pub type Response

pub type Content

pub fn request(uri: String) -> Request {
  todo
}

pub fn response() -> Response {
  todo
}

pub fn add_content(response: Response, content: Content) -> Response {
  todo
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

pub fn mime_type(content: Content, mime_type: String) -> Content {
  todo
}
