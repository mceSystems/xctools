import Foundation

enum EmbedError: Error, CustomStringConvertible {
    case notFound(path: String)
    case invalidExtension
    var description: String {
        switch self {
        case .notFound(let path):
            return "File not found at path: \(path)"
        case .invalidExtension(let path):
            return "File doesn't have a .framework extension: \(path)"
        }
    }
}
