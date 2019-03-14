# hattr - parse HTML

[![Build Status](https://secure.travis-ci.org/michaelnisi/hattr.svg)](http://travis-ci.org/michaelnisi/hattr)

The **hattr** iOS package provides a naïve HTML parser to efficiently transform HTML into attributed strings.

## Goals

- No dependencies except UIKit
- Offloadable from main thread
- Simple and fast

> 50X faster than `NSAttributedString.init(data:options:documentAttributes:)`

At least 50X less correct.

## Example

```swift
import HTMLAttributor

let hattr = HTMLAttributor()
let tree = try! hattr.parse(html)
let attributedText = try! hattr.attributedString(tree)
```

Find a runnable example in `HTMLPlayground.playground`.

## License

[MIT License](https://raw.github.com/michaelnisi/hattr/master/LICENSE)
