//
//  NodeTreeTransforming.swift
//  HTMLAttributor
//
//  Created by Michael Nisi on 13.03.19.
//  Copyright © 2019 Michael Nisi. All rights reserved.
//

import Foundation

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

extension Node: Equatable {
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.uid == rhs.uid
  }
}

extension Node: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uid)
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
    styles: [String : [NSAttributedString.Key : Any]]
  ) throws -> NSAttributedString
  
}

