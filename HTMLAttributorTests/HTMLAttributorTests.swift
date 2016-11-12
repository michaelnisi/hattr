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

  var hattr: HTMLAttributor!

  override func setUp() {
    super.setUp()
    hattr = HTMLAttributor()
  }

  override func tearDown() {
    hattr = nil
    super.tearDown()
  }

  func testString() {
    func f(_ str: String) -> String {
      let tree = try! self.hattr.parse(str)
      return try! self.hattr.string(tree)
    }
    
    // Not a fan of these trailing new lines.
    
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
      let tree = try! self.hattr.parse(str)
      return try! self.hattr.attributedString(tree)
    }
    let wanted = [
      "",
      "Aliens?",
      "Aliens?\n\n",
      "Aliens?\n\nWhy yes.",
      "Aliens?\n\nWhy yes.\nOh noes …",
      "a\nb\nc\n",
      "This is a simple sample.\n\n",
      "This\n\nSucks\n\n"
    ]
    
    let found = [
      f(""),
      f("Aliens?"),
      f("<h1>Aliens?</h1>"),
      f("<h1>Aliens?</h1>Why yes."),
      f("<h1>Aliens?</h1>Why yes.<br/>Oh noes …"),
      f("<ul><li>a</li><li>b</li><li>c</li></ul>"),
      f("<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"),
      f("<h1>This</h1><h1>Sucks</h1>")
    ]
    
    XCTAssertEqual(wanted.count, found.count)
    
    // TODO: Test attributes
    
    for (i, b) in wanted.enumerated() {
      let a = found[i].string
      XCTAssertEqual(a, b)
    }
  }
  
  func testAllNodesCount() {
    func f(_ str: String) -> Int {
      let tree = try! self.hattr.parse(str)
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
  
  // Countering my subsiding motivation to continue writing this software, I
  // compared performance: right now our version is 10X faster.
  
  func testAttributedStringPerformance() {
    self.measure {
      let html = "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"
      let tree = try! self.hattr.parse(html)
      let _ = try! self.hattr.attributedString(tree)
    }
  }
  
  // Measuring Apple's code here for comparison, which takes ages to start its
  // initial run because it has to load a plethora of dependencies first.
  
  func testDataUsingEncodingPerformance() {
    self.measure {
      let html = "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"
      let data = html.data(using: String.Encoding.utf8)!
      let opts: [String: AnyObject] = [
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
        NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject,
      ]
      let _ = try! NSMutableAttributedString(
        data: data,
        options: opts,
        documentAttributes: nil
      )
    }
  }
}
