import cymbal.{array, block, float, int, string}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn encode_int_test() {
  int(123)
  |> cymbal.encode
  |> should.equal(
    "---
123
",
  )
}

pub fn encode_float_test() {
  float(123.45)
  |> cymbal.encode
  |> should.equal(
    "---
123.45
",
  )
}

pub fn encode_string_test() {
  string("hello")
  |> cymbal.encode
  |> should.equal(
    "---
hello
",
  )
}

pub fn encode_yes_test() {
  string("yes")
  |> cymbal.encode
  |> should.equal(
    "---
\"yes\"
",
  )
}

pub fn encode_no_test() {
  string("no")
  |> cymbal.encode
  |> should.equal(
    "---
\"no\"
",
  )
}

pub fn encode_on_test() {
  string("on")
  |> cymbal.encode
  |> should.equal(
    "---
\"on\"
",
  )
}

pub fn encode_off_test() {
  string("off")
  |> cymbal.encode
  |> should.equal(
    "---
\"off\"
",
  )
}

pub fn encode_string_with_quote_test() {
  string("\"")
  |> cymbal.encode
  |> should.equal(
    "---
\"\\\"\"
",
  )
}

pub fn encode_string_with_escaped_quote_test() {
  string("\\")
  |> cymbal.encode
  |> should.equal(
    "---
\"\\\\\"
",
  )
}

pub fn encode_negative_number_string_test() {
  string("-1")
  |> cymbal.encode
  |> should.equal(
    "---
\"-1\"
",
  )
}

pub fn encode_negative_number_string_large_test() {
  string("-123")
  |> cymbal.encode
  |> should.equal(
    "---
\"-123\"
",
  )
}

pub fn encode_negative_float_string_test() {
  string("-3.14")
  |> cymbal.encode
  |> should.equal(
    "---
\"-3.14\"
",
  )
}

pub fn encode_dash_prefix_simple_string_test() {
  string("-abc")
  |> cymbal.encode
  |> should.equal(
    "---
-abc
",
  )
}

pub fn encode_array_test() {
  array([
    int(1),
    int(2),
    int(3),
    int(4),
    int(5),
    int(6),
    int(7),
    int(8),
    int(9),
    int(10),
  ])
  |> cymbal.encode
  |> should.equal(
    "---
- 1
- 2
- 3
- 4
- 5
- 6
- 7
- 8
- 9
- 10
",
  )
}

pub fn encode_array_nested_test() {
  array([
    int(1),
    int(2),
    array([
      int(3),
      int(4),
      int(5),
      array([int(6), int(7)]),
      int(8),
      int(9),
      int(10),
    ]),
  ])
  |> cymbal.encode
  |> should.equal(
    "---
- 1
- 2
-
  - 3
  - 4
  - 5
  -
    - 6
    - 7
  - 8
  - 9
  - 10
",
  )
}

pub fn encode_block_test() {
  block([
    #("it1", int(1)),
    #("it2", int(2)),
    #("it3", int(3)),
    #("it4", int(4)),
    #("it5", int(5)),
  ])
  |> cymbal.encode
  |> should.equal(
    "---
it1: 1
it2: 2
it3: 3
it4: 4
it5: 5
",
  )
}

pub fn encode_nested_block_test() {
  block([
    #("it1", int(1)),
    #("it2", int(2)),
    #(
      "nested1",
      block([
        #("it3", int(3)),
        #("it4", int(4)),
        #(
          "nested2",
          block([#("it3", int(3)), #("it4", int(4)), #("it5", int(5))]),
        ),
        #("it5", int(5)),
      ]),
    ),
    #("it6", int(6)),
    #("it7", int(7)),
  ])
  |> cymbal.encode
  |> should.equal(
    "---
it1: 1
it2: 2
nested1:
  it3: 3
  it4: 4
  nested2:
    it3: 3
    it4: 4
    it5: 5
  it5: 5
it6: 6
it7: 7
",
  )
}

pub fn k8s_pod_test() {
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
  |> cymbal.encode
  |> should.equal(
    "---
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: example-container
    image: nginx
    ports:
    - containerPort: 80
",
  )
}
