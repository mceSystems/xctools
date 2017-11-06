import Foundation
import PathKit
import xcproj
import Core

public struct BuildSettingsExportCommand {
    
    // MARK: - Attributes
    
    private let project: XcodeProj
    private let target: String?
    private let output: Path
    
    // MARK: - Public
    
    public init(projectPath: Path,
                target: String? = nil,
                output: Path) throws {
        self.init(project: try XcodeProj.init(path: projectPath),
                  target: target,
                  output: output)
    }
    
    init(project: XcodeProj,
         target: String? = nil,
         output: Path) {
        self.project = project
        self.target = target
        self.output = output
    }
    
    // MARK: - Public
    
    public func execute() throws {
        let settings = try buildSettings()
        try write(settings: settings)
    }
    
    // MARK: - Fileprivate
    
    fileprivate func buildSettings() throws -> [String: Any] {
        var configurations: [XCBuildConfiguration] = []
        if let target = target {
            guard let nativeTarget = project.pbxproj.nativeTargets.first(where: {$0.name == target}) else {
                throw "The target \(target) cannot be found"
            }
            configurations = self.targetConfigurationList(nativeTarget: nativeTarget).flatMap(self.configurations) ?? []
        } else {
            configurations = projectConfigurationList().flatMap(self.configurations) ?? []
        }
        var settings: [String: Any] = [:]
        configurations.forEach { (configuration) in
            let configurationName = configuration.name
            configuration.buildSettings.forEach { (setting, value) in
                settings["\(setting)[config=\(configurationName)]"] = value
            }
        }
        return settings
    }
    
    fileprivate func targetConfigurationList(nativeTarget: PBXNativeTarget) -> XCConfigurationList? {
        return nativeTarget.buildConfigurationList
            .flatMap({ configurationListReference in
                return project.pbxproj.configurationLists.first(where: {$0.reference == configurationListReference})
            })
    }
    
    fileprivate func projectConfigurationList() -> XCConfigurationList? {
        return project.pbxproj.projects
            .first
            .flatMap({ $0.buildConfigurationList })
            .flatMap({ (configurationListReference) in
                return project.pbxproj.configurationLists.first(where: {$0.reference == configurationListReference})
            })
    }
    
    fileprivate func configurations(from list: XCConfigurationList) -> [XCBuildConfiguration] {
        return list.buildConfigurations
            .flatMap({ configurationReference in
                return project.pbxproj.buildConfigurations.first(where: {$0.reference == configurationReference})
            })
    }
    
    fileprivate func write(settings: [String: Any]) throws {
        try? output.parent().mkpath()
        try settings.reduce(into: "", { (prev, value) in
            let setting = value.key
            let settingValue = value.value
            prev += setting
            prev += " = "
            if let boolValue = settingValue as? Bool {
                prev += boolValue ? "YES": "NO"
            } else if let intValue = settingValue as? Int {
                prev +=  "\(intValue)"
            } else if let stringValue = settingValue as? String {
                prev += stringValue.isEmpty ? "\"\"" : stringValue
            } else if let stringsArrayValue = settingValue as? [String] {
                prev += stringsArrayValue.joined(separator: " ")
            }
            prev += "\n"
        }).write(to: output.url, atomically: true, encoding: String.Encoding.utf8)
        
    }
}
