import Foundation
import XCTest
import PathKit

import Frameworks

final class SymbolsCopierTests: XCTestCase {

    func test_copyDsyms_copiesTheFilesFromAndToTheRightPaths() {
        var from: Path!
        var to: Path!
        let subject = SymbolsCopier { (_from, _to) in
            from = _from
            to = _to
        }
        try? subject.copyDsyms(inputPath: "from/test.framework",
                          destinationPath: "frameworks")
        XCTAssertEqual(from, "from/test.framework.dSYM")
        XCTAssertEqual(to, "frameworks/test.framework.dSYM")
    }

}
