import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 12!")

  // let filepath = "./src/days/day12.test"
  let filepath = "./src/days/day12.input"

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

type Plot {
  Plot(x: Int, y: Int, crop: String)
}

type PlotData {
  PlotData(x: Int, y: Int, crop: String, region: Int, fences: Int)
}

type Map {
  Map(map: List(List(Plot)), max_x: Int, max_y: Int)
}

fn solve_part_2(input: String) -> Int {
  let map = make_map(input)

  map.map
  |> list.flatten
  |> map_regions(map, [], 0)
  |> list.group(fn(plot) { plot.region })
  |> dict.to_list
  |> list.fold(0, fn(cost, region) {
    let #(_, region_plots) = region
    cost + get_bulk_region_cost(region_plots, map)
  })
}

fn get_bulk_region_cost(region: List(PlotData), map: Map) -> Int {
  let sides = get_sides(region, map)
  let area = list.length(region)

  area * sides
}

fn get_sides(region: List(PlotData), map: Map) -> Int {
  region
  |> list.fold(0, fn(corners, plot) { corners + count_corners(plot, map) })
}

fn count_corners(plot: PlotData, map: Map) -> Int {
  let north = get_plot(plot.x, plot.y - 1, map)
  let south = get_plot(plot.x, plot.y + 1, map)
  let east = get_plot(plot.x + 1, plot.y, map)
  let west = get_plot(plot.x - 1, plot.y, map)
  let northeast = get_plot(plot.x + 1, plot.y - 1, map)
  let southeast = get_plot(plot.x + 1, plot.y + 1, map)
  let northwest = get_plot(plot.x - 1, plot.y - 1, map)
  let southwest = get_plot(plot.x - 1, plot.y + 1, map)

  let assert [
    north,
    south,
    east,
    west,
    northeast,
    northwest,
    southeast,
    southwest,
  ] =
    [north, south, east, west, northeast, northwest, southeast, southwest]
    |> list.map(fn(neighbor) { neighbor.crop == plot.crop })

  [
    north && east && !northeast,
    !north && !east,
    north && west && !northwest,
    !north && !west,
    south && east && !southeast,
    !south && !east,
    south && west && !southwest,
    !south && !west,
  ]
  |> list.filter(fn(combo) { combo })
  |> list.length
}

fn solve_part_1(input: String) -> Int {
  let map = make_map(input)

  map.map
  |> list.flatten
  |> map_regions(map, [], 0)
  |> list.group(fn(plot) { plot.region })
  |> dict.to_list
  |> list.fold(0, fn(cost, region) {
    let #(_, region_plots) = region
    cost + get_region_cost(region_plots)
  })
}

fn get_region_cost(region: List(PlotData)) -> Int {
  let perimeter =
    region
    |> list.fold(0, fn(total, plot) { total + plot.fences })

  let area = list.length(region)

  area * perimeter
}

fn map_regions(
  plots: List(Plot),
  map: Map,
  mapped_plots: List(PlotData),
  region: Int,
) -> List(PlotData) {
  case plots {
    [plot, ..rest] -> {
      let mapped_plots = map_region([plot], map, mapped_plots, region)
      map_regions(rest, map, mapped_plots, region + 1)
    }
    [] -> mapped_plots
  }
}

fn map_region(
  plots: List(Plot),
  map: Map,
  mapped_plots: List(PlotData),
  region: Int,
) -> List(PlotData) {
  case plots {
    [plot, ..rest] -> {
      let mapped =
        mapped_plots
        |> list.find(fn(plotdata) {
          plotdata.x == plot.x && plotdata.y == plot.y
        })

      case mapped {
        Ok(_) -> map_region(rest, map, mapped_plots, region)
        Error(_) -> {
          let #(mapped_plots, plots_to_map) =
            map_plot(plot, map, mapped_plots, region)
          let plots_to_map = list.flatten([plots_to_map, rest])

          map_region(plots_to_map, map, mapped_plots, region)
        }
      }
    }
    [] -> mapped_plots
  }
}

fn map_plot(
  plot: Plot,
  map: Map,
  region_plots: List(PlotData),
  region: Int,
) -> #(List(PlotData), List(Plot)) {
  let north = get_plot(plot.x, plot.y - 1, map)
  let south = get_plot(plot.x, plot.y + 1, map)
  let east = get_plot(plot.x + 1, plot.y, map)
  let west = get_plot(plot.x - 1, plot.y, map)

  let neighbors = [north, south, east, west]
  // io.debug(neighbors)

  let fences =
    neighbors
    |> list.filter(fn(neighbor) { neighbor.crop != plot.crop })
    |> list.length

  let region_plots = [
    PlotData(plot.x, plot.y, plot.crop, region, fences),
    ..region_plots
  ]

  let neighbors_to_plot =
    neighbors
    |> list.filter(fn(neighbor) { neighbor.crop == plot.crop })
    |> list.filter(fn(neighbor) {
      let mapped =
        region_plots
        |> list.find(fn(plotdata) {
          plotdata.x == neighbor.x && plotdata.y == neighbor.y
        })

      case mapped {
        Ok(_) -> False
        Error(_) -> True
      }
    })

  // io.debug(neighbors_to_plot)

  #(region_plots, neighbors_to_plot)
}

fn make_map(input: String) -> Map {
  let lines = string.split(input, "\n")
  let assert [line, ..] = lines

  let max_y = list.length(lines) - 1
  let max_x = string.length(line) - 1

  let map =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(crop: String, x) { Plot(x, y, crop) })
    })

  Map(map, max_x, max_y)
}

fn get_plot(x: Int, y: Int, map: Map) -> Plot {
  case x, y {
    a, b if a < 0 || a > map.max_x || b < 0 || b > map.max_y ->
      Plot(a, b, "Out of Bounds")
    _, _ -> {
      let #(_, bottom) = list.split(map.map, y)
      let assert [y_row, ..] = bottom

      let #(_, right) = list.split(y_row, x)
      let assert [plot, ..] = right

      plot
    }
  }
}
