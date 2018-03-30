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
    /// An `RegionMonitor` instance monitors ...
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
        /// A Boolean value indicating whether ...
        ///
        public var isAvailable: Bool {
            return type(of: locationManager).isMonitoringAvailable(for: CLRegion.self)
        }

        ///
        ///
        ///
        public var monitoredRegions: Set<CLRegion> {
            return locationManager.monitoredRegions
        }

        ///
        ///
        ///
        public private(set) var regions: Set<CLRegion>

        ///
        ///
        ///
        public func insertRegion(_ region: CLRegion) {
            guard
                regions.insert(region).inserted
                else { return }

            locationManager.startMonitoring(for: region)
        }

        ///
        ///
        ///
        public func removeRegion(_ region: CLRegion) {
            guard
                regions.remove(region) != nil
                else { return }

            locationManager.stopMonitoring(for: region)
        }

        ///
        ///
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
