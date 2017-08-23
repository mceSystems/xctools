// Reference: https://github.com/Carthage/Carthage/blob/master/Source/carthage/CopyFrameworks.swift

import Foundation
import SwiftShell
import PathKit

public struct EmbedCommand {

    // MARK: - Attributes
    
    let buildAllConfigs: Bool
    let configsToBuild: [String]
    let xcodeEnvironment: XcodeEnvironment
    
    func execute() throws {
        if !configsToBuild.contains(xcodeEnvironment.configuration) && !buildAllConfigs {
            print("Warning: Not embedding frameworks because the following configuration is being built: \(xcodeEnvironment.configuration)")
        }
        try self.xcodeEnvironment.inputsAndOutputs.forEach(self.execute)
    }
    
    private func execute(input: String, output: String) throws {
        let inputPath = Path(input)
        let outputPath = Path(output)
        if (!inputPath.exists) {
            throw EmbedError.notFound(path: input)
        }
        if (inputPath.extension != "framework") {
            throw EmbedError.invalidExtension(path: input)
        }
        if architectures(framework: inputPath).filter({ xcodeEnvironment.validArchs.contains($0) }).count == 0 {
            print("Warning: Ignoring \(inputPath.lastComponent) because it does not support the current architecture")
        }
//        try embed(inputPath: inputPath, outputPath: outputPath)
//        try copyDsyms(inputPath: inputPath)
    }
    
    // MARK: - Private
    
    private func architectures(framework: Path) -> [String] {
        return []
    }
    
}
