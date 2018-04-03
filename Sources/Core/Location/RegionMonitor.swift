//
//  RegionMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

#if os(iOS) || os(macOS)

import CoreLocation

///
/// A `RegionMonitor` instance monitors one or more distinct regions of
/// interest for state changes (which indicate boundary transitions). A region
/// can be either a geographical region or a Bluetooth low-energy beacon
/// region.
///
/// - Note:
///   An authorization status of `authorizedAlways` is required.
///
public class RegionMonitor: BaseMonitor {
    ///
    /// Encapsulates changes to the state of a region.
    ///
    public enum Event {
        ///
        /// A region state has been updated.
        ///
        case didUpdate(Info)
    }

    ///
    /// Encapsulates information associated with a region monitor event.
    ///
    public enum Info {
        ///
        /// The error encountered in attempting to determine a region state.
        ///
        case error(Error, CLRegion?)

        ///
        /// The region state.
        ///
        case regionState(CLRegionState, CLRegion)
    }

    ///
    /// Initializes a new `RegionMonitor`.
    ///
    /// - Parameters:
    ///   - regions:    The initial set of regions to monitor for state
    ///                 changes. This set can be subsequently modified with the
    ///                 `insertRegion(_:)` and `removeRegion(_:)` methods.
    ///   - queue:      The operation queue on which the handler executes.
    ///   - handler:    The handler to call when a region state change is
    ///                 detected.
    ///
    public init(regions: Set<CLRegion> = [],
                queue: OperationQueue,
                handler: @escaping (Event) -> Void) {
        self.adapter = .init()
        self.handler = handler
        self.locationManager = LocationManagerInjector.inject()
        self.queue = queue
        self.regions = regions

        super.init()

        self.adapter.didDetermineState = { [unowned self] in
            self.handler(.didUpdate(.regionState($1, $0)))
        }

        self.adapter.didEnterRegion = { [unowned self] in
            self.handler(.didUpdate(.regionState(.inside, $0)))
        }

        self.adapter.didExitRegion = { [unowned self] in
            self.handler(.didUpdate(.regionState(.outside, $0)))
        }

        self.adapter.didFail = { [unowned self] in
            self.handler(.didUpdate(.error($0, nil)))
        }

        self.adapter.didStartMonitoring = { [unowned self] in
            self.handler(.didUpdate(.regionState(.unknown, $0)))
        }

        self.adapter.monitoringDidFail = { [unowned self] in
            self.handler(.didUpdate(.error($1, $0)))
        }

        self.locationManager.delegate = self.adapter
    }

    ///
    /// A Boolean value indicating whether the device supports region
    /// monitoring.
    ///
    public var isAvailable: Bool {
        return type(of: locationManager).isMonitoringAvailable(for: CLRegion.self)
    }

    ///
    /// The largest boundary distance that can be assigned to a region.
    ///
    public var maximumMonitoringDistance: CLLocationDistance {
        return locationManager.maximumRegionMonitoringDistance
    }

    ///
    /// The set of regions actively being monitored. There is a system-imposed,
    /// per-app limit to how many regions can be actively monitored. Therefore,
    /// `monitoredRegions.count` _may_ be less than `regions.count`.
    ///
    public var monitoredRegions: Set<CLRegion> {
        guard
            isMonitoring
            else { return [] }

        return locationManager.monitoredRegions.intersection(regions)
    }

    ///
    /// The set of regions _possibly_ being monitored.
    ///
    public private(set) var regions: Set<CLRegion>

    ///
    /// Inserts the given region into `regions` if it is not already present.
    /// If monitoring is active _and_ the system allows it, monitoring of the
    /// given region will be started.
    ///
    /// - Parameters:
    ///   - region: The region to insert into the set and possibly start
    ///             monitoring.
    ///
    public func insertRegion(_ region: CLRegion) {
        if regions.insert(region).inserted,
            isMonitoring {
            locationManager.startMonitoring(for: region)
        }
    }

    ///
    /// Removes the given region from `regions` if it is present. If monitoring
    /// is active, monitoring of the given region will be stopped.
    ///
    /// - Parameters:
    ///   - region: The region to remove from the set and stop monitoring.
    ///
    public func removeRegion(_ region: CLRegion) {
        if regions.remove(region) != nil,
            isMonitoring {
            locationManager.stopMonitoring(for: region)
        }
    }

    ///
    /// Requests the state of a region.
    ///
    public func requestState(for region: CLRegion) {
        locationManager.requestState(for: region)
    }

    private let adapter: LocationManagerDelegateAdapter
    private let handler: (Event) -> Void
    private let locationManager: LocationManagerProtocol
    private let queue: OperationQueue

    override public func cleanupMonitor() {
        regions.forEach { locationManager.stopMonitoring(for: $0) }

        super.cleanupMonitor()
    }

    override public func configureMonitor() {
        super.configureMonitor()

        regions.forEach { locationManager.startMonitoring(for: $0) }
    }
}

#endif
