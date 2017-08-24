import Foundation
import XCTest

import Frameworks

final class EmbedErrorTests: XCTestCase {

    func test_notFound_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.notFound(path: "test/").description, "File not found at path: test/")
    }

    func test_invalidExtension_returnsTheCorrectDescription() {
        XCTAssertEqual(EmbedError.invalidExtension(path: "test/").description, "File doesn't have a .framework extension: test/")
    }


}
