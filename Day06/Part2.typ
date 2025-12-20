#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers, choice

#let pad-left(string, size) = {
	return " " * (size - string.len()) + string
}

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
				result += pad-left(str(number), 3) + " "
			}
			result += "\n"
		}
		let oper = ""
		for i in range(width) {
			(rng, oper) = choice(rng, ("+", "*"))
			result += oper + "   "
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Input

#let lines = input.split("\n").map(l => l.codepoints())

#let height = lines.len()
#let width = lines.at(0).len()

#let cols = ((),) * width

#for i in range(width) {
	for j in range(height) {
		cols.at(i).push(lines.at(j).at(i, default: " "))
	}
}

#let blocks = ()
#let cur_oper = ""
#let numbers = ()

#for col in cols {
	let (..digits, oper) = col
	if oper != " " {
		if cur_oper != "" {
			blocks.push((f: cur_oper, x: numbers))
		}
		cur_oper = oper
		numbers = ()
	}
	let actual_digits = digits.filter(c => c != " ").join(default: "")
	if actual_digits == "" {
		continue
	}
	numbers.push(int(actual_digits))
}

#if cur_oper != "" {
	blocks.push((f: cur_oper, x: numbers))
}

#let show-block(block) = {
	block.at("x").intersperse(block.at("f")).map(x => $#x$).join()
}

#if blocks.len() < 21 {
	blocks.map(show-block).intersperse([\ ]).join()
} else [
	#blocks.slice(0,10).map(show-block).intersperse([\ ]).join()

	$dots.v$

	#blocks.slice(-10).map(show-block).intersperse([\ ]).join()
]

= Evaluate Each

#let result = blocks.map(block => {
	if block.at("f") == "+" {
		block.at("x").sum()
	} else if block.at("f") == "*" {
		block.at("x").product()
	} else {
		panic("Invalid oper")
	}
})

#if blocks.len() < 21 {
	blocks.zip(result).map(((block, r)) => $#show-block(block) = #r$).intersperse([\ ]).join()
} else [
	#blocks.zip(result).slice(0,10).map(((block, r)) => $#show-block(block) = #r$).intersperse([\ ]).join()

	$dots.v$

	#blocks.zip(result).slice(-10).map(((block, r)) => $#show-block(block) = #r$).intersperse([\ ]).join()
]

= Total Results

#result.sum()