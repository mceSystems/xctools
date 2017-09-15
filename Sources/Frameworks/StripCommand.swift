import Foundation
import PathKit
import Core

/// Strips architectures from a given framework.
public class StripCommand {
    
    // MARK: - Attributes
    
    /// The package path.
    private let packagePath: Path
    
    /// The architectures that will be stripped.
    private let architecturesToStrip: Set<String>
    
    // MARK: - Init
    
    /// Default constructor.
    ///
    /// - Parameters:
    ///   - packagePath: package path.
    ///   - architecturesToStrip: architectures that will be stripped.
    public init(packagePath: Path,
                architecturesToStrip: Set<String>) {
        self.packagePath = packagePath
        self.architecturesToStrip = architecturesToStrip
    }
    
    // MARK: - Func
    
    /// Executes the command.
    ///
    /// - Throws: an error if the architectures cannot be stripped.
    public func execute() throws {
        let package = Package(path: packagePath)
        let keepingArchitectures = Set(package.architectures()).subtracting(architecturesToStrip)
        try package.strip(keepingArchitectures: Array(keepingArchitectures))
    }
    
}
