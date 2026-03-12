import cymbal.{
  Colon, Dash, Indent, Key, Newline, Pipe, RightArrow, Value, array, block, bool,
  decode, float, int, null, string, tokenize_lines,
}
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn decode_map_test() {
  "---
name: Example
version: 1.0.0
map:
  key1: value1
  key2: value2
  nested_map:
    nested_key1: nested_value1
    nested_key2: nested_value2"
  |> decode
  |> should.equal(
    Ok(
      block([
        #("name", string("Example")),
        #("version", string("1.0.0")),
        #(
          "map",
          block([
            #("key1", string("value1")),
            #("key2", string("value2")),
            #(
              "nested_map",
              block([
                #("nested_key1", string("nested_value1")),
                #("nested_key2", string("nested_value2")),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  )
}

pub fn decode_sequence_test() {
  "sequence:
  - value 1
  - value 2"
  |> decode
  |> should.equal(
    Ok(block([#("sequence", array([string("value 1"), string("value 2")]))])),
  )
}

pub fn parse_block_scalar_test() {
  "---
folded_description: >
  This is my description
  which will not contain
  any newlines.
literal_description: |
  This is my description
  which will preserve
  each newline."
  |> decode
  |> should.equal(
    Ok(
      block([
        #(
          "folded_description",
          string("This is my description which will not contain any newlines."),
        ),
        #(
          "literal_description",
          string("This is my description\nwhich will preserve\neach newline."),
        ),
      ]),
    ),
  )
}

pub fn parse_literal_with_indent_test() {
  "---
literal_with_indent: |
  test:
    scalar:
      with: indents"
  |> decode
  |> should.equal(
    Ok(
      block([
        #("literal_with_indent", string("test:\n  scalar:\n    with: indents")),
      ]),
    ),
  )
}

pub fn tokenizer_basic_test() {
  "name: Example
version: 1.0.0
map:
  key1: value1
  key2: value2
  nested_map:
    nested_key1: nested_value1
    nested_key2: nested_value2
sequence:
  - value 1
  - value 2"
  |> string.split("\n")
  |> tokenize_lines
  |> should.equal([
    Indent(0),
    Key("name"),
    Colon,
    Value("Example"),
    Newline,
    Indent(0),
    Key("version"),
    Colon,
    Value("1.0.0"),
    Newline,
    Indent(0),
    Key("map"),
    Colon,
    Newline,
    Indent(1),
    Key("key1"),
    Colon,
    Value("value1"),
    Newline,
    Indent(1),
    Key("key2"),
    Colon,
    Value("value2"),
    Newline,
    Indent(1),
    Key("nested_map"),
    Colon,
    Newline,
    Indent(2),
    Key("nested_key1"),
    Colon,
    Value("nested_value1"),
    Newline,
    Indent(2),
    Key("nested_key2"),
    Colon,
    Value("nested_value2"),
    Newline,
    Indent(0),
    Key("sequence"),
    Colon,
    Newline,
    Indent(1),
    Dash,
    Value("value 1"),
    Newline,
    Indent(1),
    Dash,
    Value("value 2"),
    Newline,
  ])
}

pub fn tokenizer_block_scalar_test() {
  "folded_description: >
  This is my description
  which will not contain
  any newlines.
literal_description: |
  This is my description
  which will preserve
  each newline."
  |> string.split("\n")
  |> tokenize_lines
  |> should.equal([
    Indent(0),
    Key("folded_description"),
    Colon,
    RightArrow,
    Newline,
    Indent(1),
    Value("This is my description"),
    Newline,
    Indent(1),
    Value("which will not contain"),
    Newline,
    Indent(1),
    Value("any newlines."),
    Newline,
    Indent(0),
    Key("literal_description"),
    Colon,
    Pipe,
    Newline,
    Indent(1),
    Value("This is my description"),
    Newline,
    Indent(1),
    Value("which will preserve"),
    Newline,
    Indent(1),
    Value("each newline."),
    Newline,
  ])
}

pub fn tokenizer_sequence_map_test() {
  "- name: Test
  from: Author
  nested:
    nest: nest_value"
  |> string.split("\n")
  |> tokenize_lines
  |> should.equal([
    Indent(0),
    Dash,
    Key("name"),
    Colon,
    Value("Test"),
    Newline,
    Indent(1),
    Key("from"),
    Colon,
    Value("Author"),
    Newline,
    Indent(1),
    Key("nested"),
    Colon,
    Newline,
    Indent(2),
    Key("nest"),
    Colon,
    Value("nest_value"),
    Newline,
  ])
}

pub fn decode_sequence_map_test() {
  "- name: Test
  from: Author
  nested:
    nest: nest_value
- test"
  |> decode
  |> should.equal(
    Ok(
      array([
        block([
          #("name", string("Test")),
          #("from", string("Author")),
          #("nested", block([#("nest", string("nest_value"))])),
        ]),
        string("test"),
      ]),
    ),
  )
}

pub fn decode_test_test() {
  "---
- name: Spec Example 5.7. Block Scalar Indicators
  yaml: |
    literal: |
      some
      text
    folded: >
      some
      text
  dump: |
    literal: |
      some
      text
    folded: >
      some text"
  |> decode
  |> should.equal(
    Ok(
      array([
        block([
          #("name", string("Spec Example 5.7. Block Scalar Indicators")),
          #(
            "yaml",
            string("literal: |\n  some\n  text\nfolded: >\n  some\n  text"),
          ),
          #(
            "dump",
            string("literal: |\n  some\n  text\nfolded: >\n  some text"),
          ),
        ]),
      ]),
    ),
  )
}

pub fn decode_docker_compose_test() {
  let docker_compose =
    "services:
  mysql:
    image: mysql
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: user
      MYSQL_PASSWORD: user
      MYSQL_USER: user
      MYSQL_DATABASE: user
    volumes:
      - mysql:/var/lib/mysql
  phpmyadmin:
    image: phpmyadmin
    restart: always
    ports:
      - 8080:80
    environment:
      - PMA_ARBITRARY=1
      - PMA_PORT=3306
      - PMA_HOST=mysql
      - PMA_USER=user
      - PMA_PASSWORD=user
  prod:
    build:
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    env_file:
      - './.env'
  dev:
    build:
      context: .
      dockerfile: ./Dockerfile.dev
    ports:
      - '3000:3000'
    volumes:
      - type: bind
        source: .
        target: /usr/src/app
volumes:
  mysql: ~
  dev:"

  docker_compose
  |> decode
  |> should.equal(
    Ok(
      block([
        #(
          "services",
          block([
            #(
              "mysql",
              block([
                #("image", string("mysql")),
                #("restart", string("always")),
                #("ports", array([string("3306:3306")])),
                #(
                  "environment",
                  block([
                    #("MYSQL_ROOT_PASSWORD", string("user")),
                    #("MYSQL_PASSWORD", string("user")),
                    #("MYSQL_USER", string("user")),
                    #("MYSQL_DATABASE", string("user")),
                  ]),
                ),
                #("volumes", array([string("mysql:/var/lib/mysql")])),
              ]),
            ),
            #(
              "phpmyadmin",
              block([
                #("image", string("phpmyadmin")),
                #("restart", string("always")),
                #("ports", array([string("8080:80")])),
                #(
                  "environment",
                  array([
                    string("PMA_ARBITRARY=1"),
                    string("PMA_PORT=3306"),
                    string("PMA_HOST=mysql"),
                    string("PMA_USER=user"),
                    string("PMA_PASSWORD=user"),
                  ]),
                ),
              ]),
            ),
            #(
              "prod",
              block([
                #("build", block([#("dockerfile", string("Dockerfile"))])),
                #("ports", array([string("3000:3000")])),
                #("env_file", array([string("./.env")])),
              ]),
            ),
            #(
              "dev",
              block([
                #(
                  "build",
                  block([
                    #("context", string(".")),
                    #("dockerfile", string("./Dockerfile.dev")),
                  ]),
                ),
                #("ports", array([string("3000:3000")])),
                #(
                  "volumes",
                  array([
                    block([
                      #("type", string("bind")),
                      #("source", string(".")),
                      #("target", string("/usr/src/app")),
                    ]),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        #("volumes", block([#("mysql", null()), #("dev", block([]))])),
      ]),
    ),
  )
}

pub fn decode_types_test() {
  "---
boolean_test: true
float_test: 1.23
int_test: 123
string_test: Hello World
octal_test: 0o2000
hex_test: 0x400"
  |> decode
  |> should.equal(
    Ok(
      block([
        #("boolean_test", bool(True)),
        #("float_test", float(1.23)),
        #("int_test", int(123)),
        #("string_test", string("Hello World")),
        #("octal_test", int(1024)),
        #("hex_test", int(1024)),
      ]),
    ),
  )
}

pub fn decode_different_indent_test() {
  "---
test: value
nested:
   key: value"
  |> decode
  |> should.equal(
    Ok(
      block([
        #("test", string("value")),
        #("nested", block([#("key", string("value"))])),
      ]),
    ),
  )
}

pub fn decode_comments_test() {
  "---
test: value
nested: # Test Comment
  key: value #Comment with no after space"
  |> decode
  |> should.equal(
    Ok(
      block([
        #("test", string("value")),
        #("nested", block([#("key", string("value"))])),
      ]),
    ),
  )
}

pub fn decode_null_test() {
  "---
key: null"
  |> decode
  |> should.equal(Ok(block([#("key", null())])))
}
