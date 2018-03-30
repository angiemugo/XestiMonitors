//
//  MockLocationManager.swift
//  XestiMonitorsTests
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation
@testable import XestiMonitors

// swiftlint:disable type_body_length

internal class MockLocationManager: LocationManagerProtocol {
    init() {
        self.mockAlwaysAuthorizationRequested = false
        self.mockHeadingRunning = false
        self.mockLocationRequested = false
        self.mockRegionStateRequested = nil
        self.mockSignificantLocationRunning = false
        self.mockStandardLocationRunning = false
        self.mockVisitRunning = false
        self.mockWhenInUseAuthorizationRequested = false

        #if os(iOS) || os(macOS)
            self.monitoredRegions = []
        #endif
        #if os(iOS)
            self.rangedRegions = []
        #endif
    }

    weak var delegate: CLLocationManagerDelegate?

    #if os(iOS) || os(macOS)
    private(set) var monitoredRegions: Set<CLRegion>
    #endif

    #if os(iOS)
    private(set) var rangedRegions: Set<CLRegion>
    #endif

    #if os(iOS) || os(macOS)
    static func headingAvailable() -> Bool {
        return mockHeadingAvailable
    }
    #endif

    static func authorizationStatus() -> CLAuthorizationStatus {
        return mockAuthorizationStatus
    }

