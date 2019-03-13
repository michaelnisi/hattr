//
//  ParserDelegate.swift
//  HTMLAttributor
//
//  Created by Michael Nisi on 13.03.19.
//  Copyright © 2019 Michael Nisi. All rights reserved.
//

import Foundation

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

final class ParserDelegate: NSObject, XMLParserDelegate {

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

  @objc func parser(
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

  @objc func parser(
    _ parser: XMLParser,
    foundCharacters string: String) {
    text = (text ?? "") + string
  }

  @objc func parser(
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

  @objc func parserDidEndDocument(_ parser: XMLParser) {
    current = nil
    text = nil
  }
}
