default: check

build:
	@echo "Nothing to build"

check:
	bash test.sh

clean:
	find . -name "*~" -exec rm -vf \{\} \+

.PHONY: default build check clean
