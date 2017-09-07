// Reference: https://github.com/Carthage/Carthage/blob/master/Source/carthage/CopyFrameworks.swift

import Foundation
import SwiftShell
import PathKit
import Core

// MARK: - PackageCopying

public protocol PackageCopying {
    func copy(from: Path, to: Path, keepingArchitectures: [String]) throws
}

// MARK: - PackageCopier

public class PackageCopier: PackageCopying {
    
    // MARK: - Attributes
    
    let copy: (Path, Path) throws -> Void
    let strip: (Package, [String]) throws -> Void

    // MARK: - Init
    
    public init(copy: @escaping (Path, Path) throws -> Void = { (from, to) in
                    if (!to.parent().exists) { try to.mkpath() }
                    try from.copy(to)
                },
                strip: @escaping (Package, [String]) throws -> Void = { try $0.strip(keepingArchitectures: $1) }) {
        self.copy = copy
        self.strip = strip
    }
    
    // MARK: - FrameworkEmbedding
    
    public func copy(from: Path, to: Path, keepingArchitectures: [String]) throws {
        try copy(from, to)
        try strip(Package(path: to), keepingArchitectures)
    }
    
}

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
        try packageCopier.copy(from: inputPath, to: outputPath, keepingArchitectures: xcodeEnvironment.validArchs)
        try packageCopier.copy(from: inputDsymPath, to: outputDsymPath, keepingArchitectures: xcodeEnvironment.validArchs)
        if xcodeEnvironment.action == .install {
            try copyBCSymbolMap(package: inputPackage)
        }
    }
    
    private func copyBCSymbolMap(package: Package) throws {
        try package.bcSymbolMapsForFramework()
            .forEach{ (bcInputPath) in
                let bcOputputPath = Path(xcodeEnvironment.builtProductsDir) + bcInputPath.lastComponent
                if !bcOputputPath.parent().exists { try bcOputputPath.parent().mkpath() }
                try bcInputPath.copy(bcOputputPath)
        }
    }
    
    
}
