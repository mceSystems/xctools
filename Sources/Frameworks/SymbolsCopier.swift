import Foundation
import PathKit

public protocol SymbolsCopying {
    func copyDsyms(inputPath: Path, destinationPath: Path) throws
}

public class SymbolsCopier: SymbolsCopying {
    
    let copy: (Path, Path) throws -> Void
    
    public init(copy: @escaping (Path, Path) throws -> Void = { try $0.copy($1) }) {
        self.copy = copy
    }
    
    public func copyDsyms(inputPath: Path, destinationPath: Path) throws {
        let inputDsymPath = Path(inputPath.string + ".dSYM")
        let outputDsymPath = destinationPath + inputDsymPath.lastComponent
        try copy(inputDsymPath, outputDsymPath)
    }
    
}
