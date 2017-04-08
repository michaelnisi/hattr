[![Build Status](https://secure.travis-ci.org/michaelnisi/hattr.svg)](http://travis-ci.org/michaelnisi/hattr)
[![Code Coverage](https://codecov.io/github/michaelnisi/hattr/coverage.svg?branch=master)](https://codecov.io/github/michaelnisi/hattr?branch=master)

# hattr - parse HTML

The **hattr** package provides a simple HTML parser to efficiently transform HTML into attributed strings.

## Goals

- No dependencies
- Offloadable from main thread
- Keeping it simple

## Example

```swift
import HTMLAttributor

// html is a string of HTML

let html = HTMLAttributor()
let tree = try! html.parse(html)
let attributedText = try! html.attributedString(tree)
```

Find a runnable example in `HTMLPlayground.playground`.

## License

[MIT License](https://raw.github.com/michaelnisi/hattr/master/LICENSE)
