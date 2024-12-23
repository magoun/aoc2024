import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 3!")

  // let filepath = "./src/days/day3.test"
  let filepath = "./src/days/day3.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let lines = string.split(text, on: "\n")

  let mapped =
    lines
    |> list.flat_map(fn(s) { string.split(s, on: ")") })
    |> list.flat_map(fn(s) { string.split(s, on: "mul(") })

  // io.debug(mapped)

  let filtered =
    mapped
    |> list.filter(fn(s) {
      let split = string.split(s, ",")

      case list.length(split) {
        2 -> test_split(split)
        _ -> False
      }
    })

  // io.debug(filtered)

  let sum =
    filtered
    |> list.fold(0, fn(b, a) { b + parse_and_multiply(a) })

  // Part 1 result
  io.debug(sum)

  // Part 2 result
  let #(_, sum) =
    mapped
    |> list.fold(#(True, 0), fn(b: #(Bool, Int), a: String) -> #(Bool, Int) {
      let #(state, sum) = b
      let on = string.contains(a, "do(")
      let off = string.contains(a, "don't(")

      case on, off, state {
        True, _, _ -> #(True, sum)
        False, True, _ -> #(False, sum)
        False, False, True -> #(state, sum + test_parse_and_multiply(a))
        _, _, _ -> b
      }
    })

  io.debug(sum)
}

fn test_split(split: List(String)) -> Bool {
  let assert [left, right] = split
  let left_num = int.parse(left)
  let right_num = int.parse(right)

  case result.is_ok(left_num), result.is_ok(right_num) {
    True, True -> True
    _, _ -> False
  }
}

fn parse_and_multiply(number_pair: String) -> Int {
  let split = string.split(number_pair, ",")
  let assert [left, right] = split
  let assert Ok(left_num) = int.parse(left)
  let assert Ok(right_num) = int.parse(right)

  left_num * right_num
}

fn test_parse_and_multiply(str: String) -> Int {
  let split = string.split(str, ",")

  let proceed: Bool = case list.length(split) {
    2 -> test_split(split)
    _ -> False
  }

  case proceed {
    True -> parse_and_multiply(str)
    False -> 0
  }
}
