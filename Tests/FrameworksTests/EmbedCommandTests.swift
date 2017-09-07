import Foundation
import XCTest
import PathKit
import Frameworks

// MARK: - SymbolsCopierTests

final class SymbolsCopierTests: XCTestCase {
    
    func test_copyDsyms_copiesTheFilesFromAndToTheRightPaths() {
        var from: Path!
        var to: Path!
        let subject = SymbolsCopier { (_from, _to) in
            from = _from
            to = _to
        }
        try? subject.copyDsyms(inputPath: "from/test.framework",
                               destinationPath: "frameworks",
                               keepingArchitectures: ["aa"])
        XCTAssertEqual(from, "from/test.framework.dSYM")
        XCTAssertEqual(to, "frameworks/test.framework.dSYM")
    }
    
}

// MARK: - EmbedErrorTests

final class EmbedErrorTests: XCTestCase {
    
    func test_notFound_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.notFound(path: "test/").description, "File not found at path: test/")
    }
    
    func test_invalidExtension_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.invalidExtension(path: "test/").description, "File doesn't have a .framework extension: test/")
    }
    
}

// MARK: - MockSymbolsCopyer

final class MockSymbolsCopyer: SymbolsCopying {
    
    var copyDsymsCount: UInt = 0
    var copyDsymsStub: Error? = nil
    var copyDsymsSpy: (inputPath: Path, destinationPath: Path, keepingArchitectures: [String])?
    
    func copyDsyms(inputPath: Path, destinationPath: Path, keepingArchitectures: [String]) throws {
        copyDsymsCount += 1
        copyDsymsSpy = (inputPath: inputPath, destinationPath: destinationPath, keepingArchitectures: keepingArchitectures)
        if let copyDsymsStub = copyDsymsStub {
            throw copyDsymsStub
        }
    }
    
}
