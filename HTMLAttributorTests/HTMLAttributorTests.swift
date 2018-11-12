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

  func string(_ str: String) -> String {
    let tree = try! self.html.parse(str)
    return try! self.html.string(tree)
  }

  func testHTMLEntities() {
    let wanted = [
      """
      Puromac es una conversación sobre todo el mundo de Apple entre dos viejos amigos, uno que originalmente era un fanático de Windows, y el otro que es un entusiasta de Apple de toda la vida. Cada episodio es una mezcla de consejos, trucos, recomendaciones de aplicaciones, noticias y análisis.</br>(<i>Puromac is a conversation about all things Apple between two old friends, one who was originally a die-hard Windows user, and the other a lifelong Apple enthusiast.</i>) Hosted by Federico Hatoum & Flavio Guinsburg.
      """,
      """
      Puromac es una conversación sobre todo el mundo de Apple entre dos viejos amigos, uno que originalmente era un fanático de Windows, y el otro que es un entusiasta de Apple de toda la vida. Cada episodio es una mezcla de consejos, trucos, recomendaciones de aplicaciones, noticias y análisis.
      (Puromac is a conversation about all things Apple between two old friends, one who was originally a die-hard Windows user, and the other a lifelong Apple enthusiast.) Hosted by Federico Hatoum & Flavio Guinsburg.
      """
    ]

    let html = [
      """
      Puromac es una conversación sobre todo el mundo de Apple entre dos viejos amigos, uno que originalmente era un fanático de Windows, y el otro que es un entusiasta de Apple de toda la vida. Cada episodio es una mezcla de consejos, trucos, recomendaciones de aplicaciones, noticias y análisis.&lt;/br&gt;
      (&lt;i&gt;Puromac is a conversation about all things Apple between two old friends, one who was originally a die-hard Windows user, and the other a lifelong Apple enthusiast.&lt;/i&gt;) Hosted by Federico Hatoum &amp; Flavio Guinsburg.
      """,
      """
      Puromac es una conversación sobre todo el mundo de Apple entre dos viejos amigos, uno que originalmente era un fanático de Windows, y el otro que es un entusiasta de Apple de toda la vida. Cada episodio es una mezcla de consejos, trucos, recomendaciones de aplicaciones, noticias y análisis.<br /> (Puromac is a conversation about all things Apple between two old friends, one who was originally a die-hard Windows user, and the other a lifelong Apple enthusiast.) Hosted by Federico Hatoum &amp; Flavio Guinsburg.
      """
    ]

    XCTAssertEqual(wanted.count, html.count)

    for (i, b) in wanted.enumerated() {
      let a = string(html[i])
      XCTAssertEqual(a, b)
    }
  }

  func testEnding() {
    let wanted = [
      "abc"
    ]

    let html = [
      "<p>abc</p>"
    ]

    XCTAssertEqual(wanted.count, html.count)

    for (i, b) in wanted.enumerated() {
      let a = string(html[i])
      XCTAssertEqual(a, b)
    }
  }

  func testWhitespaces() {
    let wanted = [
      "abc",
      "abc"
    ]

    let html = [
      "   abc   ",
      """

        abc
      """
    ]

    XCTAssertEqual(wanted.count, html.count)

    for (i, b) in wanted.enumerated() {
      let a = string(html[i])
      XCTAssertEqual(a, b)
    }
  }

  func testSpaces() {
    let wanted = [
//      "Twitter: @SlateRepresent",
//      "Ending a sentence with a link.",
//      "And “link”",
//      "link (after)",
//      "(link)",
//      "A - link - for you",
//      "Ein – link – für dich",
//      "Aktuell zu den Midterms ;)\nUS-Midterm",
      "(link & link)"
    ]

    let html = [
//      "Twitter:<a> @SlateRepresent</a>",
//      "Ending a sentence with a <a>link</a>.",
//      "And “<a>link</a>”",
//      "<a>link</a> (after)",
//      "(<a>link</a>)",
//      "A - <a>link</a> - for you",
//      "Ein – <a>link</a> – für dich",
//      "Aktuell zu den Midterms ;)<br />US-Midterm \r\n\r\n \t",
      "(<a>link</a> &amp; <a>link</a> )"
    ]

    XCTAssertEqual(html.count, wanted.count)

    for (i, b) in wanted.enumerated() {
      let a = string(html[i])
      XCTAssertEqual(a, b)
    }
  }

  func testString() {
    let wanted = [
      "",
      "Aliens?",
      "Aliens?",
      "Aliens?\n\nWhy yes.",
      "Aliens?\n\nWhy yes.\nOh noes …",
      "a\nb\nc",
      "This is a simple (demo.html) sample.",
      "First\n\nSecond",
      "Root copy followed by\n\nA Headline",
      "Ripley"
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
      "Root copy followed by<h1>A Headline</h1>",
      "<p> </p>\n<p>Ripley</p>"
    ]

    XCTAssertEqual(wanted.count, html.count)

    for (i, b) in wanted.enumerated() {
      let a = string(html[i])
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
      "Aliens?",
      "Aliens?\n\nWhy yes.",
      "Aliens?\n\nWhy yes.\nOh noes …",
      "a\nb\nc",
      "This is a simple sample.",
      "This\n\nSucks",
      "Whitespace?",
      "Whitespace?"
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

  func testInvalidURL() {
    let bundle = Bundle.init(for: classForCoder)
    let url = bundle.url(forResource: "missingLink", withExtension: "html")!
    let data = try! Data(contentsOf: url)
    let str = String(data: data, encoding: .utf8)!

    let tree = try! self.html.parse(str)
    let attrStr = try! self.html.attributedString(tree)
    let all =  NSMakeRange(0, attrStr.length)

    var found = [URL]()

    attrStr.enumerateAttribute(.link, in: all) { attr, range, ref in
      guard let url = attr as? URL else {
        return
      }
      found.append(url)
    }

    XCTAssertEqual(found.count, 7)
  }

  // Countering my subsiding motivation to proceed, I compared performance:
  // NSAttributedString.DocumentType.html is 50X slower.

//  func testAttributedStringPerformance() {
//    self.measure {
//      for _ in 0..<10 {
//        let html = "<p>This is a <a href=\"demo.html\">simple</a> sample.</p>"
//        let tree = try! self.html.parse(html)
//        let _ = try! self.html.attributedString(tree)
//      }
//    }
//  }

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

