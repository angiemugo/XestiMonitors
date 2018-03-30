//
//  HeadingMonitorTests.swift
//  XestiMonitorsTests
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation
import XCTest
@testable import XestiMonitors

internal class HeadingMonitorTests: XCTestCase {
    let locationManager = MockLocationManager()

    override func setUp() {
        super.setUp()

        LocationManagerInjector.inject = { return self.locationManager }
    }

    func testIsAvailable_false() {
        let monitor = HeadingMonitor(queue: .main) { _ in }

        locationManager.updateHeading(available: false)

        XCTAssertFalse(monitor.isAvailable)
    }

    func testIsAvailable_true() {
        let monitor = HeadingMonitor(queue: .main) { _ in }

        locationManager.updateHeading(available: true)

        XCTAssertTrue(monitor.isAvailable)
    }

    func testMonitor_error() {
        let expectation = self.expectation(description: "Handler called")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: HeadingMonitor.Event?
        let monitor = HeadingMonitor(queue: .main) { event in
            expectedEvent = event
            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateHeading(error: expectedError)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .error(error) = info {
            XCTAssertEqual(error as NSError, expectedError)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_heading() {
        let expectation = self.expectation(description: "Handler called")
        let expectedHeading = CLHeading()
        var expectedEvent: HeadingMonitor.Event?
        let monitor = HeadingMonitor(queue: .main) { event in
            expectedEvent = event
            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateHeading(expectedHeading)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .heading(heading) = info {
            XCTAssertEqual(heading, expectedHeading)
        } else {
            XCTFail("Unexpected event")
        }
    }
}
