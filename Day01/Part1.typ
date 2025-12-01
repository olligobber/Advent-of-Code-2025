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

= Process input

#let input = read("input")

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