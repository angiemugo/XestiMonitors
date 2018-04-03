//
//  BeaconRangingMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

#if os(iOS)

import CoreLocation

///
/// A `BeaconRangingMonitor` instance monitors the range (_i.e._, the relative
/// proximity) to Bluetooth low-energy beacons inside one or more regions.
///
public class BeaconRangingMonitor: BaseMonitor {
    ///
    /// Encapsulates changes to the beacon ranges inside a region.
    ///
    public enum Event {
        ///
        /// One or more beacon ranges have been updated.
        ///
        case didUpdate(Info)
    }

    ///
    /// Encapsulates information associated with a beacon ranging monitor
    /// event.
    ///
    public enum Info {
        ///
        /// The current beacon ranges.
        ///
        case beacons([CLBeacon], CLBeaconRegion)

        ///
        /// The error encountered in attempting to determine the beacon ranges
        /// inside a region.
        ///
        case error(Error, CLBeaconRegion?)
    }

    ///
    /// Initializes a new `BeaconRangingMonitor`.
    ///
    /// - Parameters:
    ///   - regions:    The initial set of beacon regions to monitor for range
    ///                 changes. This set can be subsequently modified with the
    ///                 `insertRegion(_:)` and `removeRegion(_:)` methods.
    ///   - queue:      The operation queue on which the handler executes.
    ///   - handler:    The handler to call when a beacon range change is
    ///                 detected.
    ///
    public init(regions: Set<CLBeaconRegion> = [],
                queue: OperationQueue,
                handler: @escaping (Event) -> Void) {
        self.adapter = .init()
        self.handler = handler
        self.locationManager = LocationManagerInjector.inject()
        self.queue = queue
        self.regions = regions

        super.init()

        self.adapter.didFail = { [unowned self] in
            self.handler(.didUpdate(.error($0, nil)))
        }

        self.adapter.didRangeBeacons = { [unowned self] in
            self.handler(.didUpdate(.beacons($1, $0)))
        }

        self.adapter.rangingBeaconsDidFail = { [unowned self] in
            self.handler(.didUpdate(.error($1, $0)))
        }

        self.locationManager.delegate = self.adapter
    }

    ///
    /// A Boolean value indicating whether the device supports ranging of
    /// Bluetooth beacons.
    ///
    public var isAvailable: Bool {
        return type(of: locationManager).isRangingAvailable()
    }

    ///
    /// The set of beacon regions actively being tracked using ranging. There
    /// is a system-imposed, per-app limit to how many regions can be actively
    /// ranged. Therefore, `rangedRegions` _may_ be less than `regions.count`.
    ///
    public var rangedRegions: Set<CLBeaconRegion> {
        guard
            isMonitoring
            else { return [] }

        #if swift(>=4.1)
        let tmpRegions = Set(locationManager.rangedRegions.compactMap { $0 as? CLBeaconRegion })
        #else
        let tmpRegions = Set(locationManager.rangedRegions.flatMap { $0 as? CLBeaconRegion })
        #endif

        return tmpRegions.intersection(regions)
    }

    //
    // The set of beacon regions _possibly_ being tracked using ranging.
    //
    public private(set) var regions: Set<CLBeaconRegion>

    ///
    /// Inserts the given beacon region into `regions` if it is not already
    /// present. If monitoring is active _and_ the system allows it, ranging of
    /// the given beacon region will be started.
    ///
    /// - Parameters:
    ///   - region: The beacon region to insert into the set and possibly start
    ///             ranging.
    ///
    public func insertRegion(_ region: CLBeaconRegion) {
        if regions.insert(region).inserted,
            isMonitoring {
            locationManager.startRangingBeacons(in: region)
        }
    }

    ///
    /// Removes the given beacon region from `regions` if it is present.
    /// If monitoring is active, ranging of the given beacon region will be
    /// stopped.
    ///
    /// - Parameters:
    ///   - region: The beacon region to remove from the set and stop ranging.
    ///
    public func removeRegion(_ region: CLBeaconRegion) {
        if regions.remove(region) != nil,
            isMonitoring {
            locationManager.stopRangingBeacons(in: region)
        }
    }

    private let adapter: LocationManagerDelegateAdapter
    private let handler: (Event) -> Void
    private let locationManager: LocationManagerProtocol
    private let queue: OperationQueue

    override public func cleanupMonitor() {
        regions.forEach { locationManager.stopRangingBeacons(in: $0) }

        super.cleanupMonitor()
    }

    override public func configureMonitor() {
        super.configureMonitor()

        regions.forEach { locationManager.startRangingBeacons(in: $0) }
    }
}

#endif
