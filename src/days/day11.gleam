import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 11!")

  // let filepath = "./src/days/day11.test"
  let filepath = "./src/days/day11.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let part_1_result = solve_part_1(text)
  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  let part_2_result = solve_part_2(text)
  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

type MagicStone {
  Stone(value: Int, blinks_left: Int)
}

fn solve_part_1(input: String) -> Int {
  get_stones(input)
  |> blink(25)
  |> list.length
}

fn solve_part_2(input: String) -> Int {
  let #(count, magic_stones) =
    get_stones(input)
    |> get_magic_stones(75, [])

  count + compute_magic_stones(magic_stones, 0, dict.new())
}

fn compute_magic_stones(
  stones: List(MagicStone),
  accumulator: Int,
  cache: Dict(MagicStone, Int),
) -> Int {
  let assert [stone, ..rest] = stones
  let cached = cache |> dict.get(stone)

  let result = case cached {
    Ok(sum) -> sum
    Error(_) -> {
      case stone {
        Stone(_, b) if b > 5 ->
          fast_forward(stone)
          |> compute_magic_stones(0, cache)
        Stone(v, b) -> list.length(blink([v], b))
      }
    }
  }

  let cache = case cached {
    Ok(_) -> cache
    Error(_) -> cache |> dict.insert(stone, result)
  }

  let total = accumulator + result

  case rest {
    [] -> total
    _ -> compute_magic_stones(rest, total, cache)
  }
}

// fn compute_magic_stone(stone: MagicStone, cache: Dict(MagicStone, Int)) -> Int {
//   case stone {
//     Stone(_, b) if b > 5 ->
//       fast_forward(stone)
//       |> list.fold(0, fn(sum, stone) { sum + compute_magic_stone(stone) })
//     _ -> stone_to_sum(stone)
//   }
// }

fn stone_to_sum(stone: MagicStone) -> Int {
  case stone {
    Stone(0, 1) -> 1
    Stone(0, 2) -> 1
    Stone(0, 3) -> 2
    Stone(0, 4) -> 4
    Stone(0, 5) -> 4
    Stone(1, 1) -> 1
    Stone(1, 2) -> 2
    Stone(1, 3) -> 4
    Stone(1, 4) -> 4
    Stone(1, 5) ->
      2
      * stone_to_sum(Stone(2, 2))
      + stone_to_sum(Stone(0, 2))
      + stone_to_sum(Stone(4, 2))
    Stone(2, 1) -> 1
    Stone(2, 2) -> 2
    Stone(2, 3) -> 4
    Stone(2, 4) -> 4
    Stone(2, 5) ->
      2
      * stone_to_sum(Stone(4, 2))
      + stone_to_sum(Stone(0, 2))
      + stone_to_sum(Stone(8, 2))
    Stone(3, 1) -> 1
    Stone(3, 2) -> 2
    Stone(3, 3) -> 4
    Stone(3, 4) -> 4
    Stone(3, 5) ->
      stone_to_sum(Stone(6, 2))
      + stone_to_sum(Stone(0, 2))
      + stone_to_sum(Stone(7, 2))
      + stone_to_sum(Stone(2, 2))
    Stone(4, 1) -> 1
    Stone(4, 2) -> 2
    Stone(4, 3) -> 4
    Stone(4, 4) -> 4
    Stone(4, 5) ->
      stone_to_sum(Stone(8, 2))
      + stone_to_sum(Stone(0, 2))
      + stone_to_sum(Stone(9, 2))
      + stone_to_sum(Stone(6, 2))
    Stone(x, 1) if x <= 9 -> 1
    Stone(x, 2) if x <= 9 -> 1
    Stone(x, 3) if x <= 9 -> 2
    Stone(x, 4) if x <= 9 -> 4
    Stone(x, 5) if x <= 9 -> 8
    Stone(_, _) -> panic
  }
}

