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

#let list1 = ()
#let list2 = ()

#for line in input.split("\n") {
	if line != "" {
		let (a,b) = line.split()
		list1.push(int(a))
		list2.push(int(b))
	}
}

= Read Input

List 1: #drawlist(list1)

List 2: #drawlist(list2)

#let list1 = list1.sorted()

#let list2 = list2.sorted()

= Sort lists

List 1: #drawlist(list1)

List 2: #drawlist(list2)

= Compute differences

#drawlist(list1, list2)

#let differences = list1.zip(exact: true, list2).map(((a,b)) => calc.abs(a - b))

Differences: #drawlist(differences)

= Total differences

#let accum = (0,)

#for i in differences {
	accum.push(i + accum.last())
}

Accumulated sum:

#drawlist(accum)

Final sum: #accum.last()