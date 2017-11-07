import Foundation
import XCTest

@testable import Core

final class StringExtrasTests: XCTestCase {
    
    func test_condensedWhitespace_returnsTheCorrectValue() {
        let subject = "  a  b      c d ".condensedWhitespace
        XCTAssertEqual(subject, "a b c d")
    }
    
}
