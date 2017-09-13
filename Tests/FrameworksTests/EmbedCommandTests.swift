import Foundation
import XCTest
import PathKit
import Core
import Frameworks
import PathKit
import TestsFoundation
import Core

// MARK: - EmbedErrorTests

final class EmbedErrorTests: XCTestCase {
    
    func test_notFound_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.notFound(path: "test/").description, "File not found at path: test/")
    }
    
    func test_invalidExtension_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.invalidExtension(path: "test/").description, "File doesn't have a .framework extension: test/")
    }
    
}

// MARK: - EmbedCommandTests

final class EmbedCommandTests: XCIntegrationTestCase {
    
    var subject: EmbedCommand!
    var buildAllConfigs: Bool!
    var configsToBuild: [String]!
    var xcodeEnvironment: XcodeEnvironment!
    
    override func setUp() {
        super.setUp()
        buildAllConfigs = false
        configsToBuild = ["Debug"]
        subject = EmbedCommand(buildAllConfigs: false,
                               configsToBuild: ["Debug"],
                               configuration: "Debug",
                               inputsAndOutputs:  [(input: inputPath(), output: outputPath())],
                               validArchs: ["armv7"],
                               action: .install,
                               builtProductsDir: Path(outputPath()).parent().string)
        try? Path(outputPath()).mkdir()
    }
    
    func test_execute_copiesTheFramework() {
        try? subject.execute()
        XCTAssertTrue(Path(outputPath()).exists)
    }
    
    func test_execute_stripsTheArchitectures() {
        XCTAssertEqual(Package(path: Path(inputPath())).architectures(), ["armv7", "arm64"])
        try? subject.execute()
        XCTAssertEqual(Package(path: Path(outputPath())).architectures(), ["armv7"])
    }
    
    func test_execute_copiesTheFrameworkSymbols() {
        let outputDsymsPath = Path(outputPath() + ".dSYM")
        try? subject.execute()
        XCTAssertTrue(outputDsymsPath.exists)
    }
    
    func test_execute_stripsTheArchitecturesFromTheFrameworkSymbols() {
        let inputDsymsPath = Path(inputPath() + ".dSYM")
        let outputDsymsPath = Path(outputPath() + ".dSYM")
        XCTAssertEqual(Package(path: inputDsymsPath).architectures(), ["armv7", "arm64"])
        try? subject.execute()
        XCTAssertEqual(Package(path: outputDsymsPath).architectures(), ["armv7"])
    }
    
    func test_execute_doesNotCopyTheBCSymbolMaps_whenTheActionIsNotInstall() {
        subject = EmbedCommand(buildAllConfigs: false,
                               configsToBuild: ["Debug"],
                               configuration: "Debug",
                               inputsAndOutputs:  [(input: inputPath(), output: outputPath())],
                               validArchs: ["armv7"],
                               action: .archive,
                               builtProductsDir: Path(outputPath()).parent().string)
        try? subject.execute()
        XCTAssertEqual(Path(outputPath()).parent().glob("*.bcsymbolmap").count, 0)
    }
    
    func test_execute_copyTheBCSymbols_whenTheActionIsInstall() {
        try? subject.execute()
        XCTAssertEqual(Path(outputPath()).parent().glob("*.bcsymbolmap").count, 2)
    }
    
    override func tearDown() {
        super.tearDown()
        try? Path(outputPath()).delete()
    }
    
    private func inputPath() -> String {
        return (Path(#file) + "../../../Fixtures/iOSFramework/Test.framework").string
        
    }
    
    private func outputPath() -> String {
        return (tmpPath + "Test.framework").string
    }
    
    private func setXcodeEnvironment(action: Core.Action = .install,
                                     configuration: String = "Debug",
                                     validArchs: [String] = ["armv7"],
                                     builtProductsDir: String = "",
                                     targetBuildDir: String = "",
                                     inputsAndOutputs: [(input: String, output: String)] = []) {
        xcodeEnvironment = XcodeEnvironment(configuration: configuration,
                                            configurationBuildDir: "",
                                            frameworksFolderPath: "",
                                            builtProductsDir: builtProductsDir,
                                            targetBuildDir: targetBuildDir,
                                            dwardDsymFolderPath: "",
                                            expandedCodeSignIdentity: "",
                                            codeSignRequired: "YES",
                                            codeSigningAllowed: "YES",
                                            expandedCodeSignIdentityName: "",
                                            otherCodeSignFlags: "",
                                            validArchs: validArchs,
                                            action: action,
                                            inputsAndOutputs: inputsAndOutputs)
    }
    
}
