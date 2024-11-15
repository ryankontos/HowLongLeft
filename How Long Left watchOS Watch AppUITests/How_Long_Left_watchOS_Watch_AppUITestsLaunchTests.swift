//
//  How_Long_Left_watchOS_Watch_AppUITestsLaunchTests.swift
//  How Long Left watchOS Watch AppUITests
//
//  Created by Ryan on 24/9/2024.
//

import XCTest

final class How_Long_Left_watchOS_Watch_AppUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
