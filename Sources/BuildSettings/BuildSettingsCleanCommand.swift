import Foundation
import PathKit
import xcodeproj

public struct BuildSettingsCleanCommand {
    
    // MARK: - Properties
    
    private let project: XcodeProj
    private let target: String?
    private let projectPath: Path
    private let projectWriter: (XcodeProj, Path) throws -> Void
    
    // MARK: - Init
    
    public init(projectPath: Path,
                target: String? = nil) throws {
        self.init(project: try XcodeProj(path: projectPath), projectPath: projectPath, target: target)
    }
    
    public init(project: XcodeProj,
                projectPath: Path,
                target: String? = nil,
                projectWriter: @escaping (XcodeProj, Path) throws -> Void = { try $0.write(path: $1) }) {
        self.project = project
        self.projectPath = projectPath
        self.target = target
        self.projectWriter = projectWriter
    }
    
    // MARK: - Execute
    
    public func execute() throws {
        let cleanConfigurationList: (PBXProj, String) -> Void = { (pbxproj, configurationListReference) in
            guard let configurationList = pbxproj.configurationLists.filter({ $0.reference == configurationListReference }).first else { return }
            configurationList.buildConfigurations.forEach { (buildConfigurationReference) in
                guard let buildConfiguration = pbxproj
                    .buildConfigurations
                    .filter({ $0.reference == buildConfigurationReference })
                    .first else { return }
                buildConfiguration.buildSettings.removeAll()
            }
        }
        if let target = target {
            project.pbxproj.nativeTargets.filter({$0.name == target}).forEach({ cleanConfigurationList(project.pbxproj, $0.buildConfigurationList )})
            project.pbxproj.aggregateTargets
                .filter({$0.name == target})
                .forEach({ cleanConfigurationList(project.pbxproj, $0.buildConfigurationList )})
        } else {
            project.pbxproj.projects.forEach { cleanConfigurationList(project.pbxproj, $0.buildConfigurationList) }
        }
        try self.projectWriter(project, projectPath)
    }
    
}
