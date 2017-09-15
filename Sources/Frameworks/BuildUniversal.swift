import Foundation
import PathKit
import Core

/// Builds an universal framework for device & simulator
public class BuildUniversal {
    
    // MARK: - Attributes
    
    /// Workspace that contains the framework to build.
    private let workspace: Path?
    
    /// Project that contains the framework to build.
    private let project: Path?
    
    /// Scheme that builds the framework.
    private let scheme: String
    
    // MARK: - Init
    
    public init(workspace: Path? = nil,
                project: Path? = nil,
                scheme: String) {
        self.workspace = workspace
        self.project = project
        self.scheme = scheme
    }
    
    // MARK: - Func
    
    /// Executes the command.
    ///
    /// - Throws: an error if the framework cannot be built
    public func execute() throws {

    }
    
}
