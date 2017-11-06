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
                                   Option("configs", "", flag: "c", description: "Comma separated list of configs that need the framework to be embed (e.g. Debug,Release)")) { (buildAllConfigs: Bool, configs: String) in
                                    guard let environment = XcodeEnvironment() else {
                                        return print("This command can only be executed from a build phase")
                                    }
                                    try EmbedCommand(buildAllConfigs: buildAllConfigs,
                                                     configsToBuild: configs.components(separatedBy: ","),
                                                     configuration: environment.configuration,
                                                     inputsAndOutputs: environment.inputsAndOutputs,
                                                     validArchs: environment.validArchs,
                                                     action: environment.action,
                                                     builtProductsDir: environment.builtProductsDir).execute()
        }
        let stripCommand = command(Argument("path", description: "Framework path"),
                                   Option("archs", "", flag: "a", description: "Comma separated list of architectures to strip (e.g. armv7,arm64)")) { (path: String, archs: String) in
                                    try StripCommand(packagePath: Path(path), architecturesToStrip: Set(archs.components(separatedBy: ","))).execute()
        }
        frameworks.addCommand("embed", "embeds frameworks into the product /Frameworks folder", embedCommand)
        frameworks.addCommand("strip", "strip architectures from a given framework", stripCommand)
    }
    
    $0.group("build-settings", "set of tools to work with your project build settings") { (buildSettings) in
        let exportCommand = command(Option("project", "", flag: "p", description: "Xcode project"),
                                    Option("target", "", flag: "t", description: "Target whose build settings will be extracted"),
                                    Option("output", "", flag: "o", description: "Output path (e.g. /path/output.xcconfig)")) { (project: String, target: String, output: String) in
                                        if project.isEmpty {
                                            return print("Project argument is required (e.g. -p MyProject.xcodeproj)")
                                        }
                                        if output.isEmpty {
                                            return print("Output argument is required (e.g. -o /path/output.xcconfig)")
                                        }
                                        do {
                                            try BuildSettingsExportCommand(projectPath: Path(project),
                                                                           target: target.isEmpty ? nil: target,
                                                                           output: Path(output)).execute()
                                        } catch {
                                            return print(error)
                                        }
        }
        buildSettings.addCommand("export", "export your build settings into an .xcconfig file", exportCommand)
    }
    }.run()
// swiftlint:enable line_length
