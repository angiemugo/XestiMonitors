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
/// A `RegionMonitor` instance monitors ...
/// Region monitoring lets you monitor boundary crossings for defined geographical regions and Bluetooth low-energy beacon regions. (Beacon region monitoring is available in iOS only.)
/// The Core Location framework provides two ways to detect a user’s entry and exit into specific regions: geographical region monitoring (iOS 4.0 and later and OS X v10.8 and later) and beacon region monitoring (iOS 7.0 and later). A geographical region is an area defined by a circle of a specified radius around a known point on the Earth’s surface. In contrast, a beacon region is an area defined by the device’s proximity to Bluetooth low-energy beacons.
/// Monitoring distinct regions of interest and generating location events when the user enters or leaves those regions.
///
/// Be judicious when specifying the set of regions to monitor. Regions are a shared system resource, and the total number of regions available systemwide is limited. For this reason, Core Location limits to 20 the number of regions that may be simultaneously monitored by a single app. To work around this limit, consider registering only those regions in the user’s immediate vicinity. As the user’s location changes, you can remove regions that are now farther way and add regions coming up on the user’s path. If you attempt to register a region and space is unavailable, the location manager calls the locationManager:monitoringDidFailForRegion:withError: method of its delegate with the kCLErrorRegionMonitoringFailure error code.
///
/// - Note:
///   Region updates require an authorization status of `authorizedAlways`.
///
public class RegionMonitor: BaseMonitor {
    ///
    /// Encapsulates changes to ...
    ///
    public enum Event {
        ///
        ///
        ///
        case didUpdate(Info)
    }

    ///
    /// Encapsulates information associated with a region monitor event.
    ///
    public enum Info {
        ///
        ///
        ///
        case error(Error, CLRegion?)

        ///
        ///
        ///
        case regionState(CLRegionState, CLRegion)
    }

    ///
    /// Initializes a new `RegionMonitor`.
    ///
    /// - Parameters:
    ///   - regions:
    ///   - queue:      The operation queue on which the handler executes.
    ///   - handler:    The handler to call when ...
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
    /// The set of regions currently being monitored.
    ///
    public var monitoredRegions: Set<CLRegion> {
        return locationManager.monitoredRegions
    }

    ///
    /// ??? Regions possibly being monitored ???
    ///
    public private(set) var regions: Set<CLRegion>

    ///
    /// ??? Starts monitoring the specified region. ???
    ///
    public func insertRegion(_ region: CLRegion) {
        if regions.insert(region).inserted,
            isMonitoring {
            locationManager.startMonitoring(for: region)
        }
    }

    ///
    /// ??? Stops monitoring the specified region. ???
    ///
    public func removeRegion(_ region: CLRegion) {
        guard
            regions.remove(region) != nil
            else { return }

        // only if monitoring has been stopped ???

        locationManager.stopMonitoring(for: region)
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
