import fs from "node:fs";
import { Buffer } from "node:buffer";
import { Ok, Error as GError } from "./gleam.mjs";

export function read_line() {
  const buffer = Buffer.alloc(4096);
  let line = "";

  try {
    while (true) {
      const bytesRead = fs.readSync(0, buffer, 0, buffer.length, null);
      line += buffer.toString("utf-8", 0, bytesRead);

      if (/[\r\n]+$/.test(line)) {
        return new Ok(line.replace(/[\r\n]+$/, ""));
      }
    }
  } catch {
    return new GError(undefined);
  }
}
