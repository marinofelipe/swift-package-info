//
//  ProgressAnimationMock.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import TSCUtility

public final class ProgressAnimationMock: ProgressAnimationProtocol {
    public private(set) var updateCallsCount: Int = 0
    public private(set) var completeCallsCount: Int = 0
    public private(set) var clearCallsCount: Int = 0
    public private(set) var lastUpdateStep: Int?
    public private(set) var lastUpdateTotal: Int?
    public private(set) var lastUpdateText: String?
    public private(set) var lastCompleteSuccess: Bool?

    public init() { }

    public func update(
        step: Int,
        total: Int,
        text: String
    ) {
        updateCallsCount += 1
        lastUpdateStep = step
        lastUpdateTotal = total
        lastUpdateText = text
    }

    public func complete(success: Bool) {
        completeCallsCount += 1
        lastCompleteSuccess = success
    }

    public func clear() {
        clearCallsCount += 1
    }
}
