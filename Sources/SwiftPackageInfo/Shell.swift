//
//  Shell.swift
//  
//
//  Created by Marino Felipe on 27.12.20.
//

import Foundation

struct Shell {
    @discardableResult
    static func run(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        output: Pipe = .init(),
        arguments: String...
    ) -> Int32 {
        runProcess(
            launchPath: launchPath,
            workingDirectory: workingDirectory,
            output: output,
            arguments: arguments
        )
    }

    @discardableResult
    static func run(
        _ command: String,
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        output: Pipe = .init()
    ) -> Int32 {
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
            output: output,
            arguments: arguments
        )
    }

    private static func runProcess(
        launchPath: String = "/usr/bin/env",
        workingDirectory: String? = FileManager.default.currentDirectoryPath,
        output: Pipe = .init(),
        arguments: [String]
    ) -> Int32 {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        process.standardOutput = output

        if let workingDirectory = workingDirectory {
            process.currentDirectoryPath = workingDirectory
        }

        process.launch()
        process.waitUntilExit()

        return process.terminationStatus
    }
}
