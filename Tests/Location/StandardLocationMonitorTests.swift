//
//  StandardLocationMonitorTests.swift
//  XestiMonitorsTests
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation
import XCTest
@testable import XestiMonitors

internal class StandardLocationMonitorTests: XCTestCase {
    let locationManager = MockLocationManager()

    override func setUp() {
        super.setUp()

        LocationManagerInjector.inject = { return self.locationManager }
    }

    #if os(iOS) || os(macOS) || os(watchOS)
    func testMonitor_error() {
        let expectation = self.expectation(description: "Handler called")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: StandardLocationMonitor.Event?
        let monitor = StandardLocationMonitor(queue: .main) { event in
            expectedEvent = event
            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateStandardLocation(error: expectedError)
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
    #endif

    #if os(iOS) || os(macOS) || os(watchOS)
    func testMonitor_locations() {
        let expectation = self.expectation(description: "Handler called")
        let expectedLocation = CLLocation()
        var expectedEvent: StandardLocationMonitor.Event?
        let monitor = StandardLocationMonitor(queue: .main) { event in
            expectedEvent = event
            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateStandardLocation(expectedLocation)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .locations(locations) = info,
            let location = locations.last {
            XCTAssertEqual(location, expectedLocation)
        } else {
            XCTFail("Unexpected event")
        }
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    func testMonitor_requestLocation() {
        let expectation = self.expectation(description: "Handler called")
        let expectedLocation = CLLocation()
        var expectedEvent: StandardLocationMonitor.Event?
        let monitor = StandardLocationMonitor(queue: .main) { event in
            expectedEvent = event
            expectation.fulfill()
        }

        monitor.requestLocation()
        locationManager.updateStandardLocation(expectedLocation)
        waitForExpectations(timeout: 1)

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .locations(locations) = info,
            let location = locations.first {
            XCTAssertEqual(location, expectedLocation)
        } else {
            XCTFail("Unexpected event")
        }
    }
    #endif
}
