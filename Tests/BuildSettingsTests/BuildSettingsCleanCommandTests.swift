import Foundation
import XCTest
import xcproj
import BuildSettings
import PathKit

final class BuildSettingsCleanCommandTests: XCTestCase {
    
    var project: XcodeProj!
    var configProject: XCBuildConfiguration!
    var configNativeTarget: XCBuildConfiguration!
    var configAggregateTarget: XCBuildConfiguration!
    
    override func setUp() {
        super.setUp()
        let workspaceData = XCWorkspace.Data(references: [])
        let workspace = XCWorkspace(data: workspaceData)
        let pbxproj = PBXProj(objectVersion: 1,
                              rootObject: "root",
                              archiveVersion: 0)
        project = XcodeProj(workspace: workspace, pbxproj: pbxproj)
        configProject = XCBuildConfiguration(reference: "configProject",
                                             name: "config",
                                             baseConfigurationReference: nil,
                                             buildSettings: ["a": "b"])
        configNativeTarget = XCBuildConfiguration(reference: "configNativeTarget",
                                                  name: "config",
                                                  baseConfigurationReference: nil,
                                                  buildSettings: ["a": "b"])
        configAggregateTarget = XCBuildConfiguration(reference: "configAggregateTarget",
                                                     name: "config",
                                                     baseConfigurationReference: nil,
                                                     buildSettings: ["a": "b"])
        pbxproj.buildConfigurations.append(configProject)
        pbxproj.buildConfigurations.append(configNativeTarget)
        pbxproj.buildConfigurations.append(configAggregateTarget)
        pbxproj.configurationLists.append(XCConfigurationList(reference: "listProject",
                                                              buildConfigurations: ["configProject"],
                                                              defaultConfigurationName: "default"))
        pbxproj.configurationLists.append(XCConfigurationList(reference: "listNativeTarget",
                                                              buildConfigurations: ["configNativeTarget"],
                                                              defaultConfigurationName: "default"))
        pbxproj.configurationLists.append(XCConfigurationList(reference: "listAggregateTarget",
                                                              buildConfigurations: ["configAggregateTarget"],
                                                              defaultConfigurationName: "default"))
        
        pbxproj.projects.append(PBXProject(name: "proj1",
                                           reference: "ref",
                                           buildConfigurationList: "listProject",
                                           compatibilityVersion: "3",
                                           mainGroup: "main"))
        pbxproj.nativeTargets.append(PBXNativeTarget(reference: "ref2",
                                                     name: "shakira",
                                                     buildConfigurationList: "listNativeTarget",
                                                     buildPhases: [],
                                                     buildRules: [],
                                                     dependencies: []))
        pbxproj.aggregateTargets.append(PBXAggregateTarget(reference: "ref3",
                                                           name: "shakira",
                                                           buildConfigurationList: "listAggregateTarget",
                                                           buildPhases: [],
                                                           buildRules: [],
                                                           dependencies: []))
    }
    
    
    func test_execute_cleansTheConfigFromTheProject_whenThereIsNoTarget() {
        XCTAssertFalse(configProject.buildSettings.keys.count == 0)
        let subject = BuildSettingsCleanCommand(project: project,
                                                projectPath: Path("test"),
                                                target: nil,
                                                projectWriter: { (_, _) in })
        try? subject.execute()
        XCTAssertTrue(configProject.buildSettings.keys.count == 0)
    }
    
    func test_execute_writesTheProject_whenThereIsNoTarget() {
        var writeCalled: Bool = false
        let subject = BuildSettingsCleanCommand(project: project,
                                                projectPath: Path("test"),
                                                target: nil,
                                                projectWriter: { (_, _) in writeCalled = true })
        try? subject.execute()
        XCTAssertTrue(writeCalled)
    }
    
    func test_execute_cleansTheConfigFromTheTarget_whenThereIsATarget() {
        XCTAssertFalse(configNativeTarget.buildSettings.keys.count == 0)
        XCTAssertFalse(configAggregateTarget.buildSettings.keys.count == 0)
        let subject = BuildSettingsCleanCommand(project: project,
                                                projectPath: Path("test"),
                                                target: "shakira",
                                                projectWriter: { (_, _) in })
        try? subject.execute()
        XCTAssertTrue(configNativeTarget.buildSettings.keys.count == 0)
        XCTAssertTrue(configAggregateTarget.buildSettings.keys.count == 0)
    }
    
    func test_execute_writesTheProject_whenThereIsATarget() {
        var writeCalled: Bool = false
        let subject = BuildSettingsCleanCommand(project: project,
                                                projectPath: Path("test"),
                                                target: "shakira",
                                                projectWriter: { (_, _) in writeCalled = true })
        try? subject.execute()
        XCTAssertTrue(writeCalled)
    }
    
    
}
