#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers, choice

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
		let (rng, height) = integers(rng, low: 3, high: 8)
		let (rng, width) = integers(rng, low: 10, high: 20)
		let result = ""
		let number = 0
		for i in range(height) {
			for j in range(width) {
				(rng, number) = integers(rng, low: 1, high: 200)
				result += str(number) + " "
			}
			result += "\n"
		}
		let oper = ""
		for i in range(width) {
			(rng, oper) = choice(rng, ("+", "*"))
			result += oper + " "
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Input

#let (..numberlines, operline) = input.split("\n")

#let opers = operline.split()

#let numbers = opers.map(x => ())

#for line in numberlines {
	for (i, word) in line.split().enumerate() {
		numbers.at(i).push(int(word))
	}
}

#if numbers.len() < 21 {
	table(
		columns: numbers.at(0).len() + 1,
		..(
			range(numbers.len()).map(i => numbers.at(i) + (opers.at(i),)).map(x => x.map(y => $#y$)).join()
		)
	)
} else {
	table(
		columns: numbers.at(0).len() + 1,
		..(
			range(0, 10).map(i => numbers.at(i) + (opers.at(i),)).map(x => x.map(y => $#y$)).join() +
			(($dots.v$,) * (numbers.at(0).len() + 1)) +
			range(-10, -1).map(i => numbers.at(i) + (opers.at(i),)).map(x => x.map(y => $#y$)).join()
		)
	)
}

= Get result of each

#let result = numbers.zip(opers).map(((n, o)) => {
	if o == "+" {
		n.sum()
	} else if o == "*" {
		n.product()
	} else {
		panic("Invalid oper")
	}
})

#if numbers.len() < 21 {
	table(
		columns: numbers.at(0).len() + 3,
		..(
			range(numbers.len()).map(i => numbers.at(i) + (opers.at(i), "=", result.at(i))).map(x => x.map(y => $#y$)).join()
		)
	)
} else {
	table(
		columns: numbers.at(0).len() + 3,
		..(
			range(0, 10).map(i => numbers.at(i) + (opers.at(i), "=", result.at(i))).map(x => x.map(y => $#y$)).join() +
			(($dots.v$,) * (numbers.at(0).len() + 3)) +
			range(-10, -1).map(i => numbers.at(i) + (opers.at(i), "=", result.at(i))).map(x => x.map(y => $#y$)).join()
		)
	)
}

= Total All Results

#result.sum()