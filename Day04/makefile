.PHONY: all
all: real sample

.PHONY: real
real: Part1Real.pdf Part2Real.pdf

.PHONY: sample
sample: Part1Sample.pdf Part2Sample.pdf

.PHONY: clean
clean:
	rm -f Part1Real.pdf
	rm -f Part1Sample.pdf
	rm -f Part2Real.pdf
	rm -f Part2Sample.pdf

.PHONY: watch
watch:
	trap 'kill 0' SIGINT; \
	\
	typst w Part1.typ Part1Real.pdf --input data="$$(cat input)" & \
	typst w Part2.typ Part2Real.pdf --input data="$$(cat input)" & \
	typst w Part1.typ Part1Sample.pdf --input random="0" & \
	typst w Part2.typ Part2Sample.pdf --input random="0" & \
	wait

.PHONY: watch-real
watch-real:
	trap 'kill 0' SIGINT; \
	\
	typst w Part1.typ Part1Real.pdf --input data="$$(cat input)" & \
	typst w Part2.typ Part2Real.pdf --input data="$$(cat input)" & \
	wait

.PHONY: watch-sample
watch-sample:
	trap 'kill 0' SIGINT; \
	\
	typst w Part1.typ Part1Sample.pdf --input random="0" & \
	typst w Part2.typ Part2Sample.pdf --input random="0" & \
	wait

Part1Real.pdf: Part1.typ input
	typst c Part1.typ Part1Real.pdf --input data="$$(cat input)"

Part2Real.pdf: Part2.typ input
	typst c Part2.typ Part2Real.pdf --input data="$$(cat input)"

Part1Sample.pdf: Part1.typ
	typst c Part1.typ Part1Sample.pdf --input random="0"

Part2Sample.pdf: Part2.typ
	typst c Part2.typ Part2Sample.pdf --input random="0"

