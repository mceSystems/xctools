import Foundation
import XCTest

import xcodembed

class ActionTests: XCTestCase {
    
    func test_archive_hasTheCorrectValue() {
        XCTAssertEqual(Action.archive.rawValue, "archive")
    }
    
    func test_install_hasTheCorrectValue() {
        XCTAssertEqual(Action.install.rawValue, "install")
    }
    
}
