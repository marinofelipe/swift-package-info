//
//  Shell.swift
//  
//
//  Created by Marino Felipe on 27.12.20.
//

import Foundation

struct Shell {
    struct Output: Equatable, CustomStringConvertible {
        let succeeded: Bool
        let outputText: String?
        let errorText: String?

        var description: String {
            if succeeded {
                return """
                    Command did run SUCCESSFULLY!
                    -----------------------------
                    OUTPUT: \(outputText ?? "")
                """
            } else {
                return """
                    FAILED to run command
                    -----------------------------
                    OUTPUT: \(outputText ?? "")
                    -----------------------------
                    ERROR: \(errorText ?? "")
                """
            }
        }
    }

    @discardableResult
    static func run(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        outputPipe: Pipe = .init(),
        arguments: String...
    ) -> Output {
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
    ) -> Output {
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
    ) -> Output {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        if let workingDirectory = workingDirectory {
            process.currentDirectoryPath = workingDirectory
        }

        Printer.print("Running process...")

        process.launch()
        process.waitUntilExit()

        let semaphore = DispatchSemaphore(value: 0)

        let completionHandler: (Process) -> Output = { process in
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let outputText = String(data: outputData, encoding: .utf8)?
                .trimmingCharacters(in: .newlines)

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorText = String(data: errorData, encoding: .utf8)?
                .trimmingCharacters(in: .newlines)

            return .init(
                succeeded: process.terminationStatus == 0,
                outputText: outputText,
                errorText: errorText
            )
        }

        process.terminationHandler = { _ in
            semaphore.signal()
        }

        semaphore.wait()

        Printer.print("Running finished...")

        return completionHandler(process)
    }
}
