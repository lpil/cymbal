# cymbal

Build YAML in Gleam!

[![Package Version](https://img.shields.io/hexpm/v/cymbal)](https://hex.pm/packages/cymbal)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cymbal/)

```sh
gleam add cymbal
```
```gleam
import cymbal.{block, array, string, int}

pub fn main() {
  let document = 
    block([
      #("apiVersion", string("v1")),
      #("kind", string("Pod")),
      #("metadata", block([#("name", string("example-pod"))])),
      #(
        "spec",
        block([
          #(
            "containers",
            array([
              block([
                #("name", string("example-container")),
                #("image", string("nginx")),
                #("ports", array([block([#("containerPort", int(80))])])),
              ]),
            ]),
          ),
        ]),
      ),
    ])

  cymbal.encode(document)
  // ---
  // apiVersion: v1
  // kind: Pod
  // metadata:
  //   name: example-pod
  // spec:
  //   containers:
  //   - name: example-container
  //     image: nginx
  //     ports:
  //     - containerPort: 80
  )
}
```

Further documentation can be found at <https://hexdocs.pm/cymbal>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
