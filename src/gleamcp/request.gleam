import gleam/option.{type Option}

pub type Initialize {
  Initialize(method: String, params: InitializeParams)
}

pub type InitializeParams {
  InitializeParams(
    protocol_version: String,
    capabilities: ClientCapabilities,
    client_info: Implementation,
  )
}

pub type ClientCapabilities {
  ClientCapabilities(roots: Option(Roots), sampling: Option(Sampling))
}

pub type Roots {
  Roots(list_changed: Option(Bool))
}

pub type Sampling {
  Sampling
}

pub type Implementation {
  Implementation(name: String, version: String)
}
// export interface InitializeRequest extends Request {
//   method: "initialize";
//   params: {
//     /**
//      * The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
//      */
//     protocolVersion: string;
//     capabilities: ClientCapabilities;
//     clientInfo: Implementation;
//   };
// }
