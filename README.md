# gleamcp

[![Package Version](https://img.shields.io/hexpm/v/gleamcp)](https://hex.pm/packages/gleamcp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamcp/)

```sh
gleam add gleamcp@1
```
```gleam
import gleamcp

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/gleamcp>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Core Concepts

### Server

<details>
<summary>Show Server Examples</summary>

The server is your core interface to the MCP protocol. It handles connection management, protocol compliance, and message routing:

```gleam
let srv = server.new("My Server", "1.0.0")

server.serve_stdio(srv) // Result(Pid?, StartError)
process.sleep_forever()
```

</details>

### Resources

<details>
<summary>Show Resource Examples</summary>
Resources are how you expose data to LLMs. They can be anything - files, API responses, database queries, system information, etc. Resources can be:

- Static (fixed URI)
- Dynamic (using URI templates)

Here's a simple example of a static resource:

```gleam
// static resource example - exposing a README file
let res = resource.new("docs://readme", "Project README")
  |> resource.description("The project's README file")
  |> resource.mime_type("text/markdown")

server.new()
  |> server.add_resource(res, fn(req) {
    let content = simplifile.read_file("README.md")
    resource.TextContents(
      uri: "docs://readme",
      mime_type: "text/markdown",
      text: content,
    )
  })
```

### Unsupported Features
* batch messages
* resource subscribe
* pagination (it returns all resources, etc.)
* resource templates (need a uri template lib)
* server notifications (resources cannot change yet)
* _meta field
* experimental field
