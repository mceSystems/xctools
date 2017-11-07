import Foundation
import Core
import XCTest

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
    
}

