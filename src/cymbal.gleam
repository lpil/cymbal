import gleam/string

/// Convert a YAML document into a string.
///
pub fn encode(doc: Yaml) -> String {
  let start = case doc {
    Bool(_) | Int(_) | Float(_) | String(_) | Null -> "---\n"
    Array(_) | Block(_) -> "---"
  }

  en(start, 0, doc) <> "\n"
}

/// Convert a YAML document into a string without the document start.
///
pub fn encode_without_document_start(doc: Yaml) -> String {
  en("", 0, doc) <> "\n"
}

/// Convert a string into a YAML document.
///
pub fn decode(value: String) -> Result(Yaml, String) {
  string.split(value, "\n")
  |> tokenize_lines
  |> parse_tokens
}

import gleam/float
import gleam/int
import gleam/list
import gleam/result

pub type Token {
  Dash
  Colon
  Newline
  Key(String)
  Value(String)
  Indent(Int)
  Pipe
  RightArrow
}

pub fn en(acc: String, in: Int, doc: Yaml) -> String {
  case doc {
    Bool(True) -> acc <> "true"
    Bool(False) -> acc <> "false"
    Null -> acc <> "null"
    Int(i) -> acc <> int.to_string(i)
    Float(i) -> acc <> float.to_string(i)
    String(i) -> en_string(acc, i)
    Array(i) -> en_array(acc, in, i)
    Block(i) -> en_block(acc, in, True, i)
  }
}

fn en_array(acc: String, in: Int, docs: List(Yaml)) -> String {
  case docs {
    [] -> acc
    [doc, ..docs] -> {
      let acc =
        acc
        |> string.append("\n")
        |> indent(in)
      let acc = case doc {
        Bool(_) | Int(_) | Float(_) | String(_) | Null ->
          en(acc <> "- ", in + 1, doc)
        Array(_) -> en(acc <> "-", in + 1, doc)
        Block(docs) -> en_block(acc <> "- ", in + 1, False, docs)
      }
      en_array(acc, in, docs)
    }
  }
}

