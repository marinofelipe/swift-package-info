//
//  Result+Core.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

public extension Result {
    var value: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }

    @discardableResult
    func onSuccess(_ action: (Success) -> Void) -> Result<Success, Failure> {
        guard case let .success(value) = self else { return self }
        action(value)
        return self
    }

    @discardableResult
    func onFailure(_ action: (Failure) -> Void) -> Result<Success, Failure> {
        guard case let .failure(error) = self else { return self }
        action(error)
        return self
    }
}

