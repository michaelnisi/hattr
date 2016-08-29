# HTMLAttributor - parse HTML

This framework provides a simple HTML parser to efficiently transform HTML snippets into attributed strings.

## Goals

- No dependencies
- Offloadable from main thread
- Keeping it simple

## Example

```swift
import HTMLAttributor

// html is a string of HTML

let worker = HTMLAttributor()
let tree = try! worker.parse(html)
let text = try! worker.attributedString(tree)
```

Find a runnable example in `HTMLPlayground.playground`.

## License

[MIT License](https://raw.github.com/michaelnisi/hattr/master/LICENSE)
