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
    let configuration: String
    let inputsAndOutputs: [(input: String, output: String)]
    let validArchs: [String]
    let action: Action
    let builtProductsDir: String
    
    // MARK: - Init
    
    public init(buildAllConfigs: Bool,
                configsToBuild: [String],
                configuration: String,
                inputsAndOutputs: [(input: String, output: String)],
                validArchs: [String],
                action: Action,
                builtProductsDir: String) {
        self.buildAllConfigs = buildAllConfigs
        self.configsToBuild = configsToBuild
        self.configuration = configuration
        self.inputsAndOutputs = inputsAndOutputs
        self.validArchs = validArchs
        self.action = action
        self.builtProductsDir = builtProductsDir
    }
    
    // MARK: - Public
    
    public func execute() throws {
        if !configsToBuild.contains(configuration) && !buildAllConfigs {
            print("Warning: Not embedding frameworks because the following configuration is being built: \(configuration)")
        }
        try inputsAndOutputs.forEach(self.embed)
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
        if inputPackage.architectures().filter({ validArchs.contains($0) }).count == 0 {
            print("Warning: Ignoring \(inputPath.lastComponent) because it does not support the current architecture")
        }
        let inputDsymPath = Path(inputPath.string + ".dSYM")
        let outputDsymPath = outputPath.parent() + inputDsymPath.lastComponent
        
        // Frameworks
        if !outputPath.parent().exists {
            try outputPath.parent().mkpath()
        }
        if outputPath.exists {
            try outputPath.delete()
        }
        try inputPath.copy(outputPath)
        try Package(path: outputPath).strip(keepingArchitectures: validArchs)
        
        // Symbols
        if !outputDsymPath.parent().exists {
            try outputDsymPath.parent().mkpath()
        }
        if outputDsymPath.exists {
            try outputDsymPath.delete()
        }
        try inputDsymPath.copy(outputDsymPath)
        try Package(path: outputDsymPath).strip(keepingArchitectures: validArchs)
        
        // BCSymbolMap
        if action == .install {
            try Package(path: inputPath).bcSymbolMapsForFramework()
                .forEach{ (bcInputPath) in
                    let bcOputputPath = Path(builtProductsDir) + bcInputPath.lastComponent
                    if !bcOputputPath.parent().exists { try bcOputputPath.parent().mkpath() }
                    if bcOputputPath.exists { try bcOputputPath.delete() }
                    try bcInputPath.copy(bcOputputPath)
            }
        }
    }
    
}
