//
//  HTMLAttributor.swift
//  HTMLAttributor
//
//  Created by Michael on 8/9/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import Foundation

// MARK: API

protocol HTMLParser {
  func parse(html: String) throws -> NSAttributedString
}

// MARK: -

// TODO: Write HTML parser

private final class ParserDelegate: NSObject, NSXMLParserDelegate {
  @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
    print(parseError)
  }
  
  @objc func parser(
    parser: NSXMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String : String]
  ) {
    print(elementName)
  }
  
  var attributedString = NSMutableAttributedString(string: "Oi!")
}

public class HTMLAttributor: HTMLParser {
  private let attributes: [String: AnyObject]
  
  init(attributes: [String: AnyObject]) {
    self.attributes = attributes
  }
  
  func parse(html: String) throws -> NSAttributedString {
    let data = html.dataUsingEncoding(NSUTF8StringEncoding)!
    let parser = NSXMLParser(data: data)
    
    parser.shouldProcessNamespaces = false
    let delegate = ParserDelegate()
    parser.delegate = delegate
    
    guard parser.parse() else { throw parser.parserError! }
    return delegate.attributedString
  }
}