fn fast_forward(stone: MagicStone) -> List(MagicStone) {
  case stone {
    Stone(0, b) -> [Stone(1, b - 1)]
    Stone(1, b) -> [
      Stone(2, b - 3),
      Stone(0, b - 3),
      Stone(2, b - 3),
      Stone(4, b - 3),
    ]
    Stone(2, b) -> [
      Stone(4, b - 3),
      Stone(0, b - 3),
      Stone(4, b - 3),
      Stone(8, b - 3),
    ]
    Stone(3, b) -> [
      Stone(6, b - 3),
      Stone(0, b - 3),
      Stone(7, b - 3),
      Stone(2, b - 3),
    ]
    Stone(4, b) -> [
      Stone(8, b - 3),
      Stone(0, b - 3),
      Stone(9, b - 3),
      Stone(6, b - 3),
    ]
    Stone(5, b) -> [
      Stone(2, b - 5),
      Stone(0, b - 5),
      Stone(4, b - 5),
      Stone(8, b - 5),
      Stone(2, b - 5),
      Stone(8, b - 5),
      Stone(8, b - 5),
      Stone(0, b - 5),
    ]
    Stone(6, b) -> [
      Stone(2, b - 5),
      Stone(4, b - 5),
      Stone(5, b - 5),
      Stone(7, b - 5),
      Stone(9, b - 5),
      Stone(4, b - 5),
      Stone(5, b - 5),
      Stone(6, b - 5),
    ]
    Stone(7, b) -> [
      Stone(2, b - 5),
      Stone(8, b - 5),
      Stone(6, b - 5),
      Stone(7, b - 5),
      Stone(6, b - 5),
      Stone(0, b - 5),
      Stone(3, b - 5),
      Stone(2, b - 5),
    ]
    Stone(8, b) -> [
      Stone(3, b - 5),
      Stone(2, b - 5),
      Stone(7, b - 5),
      Stone(7, b - 5),
      Stone(2, b - 5),
      Stone(6, b - 5),
      Stone(8, b - 4),
    ]
    Stone(9, b) -> [
      Stone(3, b - 5),
      Stone(6, b - 5),
      Stone(8, b - 5),
      Stone(6, b - 5),
      Stone(9, b - 5),
      Stone(1, b - 5),
      Stone(8, b - 5),
      Stone(4, b - 5),
    ]
    _ -> panic
  }
}

fn get_magic_stones(
  stones: List(Int),
  blinks: Int,
  magic_stones: List(MagicStone),
) -> #(Int, List(MagicStone)) {
  let new_magic_stones =
    list.filter(stones, fn(stone) { stone <= 9 })
    |> list.map(fn(stone) { Stone(stone, blinks) })

  let magic_stones = list.flatten([new_magic_stones, magic_stones])

  let new_stones =
    stones
    |> list.filter(fn(stone) { stone > 9 })
    |> list.map(fn(stone) { shift(stone) })
    |> list.flatten

  // io.debug(blinks)

  case new_stones {
    [] -> #(0, magic_stones)
    _ ->
      case blinks {
        1 -> {
          #(list.length(new_stones), magic_stones)
        }
        _ -> get_magic_stones(new_stones, blinks - 1, magic_stones)
      }
  }
}

fn get_stones(input: String) -> List(Int) {
  input
  |> string.split(" ")
  |> list.map(fn(s) {
    let assert Ok(stone) = int.parse(s)
    stone
  })
}

fn blink(stones: List(Int), blinks: Int) -> List(Int) {
  let new_stones =
    stones
    |> list.map(fn(stone) { shift(stone) })
    |> list.flatten

  // io.debug(new_stones)

  case blinks {
    1 -> new_stones
    _ -> blink(new_stones, blinks - 1)
  }
}

fn shift(stone: Int) -> List(Int) {
  case stone {
    0 -> [1]
    _ -> {
      let assert Ok(digits) = int.digits(stone, 10)
      case int.is_even(list.length(digits)) {
        True -> split(stone)
        False -> [stone * 2024]
      }
    }
  }
}

fn split(stone: Int) -> List(Int) {
  let assert Ok(digits) = int.digits(stone, 10)
  let #(left, right) = list.split(digits, list.length(digits) / 2)
  let assert Ok(left_stone) = int.undigits(left, 10)
  let assert Ok(right_stone) = int.undigits(right, 10)
  [left_stone, right_stone]
}
