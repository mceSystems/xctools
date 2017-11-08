import Foundation
import Core
import XCTest
import xcproj
import PathKit

@testable import BuildSettings

final class BuildSettingsExportCommandTests: XCTestCase {
    
    func test_configurationBuildSettingInit_setsTheCorrectValues_whenTheValueIsABool() {
        var subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: true)
        XCTAssertEqual(subject.value, "YES")
        XCTAssertFalse(subject.inherited)
        subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: false)
        XCTAssertEqual(subject.value, "NO")
        XCTAssertFalse(subject.inherited)
    }
    
    func test_configurationBuildSettingInit_setsTheCorrectValues_whenTheValueIsAInt() {
        let subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: 3)
        XCTAssertEqual(subject.value, "3")
        XCTAssertFalse(subject.inherited)
    }
    
    func test_configurationBuildSettingInit_setsTheCorrectValues_whenTheValueIsAString() {
        var subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: "/path")
        XCTAssertEqual(subject.value, "/path")
        XCTAssertFalse(subject.inherited)
        subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: "")
        XCTAssertEqual(subject.value, "\"\"")
        XCTAssertTrue(subject.inherited)
        subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: "/path $(inherited)")
        XCTAssertEqual(subject.value, "/path")
        XCTAssertTrue(subject.inherited)
    }
    
    func test_configurationBuildSettingInit_setsTheCorrectValues_whenTheValueIsArray() {
        var subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: ["a", "b"])
        XCTAssertEqual(subject.value, "a b")
        XCTAssertFalse(subject.inherited)
        subject = BuildSettingsExportCommand.ConfigurationBuildSetting(value: ["a", "$(inherited)"])
        XCTAssertEqual(subject.value, "a")
        XCTAssertTrue(subject.inherited)
    }
    
    func test_execute_returnsTheCorrectContent_whenProjectSettings() {
        let subject = try? output(project: project())
        XCTAssertEqual(subject, """
        A=[config=Debug] = AA_VALUE
        A=[config=Release] = AA_VALUE
        B=[config=Debug] = 33
        B=[config=Release] = BB_VALUE\n
        """)
    }
    
    func test_execute_returnsTheCorrectContent_whenTargetSettings() {
        let subject = try? output(project: project(), target: "target")
        XCTAssertEqual(subject, """
        A=[config=Debug] = A_VALUE
        A=[config=Release] = A_VALUE2
        B=[config=Debug] = B_VALUE $(inherited)
        B=[config=Release] = YES\n
        """)
    }
    
    func test_execute_returnsTheCorrectContent_whenTargetSettingsMerging() {
        let subject = try? output(project: project(), target: "target", mergeSettings: true)
        XCTAssertEqual(subject, """
        A=[config=Debug] = A_VALUE
        A=[config=Release] = A_VALUE2
        B=[config=Debug] = 33 B_VALUE
        B=[config=Release] = YES\n
        """)
    }
    
    // MARK: - Fileprivate
    
    fileprivate func project() -> XcodeProj {
        let workspace = XCWorkspace()
        let pbxproj = PBXProj(objectVersion: 0, rootObject: "root")
        let project = XcodeProj(workspace: workspace, pbxproj: pbxproj)
        let target = PBXNativeTarget(reference: "target",
                                     name: "target",
                                     buildConfigurationList: "target_list")
        pbxproj.addObject(target)
        let proj = PBXProject(name: "project",
                              reference: "project",
                              buildConfigurationList: "project_list",
                              compatibilityVersion: "version",
                              mainGroup: "main")
        pbxproj.addObject(proj)
        let targetList = XCConfigurationList(reference: "target_list",
                                             buildConfigurations: ["target_config_1",
                                                                   "target_config_2"])
        pbxproj.addObject(targetList)
        let projectList = XCConfigurationList(reference: "project_list",
                                              buildConfigurations: ["project_config_1",
                                                                    "project_config_2"])
        pbxproj.addObject(projectList)
        let targetConfig1 = XCBuildConfiguration(reference: "target_config_1",
                                                 name: "Debug",
                                                 buildSettings: ["A": "A_VALUE",
                                                                 "B": ["$(inherited)", "B_VALUE"]])
        pbxproj.addObject(targetConfig1)
        let targetConfig2 = XCBuildConfiguration(reference: "target_config_2",
                                                 name: "Release",
                                                 buildSettings: ["A": "A_VALUE2",
                                                                 "B": true])
        pbxproj.addObject(targetConfig2)
        
        let projectConfig1 = XCBuildConfiguration(reference: "project_config_1",
                                                  name: "Debug",
                                                  buildSettings: ["A": "AA_VALUE",
                                                                  "B": 33])
        pbxproj.addObject(projectConfig1)
        let projectConfig2 = XCBuildConfiguration(reference: "project_config_2",
                                                  name: "Release",
                                                  buildSettings: ["A": "AA_VALUE",
                                                                  "B": "BB_VALUE"])
        pbxproj.addObject(projectConfig2)
        return project
    }
    
    fileprivate func output(project: XcodeProj,
                            target: String? = nil,
                            mergeSettings: Bool = false) throws -> String {
        let output = Path("output/")
        var content: String = ""
        try BuildSettingsExportCommand(project: project,
                                       target: target,
                                       output: output,
                                       mergeSettings: mergeSettings) { (_output, _content) in
                                        content = _content
                                        XCTAssertEqual(_output, output)
            }.execute()
        return content
    }
    
}

