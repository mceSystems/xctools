import Foundation
import XCTest
import PathKit
import Core
import Frameworks
import PathKit

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

final class EmbedCommandTests: XCTestCase {
    
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
    
    func test_execute() {
        try? subject.execute()
    }
    
    override func tearDown() {
        super.tearDown()
        try? Path(outputPath()).delete()
    }
    
    private func inputPath() -> String {
        return (Path(#file) + "../../../Fixtures/iOSFramework/Test.framework").string
        
    }
    
    private func outputPath() -> String {
        return (Path(#file) + "../../../Fixtures/tmp/Test.framework").string
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
