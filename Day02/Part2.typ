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
		let (rng, size) = integers(rng, low: 100, high: 200)
		let low = 0
		let d = 0
		let result = ""
		for i in range(size) {
			(rng, low) = integers(rng, low: 0, high: 1000000)
			(rng, d) = integers(rng, low: 1, high: 100000)
			result += str(low) + "-" + str(low + d) + ","
		}
		result.slice(0, -1)
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Process input

#let intervals = ()

#for word in input.trim().split(",") {
	let (start, end) = word.split("-")
	intervals.push((int(start), int(end)))
}

Start values: #drawlist(intervals.map(((s, e)) => s))

End values: #drawlist(intervals.map(((s, e)) => e))

Size of interval: #drawlist(intervals.map(((s, e)) => e - s))

= Filter invalid

#let isInvalid(number) = {
	let string = str(number)
	let n = string.len()
	for d in range(1, int(calc.pow(n, 1/2)) + 1) {
		if calc.rem(n, d) != 0 {
			continue
		}
		let e = calc.quo(n, d)

		let slice = string.slice(0, d)
		for i in range(1, e) {
			if string.slice(i * d, (i + 1) * d) != slice {
				break
			}
			if i == e - 1 {
				return true
			}
		}

		let slice = string.slice(0, e)
		for i in range(1, d) {
			if string.slice(i * e, (i + 1) * e) != slice {
				break
			}
			if i == d - 1 {
				return true
			}
		}
	}
	return false
}

#let invalid = ()

#for (s,e) in intervals {
	for i in range(s, e+1) {
		if isInvalid(i) {
			invalid.push(i)
		}
	}
}

List of invalid: #drawlist(invalid)

= Sum invalid

Sum of invalid: #invalid.sum()