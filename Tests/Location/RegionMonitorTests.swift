//
//  RegionMonitorTests.swift
//  XestiMonitorsTests
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation
import XCTest
@testable import XestiMonitors

internal class RegionMonitorTests: XCTestCase {
    let locationManager = MockLocationManager()

    override func setUp() {
        super.setUp()

        LocationManagerInjector.inject = { return self.locationManager }
    }

    func testIsAvailable_false() {
        let monitor = RegionMonitor(queue: .main) { _ in }

        locationManager.updateRegion(available: false)

        XCTAssertFalse(monitor.isAvailable)
    }

    func testIsAvailable_true() {
        let monitor = RegionMonitor(queue: .main) { _ in }

        locationManager.updateRegion(available: true)

        XCTAssertTrue(monitor.isAvailable)
    }

    func testMonitor_error1() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateRegion(expectedRegion,
                                     error: expectedError)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .error(error, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertEqual(error as NSError, expectedError)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_error2() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateRegion(error: expectedError)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .error(error, region) = info {
            XCTAssertNil(region)
            XCTAssertEqual(error as NSError, expectedError)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_regionState_enter() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateRegion(enter: expectedRegion)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .regionState(state, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertEqual(state, .inside)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_regionState_exit() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateRegion(exit: expectedRegion)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .regionState(state, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertEqual(state, .outside)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_regionState_request() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        let expectedState = CLRegionState.inside
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.requestState(for: expectedRegion)
        locationManager.updateRegion(state: expectedState)
        waitForExpectations(timeout: 1)

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .regionState(state, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertEqual(state, expectedState)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_regionState_start() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                              radius: 100,
                                              identifier: "bogus")
        var expectedEvent: RegionMonitor.Event?
        let monitor = RegionMonitor(regions: [expectedRegion],
                                    queue: .main) { event in
                                        expectedEvent = event
                                        expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateRegion(start: expectedRegion)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .regionState(state, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertEqual(state, .unknown)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitoredRegions_empty() {
        let monitor = RegionMonitor(regions: [],
                                    queue: .main) { _ in }

        monitor.startMonitoring()
        XCTAssertTrue(monitor.monitoredRegions.isEmpty)
        XCTAssertTrue(monitor.regions.isEmpty)
        monitor.stopMonitoring()
    }

    func testMonitoredRegions_insert() {
        let expectedRegion1 = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                               radius: 100,
                                               identifier: "bogus1")
        let expectedRegion2 = CLCircularRegion(center: CLLocationCoordinate2DMake(200, 200),
                                               radius: 100,
                                               identifier: "bogus2")
        let monitor = RegionMonitor(regions: [expectedRegion1],
                                    queue: .main) { _ in }

        monitor.startMonitoring()
        monitor.insertRegion(expectedRegion1)   // should add it once only
        monitor.insertRegion(expectedRegion2)
        XCTAssertEqual(monitor.monitoredRegions.count, 2)
        XCTAssertTrue(monitor.monitoredRegions.contains(expectedRegion1))
        XCTAssertTrue(monitor.monitoredRegions.contains(expectedRegion2))
        XCTAssertEqual(monitor.regions.count, 2)
        XCTAssertTrue(monitor.regions.contains(expectedRegion1))
        XCTAssertTrue(monitor.regions.contains(expectedRegion2))
        monitor.stopMonitoring()
    }

    func testMonitoredRegions_remove() {
        let expectedRegion1 = CLCircularRegion(center: CLLocationCoordinate2DMake(100, 100),
                                               radius: 100,
                                               identifier: "bogus1")
        let expectedRegion2 = CLCircularRegion(center: CLLocationCoordinate2DMake(200, 200),
                                               radius: 100,
                                               identifier: "bogus2")
        let monitor = RegionMonitor(regions: [expectedRegion1, expectedRegion2],
                                    queue: .main) { _ in }

        monitor.startMonitoring()
        monitor.removeRegion(expectedRegion1)
        monitor.removeRegion(expectedRegion1)   // should remove it once only
        XCTAssertEqual(monitor.monitoredRegions.count, 1)
        XCTAssertFalse(monitor.monitoredRegions.contains(expectedRegion1))
        XCTAssertTrue(monitor.monitoredRegions.contains(expectedRegion2))
        XCTAssertEqual(monitor.regions.count, 1)
        XCTAssertFalse(monitor.regions.contains(expectedRegion1))
        XCTAssertTrue(monitor.regions.contains(expectedRegion2))
        monitor.stopMonitoring()
    }
}
