//
//  HTMLAttributorTests.swift
//  HTMLAttributorTests
//
//  Created by Michael on 8/9/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import XCTest
@testable import HTMLAttributor

class HTMLAttributorTests: XCTestCase {

  var parser: HTMLAttributor!

  override func setUp() {
    super.setUp()
    let attr = [NSForegroundColorAttributeName: UIColor.lightTextColor()]
    parser = HTMLAttributor(attributes: attr)
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    parser = nil
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }

}
