//
//  Shell.swift
//  
//
//  Created by Marino Felipe on 27.12.20.
//

import Foundation

struct Shell {
    typealias Succeeded = Bool

    @discardableResult
    static func run(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe = .init(),
        arguments: String...
    ) -> Succeeded {
        runProcess(
            launchPath: launchPath,
            workingDirectory: workingDirectory,
            outputPipe: outputPipe,
            arguments: arguments
        )
    }

    @discardableResult
    static func run(
        _ command: String,
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe = .init()
    ) -> Succeeded {
        let commands = command.split(whereSeparator: \.isWhitespace)

        let arguments: [String]
        if commands.count > 1 {
            arguments = commands.map { String($0) }
        } else {
            arguments = command
                .split { [" -", " --"].contains(String($0)) }
                .map { String($0) }
        }

        return runProcess(
            launchPath: launchPath,
            workingDirectory: workingDirectory,
            outputPipe: outputPipe,
            arguments: arguments
        )
    }

    private static func runProcess(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe = .init(),
        errorPipe: Pipe = .init(),
        arguments: [String]
    ) -> Succeeded {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        if let workingDirectory = workingDirectory {
            process.currentDirectoryPath = workingDirectory
        }

        let semaphore = DispatchSemaphore(value: 0)

        let outputHandler = outputPipe.fileHandleForReading

        outputHandler.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty == false {
                String(data: data, encoding: .utf8).map { Console.default.write($0, addLineBreakAfter: false) }
            } else {
                outputHandler.readabilityHandler = nil
            }
        }

        let errorHandler = errorPipe.fileHandleForReading

        errorHandler.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty == false {
                String(data: data, encoding: .utf8).map {
                    Console.default.lineBreakAndWrite(
                        $0,
                        color: .red
                    )
                }
            } else {
                errorHandler.readabilityHandler = nil
            }
        }

        Console.default.lineBreakAndWrite(
            "Running Shell command",
            color: .yellow
        )

        process.launch()
        process.waitUntilExit()
        process.terminationHandler = { _ in
            semaphore.signal()
        }

        semaphore.wait()

        Console.default.lineBreakAndWrite(
            "Finished Shell command",
            color: .yellow
        )

        return process.terminationStatus == 0
    }
}
