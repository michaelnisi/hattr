//
//  ParserDelegate.swift
//  HTMLAttributor
//
//  Created by Michael Nisi on 13.03.19.
//  Copyright © 2019 Michael Nisi. All rights reserved.
//

import Foundation

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
