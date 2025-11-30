.PHONY: all
all: Part1.pdf Part2.pdf

.PHONY: clean
clean:
	rm -f Part1.pdf
	rm -f Part2.pdf

.PHONY: watch
watch:
	typst w Part1.typ & typst w Part2.typ && kill $!

Part1.pdf: Part1.typ input
	typst c Part1.typ

Part2.pdf: Part2.typ input
	typst c Part2.typ


