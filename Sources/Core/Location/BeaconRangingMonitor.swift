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
    /// An `BeaconRangingMonitor` instance monitors ...
    ///
    public class BeaconRangingMonitor: BaseMonitor {
        ///
        /// Encapsulates changes to ...
        ///
        public enum Event {
            ///
            /// ...  has been updated.
            ///
            case didUpdate(Info)
        }

        ///
        /// Encapsulates information associated with a beacon ranging monitor
        /// event.
        ///
        public enum Info {
            ///
            ///
            ///
            case beacons([CLBeacon], CLBeaconRegion)

            ///
            /// The error encountered in attempting to ...
            ///
            case error(Error, CLBeaconRegion?)
        }

        ///
        /// Initializes a new `BeaconRangingMonitor`.
        ///
        /// - Parameters:
        ///   - regions:
        ///   - queue:      The operation queue on which the handler executes.
        ///   - handler:    The handler to call when ...
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
        /// The set of beacon regions currently being tracked using ranging.
        ///
        public var rangedRegions: Set<CLBeaconRegion> {
            #if swift(>=4.1)
            return Set(locationManager.rangedRegions.compactMap { $0 as? CLBeaconRegion })
            #else
            return Set(locationManager.rangedRegions.flatMap { $0 as? CLBeaconRegion })
            #endif
        }

        //
        // ??? The set of possible beacon regions being range monitored. ???
        //
        public private(set) var regions: Set<CLBeaconRegion>

        ///
        /// ??? Starts the delivery of notifications for the specified beacon region. ???
        ///
        public func insertRegion(_ region: CLBeaconRegion) {
            guard
                regions.insert(region).inserted
                else { return }

            // only if monitoring has been started ...

            locationManager.startRangingBeacons(in: region)
        }

        ///
        /// ??? Stops the delivery of notifications for the specified beacon region. ???
        ///
        public func removeRegion(_ region: CLBeaconRegion) {
            guard
                regions.remove(region) != nil
                else { return }

            // only if monitoring has been stopped ???

            locationManager.stopRangingBeacons(in: region)
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
