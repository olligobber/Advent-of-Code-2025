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
		let (rng, (width, height)) = integers(rng, low: 30, high: 50, size: 2)
		let result = ""
		let char = ""
		for i in range(height) {
			for j in range(width) {
				(rng, char) = choice(rng, ("@", "@", "."))
				result += char
			}
			result += "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Data

#let grid = input.split("\n").filter(s => s != "").map(s => s.clusters())

#let height = grid.len()

#let width = grid.at(0).len()

#let isPaper(x, y) = {
	if x < 0 or y < 0 {
		return false
	}
	return grid.at(y, default: ()).at(x, default: ".") == "@"
}

#table(
	rows: (15cm / width,) * height,
	columns: (15cm / width,) * width,
	fill: (x, y) => {
		if isPaper(x,y) {
			black
		} else {
			white
		}
	},
	stroke: gray,
)

= Check if each is Retrievable

#let neighbours(x, y) = range(-1, 2).map(dx =>
	range(-1, 2).map(dy =>
		if dx == 0 and dy == 0 {
			()
		} else {
			((x + dx, y + dy),)
		}
	).join()
).join()

#let accessible = ()

#for y in range(height) {
	let row = ()
	for x in range(width) {
		if not isPaper(x,y) {
			row.push(false)
			continue
		}
		let paperNeighbours = 0
		for ((a, b)) in neighbours(x,y) {
			if isPaper(a, b) {
				paperNeighbours += 1
			}
		}
		row.push(paperNeighbours < 4)
	}
	accessible.push(row)
}

#table(
	rows: (15cm / width,) * height,
	columns: (15cm / width,) * width,
	fill: (x, y) => {
		if accessible.at(y).at(x) {
			red
		} else if isPaper(x,y) {
			black
		} else {
			white
		}
	},
	stroke: gray,
)

= Count Retrievable

#let total = 0

#for row in accessible {
	for b in row {
		if b { total += 1 }
	}
}

#total