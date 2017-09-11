// Reference: https://github.com/Carthage/Carthage/blob/master/Source/carthage/CopyFrameworks.swift

import Foundation
import SwiftShell
import PathKit
import Core

// MARK: - EmbedError

/// Embed error.
///
/// - notFound: the framework to embed hasn't been found.
/// - invalidExtension: the framework path is invalid.
public enum EmbedError: Error, CustomStringConvertible {
    case notFound(path: String)
    case invalidExtension(path: String)
    public var description: String {
        switch self {
        case .notFound(let path):
            return "File not found at path: \(path)"
        case .invalidExtension(let path):
            return "File doesn't have a .framework extension: \(path)"
        }
    }
}

// MARK: - EmbedCommand

public class EmbedCommand {
    
    // MARK: - Attributes
    
    let buildAllConfigs: Bool
    let configsToBuild: [String]
    let xcodeEnvironment: XcodeEnvironment
    let packageCopier: PackageCopying
    
    // MARK: - Init
    
    init(buildAllConfigs: Bool,
         configsToBuild: [String],
         xcodeEnvironment: XcodeEnvironment,
         packageCopier: PackageCopying) {
        self.buildAllConfigs = buildAllConfigs
        self.configsToBuild = configsToBuild
        self.xcodeEnvironment = xcodeEnvironment
        self.packageCopier = packageCopier
    }
    
    public convenience init(buildAllConfigs: Bool,
                            configsToBuild: [String],
                            xcodeEnvironment: XcodeEnvironment) {
        self.init(buildAllConfigs: buildAllConfigs,
                  configsToBuild: configsToBuild,
                  xcodeEnvironment: xcodeEnvironment,
                  packageCopier: PackageCopier())
    }

    // MARK: - Public
    
    public func execute() throws {
        if !configsToBuild.contains(xcodeEnvironment.configuration) && !buildAllConfigs {
            print("Warning: Not embedding frameworks because the following configuration is being built: \(xcodeEnvironment.configuration)")
        }
        try self.xcodeEnvironment.inputsAndOutputs.forEach(self.embed)
    }
    
    private func embed(input: String, output: String) throws {
        let inputPath = Path(input)
        let outputPath = Path(output)
        if inputPath.extension != "framework" || outputPath.extension != "framework" {
            throw EmbedError.invalidExtension(path: input)
        }
        if !inputPath.exists {
            throw EmbedError.notFound(path: input)
        }
        let inputPackage = Package(path: inputPath)
        if inputPackage.architectures().filter({ xcodeEnvironment.validArchs.contains($0) }).count == 0 {
            print("Warning: Ignoring \(inputPath.lastComponent) because it does not support the current architecture")
        }
        let inputDsymPath = Path(inputPath.string + ".dSYM")
        let outputDsymPath = outputPath + inputDsymPath.lastComponent
        
        // Frameworks
        try outputPath.parent().mkpath()
        try inputPath.copy(outputPath)
        try Package(path: outputPath).strip(keepingArchitectures: xcodeEnvironment.validArchs)
        
        // Symbols
        try outputDsymPath.parent().mkpath()
        try inputDsymPath.copy(outputDsymPath)
        try Package(path: outputDsymPath).strip(keepingArchitectures: xcodeEnvironment.validArchs)

        // BCSymbolMap
        if xcodeEnvironment.action == .install {
            try package.bcSymbolMapsForFramework()
                .forEach{ (bcInputPath) in
                    let bcOputputPath = Path(xcodeEnvironment.builtProductsDir) + bcInputPath.lastComponent
                    if !bcOputputPath.parent().exists { try bcOputputPath.parent().mkpath() }
                    try bcInputPath.copy(bcOputputPath)
            }
        }
    }
    
}
