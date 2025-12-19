#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers
#import "@preview/cetz:0.4.2": canvas, draw
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
				plot.add(((r.at("start"), i), (r.at("end") + 0.5, i)), mark:"o", fill: true)
			}
		}
	)
})

= Merge Overlapping Ranges

#let merge(r, s) = {
	if r.at("end") < s.at("start") {
		return none
	}
	if s.at("end") < r.at("start") {
		return none
	}
	return (start: calc.min(s.at("start"), r.at("start")), end : calc.max(s.at("end"), r.at("end")))
}

#let merged = ()

#for r in ranges {
	let new-merged = ()
	for s in merged {
		if merge(r, s) == none {
			new-merged.push(s)
		} else {
			r = merge(r, s)
		}
	}
	new-merged.push(r)
	merged = new-merged
}

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: none,
		x-label: none,
		y-label: none,
		{
			for (i, r) in merged.enumerate() {
				plot.add(((r.at("start"), i), (r.at("end") + 0.5, i)), mark:"o", fill: true)
			}
		}
	)
})

= Count Size of each Range

#let sized = ()

#for r in merged {
	sized.push((start: r.at("start"), end: r.at("end"), size: r.at("end") - r.at("start") + 1))
}

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: none,
		x-label: none,
		y-label: none,
		{
			for (i, r) in sized.enumerate() {
				plot.add(((r.at("start"), i), (r.at("end") + 0.5, i)), mark:"o", fill: true)
				plot.annotate({
					draw.content(((r.at("end") + r.at("start"))/2, i), [#r.at("size")])
				})
			}
		}
	)
})

= Total Sizes

#sized.map(x => x.at("size")).sum()