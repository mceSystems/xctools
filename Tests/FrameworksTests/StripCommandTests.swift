import Foundation
import XCTest
import PathKit
import Core
import Frameworks
import PathKit
import TestsFoundation
import Core


// MARK: - StripCommandTests

final class StripCommandTests: XCIntegrationTestCase {
    
    var subject: StripCommand!
    
    override func setUp() {
        super.setUp()
        subject = StripCommand(packagePath: outputPath(),
                               architecturesToStrip: ["armv7"])
    }
    
    func test_execute_stripsTheGivenArchitecture() {
        try? inputPath().copy(outputPath())
        XCTAssertEqual(Package(path: outputPath()).architectures(), ["armv7", "arm64"])
        try? subject.execute()
        XCTAssertEqual(Package(path: outputPath()).architectures(), ["arm64"])
    }
    
    private func inputPath() -> Path {
        return (Path(#file) + "../../../Fixtures/iOSFramework/Test.framework")
        
    }
    
    private func outputPath() -> Path {
        return (tmpPath + "Test.framework")
    }

}
