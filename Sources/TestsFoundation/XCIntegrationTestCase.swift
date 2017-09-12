import XCTest
import PathKit

open class XCIntegrationTestCase: XCTestCase {

    public var tmpPath: Path! = Path(NSTemporaryDirectory()) + randomString()

    override open func setUp() {
        super.setUp()
        try? tmpPath.mkpath()
    }

    override open func tearDown() {
        super.tearDown()
        try? tmpPath.delete()
    }
    
}

fileprivate func randomString(length: Int = 5) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}
