import Foundation
import SwiftShell

/// Returns the path of the command in the system. If cannot be found, it returns the default path.
///
/// - Parameters:
///   - command: command whose path will be returned.
///   - defaultPath: default path in case it cannot be found.
/// - Returns: the path in the system or the default one.
func which(command: String, defaultPath: String) -> String {
    let output = run("which", command)
    if output.error == nil && !output.stdout.isEmpty {
        return output.stdout
    } else {
        return defaultPath
    }
}
