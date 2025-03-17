//  Copyright (c) 2025 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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

    @discardableResult
    func onSuccess(_ action: (Success) throws -> Void) rethrows -> Result<Success, Failure> {
        guard case let .success(value) = self else { return self }
        try action(value)
        return self
    }

    @discardableResult
    func onFailure(_ action: (Failure) throws -> Void) rethrows -> Result<Success, Failure> {
        guard case let .failure(error) = self else { return self }
        try action(error)
        return self
    }
}
