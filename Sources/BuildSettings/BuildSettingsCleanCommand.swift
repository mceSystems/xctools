import Foundation
import PathKit
import xcodeproj

public struct BuildSettingsCleanCommand {
    
    // MARK: - Properties
    
    private let project: XcodeProj
    private let target: String?
    private let projectPath: Path
    
    // MARK: - Init
    
    public init(projectPath: Path, target: String? = nil) throws {
        self.init(project: try XcodeProj(path: projectPath), projectPath: projectPath, target: target)
    }
    
    public init(project: XcodeProj, projectPath: Path, target: String? = nil) {
        self.project = project
        self.projectPath = projectPath
        self.target = target
    }
    
    // MARK: - Execute
    
    public func execute() throws {
        let cleanConfigurationList: (PBXProj, String) -> () = { (pbxproj, configurationListReference) in
            guard let configurationList = pbxproj.configurationLists.filter({ $0.reference == configurationListReference }).first else { return }
            configurationList.buildConfigurations.forEach { (buildConfigurationReference) in
                guard let buildConfiguration = pbxproj.buildConfigurations.filter({ $0.reference == buildConfigurationReference }).first else { return }
                buildConfiguration.buildSettings.dictionary.removeAll()
            }
        }
        if let target = target {
            project.pbxproj.nativeTargets.filter({$0.name == target}).forEach({ cleanConfigurationList(project.pbxproj, $0.buildConfigurationList )})
            project.pbxproj.aggregateTargets.filter({$0.name == target}).forEach({ cleanConfigurationList(project.pbxproj, $0.buildConfigurationList )})
        } else {
            project.pbxproj.projects.forEach { cleanConfigurationList(project.pbxproj, $0.buildConfigurationList) }
        }
        try project.write(path: projectPath)
    }
    
}
