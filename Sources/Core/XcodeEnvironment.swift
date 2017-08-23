// Reference: https://developer.apple.com/legacy/library/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html#//apple_ref/doc/uid/TP40003931-CH3-SW105
import Foundation
import PathKit

public struct XcodeEnvironment {

    // MARK: - Attributes

    public let configuration: String
    public let configurationBuildDir: String
    public let frameworksFolderPath: String
    public let builtProductsDir: String
    public let targetBuildDir: String
    public let dwardDsymFolderPath: String
    public let expandedCodeSignIdentity: String
    public let codeSignRequired: String
    public let codeSigningAllowed: String
    public let expandedCodeSignIdentityName: String
    public let otherCodeSignFlags: String
    public let validArchs: String
    public let action: Action
    public let inputsAndOutputs: [(input: String, output: String)]

    // MARK: - Init

    public init?(environment: [String: String] = ProcessInfo.processInfo.environment,
                 inputsAndOutputs: [(input: String, output: String)] = XcodeEnvironment.pairedInputAndOutputs()) {
        guard let configuration = environment["CONFIGURATION"] else { return nil }
        guard let configurationBuildDir = environment["CONFIGURATION_BUILD_DIR"] else { return nil }
        guard let frameworksFolderPath = environment["FRAMEWORKS_FOLDER_PATH"] else { return nil }
        guard let builtProductsDir = environment["BUILT_PRODUCTS_DIR"] else { return nil }
        guard let targetBuildDir = environment["TARGET_BUILD_DIR"] else { return nil }
        guard let dwardDsymFolderPath = environment["DWARF_DSYM_FOLDER_PATH"] else { return nil }
        guard let expandedCodeSignIdentity = environment["EXPANDED_CODE_SIGN_IDENTITY"] else { return nil }
        guard let codeSignRequired = environment["CODE_SIGNING_REQUIRED"] else { return nil }
        guard let codeSigningAllowed = environment["CODE_SIGNING_ALLOWED"] else { return nil }
        guard let expandedCodeSignIdentityName = environment["EXPANDED_CODE_SIGN_IDENTITY_NAME"] else { return nil }
        guard let otherCodeSignFlags = environment["OTHER_CODE_SIGN_FLAGS"] else { return nil }
        guard let validArchs = environment["VALID_ARCHS"] else { return nil }
        guard let action = environment["ACTION"] else { return nil }
        self.configuration = configuration
        self.configurationBuildDir = configurationBuildDir
        self.frameworksFolderPath = frameworksFolderPath
        self.builtProductsDir = builtProductsDir
        self.targetBuildDir = targetBuildDir
        self.dwardDsymFolderPath = dwardDsymFolderPath
        self.expandedCodeSignIdentity = expandedCodeSignIdentity
        self.codeSignRequired = codeSignRequired
        self.codeSigningAllowed = codeSigningAllowed
        self.expandedCodeSignIdentityName = expandedCodeSignIdentityName
        self.otherCodeSignFlags = otherCodeSignFlags
        self.validArchs = validArchs
        self.action = Action(rawValue: action) ?? .install
        self.inputsAndOutputs = inputsAndOutputs
    }
    
    // MARK: - Public
    
    public func destinationPath() -> Path {
        if action == .install {
            return Path(builtProductsDir)
        } else {
            return Path(targetBuildDir)
        }
    }
    
    private func frameworksPath() -> Path {
        return destinationPath() + Path(frameworksFolderPath)
    }
    
    // MARK: - Static
    
    public static func pairedInputAndOutputs(environment: [String: String] = ProcessInfo.processInfo.environment) -> [(input: String, output: String)] {
        var array: [(input: String, output: String)] = []
        var count: Int = 0
        while(true) {
            guard let input = environment["SCRIPT_INPUT_FILE_\(count)"],
                let output = environment["SCRIPT_OUTPUT_FILE_\(count)"] else {
                    return array
            }
            array.append((input: input, output: output))
            count += 1
        }
    }

}
