// Reference https://medium.com/@syshen/create-an-ios-universal-framework-148eb130a46c
// Reference http://arsenkin.com/ios-universal-framework.html
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
    
    /// Configuration to build.
    private let config: String
    
    // MARK: - Init
    
    public init(workspace: Path? = nil,
                project: Path? = nil,
                scheme: String,
                config: String) {
        self.workspace = workspace
        self.project = project
        self.scheme = scheme
        self.config = config
    }
    
    // MARK: - Public
    
    /// Executes the command.
    ///
    /// - Throws: an error if the framework cannot be built
    public func execute() throws {
        let simulatorBuildOutput = System.xcodebuild(projectParameter(),
                                                     "-scheme", scheme,
                                                     "-sdk", "iphonesimulator",
                                                     "-config", config,
                                                     "ONLY_ACTIVE_ARCH=NO",
                                                     "clean build")
        let deviceBuildOutput = System.xcodebuild(projectParameter(),
                                                  "-scheme", scheme,
                                                  "-sdk", "iphoneos",
                                                  "-config", config,
                                                  "ONLY_ACTIVE_ARCH=NO",
                                                  "clean build")

    }
    
    // MARK: - Private
    
    private func projectParameter() -> String {
        if let workspace = workspace {
            return "-workspace \(workspace.string)"
        } else if let project = project {
            return "-project \(project.string)"
        }
        return ""
    }
    
}