fn en_block(
  acc: String,
  in: Int,
  newline: Bool,
  docs: List(#(String, Yaml)),
) -> String {
  case docs {
    [] -> acc
    [#(name, doc), ..docs] if newline ->
      acc
      |> string.append("\n")
      |> indent(in)
      |> en_string(name)
      |> block_child(in, doc)
      |> en_block(in, True, docs)
    [#(name, doc), ..docs] ->
      acc
      |> en_string(name)
      |> block_child(in, doc)
      |> en_block(in, True, docs)
  }
}

fn block_child(acc: String, in: Int, doc: Yaml) -> String {
  case doc {
    Bool(_) | Int(_) | Float(_) | String(_) | Null -> en(acc <> ": ", in, doc)
    Array(_) -> en(acc <> ":", in, doc)
    Block(i) -> en_block(acc <> ":", in + 1, True, i)
  }
}

fn indent(acc: String, i: Int) -> String {
  acc <> string.repeat("  ", i)
}

fn is_simple_string(s: String) -> Bool {
  case s {
    "yes" | "no" | "on" | "off" -> False
    "0" <> _
    | "1" <> _
    | "2" <> _
    | "3" <> _
    | "4" <> _
    | "5" <> _
    | "6" <> _
    | "7" <> _
    | "8" <> _
    | "9" <> _
    | "-0" <> _
    | "-1" <> _
    | "-2" <> _
    | "-3" <> _
    | "-4" <> _
    | "-5" <> _
    | "-6" <> _
    | "-7" <> _
    | "-8" <> _
    | "-9" <> _ -> False
    _ -> is_simple_string_rest(s)
  }
}

fn is_simple_string_rest(s: String) -> Bool {
  case s {
    "" -> True
    "0" <> s
    | "1" <> s
    | "2" <> s
    | "3" <> s
    | "4" <> s
    | "5" <> s
    | "6" <> s
    | "7" <> s
    | "8" <> s
    | "9" <> s
    | "a" <> s
    | "b" <> s
    | "c" <> s
    | "d" <> s
    | "e" <> s
    | "f" <> s
    | "g" <> s
    | "h" <> s
    | "i" <> s
    | "j" <> s
    | "k" <> s
    | "l" <> s
    | "m" <> s
    | "n" <> s
    | "o" <> s
    | "p" <> s
    | "q" <> s
    | "r" <> s
    | "s" <> s
    | "t" <> s
    | "u" <> s
    | "v" <> s
    | "w" <> s
    | "x" <> s
    | "y" <> s
    | "z" <> s
    | "A" <> s
    | "B" <> s
    | "C" <> s
    | "D" <> s
    | "E" <> s
    | "F" <> s
    | "G" <> s
    | "H" <> s
    | "I" <> s
    | "J" <> s
    | "K" <> s
    | "L" <> s
    | "M" <> s
    | "N" <> s
    | "O" <> s
    | "P" <> s
    | "Q" <> s
    | "R" <> s
    | "S" <> s
    | "T" <> s
    | "U" <> s
    | "V" <> s
    | "W" <> s
    | "X" <> s
    | "Y" <> s
    | "Z" <> s
    | "_" <> s
    | "-" <> s -> is_simple_string_rest(s)
    _ -> False
  }
}

fn en_string(acc: String, i: String) -> String {
  case is_simple_string(i) {
    True -> acc <> i
    False -> en_quoted_string(acc, i)
  }
}

fn en_quoted_string(acc: String, i: String) -> String {
  acc
  <> "\""
  <> {
    i
    |> string.replace("\\", "\\\\")
    |> string.replace("\"", "\\\"")
  }
  <> "\""
}

/// A YAML document which can be converted into a string using the `encode`
/// function.
///
pub type Yaml {
  Int(Int)
  Bool(Bool)
  Float(Float)
  String(String)
  Array(List(Yaml))
  Block(List(#(String, Yaml)))
  Null
}

/// Create a YAML document from a bool.
///
pub fn bool(i: Bool) -> Yaml {
  Bool(i)
}

/// Create a YAML document from an int.
///
pub fn int(i: Int) -> Yaml {
  Int(i)
}

/// Create a YAML document from a float.
///
pub fn float(i: Float) -> Yaml {
  Float(i)
}

/// Create a YAML document from a string.
///
pub fn string(i: String) -> Yaml {
  String(i)
}

/// Create a YAML document from a null.
///
pub fn null() -> Yaml {
  Null
}

/// Create a YAML document from a list of YAML documents.
///
pub fn array(i: List(Yaml)) -> Yaml {
  Array(i)
}

/// Create a YAML document from a list of named YAML values.
///
pub fn block(i: List(#(String, Yaml))) -> Yaml {
  Block(i)
}

// -------------
// DECODER START
// -------------

/// Tokenizes all strings in a given list of string as lines in a yaml document
pub fn tokenize_lines(value: List(String)) {
  let tokens =
    value
    |> list.flat_map(tokenize_line)

  let document_indent_size = get_indent_size(tokens)

  tokens
  |> list.map(fn(a) {
    case a {
      Indent(indent) -> Indent(indent / document_indent_size)
      _ -> a
    }
  })
}

/// Returns the first indent in a yaml document that isn't 0
fn get_indent_size(tokens: List(Token)) -> Int {
  case tokens {
    [Indent(indent), ..] if indent > 0 -> indent
    [_, ..rest] -> get_indent_size(rest)
    [] -> 0
  }
}

/// Gets a list of tokens for a given line in a yaml document
fn tokenize_line(line: String) {
  let stripped = case list.first(string.split(string.trim(line), " #")) {
    Ok(value) -> value
    Error(_) -> ""
  }
  let indent = count_leading_spaces(line)

  case string.first(stripped) {
    Ok(value) if value == "-" -> {
      case stripped {
        "---" -> []
        _ -> tokenize_sequence_item(stripped, indent)
      }
    }

    Ok(_) -> tokenize_key_value_pair(stripped, indent)
    Error(_) -> []
  }
}

fn count_leading_spaces(line: String) -> Int {
  line
  |> string.split("")
  |> list.take_while(fn(char) { char == " " })
  |> list.length
}

fn get_tokenized_value_or_block_scalar_indicator(stripped: String) {
  case
    string.split(stripped, ": ")
    |> list.rest
    |> result.unwrap([])
    |> string.join(": ")
  {
    ">" -> RightArrow
    "|" -> Pipe
    _ ->
      Value(
        string.split(stripped, ": ")
        |> list.rest
        |> result.unwrap([])
        |> string.join(": "),
      )
  }
}

/// Tokenize a line that contains a dash at the start
/// 
/// Includes
/// - \- value:
/// - \- value
fn tokenize_sequence_item(stripped: String, indent: Int) {
  let tokenized_sequence_item = case string.contains(stripped, ":\n") {
    True -> [
      Indent(indent),
      Dash,
      Value(string.drop_left(stripped, 2)),
      Colon,
      Newline,
    ]
    False -> [
      Indent(indent),
      Dash,
      Value(string.drop_left(stripped, 2)),
      Newline,
    ]
  }

  case string.contains(stripped, ": ") {
    True -> [
      Indent(indent),
      Dash,
      Key(
        string.split(stripped, ": ")
        |> list.first
        |> result.unwrap("")
        |> string.drop_left(2),
      ),
      Colon,
      get_tokenized_value_or_block_scalar_indicator(stripped),
      Newline,
    ]
    False -> tokenized_sequence_item
  }
}

/// Tokenize an entry in a yaml mapping
/// 
/// Includes
/// - key: value
/// - key:
fn tokenize_key_value_pair(stripped: String, indent: Int) {
  case string.contains(stripped, ": ") {
    True -> [
      Indent(indent),
      Key(
        string.split(stripped, ": ")
        |> list.first
        |> result.unwrap(""),
      ),
      Colon,
      get_tokenized_value_or_block_scalar_indicator(stripped),
      Newline,
    ]
    False ->
      case string.contains(stripped, ":") {
        True -> [
          Indent(indent),
          Key(
            string.split(stripped, ":")
            |> list.first
            |> result.unwrap(""),
          ),
          Colon,
          Newline,
        ]
        False -> [Indent(indent), Value(stripped), Newline]
      }
  }
}

pub fn parse_tokens(tokens: List(Token)) -> Result(Yaml, String) {
  let result = case tokens {
    [Indent(_), Dash, ..] -> parse_array(tokens, 0)
    _ -> parse_block(tokens, 0)
  }

  case result {
    Ok(#(yaml, _)) -> Ok(yaml)
    Error(error) -> Error(error)
  }
}

fn parse_block(
  tokens: List(Token),
  indent: Int,
) -> Result(#(Yaml, List(Token)), String) {
  let items = []
  parse_block_items(tokens, indent, items)
}

fn parse_block_items(
  tokens: List(Token),
  indent: Int,
  items: List(#(String, Yaml)),
) -> Result(#(Yaml, List(Token)), String) {
  case tokens {
    [] -> Ok(#(block(items), tokens))

    [Indent(current_indent), ..] if current_indent < indent ->
      Ok(#(block(items), tokens))

    [Indent(current_indent), Key(key), Colon, Value(value), Newline, ..rest]
      if current_indent == indent
    ->
      parse_block_items(
        rest,
        indent,
        list.append(items, [#(key, parse_value(value))]),
      )

    [Indent(current_indent), Key(key), Colon, Newline, ..rest]
      if current_indent == indent
    -> {
      case parse_block(rest, indent + 1) {
        Ok(#(nested_block, remaining_tokens)) ->
          parse_block_items(
            remaining_tokens,
            indent,
            list.append(items, [#(key, nested_block)]),
          )
        Error(error) -> Error(error)
      }
    }

    // TODO: Make the following two cases into one as only the Fold/Keep changes
    [Indent(current_indent), Key(key), Colon, RightArrow, Newline, ..rest]
      if current_indent == indent
    -> {
      let #(multiline_string, new_tokens) =
        parse_block_scalar(rest, "", current_indent + 1, Fold)

      parse_block_items(
        new_tokens,
        indent,
        list.append(items, [#(key, parse_value(multiline_string))]),
      )
    }

    [Indent(current_indent), Key(key), Colon, Pipe, Newline, ..rest]
      if current_indent == indent
    -> {
      let #(multiline_string, new_tokens) =
        parse_block_scalar(rest, "", current_indent + 1, Keep)

      parse_block_items(
        new_tokens,
        indent,
        list.append(items, [#(key, parse_value(multiline_string))]),
      )
    }

    [Indent(current_indent), Dash, Value(_), Newline, ..]
      if current_indent == indent
    -> parse_array(tokens, indent)

    [Indent(current_indent), Dash, Key(_), Colon, Value(_), Newline, ..]
      if current_indent == indent
    -> parse_array(tokens, indent)

    _ -> Ok(#(block(items), tokens))
  }
}

type BlockScalarType {
  Fold
  Keep
}

fn parse_block_scalar(
  tokens: List(Token),
  value: String,
  indent: Int,
  block_type: BlockScalarType,
) -> #(String, List(Token)) {
  case tokens {
    // Check if parsing of the block scalar should continue
    [Indent(current_indent), ..] if current_indent >= indent ->
      case block_type {
        Fold -> {
          let #(line_as_string, new_tokens) =
            tokens_to_string_until_newline(tokens, "", indent)
          parse_block_scalar(
            new_tokens,
            value
              <> case value {
              "" -> ""
              _ -> " "
            }
              <> line_as_string,
            indent,
            block_type,
          )
        }
        Keep -> {
          let #(line_as_string, new_tokens) =
            tokens_to_string_until_newline(tokens, "", indent)
          parse_block_scalar(
            new_tokens,
            value
              <> case value {
              "" -> ""
              _ -> "\n"
            }
              <> line_as_string,
            indent,
            block_type,
          )
        }
      }

    // Stop parsing the block scalar
    _ -> #(value, tokens)
  }
}

fn tokens_to_string_until_newline(
  tokens: List(Token),
  current_value: String,
  indent: Int,
) -> #(String, List(Token)) {
  case tokens {
    [Indent(current_indent), ..rest] ->
      tokens_to_string_until_newline(
        rest,
        current_value <> create_spaces(current_indent - indent, ""),
        indent,
      )
    [Dash, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> "-", indent)
    [Colon, Newline, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> ":\n", indent)
    [Colon, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> ": ", indent)
    [Key(key), ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> key, indent)
    [Value(value), ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> value, indent)
    [Pipe, Newline, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> "|\n", indent)
    [Pipe, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> "| ", indent)
    [RightArrow, ..rest] ->
      tokens_to_string_until_newline(rest, current_value <> ">", indent)
    [Newline, ..rest] -> #(current_value, rest)
    [] -> #(current_value, tokens)
  }
}

fn create_spaces(count: Int, acc: String) -> String {
  case count {
    0 -> acc
    _ -> create_spaces(count - 1, acc <> "  ")
  }
}

fn parse_array(
  tokens: List(Token),
  indent: Int,
) -> Result(#(Yaml, List(Token)), String) {
  parse_array_items(tokens, indent, [])
}

fn parse_array_items(
  tokens: List(Token),
  indent: Int,
  items: List(Yaml),
) -> Result(#(Yaml, List(Token)), String) {
  case tokens {
    [] -> Ok(#(array(items), tokens))

    [
      Indent(current_indent),
      Dash,
      Key(key),
      Colon,
      Value(value),
      Newline,
      ..rest
    ] -> {
      case
        parse_block_items(rest, current_indent + 1, [#(key, parse_value(value))])
      {
        Ok(#(block, new_tokens)) ->
          parse_array_items(
            new_tokens,
            current_indent,
            list.append(items, [block]),
          )
        Error(error) -> Error(error)
      }
    }

    [Indent(_), Dash, Dash, ..] -> Error("Nested sequences are not implemented")

    [Indent(current_indent), Dash, Value(value), Newline, ..rest]
      if current_indent == indent
    ->
      parse_array_items(
        rest,
        current_indent,
        list.append(items, [parse_value(value)]),
      )

    _ -> Ok(#(array(items), tokens))
  }
}

/// Entry point to parse value, same as running parse_float
fn parse_value(value: String) -> Yaml {
  parse_float(value)
}

fn parse_float(value: String) {
  case float.parse(value) {
    Ok(float) -> Float(float)
    _ -> parse_int(value)
  }
}

fn parse_int(value: String) {
  case int.parse(value) {
    Ok(int) -> Int(int)
    _ -> parse_octal(value)
  }
}

fn parse_octal(value: String) {
  case
    octal_to_decimal(string.drop_left(value, 2)),
    string.starts_with(value, "0o")
  {
    Ok(decimal), True -> int(decimal)
    _, _ -> parse_hexadecimal(value)
  }
}

fn parse_hexadecimal(value: String) {
  case
    hex_to_decimal(string.drop_left(value, 2)),
    string.starts_with(value, "0x")
  {
    Ok(decimal), True -> int(decimal)
    _, _ -> parse_boolean(value)
  }
}

fn parse_boolean(value: String) {
  case
    value == "false"
    || value == "False"
    || value == "FALSE"
    || value == "true"
    || value == "True"
    || value == "TRUE"
  {
    True -> bool(value == "true")
    _ -> parse_null(value)
  }
}

fn parse_null(value: String) {
  case value == "null" || value == "Null" || value == "NULL" || value == "~" {
    True -> null()
    _ -> parse_string(value)
  }
}

fn parse_string(value: String) {
  string(string.replace(string.replace(value, "\"", ""), "'", ""))
}

fn octal_char_to_decimal(octal_char: String) -> Result(Int, String) {
  case octal_char {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    _ -> Error("Invalid octal digit")
  }
}

fn octal_to_decimal(octal: String) -> Result(Int, String) {
  let octal_chars = string.split(octal, "")
  let length = list.length(octal_chars)

  list.index_fold(octal_chars, Ok(0), fn(acc, char, index) {
    case acc, octal_char_to_decimal(char) {
      Ok(acc_value), Ok(digit) ->
        Ok(
          acc_value
          + digit
          * float.round(result.unwrap(
            int.power(8, int.to_float(length - 1 - index)),
            1.0,
          )),
        )

      Error(e), _ -> Error(e)
      _, Error(e) -> Error(e)
    }
  })
}

fn hex_to_decimal(hex: String) -> Result(Int, String) {
  let hex_chars = string.split(hex, "")
  let length = list.length(hex_chars)
  let decimal_value =
    list.index_fold(hex_chars, Ok(0), fn(acc, char, index) {
      case acc {
        Ok(value) ->
          case hex_char_to_value(char) {
            Ok(char_value) ->
              Ok(
                value
                + char_value
                * float.round(result.unwrap(
                  int.power(16, int.to_float(length - 1 - index)),
                  1.0,
                )),
              )
            Error(e) -> Error(e)
          }
        Error(e) -> Error(e)
      }
    })
  decimal_value
}

fn hex_char_to_value(hex_char: String) -> Result(Int, String) {
  case hex_char {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    "a" -> Ok(10)
    "A" -> Ok(10)
    "b" -> Ok(11)
    "B" -> Ok(11)
    "c" -> Ok(12)
    "C" -> Ok(12)
    "d" -> Ok(13)
    "D" -> Ok(13)
    "e" -> Ok(14)
    "E" -> Ok(14)
    "f" -> Ok(15)
    "F" -> Ok(15)
    _ -> Error("Invalid hexadecimal character: " <> hex_char)
  }
}
