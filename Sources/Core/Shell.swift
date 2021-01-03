//
//  Shell.swift
//  
//
//  Created by Marino Felipe on 27.12.20.
//

import Foundation

public struct Shell {
    public typealias Succeeded = Bool

    public static func run(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        arguments: String...,
        verbose: Bool,
        completion: ((Succeeded) -> Void)?
    ) {
        runProcess(
            launchPath: launchPath,
            workingDirectory: workingDirectory,
            arguments: arguments,
            verbose: verbose,
            completion: completion
        )
    }

    public static func run(
        _ command: String,
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        verbose: Bool,
        completion: ((Succeeded) -> Void)?
    ) {
        let commands = command.split(whereSeparator: \.isWhitespace)

        let arguments: [String]
        if commands.count > 1 {
            arguments = commands.map { String($0) }
        } else {
            arguments = command
                .split { [" -", " --"].contains(String($0)) }
                .map { String($0) }
        }

        runProcess(
            launchPath: launchPath,
            workingDirectory: workingDirectory,
            arguments: arguments,
            verbose: verbose,
            completion: completion
        )
    }
}

// MARK: - Private

private extension Shell {
    static func runProcess(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        errorPipe: Pipe = .init(),
        arguments: [String],
        verbose: Bool,
        completion: ((Succeeded) -> Void)?
    ) {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardError = errorPipe

        if verbose == false {
            process.standardOutput = nil
        }

        if let workingDirectory = workingDirectory {
            process.currentDirectoryPath = workingDirectory
        }

        if verbose {
            let errorHandler = errorPipe.fileHandleForReading
            errorHandler.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty == false {
                    String(data: data, encoding: .utf8).map {
                        Console.default.lineBreakAndWrite(
                            .init(
                                text: $0,
                                color: .red
                            )
                        )
                    }
                } else {
                    errorHandler.readabilityHandler = nil
                }
            }

            Console.default.lineBreakAndWrite(
                .init(
                    text: "Running Shell command",
                    color: .yellow
                )
            )
        }

        process.launch()
        process.terminationHandler = { _ in
            if verbose {
                Console.default.lineBreakAndWrite(
                    .init(
                        text: "Finished Shell command",
                        color: .yellow
                    )
                )
            }
            completion?(process.terminationStatus == 0)
        }
    }
}
