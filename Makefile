.PHONY: build app run clean

build:
	swift build -c release

app: build
	bash scripts/package-app.sh

run: app
	open ".build/Day.Lit.app"

clean:
	rm -rf .build
