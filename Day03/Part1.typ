#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers
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
		let (rng, (width, height)) = integers(rng, low: 10, high: 20, size: 2)
		let result = ""
		let digit = 0
		for i in range(height) {
			for j in range(width) {
				(rng, digit) = integers(rng, low:0, high:10)
				result += str(digit)
			}
			result += "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Process Input

#let batteries = ()

#for line in input.split("\n") {
	if line == "" {
		continue
	}
	let row = ()
	for char in line {
		row.push(int(char))
	}
	batteries.push(row)
}

Batteries: #drawlist(..batteries)

= Find Best Pair in each Row

#let bestTens = ()
#let bestUnits = ()
#let bestVals = ()

#for line in batteries {
	let tensVal = calc.max(..line.slice(0, -1))
	let tensIndex = line.position(x => x == tensVal)
	let unitsVal = calc.max(..line.slice(tensIndex+1))
	let unitsIndex = tensIndex + line.slice(tensIndex+1).position(x => x == unitsVal)
	bestTens.push(tensIndex)
	bestUnits.push(unitsIndex)
	bestVals.push(tensVal * 10 + unitsVal)
}

#drawlist(bestVals)

= Total Result

#bestVals.sum()