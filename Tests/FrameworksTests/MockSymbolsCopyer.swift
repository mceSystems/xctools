import Foundation
import PathKit

import Frameworks

final class MockSymbolsCopyer: SymbolsCopying {
    
    var copyDsymsCount: UInt = 0
    var copyDsymsStub: Error? = nil
    var copyDsymsSpy: (inputPath: Path, destinationPath: Path)?
    
    func copyDsyms(inputPath: Path, destinationPath: Path) throws {
        copyDsymsCount += 1
        copyDsymsSpy = (inputPath: inputPath, destinationPath: destinationPath)
        if let copyDsymsStub = copyDsymsStub {
            throw copyDsymsStub
        }
    }
    
}
