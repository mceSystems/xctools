// Reference: https://github.com/Carthage/Carthage/blob/53da2e143306ba502e468842667ee8cd763d5a5b/Source/CarthageKit/Xcode.swift
import Foundation
import PathKit
import SwiftShell

/// Package type.
///
/// - framework: the package is a framework.
/// - bundle: the package is a bundle with resoureces.
/// - dSYM: the pckage contains dynamic symbols.
public enum PackageType: String {
    case framework = "FMWK"
    case bundle = "BNDL"
    case dSYM = "dSYM"
}

public struct Package {
    
    // MARK: - Attributes
    
    private let path: Path
    
    // MARK: - Init
    
    public init(path: Path) {
        self.path = path
    }
    
    // MARK: - Public
    
    /// Returns the path of the binary inside the package.
    ///
    /// - Returns: path of the binary (if it exists).
    public func binaryPath() -> Path? {
        guard let bundle = Bundle(path: path.string) else { return nil }
        guard let packageType = packageType() else { return nil }
        switch packageType {
        case .framework, .bundle:
            return (bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String).map({Path($0)})
        case .dSYM:
            let binaryName = path.url.deletingPathExtension().deletingPathExtension().lastPathComponent
            if !binaryName.isEmpty {
                return path + Path("Contents/Resources/DWARF/\(binaryName)")
            }
        }
        return nil
    }
    
    /// Returns the package type.
    ///
    /// - Returns: package type.
    public func packageType() -> PackageType? {
        guard let bundle = Bundle(path: path.string) else { return nil }
        guard let bundlePackageType = bundle.object(forInfoDictionaryKey: "CFBundlePackageType") as? String else { return nil }
        return PackageType(rawValue: bundlePackageType)
    }
    
    /// Returns the supported architectures of the given package.
    ///
    /// - Returns: all the supported architectures.
    public func architectures() -> [String] {
        guard let _binaryPath = binaryPath() else { return [] }
        let lipoResult = run("/usr/bin/xcrun", "lipo", "-info", _binaryPath.string)
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: " _-")
        let scanner = Scanner(string: lipoResult.stdout)
        
        if scanner.scanString("Architectures in the fat file:", into: nil) {
            // The output of "lipo -info PathToBinary" for fat files
            // looks roughly like so:
            //
            //     Architectures in the fat file: PathToBinary are: armv7 arm64
            //
            var architectures: NSString?
            scanner.scanString(_binaryPath.string, into: nil)
            scanner.scanString("are:", into: nil)
            scanner.scanCharacters(from: characterSet, into: &architectures)
            let components = architectures?
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
            if let components = components {
                return components
            }
        }
        if scanner.scanString("Non-fat file:", into: nil) {
            // The output of "lipo -info PathToBinary" for thin
            // files looks roughly like so:
            //
            //     Non-fat file: PathToBinary is architecture: x86_64
            //
            var architecture: NSString?
            scanner.scanString(_binaryPath.string, into: nil)
            scanner.scanString("is architecture:", into: nil)
            scanner.scanCharacters(from: characterSet, into: &architecture)
            if let architecture = architecture {
                return [architecture as String]
            }
        }
        return []
    }
    
    // MARK: - Strip
    
    /// Strips the package content to contain only the necessary data for the given architectures.
    ///
    /// - Parameter keepingArchitectures: architectures to keep in the package.
    /// - Throws: throws an error if the stripping fails.
    public func strip(keepingArchitectures: [String]) throws {
        switch self.packageType() {
        case .framework?, .bundle?:
            try stripFramework(keepingArchitectures: keepingArchitectures)
        case .dSYM?:
            try stripDSYM(keepingArchitectures: keepingArchitectures)
        default:
            return
        }
    }
    
    /// Strips unnecessary content from a framework.
    ///
    /// - Parameter keepingArchitectures: architectures to be kept.
    /// - Throws: throws an error if the stripping fails.
    func stripFramework(keepingArchitectures: [String]) throws {
        try stripArchitectures(keepingArchitectures: keepingArchitectures)
        stripHeaders(frameworkPath: path)
        stripPrivateHeaders(frameworkPath: path)
        stripModulesDirectory(frameworkPath: path)
    }
    
    /// Strips unnecessary architectures from a DSYM package.
    ///
    /// - Parameter keepingArchitectures: architectures to be kept.
    /// - Throws: throws an error if the stripping fails.
    func stripDSYM(keepingArchitectures: [String]) throws {
        try stripArchitectures(keepingArchitectures: keepingArchitectures)
    }
    
    
    /// Strips the unnecessary architectures from the package.
    ///
    /// - Parameter keepingArchitectures: architectures to be kept.
    /// - Throws: an error if the stripping fails.
    func stripArchitectures(keepingArchitectures: [String]) throws {
        let architecturesInPackage = architectures()
        let architecturesToStrip = architecturesInPackage.filter({!keepingArchitectures.contains($0)})
        try architecturesToStrip.forEach({
            try stripArchitecture(packagePath: path, architecture: $0)
        })
    }
    
    /// Strips an architecture from a given package.
    ///
    /// - Parameters:
    ///   - packagePath: package path.
    ///   - architecture: architecture to be stripped.
    /// - Throws: throws an error if the stripping fails.
    func stripArchitecture(packagePath: Path, architecture: String) throws {
        let output = run("/usr/bin/xcrun", "lipo", "-remove", architecture, "-output", packagePath.string, packagePath.string)
        if let error = output.error {
            throw error
        }
    }
    
    /// Strips the headers from a given framework.
    ///
    /// - Parameter frameworkPath: path to the framework whose headers will be stripped.
    func stripHeaders(frameworkPath: Path) {
        stripDirectory(name: "Headers", from: frameworkPath)
    }
    
    /// Strips the private headers from a given framework.
    ///
    /// - Parameter frameworkPath: path to the framework whose private headers will be stripped.
    func stripPrivateHeaders(frameworkPath: Path) {
        stripDirectory(name: "PrivateHeaders", from: frameworkPath)
    }
    
    
    /// Strips the modules directory from a given framework.
    ///
    /// - Parameter frameworkPath: path to the framework whose modules directory will be stripped.
    func stripModulesDirectory(frameworkPath: Path) {
        stripDirectory(name: "Modules", from: frameworkPath)
    }
    
    
    /// Strips a directory from a given framework.
    ///
    /// - Parameters:
    ///   - name: name of the folder that will be stripped from the framework.
    ///   - frameworkPath: path to the framework whose directory will be stripped.
    func stripDirectory(name: String, from frameworkPath: Path) {
        let path = frameworkPath + Path(name)
        try? FileManager.default.removeItem(atPath: path.string)
    }


}
