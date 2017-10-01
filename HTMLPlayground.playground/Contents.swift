//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import HTMLAttributor

struct Strings: Codable {
  let strings: [String]
}

let url = Bundle.main.url(forResource: "strings", withExtension: "json")!
let json = try! Data(contentsOf: url)
let decoder = JSONDecoder()
let strings = try! decoder.decode(Strings.self, from: json).strings

let html = HTMLAttributor()
let str = strings.first!
let tree = try! html.parse(str)
let a = try! html.attributedString(tree)

let data = str.data(using: .utf8)!
let b = try! NSAttributedString(data: data,
  options: [
    .documentType: NSAttributedString.DocumentType.html,
    .characterEncoding: String.Encoding.utf8.rawValue,
  ], documentAttributes: nil
)

let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 640, height: 1136))
PlaygroundPage.current.liveView = textView
textView.attributedText = a
