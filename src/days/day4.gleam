import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 4!")

  // let filepath = "./src/days/day4.test"
  let filepath = "./src/days/day4.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let grid =
    string.split(text, on: "\n")
    |> list.map(string.trim)

  // io.debug(grid)
  // io.debug(is_char_at_pos("X", grid, 2, 1))

  let sum = solve_grid(grid)

  // Part 1 result
  io.println("Part 1:")
  io.debug(sum)

  let part_2_sum = solve_grid_x_mas(grid)

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_sum)
}

// top left char is x: 0, y: 0
fn is_char_at_pos(char: String, grid: List(String), x: Int, y: Int) -> Bool {
  let #(_, right) = list.split(grid, y)
  let assert Ok(#(line, _)) = list.pop(right, fn(_) { True })
  let test_char = string.slice(line, x, 1)

  case string.compare(test_char, char) {
    order.Eq -> True
    _ -> False
  }
}

fn solve_grid(grid: List(String)) {
  // For each row, look for an "X"
  // If we find one, check each direction for "MAS"
  // If one is found, add 1 to sum
  list.index_fold(grid, 0, fn(b, line, y) {
    // io.println("At y: " <> int.to_string(y))

    line
    |> string.to_graphemes
    |> list.index_fold(b, fn(inner_sum, char, x) {
      // io.println("At x: " <> int.to_string(x))

      case char {
        "X" -> inner_sum + check_pos(x, y, grid)
        _ -> inner_sum
      }
    })
  })
}

fn solve_grid_x_mas(grid: List(String)) -> Int {
  // For each row, look for an "A"
  // If we find one, check for crossed MAS on the A
  // If both diagonals are MAS, add 1
  list.index_fold(grid, 0, fn(b, line, y) {
    // io.println("At y: " <> int.to_string(y))

    line
    |> string.to_graphemes
    |> list.index_fold(b, fn(inner_sum, char, x) {
      // io.println("At x: " <> int.to_string(x))

      case char {
        "A" -> inner_sum + check_pos_x_mas(x, y, grid)
        _ -> inner_sum
      }
    })
  })
}

fn check_pos(x: Int, y: Int, grid: List(String)) -> Int {
  let max_y = list.length(grid) - 1
  let assert Ok(line) = list.first(grid)
  let max_x = string.length(line) - 1

  let count = case x {
    a if a <= max_x - 3 -> check_right(x, y, grid)
    _ -> 0
  }

  let count =
    count
    + case x {
      a if a >= 3 -> check_left(x, y, grid)
      _ -> 0
    }

  let count =
    count
    + case y {
      b if b >= 3 -> check_up(x, y, grid)
      _ -> 0
    }

  let count =
    count
    + case y {
      b if b <= max_y - 3 -> check_down(x, y, grid)
      _ -> 0
    }

  let count =
    count
    + case x, y {
      a, b if b >= 3 && a <= max_x - 3 -> check_up_right(x, y, grid)
      _, _ -> 0
    }

  let count =
    count
    + case x, y {
      a, b if b <= max_y - 3 && a <= max_x - 3 -> check_down_right(x, y, grid)
      _, _ -> 0
    }

  let count =
    count
    + case x, y {
      a, b if b >= 3 && a >= 3 -> check_up_left(x, y, grid)
      _, _ -> 0
    }

  let count =
    count
    + case x, y {
      a, b if b <= max_y - 3 && a >= 3 -> check_down_left(x, y, grid)
      _, _ -> 0
    }

  count
}

fn check_pos_x_mas(x: Int, y: Int, grid: List(String)) -> Int {
  let max_y = list.length(grid) - 1
  let assert Ok(line) = list.first(grid)
  let max_x = string.length(line) - 1

  // Hijack the old check functions. For an X-MAS, one of these should be 1
  // They cannot both be 1
  let down_left_to_up_right = case x, y {
    a, b if b <= max_y - 1 && b >= 1 && a <= max_x - 1 && a >= 1 ->
      check_down_left(x + 2, y - 2, grid) + check_up_right(x - 2, y + 2, grid)
    _, _ -> 0
  }

  let up_left_to_down_right = case x, y {
    a, b if b <= max_y - 1 && b >= 1 && a <= max_x - 1 && a >= 1 ->
      check_up_left(x + 2, y + 2, grid) + check_down_right(x - 2, y - 2, grid)
    _, _ -> 0
  }

  case down_left_to_up_right + up_left_to_down_right {
    2 -> 1
    _ -> 0
  }
}

fn check_right(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x + 1, y)
  let a = is_char_at_pos("A", grid, x + 2, y)
  let s = is_char_at_pos("S", grid, x + 3, y)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_left(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x - 1, y)
  let a = is_char_at_pos("A", grid, x - 2, y)
  let s = is_char_at_pos("S", grid, x - 3, y)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_up(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x, y - 1)
  let a = is_char_at_pos("A", grid, x, y - 2)
  let s = is_char_at_pos("S", grid, x, y - 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_down(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x, y + 1)
  let a = is_char_at_pos("A", grid, x, y + 2)
  let s = is_char_at_pos("S", grid, x, y + 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_up_right(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x + 1, y - 1)
  let a = is_char_at_pos("A", grid, x + 2, y - 2)
  let s = is_char_at_pos("S", grid, x + 3, y - 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_down_right(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x + 1, y + 1)
  let a = is_char_at_pos("A", grid, x + 2, y + 2)
  let s = is_char_at_pos("S", grid, x + 3, y + 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_up_left(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x - 1, y - 1)
  let a = is_char_at_pos("A", grid, x - 2, y - 2)
  let s = is_char_at_pos("S", grid, x - 3, y - 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}

fn check_down_left(x: Int, y: Int, grid: List(String)) -> Int {
  let m = is_char_at_pos("M", grid, x - 1, y + 1)
  let a = is_char_at_pos("A", grid, x - 2, y + 2)
  let s = is_char_at_pos("S", grid, x - 3, y + 3)

  case m && a && s {
    True -> 1
    False -> 0
  }
}
