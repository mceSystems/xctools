// swiftlint:disable line_length
import Foundation
import Commander
import PathKit
import BuildSettings
import Frameworks
import Core

Group {
    $0.group("frameworks", "set of tools to work with frameworks in your project") { (frameworks) in
        let embedCommand = command(Flag("allconfigs", flag: "a", description: "Embed the frameworks for all the configurations", default: true),
                                   Option("configs", "", flag: "c", description: "Array separated list of configs that need the framework to be embed (e.g. Debug,Release)")) { (buildAllConfigs: Bool, configs: String) in
                                    try EmbedCommand(buildAllConfigs: buildAllConfigs, configsToBuild: configs.components(separatedBy: ","), xcodeEnvironment: XcodeEnvironment()!).execute()
        }
        frameworks.addCommand("embed", "embeds frameworks into the product /Frameworks folder", embedCommand)
    }
//    $0.group("version", "set of tools to update the version of your projects", closure: { (version) in
//        let upgradeCommand = command {
//            
//        }
//        let downgradeCommand = command {
//            
//        }
//        version.addCommand("upgrade", "upgrades the version of your project", upgradeCommand)
//        version.addCommand("downgrade", "downgrades the version of your project", downgradeCommand)
//    })
//    $0.group("build-settings", "a set of tools to interact with your project/target build settings", closure: { (buildSettings) in
//        let cleanCommand = command(Option("target", "", flag: "t", description: "The target whose build settings will be cleaned"),
//                                   Argument("project", description: "The project to execute the command on")) { (target: String, project: String) in
//                                    try BuildSettingsCleanCommand(projectPath: Path(project),
//                                                                  target: target).execute()
//        }
//        buildSettings.addCommand("clean", "removes all the build settings from the given project/target", cleanCommand)
//    })
}.run()
// swiftlint:enable line_length
