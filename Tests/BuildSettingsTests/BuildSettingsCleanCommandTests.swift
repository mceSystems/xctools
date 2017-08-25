import Foundation
import XCTest
import xcodeproj
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
        let pbxproj = PBXProj(archiveVersion: 0,
                              objectVersion: 1,
                              rootObject: "root")
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
                                                              buildConfigurations: Set<String>(arrayLiteral: "configProject"),
                                                              defaultConfigurationName: "default"))
        pbxproj.configurationLists.append(XCConfigurationList(reference: "listNativeTarget",
                                                              buildConfigurations: Set<String>(arrayLiteral: "configNativeTarget"),
                                                              defaultConfigurationName: "default"))
        pbxproj.configurationLists.append(XCConfigurationList(reference: "listAggregateTarget",
                                                              buildConfigurations: Set<String>(arrayLiteral: "configAggregateTarget"),
                                                              defaultConfigurationName: "default"))
        pbxproj.projects.append(PBXProject(reference: "ref",
                                           buildConfigurationList: "listProject",
                                           compatibilityVersion: "3",
                                           mainGroup: "main"))
        pbxproj.nativeTargets.append(PBXNativeTarget(reference: "ref2",
                                                     buildConfigurationList: "listNativeTarget",
                                                     buildPhases: [],
                                                     buildRules: [],
                                                     dependencies: [],
                                                     name: "shakira"))
        pbxproj.aggregateTargets.append(PBXAggregateTarget(reference: "ref3",
                                                           buildConfigurationList: "listAggregateTarget",
                                                           buildPhases: [],
                                                           buildRules: [],
                                                           dependencies: [],
                                                           name: "shakira"))
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
