#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers
#import "@preview/cetz:0.4.2": canvas
#import "@preview/cetz-plot:0.1.3": plot

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
		let (rng, maxIngredient) = integers(rng, low: 100, high: 200)
		let (rng, numRanges) = integers(rng, low: 5, high: 10)
		let startRange = 0
		let lenRange = 0
		let result = ""
		for i in range(numRanges) {
			(rng, startRange) = integers(rng, low: 0, high: maxIngredient)
			(rng, lenRange) = integers(rng, low:0, high: 15)
			result += str(startRange) + "-" + str(startRange + lenRange) + "\n"
		}
		result += "\n"
		let (rng, numAvailable) = integers(rng, low: 100, high: 200)
		let ingredient = 0
		for i in range(numAvailable) {
			(rng, ingredient) = integers(rng, low: 0, high: maxIngredient)
			result += str(ingredient) + "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Data

#let ranges = ()

#let (rangeInput, availableInput) = input.split("\n\n")

#for line in rangeInput.split("\n") {
	let (start, end) = line.split("-")
	ranges.push((start: int(start), end: int(end)))
}

#let available = ()

#for line in availableInput.split("\n") {
	if line == "" { continue }
	available.push(int(line))
}

Ranges

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: none,
		x-label: none,
		y-label: none,
		{
			for (i, r) in ranges.enumerate() {
				plot.add(((r.at("start"), i), (r.at("end") + 0.1, i)), mark:"o", fill: true)
			}
		}
	)
})

Available

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: none,
		x-label: none,
		y-label: none,
		{
			for (i, a) in available.enumerate() {
				plot.add(((a, i),), mark:"o")
			}
		}
	)
})

= Determine Available and Fresh

#let fresh = ()
#let spoiled = ()

#for (i, a) in available.enumerate() {
	let is-fresh = false
	for r in ranges {
		if r.at("start") <= a and a <= r.at("end") {
			is-fresh = true
			break
		}
	}
	if is-fresh {
		fresh.push((a, i))
	} else {
		spoiled.push((a, i))
	}
}

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: none,
		x-label: none,
		y-label: none,
		{
			plot.add(fresh, mark:"o", label: "Fresh", style: (stroke: none))
			plot.add(spoiled, mark: "o", label: "Spoiled", style: (stroke: none))
		}
	)
})

= Total Fresh

#fresh.len()