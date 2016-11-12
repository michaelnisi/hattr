P=HTMLAttributor.xcodeproj

XCODEBUILD=xcodebuild

IOS_DEST=-destination 'platform=iOS Simulator,name=iPhone 7'

all: iOS

clean:
	$(XCODEBUILD) clean

test_%:
	$(XCODEBUILD) test -project $(P) -configuration Debug -scheme $(SCHEME) $(DEST)

build_%:
	$(XCODEBUILD) build -project $(P) -configuration Release -scheme $(SCHEME)

%iOS: SCHEME := HTMLAttributor

test_iOS: DEST := $(IOS_DEST)

iOS: build_iOS
check_iOS: test_iOS

test: test_iOS

.PHONY: all, clean, test, %OS
