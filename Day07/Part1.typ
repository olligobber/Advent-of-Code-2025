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

#let splits = 0

#for y in range(1, height) {
	for x in range(width) {
		if grid.at(y - 1).at(x) != "S" and grid.at(y - 1).at(x) != "|" {
			continue
		}
		if grid.at(y).at(x) == "^" {
			splits += 1
			if x != 0 {
				grid.at(y).at(x - 1) = "|"
			}
			if x != width - 1 {
				grid.at(y).at(x + 1) = "|"
			}
		} else {
			grid.at(y).at(x) = "|"
		}
	}
}

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
		} else if grid.at(y).at(x) == "|" {
			red
		} else {
			panic("Unexpected character")
		}
	},
	stroke: gray,
)

Total Splits: #splits