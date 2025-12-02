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

= Process input

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

#let inputs = ()

#for line in input.split("\n") {
	if line == "" { continue }
	let dir = line.at(0)
	let amount = int(line.slice(1))
	inputs.push((dir, amount))
}

Input: #inputs

= Compute relative changes

#let changes = inputs.map(((dir, amount)) => {
	if dir == "L" {
		-amount
	} else if dir == "R" {
		amount
	} else {
		panic("Invalid direction: " + dir)
	}
})

#drawlist(changes)

= Compute Crossings of Zero

#let positions = (50,)
#let crossings = (0,)

#for change in changes {
	let div = calc.div-euclid(positions.last() + change, 100)
	let rem = calc.rem-euclid(positions.last() + change, 100)

	let count = 0

	if positions.last() + change == 0 {
		count += 1
	}

	if div > 0 {
		count += div
	}

	if div < 0 {
		count += -div

		if positions.last() == 0 {
			count -= 1
		}

		if rem == 0 {
			count += 1
		}
	}

	crossings.push(count)
	positions.push(rem)
}

List of positions:
#drawlist(positions)

List of crossings:
#drawlist(crossings)

= Total crossings and landings

Total is #crossings.sum()