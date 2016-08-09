project=HTMLAttributor.xcodeproj
scheme=HTMLAttributor
sdk=iphonesimulator

all: clean build

clean:
	-rm -rf build

build:
	xcodebuild build -configuration Debug

test:
	xcodebuild test -configuration Debug -scheme $(scheme) -destination 'platform=iOS Simulator,name=iPhone 6s'

.PHONY: all clean test
