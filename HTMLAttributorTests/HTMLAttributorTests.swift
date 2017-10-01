//
//  HTMLAttributorTests.swift
//  HTMLAttributor
//
//  Created by Michael on 8/9/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import XCTest
@testable import HTMLAttributor

class HTMLAttributorTests: XCTestCase {
  
  var html: HTMLAttributor!
  
  override func setUp() {
    super.setUp()
    html = HTMLAttributor()
  }
  
  override func tearDown() {
    html = nil
    super.tearDown()
  }
  
  func testString() {
    func f(_ str: String) -> String {
      let tree = try! self.html.parse(str)
      return try! self.html.string(tree)
    }
    
    let wanted = [
      "",
      "Aliens?",
      "Aliens?\n\n",
      "Aliens?\n\nWhy yes.",
      "Aliens?\n\nWhy yes.\nOh noes …",
      "a\nb\nc\n",
      "This is a simple (demo.html) sample.\n\n",
      "First\n\nSecond\n\n",
      "Root copy followed by\n\nA Headline\n\n"
    ]
    
    let html = [
      "",
      "Aliens?",
      "<h1>Aliens?</h1>",
      "<h1>Aliens?</h1>Why yes.",
      // Note the self-closing '<br/>', NSXMLParser would, not unreasonably,
      // choke on an open '<br>'.
      "<h1>Aliens?</h1>Why yes.<br/>Oh noes …",
      "<ul><li>a</li><li>b</li><li>c</li></ul>",
      "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>",
      "<h1>First</h1><h1>Second</h1>",
      "Root copy followed by<h1>A Headline</h1>"
    ]
    
    XCTAssertEqual(wanted.count, html.count)
    
    for (i, b) in wanted.enumerated() {
      let a = f(html[i])
      XCTAssertEqual(a, b)
    }
  }
  
  func testAttributedString() {
    func f(_ str: String) -> NSAttributedString {
      let tree = try! self.html.parse(str)
      return try! self.html.attributedString(tree)
    }
    
    let wanted = [
      "",
      "Aliens?",
      "Aliens?\n\n",
      "Aliens?\n\nWhy yes.",
      "Aliens?\n\nWhy yes.\nOh noes …",
      "a\nb\nc\n",
      "This is a simple sample.\n\n",
      "This\n\nSucks\n\n",
      "Whitespace?",
      "Whitespace?\n\n"
    ]
    
    let found = [
      f(""),
      f("Aliens?"),
      f("<h1>Aliens?</h1>"),
      f("<h1>Aliens?</h1>Why yes."),
      f("<h1>Aliens?</h1>Why yes.<br/>Oh noes …"),
      f("<ul><li>a</li><li>b</li><li>c</li></ul>"),
      f("<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"),
      f("<h1>This</h1><h1>Sucks</h1>"),
      f("  Whitespace?"),
      f("<h1>  Whitespace?</h1>")
    ]
    
    XCTAssertEqual(wanted.count, found.count)
    
    for (i, b) in wanted.enumerated() {
      let a = found[i].string
      XCTAssertEqual(a, b)
    }
  }
  
  func testAllNodesCount() {
    func f(_ str: String) -> Int {
      let tree = try! self.html.parse(str)
      return allNodes(tree).count
    }
    let tests = [
      (f(""), 1),
      (f("Aliens?"), 2),
      (f("<h1>Aliens?</h1>"), 3),
      (f("<h1>Aliens?</h1>Why yes."), 4),
      (f("<h1>Aliens?</h1>Why yes.<br/>Oh noes …"), 6),
      (f("<ul><li>a</li><li>b</li><li>c</li></ul>"), 8)
    ]
    for t in tests {
      XCTAssertEqual(t.0, t.1)
    }
  }
  
  func testTrimLeft() {
    XCTAssertEqual(trimLeft(""), "")
    XCTAssertEqual(trimLeft(" hello"), "hello")
    XCTAssertEqual(trimLeft("   hello"), "hello")
  }
  
  // Countering my subsiding motivation to proceed, I compared performance:
  // right now our version is 10X faster, generously ignoring initialization.
  
  func testAttributedStringPerformance() {
    self.measure {
      for _ in 0..<10 {
        let html = "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"
        let tree = try! self.html.parse(html)
        let _ = try! self.html.attributedString(tree)
      }
    }
  }
  
  // Measuring Apple's full blown HTML parser for comparison, which takes ages
  // to start its initial run because it has to load a plethora of dependencies
  // first.
  
//  func testDataUsingEncodingPerformance() {
//    self.measure {
//      for _ in 0..<10 {
//        let html = "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"
//        let data = html.data(using: String.Encoding.utf8)!
//
//        let _ = try! NSAttributedString(
//          data: data,
//          options: [
//            .documentType: NSAttributedString.DocumentType.html,
//            .characterEncoding: String.Encoding.utf8.rawValue
//          ],
//          documentAttributes: nil
//        )
//      }
//    }
//  }
}

