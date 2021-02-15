//
//  Shell.swift
//  
//
//  Created by Marino Felipe on 27.12.20.
//

import Foundation

public enum Shell {
    static let pipeReadingQueue = DispatchQueue(label: "Core.Shell.pipeReadingQueue")

    public struct Output: Equatable {
        public let succeeded: Bool
        public let data: Data
        public let errorData: Data
    }

    @discardableResult
    public static func run(
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe = .init(),
        errorPipe: Pipe = .init(),
        arguments: String...,
        verbose: Bool,
        timeout: TimeInterval? = 30
    ) throws -> Output {
        try runProcess(
            workingDirectory: workingDirectory,
            outputPipe: outputPipe,
            errorPipe: errorPipe,
            arguments: arguments,
            verbose: verbose,
            timeout: timeout
        )
    }

    @discardableResult
    public static func run(
        _ command: String,
        outputPipe: Pipe = .init(),
        errorPipe: Pipe = .init(),
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        verbose: Bool,
        timeout: TimeInterval? = 30
    ) throws -> Output {
        let commands = command.split(whereSeparator: \.isWhitespace)

        let arguments: [String]
        if commands.count > 1 {
            arguments = commands.map { String($0) }
        } else {
            arguments = command
                .split { [" -", " --"].contains(String($0)) }
                .map { String($0) }
        }

        return try runProcess(
            workingDirectory: workingDirectory,
            outputPipe: outputPipe,
            errorPipe: errorPipe,
            arguments: arguments,
            verbose: verbose,
            timeout: timeout
        )
    }
}

public extension Shell {
    @discardableResult
    static func performShallowGitClone(
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        repositoryURLString: String,
        branchOrTag: String,
        verbose: Bool,
        timeout: TimeInterval? = 15
    ) throws -> Output {
        try Shell.run(
            "git clone --branch \(branchOrTag) --depth 1 \(repositoryURLString)",
            workingDirectory: workingDirectory,
            verbose: verbose,
            timeout: timeout
        )
    }
}

// MARK: - Private

private extension Shell {
    static func runProcess(
        workingDirectory: String?,
        outputPipe: Pipe,
        errorPipe: Pipe,
        arguments: [String],
        verbose: Bool,
        timeout: TimeInterval?
    ) throws -> Output {
        let process = Process.make(
            workingDirectory: workingDirectory,
            outputPipe: outputPipe,
            errorPipe: errorPipe,
            arguments: arguments,
            verbose: verbose
        )

        if verbose {
            Console.default.lineBreakAndWrite(
                .init(
                    text: "Running Shell command",
                    color: .yellow
                )
            )
        }

        var outputData = Data()
        var errorData = Data()

        readData(
            from: outputPipe,
            isError: false,
            verbose: verbose
        ) { availableData in
            outputData.append(availableData)
        }
        readData(
            from: errorPipe,
            isError: true,
            verbose: verbose
        ) { availableData in
            errorData.append(availableData)
        }

        timeout.map {
            DispatchQueue.main.asyncAfter(deadline: .now() + $0) {
                if process.isRunning { process.terminate() }
            }
        }

        try process.run()
        process.waitUntilExit()

        if verbose {
            Console.default.lineBreakAndWrite(
                .init(
                    text: "Finished Shell command",
                    color: .yellow
                )
            )
        }

        return .init(
            succeeded: process.terminationStatus == 0,
            data: outputData,
            errorData: errorData
        )
    }

    static func readData(
        from pipe: Pipe,
        isError: Bool,
        verbose: Bool,
        availableDataHandler: ((Data) -> Void)?
    ) {
        pipe.fileHandleForReading.readabilityHandler = { fileHandle in
            pipeReadingQueue.async {
                let data = fileHandle.availableData
                if data.isEmpty == false {
                    String(data: data, encoding: .utf8).map {
                        availableDataHandler?(data)
                        guard verbose else { return }

                        if isError {
                            Console.default.lineBreakAndWrite(
                                .init(
                                    text: $0,
                                    color: .red
                                )
                            )
                        } else {
                            Console.default.write(.init(text: $0, hasLineBreakAfter: false))
                        }
                    }
                } else {
                    pipe.fileHandleForReading.readabilityHandler = nil
                }
            }
        }
    }
}

extension Process {
    static func make(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe,
        errorPipe: Pipe,
        arguments: [String],
        verbose: Bool
    ) -> Process {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardError = errorPipe
        process.standardOutput = outputPipe
        if let workingDirectory = workingDirectory {
            process.currentDirectoryPath = workingDirectory
        }
        return process
    }
}
