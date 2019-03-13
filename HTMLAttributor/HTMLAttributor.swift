//
//  HTMLAttributor.Swift
//  HTMLAttributor
//
//  Created by Michael on 8/9/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import Foundation
import UIKit

func allNodes(_ root: Node) -> [Node] {
  return root.children.reduce([root]) { acc, node in
    acc + allNodes(node)
  }
}

func candidate(_ root: Node, node: Node) -> Node {
  func fallback() -> Node {
    let nodes = allNodes(root)
    let p = parent(node, nodes: nodes)

    return candidate(root, node: p)
  }

  switch node.type {
  case .element(let data):
    if data.tagName == "br" {
      return fallback()
    }
  case .text:
    return fallback()
  }
  return node
}

func parent(_ node: Node, nodes: [Node]) -> Node {
  assert(!nodes.isEmpty, "no candidates")

  let parents = nodes.filter {
    $0.children.contains { $0 == node }
  }

  assert(!parents.isEmpty, "\(node.uid) is an orphan")
  assert(parents.count == 1, "multiple parents")
  
  let p = parents.first!
  
  switch p.type {
  case.element(let data):
    assert(data.tagName != "br", "invalid parent: br")
  case .text:
    fatalError("invalid parent: text node")
  }
  
  return p
}

private func NSRange(from range: Range<String.Index>, within string: String)
  -> NSRange {
    let utf16view = string.utf16
    let from = range.lowerBound.samePosition(in: utf16view)!
    let to = range.upperBound.samePosition(in: utf16view)!

    let loc = utf16view.distance(from: utf16view.startIndex, to: from)
    let len = utf16view.distance(from: from, to: to)
    
    return NSMakeRange(loc, len)
}

private extension CharacterSet {

  static let noSpacesAfter = CharacterSet(charactersIn: "“(")
    .union(.whitespacesAndNewlines)

  static let noSpacesBefore = CharacterSet.punctuationCharacters
    .subtracting(CharacterSet(charactersIn: "-–&"))

  static let ignored = CharacterSet.whitespacesAndNewlines
    .union(.controlCharacters)
    .union(.illegalCharacters)
}

private extension String {

  func beginsWith(range: CharacterSet) -> Bool {
    return prefix(1).rangeOfCharacter(from: range) != nil
  }

  func endsWith(range: CharacterSet) -> Bool {
    return suffix(1).rangeOfCharacter(from: range) != nil
  }

  func sanitized() -> String {
    return self.trimmingCharacters(in: .ignored)
      .components(separatedBy: .controlCharacters)
      .joined()
  }

}

public final class HTMLAttributor {
  
  private var delegate: ParserDelegate!
  
  public init() {}
  
  private struct TaggedRange {
    let tag: String
    let attributes: [String : String]?
    let range: NSRange
  }
  
