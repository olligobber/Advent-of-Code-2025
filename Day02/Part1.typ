#set page(height: auto)

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

#let input = read("input")

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
	let n = calc.quo(string.len(),2)
	if string.len() != 2 * n {
		return false
	}
	return string.slice(0, n) == string.slice(n, 2*n)
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