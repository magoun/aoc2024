import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 7!")

  // let filepath = "./src/days/day7.test"
  let filepath = "./src/days/day7.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let part_1_result = sum_calibrations(text)

  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  let part_2_result = sum_calibrations_with_concat(text)

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

fn sum_calibrations_with_concat(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.fold(0, fn(sum, line) {
    case is_solvable_with_concat(line) {
      True -> sum + get_test_value(line)
      False -> sum
    }
  })
}

fn is_solvable_with_concat(line: String) -> Bool {
  let value = get_test_value(line)
  io.debug(value)
  let numbers = get_numbers(line) |> list.reverse

  let potentials = get_potentials_with_concat(numbers)
  // io.debug(potentials)
  list.contains(potentials, value)
}

fn get_potentials_with_concat(numbers: List(Int)) -> List(Int) {
  case numbers {
    [a, b] -> [a + b, a * b, concat(b, a)]
    [a, ..rest] -> {
      let plus = get_potentials_with_concat(rest) |> list.map(fn(x) { x + a })
      let times = get_potentials_with_concat(rest) |> list.map(fn(x) { x * a })
      let concat =
        get_potentials_with_concat(rest) |> list.map(fn(x) { concat(x, a) })
      list.flatten([plus, times, concat])
    }
    [] -> panic
  }
}

fn concat(left: Int, right: Int) -> Int {
  let left_string = int.to_string(left)
  let right_string = int.to_string(right)
  let assert Ok(value) = int.parse(left_string <> right_string)
  value
}

fn sum_calibrations(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.fold(0, fn(sum, line) {
    case is_solvable(line) {
      True -> sum + get_test_value(line)
      False -> sum
    }
  })
}

fn is_solvable(line: String) -> Bool {
  let value = get_test_value(line)
  let numbers = get_numbers(line) |> list.reverse

  let potentials = get_potentials(numbers)
  list.contains(potentials, value)
}

fn get_potentials(numbers: List(Int)) -> List(Int) {
  case numbers {
    [a, b] -> [a + b, a * b]
    [a, ..rest] -> {
      let plus = get_potentials(rest) |> list.map(fn(x) { x + a })
      let times = get_potentials(rest) |> list.map(fn(x) { x * a })
      list.flatten([plus, times])
    }
    [] -> panic
  }
}

fn get_test_value(line: String) -> Int {
  let assert [left, _] = string.split(line, ":")
  let assert Ok(value) = int.parse(left)
  value
}

fn get_numbers(line: String) -> List(Int) {
  let assert [_, ..rest] = string.split(line, " ")
  rest
  |> list.map(fn(s) {
    let assert Ok(number) = int.parse(s)
    number
  })
}
