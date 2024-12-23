import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 5!")

  // let filepath = "./src/days/day5.test"
  let filepath = "./src/days/day5.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let split = string.split(text, on: "\n")

  let rules =
    split
    |> list.filter(fn(s) { string.contains(s, "|") })
    |> list.map(string.trim)

  let updates =
    split
    |> list.filter(fn(s) { string.contains(s, ",") })
    |> list.map(string.trim)

  let sum = get_correct_middle_sum(updates, rules)

  // Part 1 result
  io.println("Part 1:")
  io.debug(sum)

  let part_2_sum = get_corrected_middle_sum(updates, rules)

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_sum)
}

fn get_correct_middle_sum(updates: List(String), rules: List(String)) -> Int {
  updates
  |> list.fold(0, fn(b, update) {
    case update_is_ordered_correctly(update, rules) {
      True -> b + get_middle_page(update)
      False -> b
    }
  })
}

fn get_corrected_middle_sum(updates: List(String), rules: List(String)) -> Int {
  updates
  |> list.fold(0, fn(b, update) {
    case update_is_ordered_correctly(update, rules) {
      True -> b
      False -> b + get_middle_page_of_corrected_update(update, rules)
    }
  })
}

fn get_middle_page_of_corrected_update(
  update: String,
  rules: List(String),
) -> Int {
  let corrected = correct_update_order(update, rules)
  get_middle_page(corrected)
}

fn correct_update_order(update: String, rules: List(String)) -> String {
  let pages = string.split(update, ",")
  let applicable_rules = get_applicable_rules(pages, rules)
  let ideal = get_ideal_update_order(pages, applicable_rules)

  let update_list = string.split(update, ",")

  ideal
  |> string.split(",")
  |> list.filter(fn(s) { list.contains(update_list, s) })
  |> string.join(",")
}

fn get_applicable_rules(
  pages: List(String),
  rules: List(String),
) -> List(String) {
  rules
  |> list.filter(fn(s) {
    let assert [left, right] = string.split(s, "|")
    list.contains(pages, left) && list.contains(pages, right)
  })
}

// Find the number not on the right side of a rule
fn get_unrestricted_page(pages: List(String), rules: List(String)) -> String {
  let rules_right =
    list.map(rules, fn(s) { string.split(s, "|") })
    |> list.map(fn(x) {
      let assert Ok(right) = list.last(x)
      right
    })
    |> list.unique

  let assert Ok(result) =
    pages
    |> list.filter(fn(x) { !list.contains(rules_right, x) })
    |> list.first

  result
}

fn get_ideal_update_order(pages: List(String), rules: List(String)) -> String {
  case pages {
    [] -> ""
    [x] -> x
    [_, _, ..] -> {
      let unrestricted_page = get_unrestricted_page(pages, rules)
      let assert Ok(#(_, remaining_pages)) =
        list.pop(pages, fn(s) { s == unrestricted_page })

      let filtered_rules = filter_rules(unrestricted_page, rules)

      unrestricted_page
      <> ","
      <> get_ideal_update_order(remaining_pages, filtered_rules)
    }
  }
}

fn filter_rules(page_to_remove: String, rules: List(String)) -> List(String) {
  rules
  |> list.filter(fn(s) { !string.starts_with(s, page_to_remove) })
}

fn update_is_ordered_correctly(update: String, rules: List(String)) -> Bool {
  // If the first unique page obeys the rules, all subsequent copies of the same page do too
  let pages =
    string.split(update, ",")
    |> list.unique

  // Check that each page obeys the rules
  let error =
    pages
    |> list.fold_until(0, fn(_, page) {
      case flag_page_error(page, pages, rules) {
        0 -> list.Continue(0)
        _ -> list.Stop(1)
      }
    })

  case error {
    0 -> True
    _ -> False
  }
}

fn flag_page_error(
  page: String,
  pages: List(String),
  rules: List(String),
) -> Int {
  let #(previous_pages, _) = list.split_while(pages, fn(x) { x != page })

  rules
  |> list.fold_until(0, fn(_, rule) {
    let assert [needed, needs] = string.split(rule, "|")
    let rule_applies =
      list.contains(pages, needed)
      && list.contains(pages, needs)
      && needs == page

    let error = case rule_applies {
      True -> is_rule_error(needed, previous_pages)
      _ -> False
    }

    case error {
      True -> list.Stop(1)
      False -> list.Continue(0)
    }
  })
}

fn is_rule_error(needed: String, previous_pages: List(String)) -> Bool {
  !list.contains(previous_pages, needed)
}

fn get_middle_page(update: String) -> Int {
  let pages = string.split(update, ",")
  let middle_index = { list.length(pages) - 1 } / 2
  let #(_, right) = list.split(pages, middle_index)
  let assert Ok(page) = list.first(right)
  let assert Ok(page_number) = int.parse(page)

  page_number
}
