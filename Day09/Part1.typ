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
		let (rng, (width, height)) = integers(rng, low:10, high:20, size:2)
		let x = 0
		let y = 0
		let result = ""
		let (rng, num_reds) = integers(rng, low: int((width * height) / 10), high: int((width * height) / 5))
		for i in range(num_reds) {
			(rng, x) = integers(rng, low: 0, high: width)
			(rng, y) = integers(rng, low: 0, high: height)
			result += str(x) + "," + str(y) + "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Input

#let points = ()

#for line in input.split("\n") {
	if line == "" { continue }
	let (x, y) = line.split(",")
	points.push((int(x), int(y)))
}

#canvas({
	plot.plot(
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: auto,
		x-label: none,
		y-label: none,
		{
			plot.add(points, style:(stroke:none), mark: "o")
		}
	)
})

= Find Largest Rectange

#let best-i = points.at(0)
#let best-j = points.at(0)
#let best-a = 1

#for i in points {
	for j in points {
		let a = (i.at(0) - j.at(0) + 1) * (i.at(1) - j.at(1) + 1)
		if a > best-a {
			best-i = i
			best-j = j
			best-a = a
		}
	}
}

#canvas({
	import draw: content
	plot.plot(
		name: "plot",
		size: (15, 5),
		x-tick-step: auto,
		y-tick-step: auto,
		x-label: none,
		y-label: none,
		{
			plot.add(points, style:(stroke:none), mark: "o")
			plot.add((best-i, (best-i.at(0), best-j.at(1)), best-j, (best-j.at(0), best-i.at(1)), best-i))
			plot.add-anchor("a", ((best-i.at(0) + best-j.at(0))/2, (best-i.at(1) + best-j.at(1))/2))
		}
	)
	content("plot.a", $#best-a$)
})