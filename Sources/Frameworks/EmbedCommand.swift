// Reference: https://github.com/Carthage/Carthage/blob/master/Source/carthage/CopyFrameworks.swift

import Foundation
import SwiftShell
import PathKit
import Core

public class EmbedCommand {
    
    // MARK: - Attributes
    
    let buildAllConfigs: Bool
    let configsToBuild: [String]
    let xcodeEnvironment: XcodeEnvironment
    let symbolsCopier: SymbolsCopying
    
    // MARK: - Init
    
    init(buildAllConfigs: Bool,
         configsToBuild: [String],
         xcodeEnvironment: XcodeEnvironment,
         symbolsCopier: SymbolsCopying) {
        self.buildAllConfigs = buildAllConfigs
        self.configsToBuild = configsToBuild
        self.xcodeEnvironment = xcodeEnvironment
        self.symbolsCopier = symbolsCopier
    }
    
    public convenience init(buildAllConfigs: Bool,
                            configsToBuild: [String],
                            xcodeEnvironment: XcodeEnvironment) {
        self.init(buildAllConfigs: buildAllConfigs,
                  configsToBuild: configsToBuild,
                  xcodeEnvironment: xcodeEnvironment,
                  symbolsCopier: SymbolsCopier())
    }
    
    
    // MARK: - Public
    
    public func execute() throws {
        if !configsToBuild.contains(xcodeEnvironment.configuration) && !buildAllConfigs {
            print("Warning: Not embedding frameworks because the following configuration is being built: \(xcodeEnvironment.configuration)")
        }
        try self.xcodeEnvironment.inputsAndOutputs.forEach(self.execute)
    }
    
    private func execute(input: String, output: String) throws {
        let inputPath = Path(input)
        let outputPath = Path(output)
        if inputPath.extension != "framework" || outputPath.extension != "framework" {
            throw EmbedError.invalidExtension(path: input)
        }
        if !inputPath.exists {
            throw EmbedError.notFound(path: input)
        }
        if architectures(framework: inputPath).filter({ xcodeEnvironment.validArchs.contains($0) }).count == 0 {
            print("Warning: Ignoring \(inputPath.lastComponent) because it does not support the current architecture")
        }
        //        try embed(inputPath: inputPath, outputPath: outputPath)
        try symbolsCopier.copyDsyms(inputPath: inputPath, destinationPath: outputPath.parent())
    }
    
    // MARK: - Private
    
    private func architectures(framework: Path) -> [String] {
        return []
    }
    
}
