# Source of this grammar

- Source: <https://github.com/vale-cli/vale/releases/download/v3.28.1/grammar-typescript.zip>
- Release: Vale v3.28.1
- File: `typescript.wasm`, from `grammar-typescript/styles/config/grammars/` in the zip
- SHA-256 of the zip: fe1518289a3b21497b9ff6e246bc08ab440f4ade01bddb1812cd09ce80b591b3
- SHA-256 of typescript.wasm: 5ff0d1f4e3352f641dda76cc9447c87c3573c99d6ed67cc6cdfda08039c7a3ec
- License: MIT
- Date: 2026-11-21

The file is an unchanged copy, so that lint needs no network. Do not edit it. Vale reads it for the `Grammars` setting in `.vale.ini`. The views in `.vale/styles/config/views` use it to find the comments and the strings in `.mts` files.

## Origin and license

Vale builds the file with `grammars/build.sh` (<https://github.com/vale-cli/vale/blob/v3.28.1/grammars/build.sh>). The build joins the tree-sitter core and the TypeScript parser from the Go module `github.com/smacker/go-tree-sitter` at version `v0.0.0-20240827094217-dd81d9e9be82`. `go.mod` of Vale v3.28.1 pins that version.

Each of these projects has an MIT license. The texts date from 2026-11-21:

- tree-sitter-typescript: <https://github.com/tree-sitter/tree-sitter-typescript/blob/master/LICENSE>
- go-tree-sitter: <https://github.com/smacker/go-tree-sitter/blob/master/LICENSE>
- Vale: <https://github.com/vale-cli/vale/blob/v3/LICENSE>

Confirmed on 2026-11-21:

- The go-tree-sitter commit `dd81d9e9be82` takes tree-sitter-typescript at `v0.21.2`. Its `_automation/grammars.json` lists this reference: <https://github.com/smacker/go-tree-sitter/blob/dd81d9e9be82/_automation/grammars.json>. The `typescript/typescript/parser.c` file of that commit has `LANGUAGE_VERSION 14`.
- The tree-sitter C runtime (the core `.c` files at the root of go-tree-sitter) has the MIT license: <https://github.com/tree-sitter/tree-sitter/blob/master/LICENSE>. go-tree-sitter has no separate copy of this text.
- `build.sh` runs `zig cc -target wasm32-wasi`, so the file probably also holds wasi-libc code. wasi-libc as a whole has three licenses: Apache-2.0 with LLVM exceptions, Apache-2.0 and MIT: <https://github.com/WebAssembly/wasi-libc/blob/main/README.md>.

Unconfirmed: the wasi-libc version that zig 0.16.0 bundles, and which of its files the linker kept in `typescript.wasm`. So I did not confirm the licenses of the wasi-libc code in this file. The build script does not state them.
