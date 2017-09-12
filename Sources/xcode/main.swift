// swiftlint:disable line_length
import Foundation
import Commander
import PathKit
import BuildSettings
import Frameworks
import Core

enum XcodeError: Error {
    case xcodeEnvironmentNotFound
}

Group {
    $0.group("frameworks", "set of tools to work with frameworks in your project") { (frameworks) in
        let embedCommand = command(Flag("allconfigs", flag: "a", description: "Embed the frameworks for all the configurations", default: true),
                                   Option("configs", "", flag: "c", description: "Array separated list of configs that need the framework to be embed (e.g. Debug,Release)")) { (buildAllConfigs: Bool, configs: String) in                                    
                                    guard let environment = XcodeEnvironment() else{
                                        throw XcodeError.xcodeEnvironmentNotFound
                                    }
                                    try EmbedCommand(buildAllConfigs: buildAllConfigs,
                                                     configsToBuild: configs.components(separatedBy: ","),
                                                     configuration: environment.configuration,
                                                     inputsAndOutputs: environment.inputsAndOutputs,
                                                     validArchs: environment.validArchs,
                                                     action: environment.action,
                                                     builtProductsDir: environment.builtProductsDir).execute()
        }
        frameworks.addCommand("embed", "embeds frameworks into the product /Frameworks folder", embedCommand)
    }
    }.run()
// swiftlint:enable line_length
