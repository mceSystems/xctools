import Foundation
import XCTest

import xcodembed

class XcodeEnvironmentTests: XCTestCase {
    
    func test_initializes_withTheCorrectProperties() {
        var dictionary: [String: String] = [:]
        dictionary["CONFIGURATION"] = "CONFIGURATION"
        dictionary["CONFIGURATION_BUILD_DIR"] = "CONFIGURATION_BUILD_DIR"
        dictionary["FRAMEWORKS_FOLDER_PATH"] = "FRAMEWORKS_FOLDER_PATH"
        dictionary["BUILT_PRODUCTS_DIR"] = "BUILT_PRODUCTS_DIR"
        dictionary["TARGET_BUILD_DIR"] = "TARGET_BUILD_DIR"
        dictionary["DWARF_DSYM_FOLDER_PATH"] = "DWARF_DSYM_FOLDER_PATH"
        dictionary["EXPANDED_CODE_SIGN_IDENTITY"] = "EXPANDED_CODE_SIGN_IDENTITY"
        dictionary["CODE_SIGNING_REQUIRED"] = "CODE_SIGNING_REQUIRED"
        dictionary["CODE_SIGNING_ALLOWED"] = "CODE_SIGNING_ALLOWED"
        dictionary["EXPANDED_CODE_SIGN_IDENTITY_NAME"] = "EXPANDED_CODE_SIGN_IDENTITY_NAME"
        dictionary["OTHER_CODE_SIGN_FLAGS"] = "OTHER_CODE_SIGN_FLAGS"
        dictionary["VALID_ARCHS"] = "VALID_ARCHS"
        dictionary["ACTION"] = "archive"
        let subject = XcodeEnvironment(environment: dictionary,
                                       inputsAndOutputs: [(input: "a", output: "b")])
        XCTAssertEqual(subject?.configuration, "CONFIGURATION")
        XCTAssertEqual(subject?.configurationBuildDir, "CONFIGURATION_BUILD_DIR")
        XCTAssertEqual(subject?.frameworksFolderPath, "FRAMEWORKS_FOLDER_PATH")
        XCTAssertEqual(subject?.builtProductsDir, "BUILT_PRODUCTS_DIR")
        XCTAssertEqual(subject?.targetBuildDir, "TARGET_BUILD_DIR")
        XCTAssertEqual(subject?.dwardDsymFolderPath, "DWARF_DSYM_FOLDER_PATH")
        XCTAssertEqual(subject?.expandedCodeSignIdentity, "EXPANDED_CODE_SIGN_IDENTITY")
        XCTAssertEqual(subject?.codeSignRequired, "CODE_SIGNING_REQUIRED")
        XCTAssertEqual(subject?.codeSigningAllowed, "CODE_SIGNING_ALLOWED")
        XCTAssertEqual(subject?.expandedCodeSignIdentityName, "EXPANDED_CODE_SIGN_IDENTITY_NAME")
        XCTAssertEqual(subject?.otherCodeSignFlags, "OTHER_CODE_SIGN_FLAGS")
        XCTAssertEqual(subject?.validArchs, "VALID_ARCHS")
        XCTAssertEqual(subject?.action, .archive)
        XCTAssertEqual(subject?.inputsAndOutputs.first?.input, "a")
        XCTAssertEqual(subject?.inputsAndOutputs.first?.output, "b")
    }
    
    func test_pairedInputAndOutputs_pairsInputAndOutputFiles() {
        var dictionary: [String: String] = [:]
        dictionary["SCRIPT_INPUT_FILE_0"] = "0_input"
        dictionary["SCRIPT_OUTPUT_FILE_0"] = "0_output"
        dictionary["SCRIPT_INPUT_FILE_1"] = "1_input"
        dictionary["SCRIPT_OUTPUT_FILE_1"] = "1_output"
        let output = XcodeEnvironment.pairedInputAndOutputs(environment: dictionary)
        XCTAssertEqual(output[0].input, "0_input")
        XCTAssertEqual(output[0].output, "0_output")
        XCTAssertEqual(output[1].input, "1_input")
        XCTAssertEqual(output[1].output, "1_output")
    }
}
