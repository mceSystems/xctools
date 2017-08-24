// import Foundation
// import Commander
// import xcodembed

// let allConfigsFlag = Flag("allconfigs", flag: "a", description: "Embed the frameworks for all the configurations", default: true)
// let configFlag = Option("configs", "", flag: "c", description: "Array separated list of configs that need the framework to be embed (e.g. Debug,Release)")
// let main = command(allConfigsFlag, configFlag) { (allConfigs: Bool, configs: String) in
//     guard let xcodeEnvironment = XcodeEnvironment() else {
//         return print("Some Xcode variables are missing, make sure that you are running the script in a build phase")
//     }
// //    try EmbedCommand(buildAllConfigs: allConfigs,
// //                     configsToBuild: configs.components(separatedBy: ","),
// //                     xcodeEnvironment: xcodeEnvironment).execute()
// }
// main.run()

