//
//  PartiallyTestedClassTests.swift
//  SonarTestTests
//
//  Created by Darrell Bennington on 9/11/23.
//

import XCTest
@testable import SonarTest

final class PartiallyTestedClassTests: XCTestCase {
    func testAddedItemIsContained() {
        let sut = PartiallyTestedClass()
        sut.add(7)
        XCTAssertTrue(sut.contains(7))
    }
}
