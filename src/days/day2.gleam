import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 2!")

  // let filepath = "./src/days/day2.test"
  let filepath = "./src/days/day2.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let reports = string.split(text, on: "\n")

  let safe_reports = list.fold(reports, 0, fn(b, a) { b + is_safe(a) })

  // Part 1 result
  io.println(int.to_string(safe_reports))

  let safe_reports_with_dampener =
    list.fold(reports, 0, fn(b, a) { b + is_safe_dampener(a) })

  // Part 2 result
  io.println(int.to_string(safe_reports_with_dampener))
}

fn is_safe(report: String) -> Int {
  let split = string.split(report, on: " ")
  let report_int =
    split
    |> list.map(fn(str) {
      let assert Ok(num) = int.parse(str)
      num
    })

  is_increasing_or_descreasing(report_int)
}

fn is_increasing_or_descreasing(report: List(Int)) -> Int {
  case report {
    [first, second, ..] if first > second -> is_decreasing(report)
    [first, second, ..] if second > first -> is_increasing(report)
    _ -> 0
  }
}

fn is_increasing(report: List(Int)) -> Int {
  case report {
    [first, second, ..rest] if first < second && second - first <= 3 ->
      is_increasing([second, ..rest])
    [_] -> 1
    _ -> 0
  }
}

fn is_decreasing(report: List(Int)) -> Int {
  case report {
    [first, second, ..rest] if first > second && first - second <= 3 ->
      is_decreasing([second, ..rest])
    [_] -> 1
    _ -> 0
  }
}

fn is_safe_dampener(report: String) -> Int {
  let split = string.split(report, on: " ")
  let report_int =
    split
    |> list.map(fn(str) {
      let assert Ok(num) = int.parse(str)
      num
    })

  case report_int {
    [first, second, ..] if first > second ->
      is_decreasing_dampener(report_int, [])
    [first, second, ..] if second > first ->
      is_increasing_dampener(report_int, [])
    _ -> check_thrice([], report_int)
  }
}

fn is_increasing_dampener(report: List(Int), prev: List(Int)) -> Int {
  case report {
    [first, second, ..rest] if first < second && second - first <= 3 ->
      is_increasing_dampener([second, ..rest], list.append(prev, [first]))
    [_, _, ..] -> check_thrice(prev, report)
    [_] -> 1
    _ -> 0
  }
}

fn is_decreasing_dampener(report: List(Int), prev: List(Int)) -> Int {
  case report {
    [first, second, ..rest] if first > second && first - second <= 3 ->
      is_decreasing_dampener([second, ..rest], list.append(prev, [first]))
    [_, _, ..] -> check_thrice(prev, report)
    [_] -> 1
    _ -> 0
  }
}

fn check_thrice(prev: List(Int), report: List(Int)) -> Int {
  // io.debug(list.append(prev, report))

  let assert [first, second, ..rest] = report

  // Remove first of problem couple
  let check_list_1 = list.append(prev, [second, ..rest])

  // Remove second of problem couple
  let check_list_2 = list.append(prev, [first, ..rest])

  // Remove last element of previous set
  let check_list_3 = case prev {
    [_, ..] -> {
      let prev_reversed = prev |> list.reverse
      let assert Ok(#(_, rest)) = list.pop(prev_reversed, fn(_) { True })
      rest
      |> list.reverse
      |> list.append(report)
    }
    _ -> []
  }

  let safe_1 = is_increasing_or_descreasing(check_list_1)
  let safe_2 = is_increasing_or_descreasing(check_list_2)
  let safe_3 = is_increasing_or_descreasing(check_list_3)

  let sum = safe_1 + safe_2 + safe_3

  case sum {
    0 -> {
      // io.debug(list.append(prev, report))
      0
    }
    _ -> {
      // io.debug(list.append(prev, report))
      1
    }
  }
}
