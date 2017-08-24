 import Foundation
 import Commander
 
 Group {
    $0.group("frameworks", "set of tools to work with frameworks in your project") { (frameworks) in
        let embedCommand = command(Flag("allconfigs", flag: "a", description: "Embed the frameworks for all the configurations", default: true),
                                   Option("configs", "", flag: "c", description: "Array separated list of configs that need the framework to be embed (e.g. Debug,Release)")) { (allConfigs: Bool, configs: String) in
                                    
        }
        frameworks.addCommand("embed", "embeds frameworks into the product /Frameworks folder", embedCommand)
    }
}.run()
