// import cymbal.{decode, encode}
// import cymbal/decode.{tokenize_lines}
// import cymbal/encode.{type Yaml, Array, Block, String, block, string}
// import gleam/int
// import gleam/io
// import gleam/iterator
// import gleam/list
// import gleam/result
// import gleam/string
// import gleeunit
// import gleeunit/should
// import simplifile.{get_files, read}

// pub fn main() {
//   gleeunit.main()
// }

// pub fn run_test_suite_test() {
//   case get_files("./test/yaml-test-suite/src") {
//     Ok(files) -> iterator.from_list(files)
//     Error(_) ->
//       panic as "You have not updated submodules with 'git submodule init && git submodule update'"
//   }
//   |> iterator.map(run_test)
//   |> iterator.to_list
//   |> evaluate_results
// }

// fn evaluate_results(results: List(Bool)) {
//   let success_count =
//     results
//     |> list.filter(fn(result) { result })
//     |> list.length

//   let fail_count =
//     results
//     |> list.filter(fn(result) { !result })
//     |> list.length

//   io.debug(
//     int.to_string(success_count)
//     <> " succeeded, "
//     <> int.to_string(fail_count)
//     <> " failed",
//   )
// }

// fn run_test(file: String) -> Bool {
//   let yaml = case
//     case read(file) {
//       Ok(contents) -> contents
//       Error(_) -> panic as "Failed to read contents of file"
//     }
//     |> decode
//   {
//     Ok(decode) -> decode
//     Error(_) -> panic
//   }

//   case yaml {
//     Array(array) -> {
//       case
//         list.key_find(
//           case result.unwrap(list.first(array), block([])) {
//             Block(block) -> block
//             _ -> panic as "Yaml must be block"
//           },
//           "yaml",
//         )
//       {
//         Ok(yaml) ->
//           case
//             list.key_find(
//               case result.unwrap(list.first(array), block([])) {
//                 Block(block) -> block
//                 _ -> panic as "Dump must be block"
//               },
//               "dump",
//             )
//           {
//             Ok(dump) -> {
//               let encoded =
//                 case
//                   case yaml {
//                     String(string) -> string
//                     _ -> panic as "Yaml must be string"
//                   }
//                   |> decode
//                 {
//                   Ok(ok) ->
//                     ok
//                     |> io.debug
//                   Error(_) -> panic as "Failed decoding yaml"
//                 }
//                 |> encode

//               let encoded_without_start =
//                 case
//                   case yaml {
//                     String(string) -> string
//                     _ -> panic as "Yaml must be string"
//                   }
//                   |> decode
//                 {
//                   Ok(ok) -> ok
//                   Error(_) -> panic as "Failed decoding yaml"
//                 }
//                 |> cymbal.encode_without_document_start

//               //   case dump {
//               //     String(string) -> string
//               //     _ -> panic as "Dump must be string"
//               //   }
//               //   |> should.equal(encoded)

//               io.debug(case
//                 result.unwrap(
//                   list.key_find(
//                     case result.unwrap(list.first(array), block([])) {
//                       Block(block) -> block
//                       _ -> panic as "Dump must be block"
//                     },
//                     "name",
//                   ),
//                   string("Name not found"),
//                 )
//               {
//                 String(string) -> string
//                 _ -> ""
//               })

//               io.debug(
//                 "Expected "
//                 <> case dump {
//                   String(string) -> string
//                   _ -> panic as "Dump must be string"
//                 },
//               )

//               case
//                 case dump {
//                   String(string) -> string
//                   _ -> panic as "Dump must be string"
//                 }
//                 == encoded
//               {
//                 True -> io.debug("Got      " <> encoded)
//                 False -> io.debug("Got      " <> encoded_without_start)
//               }

//               io.debug(" ")

//               case dump {
//                 String(string) -> string
//                 _ -> panic as "Dump must be string"
//               }
//               == encoded
//               || case dump {
//                 String(string) -> string
//                 _ -> panic as "Dump must be string"
//               }
//               == encoded_without_start
//             }
//             Error(_) -> {
//               False
//             }
//           }
//         Error(_) -> False
//       }
//     }
//     _ -> False
//   }
// }
