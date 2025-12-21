#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers, choice

#let input = {
	let hasData = sys.inputs.keys().contains("data")
	let doRandom = sys.inputs.keys().contains("random")

	if hasData and doRandom {
		panic("Cannot use both random data and provided data at the same time")
	} else if hasData {
		sys.inputs.at("data")
	} else if doRandom {
		let seed = int(sys.inputs.at("random"))
		let rng = gen-rng(seed)
		let (rng, (width, height)) = integers(rng, low: 10, high: 20, size: 2)
		let (rng, start) = integers(rng, low: 0, high: width)
		let result = "." * start + "S" + "." * (width - start - 1)
		let char = ""
		for i in range(height - 1) {
			result += "\n"
			char = ""
			for j in range(width) {
				if char == "^" {
					char = "."
				} else {
					(rng, char) = choice(rng, ("^", ".", "."))
				}
				result += char
			}
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Data

#let grid = input.split("\n").map(line => line.codepoints())

#let width = grid.at(0).len()
#let height = grid.len()

#table(
	columns: (15cm / width,) * width,
	rows: (15cm / width,) * height,
	fill: (x, y) => {
		if grid.at(y).at(x) == "." {
			none
		} else if grid.at(y).at(x) == "S" {
			green
		} else if grid.at(y).at(x) == "^" {
			black
		} else {
			panic("Unexpected character")
		}
	},
	stroke: gray,
)

= Shoot Lasers

#let paths = ((0,) * width,)*height

#for y in range(height) {
	for x in range(width) {
		if grid.at(y).at(x) == "S" {
			paths.at(y).at(x) = 1
		}
		if grid.at(y).at(x) == "^" {
			if x != 0 {
				paths.at(y).at(x - 1) += paths.at(y - 1).at(x)
			}
			if x != width - 1 {
				paths.at(y).at(x + 1) += paths.at(y - 1).at(x)
			}
		} else {
			paths.at(y).at(x) += paths.at(y - 1).at(x)
		}
	}
}

#let rowmax = paths.map(row => calc.max(..row))

#table(
	columns: (15cm / width,) * width,
	rows: (15cm / width,) * height,
	fill: (x, y) => {
		if grid.at(y).at(x) == "." {
			if rowmax.at(y) == 0 {
				none
			} else {
				red.transparentize((1 - paths.at(y).at(x) / rowmax.at(y)) * 100%)
			}
		} else if grid.at(y).at(x) == "S" {
			green
		} else if grid.at(y).at(x) == "^" {
			black
		} else {
			panic("Unexpected character")
		}
	},
	stroke: gray,
)

= Total Paths on Last Layer

#paths.at(height - 1).sum()