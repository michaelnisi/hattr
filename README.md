[![Build Status](https://secure.travis-ci.org/michaelnisi/hattr.svg)](http://travis-ci.org/michaelnisi/hattr)
[![Code Coverage](https://codecov.io/github/michaelnisi/hattr/coverage.svg?branch=master)](https://codecov.io/github/michaelnisi/hattr?branch=master)

# hattr - parse HTML

The **hattr** package provides a simple HTML parser to efficiently transform HTML into attributed strings for iOS.

## Goals

- No dependencies, except for UIKit
- Offloadable from main thread
- Keeping it simple, stupid

## Example

```swift
import HTMLAttributor

// html is a string of HTML

let hattr = HTMLAttributor()
let tree = try! hattr.parse(html)
let attributedText = try! hattr.attributedString(tree)
```

Find a runnable example in `HTMLPlayground.playground`.

## License

[MIT License](https://raw.github.com/michaelnisi/hattr/master/LICENSE)
