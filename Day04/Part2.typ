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

#let isPaper(grid, x, y) = {
	if x < 0 or y < 0 {
		return false
	}
	return grid.at(y, default: ()).at(x, default: ".") == "@"
}

#table(
	rows: (15cm / width,) * height,
	columns: (15cm / width,) * width,
	fill: (x, y) => {
		if isPaper(grid, x,y) {
			black
		} else {
			white
		}
	},
	stroke: gray,
)

= Repeatedly Remove Retrievable

#let neighbours(x, y) = range(-1, 2).map(dx =>
	range(-1, 2).map(dy =>
		if dx == 0 and dy == 0 {
			()
		} else {
			((x + dx, y + dy),)
		}
	).join()
).join()

#let removed = 0

#let to-explore = ()

#for x in range(width) {
	for y in range(height) {
		if isPaper(grid, x, y) {
			to-explore.push((x,y))
		}
	}
}

#for i in range(9 * width * height) {
	if to-explore.len() == 0 {
		break
	}
	let (x,y) = to-explore.pop()
	if not isPaper(grid,x,y) {
		continue
	}
	let paperNeighbours = ()
	for ((a, b)) in neighbours(x,y) {
		if isPaper(grid, a, b) {
			paperNeighbours.push((a,b))
		}
	}
	if paperNeighbours.len() < 4 {
		to-explore += paperNeighbours
		removed += 1
		grid.at(y).at(x) = "."
	}
}

#table(
	rows: (15cm / width,) * height,
	columns: (15cm / width,) * width,
	fill: (x, y) => {
		if isPaper(grid, x,y) {
			black
		} else {
			white
		}
	},
	stroke: gray,
)

= Finished

#removed removed in total.