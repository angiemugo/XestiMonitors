//
//  BeaconRangingMonitorTests.swift
//  XestiMonitorsTests
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation
import XCTest
@testable import XestiMonitors

internal class BeaconRangingMonitorTests: XCTestCase {
    let locationManager = MockLocationManager()

    override func setUp() {
        super.setUp()

        LocationManagerInjector.inject = { return self.locationManager }
    }

    func testIsAvailable_false() {
        let monitor = BeaconRangingMonitor(queue: .main) { _ in }

        locationManager.updateBeaconRanging(available: false)

        XCTAssertFalse(monitor.isAvailable)
    }

    func testIsAvailable_true() {
        let monitor = BeaconRangingMonitor(queue: .main) { _ in }

        locationManager.updateBeaconRanging(available: true)

        XCTAssertTrue(monitor.isAvailable)
    }

    func testMonitor_beacons() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLBeaconRegion(proximityUUID: UUID(),
                                            identifier: "bogus")
        var expectedEvent: BeaconRangingMonitor.Event?
        let monitor = BeaconRangingMonitor(regions: [expectedRegion],
                                           queue: .main) { event in
                                            expectedEvent = event
                                            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateBeaconRanging(beacons: [],
                                            in: expectedRegion)
        waitForExpectations(timeout: 1)
        monitor.stopMonitoring()

        if let event = expectedEvent,
            case let .didUpdate(info) = event,
            case let .beacons(beacons, region) = info {
            XCTAssertEqual(region, expectedRegion)
            XCTAssertTrue(beacons.isEmpty)
        } else {
            XCTFail("Unexpected event")
        }
    }

    func testMonitor_error1() {
        let expectation = self.expectation(description: "Handler called")
        let expectedRegion = CLBeaconRegion(proximityUUID: UUID(),
                                            identifier: "bogus")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: BeaconRangingMonitor.Event?
        let monitor = BeaconRangingMonitor(regions: [expectedRegion],
                                           queue: .main) { event in
                                            expectedEvent = event
                                            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateBeaconRanging(error: expectedError,
                                            for: expectedRegion)
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
        let expectedRegion = CLBeaconRegion(proximityUUID: UUID(),
                                            identifier: "bogus")
        let expectedError = NSError(domain: "CLErrorDomain",
                                    code: CLError.Code.network.rawValue)
        var expectedEvent: BeaconRangingMonitor.Event?
        let monitor = BeaconRangingMonitor(regions: [expectedRegion],
                                           queue: .main) { event in
                                            expectedEvent = event
                                            expectation.fulfill()
        }

        monitor.startMonitoring()
        locationManager.updateBeaconRanging(error: expectedError)
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

    func testRangedRegions_empty() {
        let monitor = BeaconRangingMonitor(regions: [],
                                           queue: .main) { _ in }

        monitor.startMonitoring()
        XCTAssertTrue(monitor.rangedRegions.isEmpty)
        XCTAssertTrue(monitor.regions.isEmpty)
        monitor.stopMonitoring()
    }

    func testRangedRegions_insert() {
        let expectedRegion1 = CLBeaconRegion(proximityUUID: UUID(),
                                             identifier: "bogus1")
        let expectedRegion2 = CLBeaconRegion(proximityUUID: UUID(),
                                             identifier: "bogus2")
        let monitor = BeaconRangingMonitor(regions: [expectedRegion1],
                                           queue: .main) { _ in }

        monitor.startMonitoring()
        monitor.insertRegion(expectedRegion1)   // should add it once only
        monitor.insertRegion(expectedRegion2)
        XCTAssertEqual(monitor.rangedRegions.count, 2)
        XCTAssertTrue(monitor.rangedRegions.contains(expectedRegion1))
        XCTAssertTrue(monitor.rangedRegions.contains(expectedRegion2))
        XCTAssertEqual(monitor.regions.count, 2)
        XCTAssertTrue(monitor.regions.contains(expectedRegion1))
        XCTAssertTrue(monitor.regions.contains(expectedRegion2))
        monitor.stopMonitoring()
    }

    func testRangedRegions_remove() {
        let expectedRegion1 = CLBeaconRegion(proximityUUID: UUID(),
                                             identifier: "bogus1")
        let expectedRegion2 = CLBeaconRegion(proximityUUID: UUID(),
                                             identifier: "bogus2")
        let monitor = BeaconRangingMonitor(regions: [expectedRegion1, expectedRegion2],
                                           queue: .main) { _ in }

        monitor.startMonitoring()
        monitor.removeRegion(expectedRegion1)
        monitor.removeRegion(expectedRegion1)   // should remove it once only
        XCTAssertEqual(monitor.rangedRegions.count, 1)
        XCTAssertFalse(monitor.rangedRegions.contains(expectedRegion1))
        XCTAssertTrue(monitor.rangedRegions.contains(expectedRegion2))
        XCTAssertEqual(monitor.regions.count, 1)
        XCTAssertFalse(monitor.regions.contains(expectedRegion1))
        XCTAssertTrue(monitor.regions.contains(expectedRegion2))
        monitor.stopMonitoring()
    }
}
