import gleam/int
import gleam/float
import gleam/string

/// A YAML document which can be converted into a string using the `encode`
/// function.
///
pub opaque type Yaml {
  Int(Int)
  Float(Float)
  String(String)
  Array(List(Yaml))
  Block(List(#(String, Yaml)))
}

/// Convert a YAML document into a string.
///
pub fn encode(doc: Yaml) -> String {
  let start = case doc {
    Int(_) | Float(_) | String(_) -> "---\n"
    Array(_) | Block(_) -> "---"
  }

  en(start, 0, doc) <> "\n"
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

fn en(acc: String, in: Int, doc: Yaml) -> String {
  case doc {
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
        Int(_) | Float(_) | String(_) -> en(acc <> "- ", in + 1, doc)
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
    Int(_) | Float(_) | String(_) -> en(acc <> ": ", in, doc)
    Array(_) -> en(acc <> ":", in, doc)
    Block(i) -> en_block(acc <> ":", in + 1, True, i)
  }
}

fn indent(acc: String, i: Int) -> String {
  acc <> string.repeat("  ", i)
}

fn is_simple_string(s: String) -> Bool {
  case s {
    "0" <> _
    | "1" <> _
    | "2" <> _
    | "3" <> _
    | "4" <> _
    | "5" <> _
    | "6" <> _
    | "7" <> _
    | "8" <> _
    | "9" <> _ -> False
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