  private struct StringOptions: OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let bracketLinks = StringOptions(rawValue: 1)
  }
  
  private func taggedString(
    _ tree: Node,
    opts: StringOptions = StringOptions()
  ) throws -> (String, [TaggedRange]) {
    let nodes = allNodes(tree)
    
    var ranges = [TaggedRange]()
    
    let result = nodes.reduce("") { acc, node in
      switch node.type {
      case .element(let data):
        
        // Prepending
        
        switch data.tagName {
        case "a":
          guard !acc.isEmpty, !acc.endsWith(range: .noSpacesAfter) else {
            return acc
          }
          return "\(acc) "
          
        case "br":
          // Limiting empty lines to one.
          if acc.isEmpty || acc.hasSuffix("\n\n") {
            return acc
          }
          return "\(acc)\n"
          
        case "p", "ul", "ol", "h1", "h2", "h3", "h4", "h5", "h6":
          if acc.isEmpty || acc.hasSuffix("\n\n") {
            return acc
          }
          return "\(acc)\n\n"
          
        default: return acc
        }
      case .text(let text):

        // Appending

        let trimmed = text.sanitized()

        let prefix: String = {
          if !acc.isEmpty, !acc.endsWith(range: .newlines),
            trimmed.count > 1,
            trimmed.endsWith(range: CharacterSet(charactersIn: ")")) {
            return " "
          }

          guard
            !acc.isEmpty,
            !acc.endsWith(range: .noSpacesAfter),
            !trimmed.beginsWith(range: .noSpacesBefore)
           else {
            return ""
          }

          return " "
        }()
        
        let p = parent(node, nodes: nodes)
        
        var tag: String?
        var attributes: [String : String]?
        
        let suffix: String = {
          guard node.uid != nodes.count else {
            return ""
          }
          
          switch p.type {
          case .element(let data):
            tag = data.tagName
            attributes = data.attributes
            switch data.tagName {
            case "a":
              if opts.contains(.bracketLinks) {
                if let href = attributes!["href"] {
                  return " (\(href))"
                }
              }
              return ""

            case "p", "ul", "ol", "h1", "h2", "h3", "h4", "h5", "h6":
              guard node == p.children.last, !trimmed.isEmpty else {
                return ""
              }
              return "\n\n"

            case "li":
              return "\n"

            default: return ""
            }
          default:
            return ""
          }
        }()
      
        let str = "\(acc)\(prefix)\(trimmed)\(suffix)"
        
        if let t = tag {
          let r = acc.endIndex ..< str.endIndex
          let nsr = NSRange(from: r, within: str)
          let tr = TaggedRange(tag: t, attributes: attributes, range: nsr)

          ranges.append(tr)
        }
        
        return str
      }
    }
    
    return (result, ranges)
  }
  
  public static let defaultStyles: [String: [NSAttributedString.Key : Any]] = [
    "root": [
      NSAttributedString.Key.font: UIFont.preferredFont(
        forTextStyle: UIFont.TextStyle.body),
      NSAttributedString.Key.foregroundColor: UIColor.darkText
    ],
    "h1": [
      NSAttributedString.Key.font: UIFont.preferredFont(
        forTextStyle: UIFont.TextStyle.headline),
      NSAttributedString.Key.foregroundColor: UIColor.darkText
    ],
    "a": [
      NSAttributedString.Key.font: UIFont.preferredFont(
        forTextStyle: UIFont.TextStyle.body),
      NSAttributedString.Key.foregroundColor: UIColor.blue
    ]
  ]
  
}

// MARK: - HTMLParsing

extension HTMLAttributor: HTMLParsing {
  
  /// Parses `html` into a node tree.
  public func parse(_ html: String) throws -> Node {
    delegate = ParserDelegate()
    
    // Always adding a root node to ensure somewhat valid XML.
    let str = "<root>\(html)</root>"
    let data = str.data(using: String.Encoding.utf8)!
    
    let parser = XMLParser(data: data)
    parser.shouldProcessNamespaces = false
    parser.delegate = delegate
    
    guard parser.parse() else {
      throw parser.parserError!
    }
    
    return delegate.root
  }
  
}

// MARK: - NodeTreeTransforming

extension HTMLAttributor: NodeTreeTransforming {
  
  public func attributedString(
    _ tree: Node,
    styles: [String: [NSAttributedString.Key : Any]] = HTMLAttributor.defaultStyles
  ) throws -> NSAttributedString {
    let (str, trs) = try taggedString(tree)
    
    let astr = NSMutableAttributedString(string: str)
    
    // Global attributes must be set first.
    let attrs = styles["root"]!

    astr.setAttributes(attrs, range: NSMakeRange(0, astr.length))
    
    for tr in trs {
      let tag = tr.tag
      
      guard var attrs = styles[tag] else {
        continue
      }

      if tag == "a" {
        guard let href = tr.attributes?["href"],
          let url = URL(string: href) else {
          continue
        }

        attrs[NSAttributedString.Key.link] = url as AnyObject?
      }

      let r = tr.range
      let l = r.location + r.length
      
      assert(l <= astr.length, "out of range: \(l) > \(astr.length)")
      astr.setAttributes(attrs, range: r)
    }
    
    return astr
  }
  
  public func string(_ tree: Node) throws -> String {
    let (str, _) = try taggedString(tree, opts: .bracketLinks)

    return str
  }

}


