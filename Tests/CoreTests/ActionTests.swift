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

    func test_build_hasTheCorrectValue() {
        XCTAssertEqual(Action.build.rawValue, "build")
    }

    func test_clean_hasTheCorrectValue() {
        XCTAssertEqual(Action.clean.rawValue, "clean")
    }

    func test_installhdrs_hasTheCorrectValue() {
        XCTAssertEqual(Action.installhdrs.rawValue, "installhdrs")
    }

    func test_installsrc_hasTheCorrectValue() {
        XCTAssertEqual(Action.installsrc.rawValue, "installsrc")
    }

}
