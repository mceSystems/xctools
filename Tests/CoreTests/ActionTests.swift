import Foundation
import XCTest

import Core

class ActionTests: XCTestCase {
    
    func test_archive_hasTheCorrectValue() {
        XCTAssertEqual(Action.archive.rawValue, "archive")
    }
    
    func test_install_hasTheCorrectValue() {
        XCTAssertEqual(Action.install.rawValue, "install")
    }
    
}
