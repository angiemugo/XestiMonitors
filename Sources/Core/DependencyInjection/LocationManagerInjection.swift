//
//  LocationManagerInjection.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-22.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation

internal protocol LocationManagerProtocol: class {
    var delegate: CLLocationManagerDelegate? { get set }

//    var activityType: CLActivityType

//    var allowsBackgroundLocationUpdates: Bool

//    var desiredAccuracy: CLLocationAccuracy

//    var distanceFilter: CLLocationDistance

//    var heading: CLHeading? { get }

//    var headingFilter: CLLocationDegrees

//    var headingOrientation: CLDeviceOrientation

//    var location: CLLocation? { get }

//    var maximumRegionMonitoringDistance: CLLocationDistance { get }

    #if os(iOS) || os(macOS)
    var monitoredRegions: Set<CLRegion> { get }
    #endif

//    var pausesLocationUpdatesAutomatically: Bool

    #if os(iOS)
    var rangedRegions: Set<CLRegion> { get }
    #endif

//    var showsBackgroundLocationIndicator: Bool

    static func authorizationStatus() -> CLAuthorizationStatus

//    static func deferredLocationUpdatesAvailable() -> Bool

    #if os(iOS) || os(macOS)
    static func headingAvailable() -> Bool
    #endif

    #if os(iOS) || os(macOS)
    static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool
    #endif

    #if os(iOS)
    static func isRangingAvailable() -> Bool
    #endif

    static func locationServicesEnabled() -> Bool

    #if os(iOS) || os(macOS)
    static func significantLocationChangeMonitoringAvailable() -> Bool
    #endif

//    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance,
//                                      timeout: TimeInterval)

//    func disallowDeferredLocationUpdates()

//    func dismissHeadingCalibrationDisplay()

    #if os(iOS) || os(watchOS)
    func requestAlwaysAuthorization()
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    func requestLocation()
    #endif

    #if os(iOS) || os(macOS)
    func requestState(for region: CLRegion)
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)
    func requestWhenInUseAuthorization()
    #endif

    #if os(iOS) || os(macOS)
    func startMonitoring(for region: CLRegion)
    #endif

    #if os(iOS) || os(macOS)
    func startMonitoringSignificantLocationChanges()
    #endif

    #if os(iOS)
    func startMonitoringVisits()
    #endif

    #if os(iOS)
    func startRangingBeacons(in region: CLBeaconRegion)
    #endif

    #if os(iOS)
    func startUpdatingHeading()
    #endif

    #if os(iOS) || os(macOS) || os(watchOS)
    @available(watchOS 3.0, *)
    func startUpdatingLocation()
    #endif

    #if os(iOS) || os(macOS)
    func stopMonitoring(for region: CLRegion)
    #endif

    #if os(iOS) || os(macOS)
    func stopMonitoringSignificantLocationChanges()
    #endif

    #if os(iOS)
    func stopMonitoringVisits()
    #endif

    #if os(iOS)
    func stopRangingBeacons(in region: CLBeaconRegion)
    #endif

    #if os(iOS)
    func stopUpdatingHeading()
    #endif

    func stopUpdatingLocation()
}

extension CLLocationManager: LocationManagerProtocol {}

internal struct LocationManagerInjector {
    internal static var inject: () -> LocationManagerProtocol = { return CLLocationManager() }
}
