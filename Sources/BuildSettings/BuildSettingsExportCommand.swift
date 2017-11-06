import Foundation
import PathKit
import xcproj
import Core

public struct BuildSettingsExportCommand {
    
    // MARK: - ConfigurationBuildSetting
    
    struct ConfigurationBuildSetting {
        
        let value: String
        var inherited: Bool
        
        init(value: Any) {
            let valueAndInherited = ConfigurationBuildSetting.stringValueAndInherited(from: value)
            self.value = valueAndInherited.value
            self.inherited = valueAndInherited.inherited
        }
        
        static func stringValueAndInherited(from value: Any) -> (value: String, inherited: Bool) {
            var _stringValue: String = ""
            var inherited: Bool = false
            if let boolValue = value as? Bool {
                _stringValue = boolValue ? "YES": "NO"
            } else if let intValue = value as? Int {
                _stringValue =  "\(intValue)"
            } else if let stringValue = value as? String {
                inherited = stringValue.contains("$(inherited)") || stringValue.isEmpty
                _stringValue = stringValue.isEmpty ? "\"\"" : stringValue.replacingOccurrences(of: "$(inherited)",
                                                                                         with: "")
            } else if let stringsArrayValue = value as? [String] {
                var mutableArray = stringsArrayValue
                if let index = mutableArray.index(of: "$(inherited)") {
                    inherited = stringsArrayValue.contains("$(inherited)")
                    mutableArray.remove(at: index)
                }
                _stringValue = mutableArray.joined(separator: " ")
            }
            return (value: _stringValue, inherited: inherited)
        }
        
    }
    
    // MARK: - Attributes
    
    private let project: XcodeProj
    private let target: String?
    private let output: Path
    private let mergeSettings: Bool
    
    // MARK: - Public
    
    public init(projectPath: Path,
                target: String? = nil,
                output: Path,
                mergeSettings: Bool = false) throws {
        self.init(project: try XcodeProj.init(path: projectPath),
                  target: target,
                  output: output,
                  mergeSettings: mergeSettings)
    }
    
    init(project: XcodeProj,
         target: String? = nil,
         output: Path,
         mergeSettings: Bool = false) {
        self.project = project
        self.target = target
        self.output = output
        self.mergeSettings = mergeSettings
    }
    
    // MARK: - Public
    
    public func execute() throws {
        let settings = try buildSettings()
        try write(settings: settings)
    }
    
    // MARK: - Fileprivate
    
    fileprivate func buildSettings() throws -> [String: ConfigurationBuildSetting] {
        var buildSettings: [String: ConfigurationBuildSetting] = [:]
        var projectBuildSettings: [String: ConfigurationBuildSetting] = [:]
        var targetBuildSettings: [String: ConfigurationBuildSetting] = [:]
        projectConfigurationList().flatMap(self.configurations)?.forEach({ (configuration) in
            self.buildSettings(from: configuration).forEach({projectBuildSettings[$0.key] = $0.value})
        })
        if let target = target {
            guard let nativeTarget = project.pbxproj.nativeTargets.first(where: {$0.name == target}) else {
                throw "The target \(target) cannot be found"
            }
            self.targetConfigurationList(nativeTarget: nativeTarget).flatMap(self.configurations)?.forEach({ (configuration) in
                self.buildSettings(from: configuration).forEach({targetBuildSettings[$0.key] = $0.value})
            })
        }
        if target == nil || mergeSettings {
            projectBuildSettings.forEach({buildSettings[$0.key] = $0.value})
        }
        targetBuildSettings.forEach { (targetBuildSetting) in
            if let existingSetting = buildSettings[targetBuildSetting.key], targetBuildSetting.value.inherited, mergeSettings {
                buildSettings[targetBuildSetting.key] = ConfigurationBuildSetting(value: existingSetting.value + " " + targetBuildSetting.value.value)
            } else {
                buildSettings[targetBuildSetting.key] = targetBuildSetting.value
            }
        }
        return buildSettings
    }
    
    fileprivate func buildSettings(from configuration: XCBuildConfiguration) -> [String: ConfigurationBuildSetting] {
        return configuration.buildSettings.reduce(into: [String: ConfigurationBuildSetting](), { (prev, next) in
            prev["\(next.key)=[config=\(configuration.name)]"] = ConfigurationBuildSetting(value: next.value)
        })
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
    
    fileprivate func write(settings: [String: ConfigurationBuildSetting]) throws {
        try? output.parent().mkpath()
        try settings.reduce(into: "", { (prev, value) in
            let setting = value.key
            let settingValue = value.value
            prev += setting
            prev += " = "
            prev += settingValue.value
            prev += "\n"
        }).write(to: output.url, atomically: true, encoding: String.Encoding.utf8)
        
    }
}
