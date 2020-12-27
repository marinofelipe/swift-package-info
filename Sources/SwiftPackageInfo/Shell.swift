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
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = output

        if let workingDirectory = workingDirectory {
            task.currentDirectoryPath = workingDirectory
        }

        task.launch()
        task.waitUntilExit()

        return task.terminationStatus
    }
}