    #if os(iOS) || os(macOS)
    static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
        if regionClass is CLRegion.Type {
            return mockRegionAvailable
        } else {
            return false
        }
    }
    #endif

    #if os(iOS)
    static func isRangingAvailable() -> Bool {
        return mockBeaconRangingAvailable
    }
    #endif

    static func locationServicesEnabled() -> Bool {
        return mockLocationServicesEnabled
    }

    #if os(iOS) || os(macOS)
    static func significantLocationChangeMonitoringAvailable() -> Bool {
        return mockSignificantLocationAvailable
    }
    #endif

    #if os(iOS) || os(watchOS)
    func requestAlwaysAuthorization() {
        mockAlwaysAuthorizationRequested = true
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    func requestLocation() {
        mockLocationRequested = true
    }
    #endif

    #if os(iOS) || os(macOS)
    func requestState(for region: CLRegion) {
        mockRegionStateRequested = region
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    func requestWhenInUseAuthorization() {
        mockWhenInUseAuthorizationRequested = true
    }
    #endif

    #if os(iOS) || os(macOS)
    func startMonitoring(for region: CLRegion) {
        monitoredRegions.insert(region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func startMonitoringSignificantLocationChanges() {
        mockSignificantLocationRunning = true
    }
    #endif

    #if os(iOS)
    func startMonitoringVisits() {
        mockVisitRunning = true
    }
    #endif

    #if os(iOS)
    func startRangingBeacons(in region: CLBeaconRegion) {
        rangedRegions.insert(region)
    }
    #endif

    #if os(iOS)
    func startUpdatingHeading() {
        mockHeadingRunning = true
    }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS)
    @available(watchOS 3.0, *)
    func startUpdatingLocation() {
        mockStandardLocationRunning = true
    }
    #endif

    #if os(iOS) || os(macOS)
    func stopMonitoring(for region: CLRegion) {
        monitoredRegions.remove(region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func stopMonitoringSignificantLocationChanges() {
        mockSignificantLocationRunning = false
    }
    #endif

    #if os(iOS)
    func stopMonitoringVisits() {
        mockVisitRunning = false
    }
    #endif

    #if os(iOS)
    func stopRangingBeacons(in region: CLBeaconRegion) {
        rangedRegions.remove(region)
    }
    #endif

    #if os(iOS)
    func stopUpdatingHeading() {
        mockHeadingRunning = false
    }
    #endif

    func stopUpdatingLocation() {
        mockStandardLocationRunning = false
    }

    private static var mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
    private static var mockBeaconRangingAvailable = false
    private static var mockHeadingAvailable = false
    private static var mockLocationServicesEnabled = false
    private static var mockRegionAvailable = false
    private static var mockSignificantLocationAvailable = false

    private var mockAlwaysAuthorizationRequested: Bool
    private var mockHeadingRunning: Bool
    private var mockLocationRequested: Bool
    private var mockRegionStateRequested: CLRegion?
    private var mockSignificantLocationRunning: Bool
    private var mockStandardLocationRunning: Bool
    private var mockVisitRunning: Bool
    private var mockWhenInUseAuthorizationRequested: Bool

    private var locationManager: CLLocationManager {
        return unsafeBitCast(self,
                             to: CLLocationManager.self)
    }

    // MARK: -

    func updateAuthorization(error: Error) {
        guard
            mockAlwaysAuthorizationRequested
                || mockWhenInUseAuthorizationRequested
            else { return }

        mockAlwaysAuthorizationRequested = false
        mockWhenInUseAuthorizationRequested = false

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }

    func updateAuthorization(forceStatus: CLAuthorizationStatus) {
        type(of: self).mockAuthorizationStatus = forceStatus
    }

    func updateAuthorization(status: CLAuthorizationStatus) {
        guard
            mockAlwaysAuthorizationRequested
                || mockWhenInUseAuthorizationRequested
            else { return }

        mockAlwaysAuthorizationRequested = false
        mockWhenInUseAuthorizationRequested = false

        type(of: self).mockAuthorizationStatus = status

        delegate?.locationManager?(locationManager,
                                   didChangeAuthorization: status)
    }

    #if os(iOS)
    func updateBeaconRanging(available: Bool) {
        type(of: self).mockBeaconRangingAvailable = available
    }
    #endif

    #if os(iOS)
    func updateBeaconRanging(error: Error) {
        guard
            !rangedRegions.isEmpty
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }
    #endif

    #if os(iOS)
    func updateBeaconRanging(error: Error,
                             for region: CLBeaconRegion) {
        guard
            rangedRegions.contains(region)
            else { return }

        delegate?.locationManager?(locationManager,
                                   rangingBeaconsDidFailFor: region,
                                   withError: error)
    }
    #endif

    #if os(iOS)
    func updateBeaconRanging(beacons: [CLBeacon],
                             in region: CLBeaconRegion) {
        guard
            rangedRegions.contains(region)
            else { return }

        delegate?.locationManager?(locationManager,
                                   didRangeBeacons: beacons,
                                   in: region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateHeading(available: Bool) {
        type(of: self).mockHeadingAvailable = available
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateHeading(error: Error) {
        guard
            mockHeadingRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }
    #endif

    #if os(iOS)
    func updateHeading(_ heading: CLHeading) {
        guard
            mockHeadingRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didUpdateHeading: heading)
    }
    #endif

    func updateLocationServices(enabled: Bool) {
        type(of: self).mockLocationServicesEnabled = enabled
    }

    #if os(iOS) || os(macOS)
    func updateRegion(_ region: CLRegion?,
                      error: Error) {
        if let region = region {
            guard
                monitoredRegions.contains(region)
                else { return }
        }

        delegate?.locationManager?(locationManager,
                                   monitoringDidFailFor: region,
                                   withError: error)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(available: Bool) {
        type(of: self).mockRegionAvailable = available
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(enter region: CLRegion) {
        guard
            monitoredRegions.contains(region)
            else { return }

        delegate?.locationManager?(locationManager,
                                   didEnterRegion: region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(error: Error) {
        guard
            !monitoredRegions.isEmpty
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(exit region: CLRegion) {
        guard
            monitoredRegions.contains(region)
            else { return }

        delegate?.locationManager?(locationManager,
                                   didExitRegion: region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(state: CLRegionState) {
        guard
            let region = mockRegionStateRequested
            else { return }

        delegate?.locationManager?(locationManager,
                                   didDetermineState: state,
                                   for: region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateRegion(start region: CLRegion) {
        guard
            monitoredRegions.contains(region)
            else { return }

        delegate?.locationManager?(locationManager,
                                   didStartMonitoringFor: region)
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateSignificantLocation(available: Bool) {
        type(of: self).mockSignificantLocationAvailable = available
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateSignificantLocation(_ location: CLLocation) {
        guard
            mockSignificantLocationRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didUpdateLocations: [location])
    }
    #endif

    #if os(iOS) || os(macOS)
    func updateSignificantLocation(error: Error) {
        guard
            mockSignificantLocationRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }
    #endif

    func updateStandardLocation(_ location: CLLocation) {
        guard
            mockLocationRequested
                || mockStandardLocationRunning
            else { return }

        mockLocationRequested = false

        delegate?.locationManager?(locationManager,
                                   didUpdateLocations: [location])
    }

    func updateStandardLocation(error: Error) {
        guard
            mockStandardLocationRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }

    #if os(iOS)
    func updateVisit(_ visit: CLVisit) {
        guard
            mockVisitRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didVisit: visit)
    }
    #endif

    #if os(iOS)
    func updateVisit(error: Error) {
        guard
            mockVisitRunning
            else { return }

        delegate?.locationManager?(locationManager,
                                   didFailWithError: error)
    }
    #endif
}

// swiftlint:enable type_body_length
