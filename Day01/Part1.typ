#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers, choice
#import "@preview/cetz:0.4.2": canvas
#import "@preview/cetz-plot:0.1.3": plot

#let drawlist(..lists) = canvas({
	let lists = lists.pos()
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: auto,
		x-label: none,
		y-label: none,
		{
			for list in lists {
				plot.add(list.enumerate())
			}
		}
	)
})

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
		let result = ""
		let (rng, size) = integers(rng, low: 1000, high: 2000)
		let dir
		let amount
		for i in range(size) {
			(rng, dir) = choice(rng, ("R", "L"))
			(rng, amount) = integers(rng, low: 0, high: 1000)
			result += dir + str(amount) + "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Process input

#let inputs = ()

#for line in input.split("\n") {
	if line == "" { continue }
	let dir = line.at(0)
	let amount = int(line.slice(1))
	inputs.push((dir, amount))
}

Input: #inputs

= Compute positions

#let positions = (50,)

#for (dir, amount) in inputs {
	if dir == "L" {
		positions.push(calc.rem-euclid(positions.last() - amount, 100))
	} else if dir == "R" {
		positions.push(calc.rem-euclid(positions.last() + amount, 100))
	} else {
		panic("Invalid direction: " + dir)
	}
}

#drawlist(positions)

= Find Times Position is Zero

#let atzero = ()

#for (i, pos) in positions.enumerate() {
	if pos == 0 {
		atzero.push(i)
	}
}

#atzero

= Count Times Position is Zero

#atzero.len()