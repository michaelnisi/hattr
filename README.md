[![Build Status](https://secure.travis-ci.org/michaelnisi/hattr.svg)](http://travis-ci.org/michaelnisi/hattr)
[![Coverage Status](https://coveralls.io/repos/github/michaelnisi/hattr/badge.svg?branch=master)](https://coveralls.io/github/michaelnisi/hattr?branch=master)

# hattr - parse HTML

The **hattr** package provides a simple HTML parser to efficiently transform HTML into attributed strings for iOS.

## Goals

- No dependencies, except for UIKit
- Offloadable from main thread
- 😘

## Example

```swift
import HTMLAttributor

// html is an HTML String

let hattr = HTMLAttributor()
let tree = try! hattr.parse(html)
let attributedText = try! hattr.attributedString(tree)
```

Find a runnable example in `HTMLPlayground.playground`.

## License

[MIT License](https://raw.github.com/michaelnisi/hattr/master/LICENSE)
