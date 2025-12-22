#set page(height: auto)

#import "@preview/suiji:0.5.0": gen-rng, integers
#import "@preview/cetz:0.4.2": canvas, draw

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
		let lines = 1000
		let result = ""
		let number = 0
		for i in range(lines) {
			(rng, number) = integers(rng, low:0, high: 100000)
			result += str(number) + ","
			(rng, number) = integers(rng, low:0, high: 100000)
			result += str(number) + ","
			(rng, number) = integers(rng, low:0, high: 100000)
			result += str(number) + "\n"
		}
		result
	} else {
		panic("No data specified, use `--input random=\"0\"` or `--input data=\"...\" to specify input data")
	}
}

= Parse Data

#let points = ()

#for line in input.split("\n") {
	if line == "" { continue }
	let (x,y,z) = line.split(",")
	points.push((int(x), int(y), int(z)))
}

#let scale-point((x,y,z)) = (x/10000, y/10000, z/10000)

#canvas({
	import draw: line, content, circle, ortho

	ortho(y: -30deg, x:30deg, {
		line((0,0,0), (10,0,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,10,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,0,10), mark: (end:"stealth", fill: black))
		content((10.5,0,0), $x$)
		content((0, 10.5, 0), $y$)
		content((0, 0, 10.5), $z$)
		for p in points {
			circle(scale-point(p), radius: 0.02, fill: blue, stroke: blue)
		}
	})
})

= Find 1000 Closest Pairs

#let pairs = ()

#for i in range(points.len()) {
	for j in range(i+1, points.len()) {
		pairs.push((i,j))
	}
}

#let distance((x1, y1, z1), (x2, y2, z2)) = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1)

#(pairs = pairs.sorted(key: ((a, b)) => distance(points.at(a), points.at(b))).slice(0, 1000))

#canvas({
	import draw: line, content, circle, ortho

	ortho(y: -30deg, x:30deg, {
		line((0,0,0), (10,0,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,10,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,0,10), mark: (end:"stealth", fill: black))
		content((10.5,0,0), $x$)
		content((0, 10.5, 0), $y$)
		content((0, 0, 10.5), $z$)
		for (x,y,z) in points {
			circle((x/10000, y/10000, z/10000), radius: 0.02, fill: blue, stroke: blue)
		}
		for (a,b) in pairs {
			line(scale-point(points.at(a)), scale-point(points.at(b)), stroke: navy)
		}
	})
})

= Run UnionFind on Pairs

#let uf = (("root", 0),) * points.len()

#let representative(uf, i) = {
	if uf.at(i).at(0) == "root" {
		return (uf, i)
	}
	let (uf, root) = representative(uf, uf.at(i).at(1))
	uf.at(i).at(1) = root
	return (uf, root)
}

#let union(uf, i, j) = {
	let (uf, rooti) = representative(uf, i)
	let (uf, rootj) = representative(uf, j)
	if rooti == rootj {
		return uf
	}
	let ranki = uf.at(rooti).at(1)
	let rankj = uf.at(rootj).at(1)
	if ranki < rankj {
		uf.at(rooti) = ("child", rootj)
	} else if ranki > rankj {
		uf.at(rootj) = ("child", rooti)
	} else {
		uf.at(rooti) = ("child", rootj)
		uf.at(rootj) = ("root", rankj + 1)
	}
	return uf
}

#for (i, j) in pairs {
	uf = union(uf, i, j)
}

#let groups = (:)
#let repr = 0

#for i in range(points.len()) {
	(uf, repr) = representative(uf, i)
	groups.insert(str(repr), groups.at(str(repr), default:()) + (i,))
}

#let phi = (1 + calc.sqrt(5)) / 2

#let nametocolour(name) = color.oklch(70%, 70%, phi * name * 360deg)

#canvas({
	import draw: line, content, circle, ortho

	ortho(y: -30deg, x:30deg, {
		line((0,0,0), (10,0,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,10,0), mark: (end:"stealth", fill: black))
		line((0,0,0), (0,0,10), mark: (end:"stealth", fill: black))
		content((10.5,0,0), $x$)
		content((0, 10.5, 0), $y$)
		content((0, 0, 10.5), $z$)
		for (key, group) in groups.values().enumerate() {
			let color = nametocolour(int(key))
			for i in group {
				circle(scale-point(points.at(i)), radius: 0.02, fill: color, stroke: color)
			}
		}
	})
})

= Find Three Largest Groups

#let sizes = ()

#for (key, group) in groups {
	sizes.push(group.len())
}

#(sizes = sizes.sorted(key: a => 0 - a).slice(0,3))

#sizes

= Product of Largest Sizes

#sizes.product()