// Reference: https://github.com/Carthage/Carthage/blob/53da2e143306ba502e468842667ee8cd763d5a5b/Source/CarthageKit/Xcode.swift
// Reference: https://pspdfkit.com/guides/ios/current/faq/framework-size/#toc_dsym-and-bcsymbolmaps
import Foundation
import PathKit
import SwiftShell

/// Package type.
///
/// - framework: the package is a framework.
/// - bundle: the package is a bundle with resoureces.
/// - dSYM: the package contains dynamic symbols.
public enum PackageType: String {
    case framework = "FMWK"
    case bundle = "BNDL"
    case dSYM = "dSYM"
}

public struct Package {
    
    // MARK: - Constants
    
    struct Constants {
        static var lipoArchitecturesMessage: String = "Architectures in the fat file:"
        static var lipoNonFatFileMessage: String = "Non-fat file:"
    }
    
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
            return path + (bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String).map({Path($0)})!
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
        let lipoResult = System.xcrun("lipo", "-info", _binaryPath.string)
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: " _-")
        let scanner = Scanner(string: lipoResult.stdout)
        
        if scanner.scanString(Constants.lipoArchitecturesMessage, into: nil) {
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
        if scanner.scanString(Constants.lipoNonFatFileMessage, into: nil) {
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
            if let binaryPath = binaryPath() {
                try stripArchitecture(packagePath: binaryPath, architecture: $0)
            }
        })
    }
    
    /// Strips an architecture from a given package.
    ///
    /// - Parameters:
    ///   - packagePath: package path.
    ///   - architecture: architecture to be stripped.
    /// - Throws: throws an error if the stripping fails.
    func stripArchitecture(packagePath: Path, architecture: String) throws {
        let output = System.xcrun("lipo", "-remove", architecture, "-output", packagePath.string, packagePath.string)
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

    
    // MARK: - UUID
    
    /// Returns a set of UUIDs for each architecture present in the package.
    ///
    /// - Returns: set of UUIDs.
    /// - Throws: an error if the UUIDs cannot be obtained.
    public func uuids() throws -> Set<UUID> {
        switch self.packageType() {
        case .framework?, .bundle?:
            return try uuidsForFramework()
        case .dSYM?:
            return try uuidsForDSYM()
        default:
            return Set()
        }
    }

    /// Returns a set of UUIDs for each architecture present in the framework package.
    ///
    /// - Returns: set of UUIDs.
    /// - Throws: an error if the UUIDs cannot be obtained.
    func uuidsForFramework() throws -> Set<UUID> {
        guard let binaryPath = binaryPath() else { return Set() }
        return try uuidsFromDwarfdump(path: binaryPath)
    }
    
    /// Returns a set of UUIDs for each architecture present in the DSYM package.
    ///
    /// - Returns: set of UUIDs.
    /// - Throws: an error if the UUIDs cannot be obtained.
    func uuidsForDSYM() throws -> Set<UUID> {
        return try uuidsFromDwarfdump(path: self.path)
    }
    
    /// Returns a set of UUIDs for each architecture present.
    ///
    /// - Parameter path: url of the file whose architectures UUIDs will be returned.
    /// - Returns: set of UUIDs.
    /// - Throws: an error if the UUIDs cannot be obtained.
    func uuidsFromDwarfdump(path: Path) throws -> Set<UUID> {
        let result = System.xcrun("dwarfdump", "--uuid", path.string)
        if let error = result.error {
            throw error
        }
        var uuidCharacterSet = CharacterSet()
        uuidCharacterSet.formUnion(.letters)
        uuidCharacterSet.formUnion(.decimalDigits)
        uuidCharacterSet.formUnion(CharacterSet(charactersIn: "-"))
        let scanner = Scanner(string: result.stdout)
        var uuids = Set<UUID>()
        // The output of dwarfdump is a series of lines formatted as follows
        // for each architecture:
        //
        //     UUID: <UUID> (<Architecture>) <PathToBinary>
        //
        while !scanner.isAtEnd {
            scanner.scanString("UUID: ", into: nil)
            
            var uuidString: NSString?
            scanner.scanCharacters(from: uuidCharacterSet, into: &uuidString)
            
            if let uuidString = uuidString as String?, let uuid = UUID(uuidString: uuidString) {
                uuids.insert(uuid)
            }
            // Scan until a newline or end of file.
            scanner.scanUpToCharacters(from: .newlines, into: nil)
        }
        return uuids
    }
    
    /// Returns framework bcsymbolmaps paths.
    ///
    /// - Returns: bcsymbolmaps paths.
    /// - Throws: an error if the bcsymbolmaps cannot be obtained.
    public func bcSymbolMapsForFramework() throws -> [Path] {
        let parentPath = path.parent()
        let frameworkUUIDs = try uuids()
        return frameworkUUIDs.map({ parentPath + Path($0.uuidString) + ".bcsymbolmap" })
    }
}
