//
//  HTMLAttributor.Swift
//  HTMLAttributor
//
//  Created by Michael on 8/9/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import Foundation
import UIKit

public struct ElementData {
  let tagName: String
  let attributes: [String : String]
}

public enum NodeType {
  case text(String)
  case element(ElementData)
}

public final class Node {
  var children: [Node]
  let type: NodeType
  let uid: Int
  
  init(uid: Int, type: NodeType, children: [Node] = [Node]()) {
    self.uid = uid
    self.type = type
    self.children = children
  }
  
  func append(_ node: Node) {
    children.append(node)
  }
}

extension Node: CustomStringConvertible {
  public var description: String {
    get {
      func desc() -> String {
        switch type {
        case .element(let data):
          return "\(uid): \(data.tagName)"
        case .text(let text):
          return "\(uid): \(text)"
        }
      }
      return children.reduce(desc()) { acc, child in
        "\(acc) \(child.description)"
      }
    }
  }
}

public func ==(lhs: Node, rhs: Node) -> Bool {
  return lhs.uid == rhs.uid
}

extension Node: Hashable {
  public var hashValue: Int {
    return uid
  }
}

public protocol HTMLParsing {
  func parse(_ html: String) throws -> Node
}

public protocol NodeTreeTransforming {
  
  /// An, admittedly rather limited, string representation of the tree—good
  /// enough for developing and debugging.
  ///
  /// - Parameter tree: A tree of DOM nodes.
  /// - Throws: May throw `NSXMLParser` errors.
  ///
  /// - Returns: A simplified string representation of the tree.
  func string(_ tree: Node) throws -> String
  
  /// Creates and returns an attributed string from the provided tree.
  ///
  /// It should be obvious, but please note: **this can never be a proper HTML
  /// interpreter**, the attributes are set redundantly by tag name, without
  /// any optimizations—*the last one wins*.
  ///
  /// - Parameters:
  ///   - tree: The tree to use as a source for the attributed string.
  ///   - styles: A dictionary of styles, dictionaries of attributes
  /// identified by tag names, to be set on the resulting attributed string.
  /// Without styles `HTMLAttributor.defaultStyles` are used.
  ///
  /// - Throws: May throws `NSXMLParser` errors.
  ///
  /// - Returns: An attributed Cocoa string.
  func attributedString(
    _ tree: Node,
    styles: [String : [NSAttributedStringKey : Any]]
  ) throws -> NSAttributedString
}

// MARK: - Internals

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

private final class ParserDelegate: NSObject, XMLParserDelegate {
  
  // MARK: State
  
  // The root node of our document.
  var root: Node!
  
  // The current node in the tree while parsing.
  private var current: Node!
  
  // A count of the encountered nodes.
  private var count: Int = 0
  
  func uid() -> Int {
    count += 1
    return count
  }
  
  // MARK: API
  
  // Container to accumulate strings for text nodes. Should be set to `nil`
  // after all its content has been consumed.
  var text: String?
  
  @discardableResult private func consumeText() -> Bool {
    guard let t = text else {
      return false
    }
    let textNode = Node(uid: uid(), type: .text(t))
    let p = candidate(root, node: current)
    p.append(textNode)
    text = nil
    return true
  }
  
  // MARK: NSXMLParserDelegate
  
  @objc fileprivate func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String : String]) {
    let data = ElementData(tagName: elementName, attributes: attributeDict)
    let node = Node(uid: uid(), type: .element(data))
    
    if elementName == "root" {
      root = node
    } else {
      assert(root != nil, "root cannot be nil")
      
      // When a new element starts, we have to make sure we have consumed all
      // previously accumulated text and begin a new string.
      consumeText()
      
      let p = candidate(root, node: current)
      p.append(node)
    }
    
    current = node
  }
  
  @objc fileprivate func parser(
    _ parser: XMLParser,
    foundCharacters string: String) {
    text = (text ?? "") + string
  }
  
  @objc fileprivate func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?) {
    assert(root != nil, "root cannot be nil")
    
    consumeText()
    
    guard elementName != "root" else {
      return
    }
    
    let nodes = allNodes(root)
    let p = parent(current, nodes: nodes)
    current = p
  }
  
  @objc fileprivate func parserDidEndDocument(_ parser: XMLParser) {
    current = nil
    text = nil
  }
}

func NSRange(from range: Range<String.Index>, within string: String)
  -> NSRange {
  let utf16view = string.utf16
  let from = range.lowerBound.samePosition(in: utf16view)!
  let to = range.upperBound.samePosition(in: utf16view)!
  
  let loc = utf16view.distance(from: utf16view.startIndex, to: from)
  let len = utf16view.distance(from: from, to: to)
  return NSMakeRange(loc, len)
}

func trimLeft(_ string: String) -> String {
  if string.hasPrefix(" ") {
    let str = String(string.dropFirst())
    return trimLeft(str)
  }
  return string
}

func beginsWithPunctuation(string: String) -> Bool {
  guard let first = string.first else {
    return false
  }
  let str = String(first)
  return str.rangeOfCharacter(from: .punctuationCharacters) != nil
}

func endsWithPunctuation(string: String) -> Bool {
  guard let last = string.last else {
    return false
  }
  let str = String(last)
  return str.rangeOfCharacter(from: .punctuationCharacters) != nil
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
          guard !acc.isEmpty, !acc.hasSuffix("\n"), !acc.hasSuffix(" ") else {
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
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefix: String = {
          guard
            !acc.isEmpty,
            !acc.hasSuffix(" "),
            !acc.hasSuffix("\n"),
            !beginsWithPunctuation(string: trimmed) else {
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
              if node == p.children.last {
                return "\n\n"
              }
              return ""
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
  
  public static let defaultStyles: [String: [NSAttributedStringKey : Any]] = [
    "root": [
      NSAttributedStringKey.font: UIFont.preferredFont(
        forTextStyle: UIFontTextStyle.body),
      NSAttributedStringKey.foregroundColor: UIColor.darkText
    ],
    "h1": [
      NSAttributedStringKey.font: UIFont.preferredFont(
        forTextStyle: UIFontTextStyle.headline),
      NSAttributedStringKey.foregroundColor: UIColor.darkText
    ],
    "a": [
      NSAttributedStringKey.font: UIFont.preferredFont(
        forTextStyle: UIFontTextStyle.body),
      NSAttributedStringKey.foregroundColor: UIColor.blue
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
    styles: [String: [NSAttributedStringKey : Any]] = HTMLAttributor.defaultStyles
  ) throws -> NSAttributedString {
    let (str, trs) = try taggedString(tree)
    
    let astr = NSMutableAttributedString(string: str)
    
    // Global attributes must be set first.
    
    let attrs = HTMLAttributor.defaultStyles["root"]!
    astr.setAttributes(attrs, range: NSMakeRange(0, astr.length))
    
    for tr in trs {
      let tag = tr.tag
      guard var attrs = styles[tag] else {
        continue
      }
      if tag == "a" {
        if let href = tr.attributes?["href"] {
          if let url = URL(string: href) {
            attrs[NSAttributedStringKey.link] = url as AnyObject?
          }
        }
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


