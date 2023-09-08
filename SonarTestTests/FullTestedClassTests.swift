//
//  SonarTestTests.swift
//  SonarTestTests
//
//  Created by Darrell Bennington on 9/8/23.
//

import XCTest
@testable import SonarTest

final class FullTestedClassTests: XCTestCase {
    func testAddedItemIsContained() {
        let sut = FullyTestedClass()
        sut.add(7)
        XCTAssertTrue(sut.contains(7))
    }

    func testRemovedItemIsNotContained() {
        let sut = FullyTestedClass()
        sut.add(7)
        sut.remove(7)
        XCTAssertFalse(sut.contains(7))
    }
}
