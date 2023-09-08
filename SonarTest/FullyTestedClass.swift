//
//  FullyTestedClass.swift
//  SonarTest
//
//  Created by Darrell Bennington on 9/8/23.
//

import Foundation

public class FullyTestedClass {
    var backing = Set<Int>()

    public func add(_ value: Int) {
        backing.insert(value)
    }

    public func remove(_ value: Int) {
        backing.remove(value)
    }

    public func contains(_ value: Int) -> Bool {
        return backing.contains(value)
    }
}
