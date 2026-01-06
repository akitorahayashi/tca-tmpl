@testable import TemplateApp
import XCTest

final class TemplateAppTests: XCTestCase {
  func testAppConfigurationValues() {
    XCTAssertEqual(AppConfiguration.appName, "Template App")
    XCTAssertEqual(AppConfiguration.bundleIdPrefix, "com.akitorahayashi")
    XCTAssertEqual(AppConfiguration.minimumIOSVersion, "17.0")
  }

  func testAppDependenciesLive() {
    let dependencies = AppDependencies.live()
    XCTAssertNotNil(dependencies)
  }

  #if DEBUG
    func testAppDependenciesMock() {
      let dependencies = AppDependencies.mock()
      XCTAssertNotNil(dependencies)
    }
  #endif
}
