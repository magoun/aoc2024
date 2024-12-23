import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 6!")

  // let filepath = "./src/days/day6.test"
  let filepath = "./src/days/day6.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let map = text

  // let test_var = [#(1, 2), #(1, 3), #(1, 2)]

  // io.debug(test_var |> list.unique)

  let part_1_result = map_route(map) |> list.unique |> list.length

  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  // let curr_pos = get_current_position(map)
  // io.debug(curr_pos)
  let part_2_result =
    map_route_with_loop_detection(map)
    |> list.filter(fn(move) { move.can_loop })
    |> list.length

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

pub type Move {
  Move(pos: #(Int, Int), guard_after: String, can_loop: Bool)
}

fn map_route_with_loop_detection(map: String) -> List(Move) {
  let start = get_current_position(map)
  let guard = get_character(start, map)
  move_with_loop_detection(Move(start, guard, False), [], map)
}

fn move_with_loop_detection(
  // map as normal, but track all turn coordinates and resulting travel direction (up, right, down, left)
  // when moving, check if a turn would intersect with a previous turn in the opposite direction
  // Example: if moving left, check if there is a previous turn moving to the right directly up from you
  // If there is, make sure there are no obstacles between your current pos and the previous turn.
  // If not, increment potential loop counter
  start: Move,
  turns: List(Move),
  map: String,
) -> List(Move) {
  let next_x_y = get_next_x_y(start.guard_after, start.pos)
  let #(max_x, max_y) = get_map_size(map)

  let simple_move = Move(start.pos, start.guard_after, False)

  // io.debug(start)
  // io.debug(turns)

  case next_x_y {
    #(_, y) if y > max_y || y < 0 -> [simple_move]
    #(x, _) if x > max_x || x < 0 -> [simple_move]
    _ -> {
      let next_character = get_character(next_x_y, map)
      case next_character {
        "#" -> {
          let guard = turn_right(start.guard_after)
          let turn = Move(start.pos, guard, False)
          let turns = [turn, ..turns]
          [
            turn,
            ..move_with_loop_detection(
              Move(get_next_x_y(guard, start.pos), guard, False),
              turns,
              map,
            )
          ]
        }
        _ -> {
          let can_loop = check_for_loop(start, turns, map)
          let move = Move(next_x_y, start.guard_after, can_loop)
          [move, ..move_with_loop_detection(move, turns, map)]
        }
      }
    }
  }
}

fn check_for_loop(move: Move, turns: List(Move), map: String) -> Bool {
  let turns = turns |> list.filter(fn(turn) { filter_turns(turn, move) })

  let loops =
    turns
    |> list.map(fn(turn) {
      let direction = turn_right(turn.guard_after)
      let coordinates_to_check = case direction {
        ">" | "<" ->
          list.range(move.pos.0, turn.pos.0)
          |> list.map(fn(x) { #(x, move.pos.1) })
        "^" | "v" ->
          list.range(move.pos.1, turn.pos.1)
          |> list.map(fn(y) { #(move.pos.0, y) })
        _ -> panic
      }

      coordinates_to_check
      |> list.fold(0, fn(count, x_y) {
        case get_character(x_y, map) {
          "#" -> count + 1
          _ -> count
        }
      })
    })
    |> list.filter(fn(turn_obstacles) { turn_obstacles == 0 })

  case loops {
    [] -> False
    _ -> True
  }
}

fn filter_turns(turn: Move, compare: Move) -> Bool {
  let guard_match =
    turn.guard_after == turn_right(turn_right(compare.guard_after))
  let inline = case turn_right(compare.guard_after) {
    ">" -> compare.pos.0 < turn.pos.0 && compare.pos.1 == turn.pos.1
    "<" -> compare.pos.0 > turn.pos.0 && compare.pos.1 == turn.pos.1
    "^" -> compare.pos.0 == turn.pos.0 && compare.pos.1 > turn.pos.1
    "v" -> compare.pos.0 == turn.pos.0 && compare.pos.1 < turn.pos.1
    _ -> panic
  }

  inline && guard_match
}

//b---c
//|   |
//|   |
//a---d

fn count_possible_loops(turns: List(#(Int, Int))) -> Int {
  turns
  |> list.window(4)
  |> list.fold(0, fn(count, window) {
    let assert [a, b, c, d] = window
    let ab = diff(a, b)
    let cd = diff(c, d)
    let bc = diff(b, c)
    let da = diff(d, a)

    case ab >= cd && bc <= da {
      True -> {
        io.debug(window)
        count + 1
      }
      False -> count
    }
  })
}

fn diff(a: #(Int, Int), b: #(Int, Int)) -> Int {
  case a.0 == b.0 {
    True -> int.absolute_value(a.1 - b.1)
    False -> int.absolute_value(a.0 - b.0)
  }
}

fn map_route_turns_only(map: String) -> List(#(Int, Int)) {
  let start = get_current_position(map)
  let guard = get_character(start, map)
  [start, ..move_turns_only(guard, start, map)]
}

fn move_turns_only(
  guard: String,
  pos: #(Int, Int),
  map: String,
) -> List(#(Int, Int)) {
  let next_x_y = get_next_x_y(guard, pos)
  let #(max_x, max_y) = get_map_size(map)

  case next_x_y {
    #(_, y) if y > max_y || y < 0 -> [pos]
    #(x, _) if x > max_x || x < 0 -> [pos]
    _ -> {
      let next_character = get_character(next_x_y, map)
      case next_character {
        "#" -> {
          let guard = turn_right(guard)
          [pos, ..move_turns_only(guard, get_next_x_y(guard, pos), map)]
        }
        _ -> move_turns_only(guard, next_x_y, map)
      }
    }
  }
}

fn map_route(map: String) -> List(#(Int, Int)) {
  let start = get_current_position(map)
  let guard = get_character(start, map)
  move(guard, start, map)
}

fn move(guard: String, pos: #(Int, Int), map: String) -> List(#(Int, Int)) {
  let next_x_y = get_next_x_y(guard, pos)
  let #(max_x, max_y) = get_map_size(map)

  case next_x_y {
    #(_, y) if y > max_y || y < 0 -> [pos]
    #(x, _) if x > max_x || x < 0 -> [pos]
    _ -> {
      let next_character = get_character(next_x_y, map)
      case next_character {
        "#" -> {
          let guard = turn_right(guard)
          [pos, ..move(guard, get_next_x_y(guard, pos), map)]
        }
        _ -> [pos, ..move(guard, next_x_y, map)]
      }
    }
  }
}

fn get_next_x_y(guard: String, pos: #(Int, Int)) -> #(Int, Int) {
  case guard {
    ">" -> #(pos.0 + 1, pos.1)
    "<" -> #(pos.0 - 1, pos.1)
    "^" -> #(pos.0, pos.1 - 1)
    "v" -> #(pos.0, pos.1 + 1)
    _ -> panic
  }
}

fn turn_right(guard: String) -> String {
  case guard {
    ">" -> "v"
    "v" -> "<"
    "<" -> "^"
    "^" -> ">"
    _ -> panic
  }
}

fn get_map_size(map) -> #(Int, Int) {
  let lines = map |> string.split("\n")
  let assert Ok(line) = list.first(lines)

  #(string.length(line) - 1, list.length(lines) - 1)
}

fn get_character(pos: #(Int, Int), map: String) -> String {
  let #(_, right) = map |> string.split("\n") |> list.split(pos.1)
  let assert Ok(line) = list.first(right)
  line |> string.slice(pos.0, 1)
}

fn get_current_position(map: String) -> #(Int, Int) {
  let y =
    map
    |> string.split("\n")
    |> list.index_fold(0, fn(b, line, y) {
      // io.println("At y: " <> int.to_string(y))
      let present = string_contains_guard(line)

      case present {
        True -> y
        False -> b
      }
    })

  let #(_, right) =
    map
    |> string.split("\n")
    |> list.split(y)

  let assert Ok(line) = list.first(right)

  let #(left, _) =
    line
    |> string.to_graphemes
    |> list.split_while(fn(s) { !string_contains_guard(s) })

  let x = list.length(left)

  #(x, y)
}

fn string_contains_guard(string: String) -> Bool {
  string.contains(string, "^")
  || string.contains(string, "<")
  || string.contains(string, ">")
  || string.contains(string, "v")
}
