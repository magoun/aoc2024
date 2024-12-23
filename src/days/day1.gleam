import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 1!")

  let filepath = "./src/days/day1.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  // io.println(text)

  let lines = string.split(text, on: "\n")

  let left =
    list.map(lines, fn(line) {
      let numbers = string.split(line, on: "   ")
      let assert Ok(#(number_string, _)) = list.pop(numbers, fn(_) { True })
      let assert Ok(number) = int.parse(number_string)
      number
    })

  let sorted_left = list.sort(left, by: int.compare)

  let right =
    list.map(lines, fn(line) {
      let numbers = string.split(line, on: "   ")
      let assert Ok(#(_, remaining)) = list.pop(numbers, fn(_) { True })
      let assert Ok(#(number_string, _)) = list.pop(remaining, fn(_) { True })
      let assert Ok(number) = int.parse(number_string)
      number
    })

  let sorted_right = list.sort(right, by: int.compare)

  let zipped = list.zip(sorted_left, sorted_right)

  let result =
    list.fold(zipped, 0, fn(b, a) {
      let #(left, right) = a
      b + int.absolute_value(left - right)
    })

  // Part 1 result
  io.println(int.to_string(result))

  let part2 =
    list.fold(sorted_left, 0, fn(b, a) {
      let appearances = get_total_appearances(a, sorted_right, 0)
      b + { a * appearances }
    })

  // Part 2 result
  io.println(int.to_string(part2))
}

fn get_total_appearances(needle: Int, haystack: List(Int), start: Int) -> Int {
  let res = list.pop(haystack, fn(a) { a == needle })

  case result.is_ok(res) {
    True ->
      get_total_appearances(needle, result.unwrap(res, #(0, [])).1, start + 1)
    False -> start
  }
}
