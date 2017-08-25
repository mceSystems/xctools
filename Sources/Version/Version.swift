import Foundation
import PathKit

// MARK: - VersionError

public enum VersionError: Error {
    case projectNotFound(path: Path)
    case targetNotFound(target: String)
    case plistNotFound
}

// MARK: - Version

public struct Version {
    
    public enum Action {
        case upgrade
        case downgrade
    }
    
    public enum Component {
        case major
        case minor
        case patch
    }
    
    // MARK: - Properties
    
    private let action: Action
    private let projectPath: Path
    private let component: Component
    private let target: String
    
    // MARK: - Init
    
    public init(projectPath: Path,
                target: String,
                component: Component = .minor,
                action: Action = .upgrade) {
        self.projectPath = projectPath
        self.target = target
        self.component = component
        self.action = action
    }
    
    // MARK: - Public
    
    public func execute() throws {
        
    }
    
}
