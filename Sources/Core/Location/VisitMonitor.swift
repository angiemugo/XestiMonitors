//
//  VisitMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

#if os(iOS)

    import CoreLocation

    ///
    /// An `VisitMonitor` instance monitors the app for visit-related events. ???
    ///
    public class VisitMonitor: BaseMonitor {
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
        /// Encapsulates information associated with a visit monitor event.
        ///
        public enum Info {
            ///
            ///
            ///
            case error(Error)

            ///
            ///
            ///
            case visit(CLVisit)
        }

        ///
        /// Initializes a new `VisitMonitor`.
        ///
        /// - Parameters:
        ///   - queue:      The operation queue on which the handler executes.
        ///   - handler:    The handler to call when ...
        ///
        public init(queue: OperationQueue,
                    handler: @escaping (Event) -> Void) {
            self.adapter = .init()
            self.handler = handler
            self.locationManager = LocationManagerInjector.inject()
            self.queue = queue

            super.init()

            self.adapter.didFail = { [unowned self] in
                self.handler(.didUpdate(.error($0)))
            }

            self.adapter.didVisit = { [unowned self] in
                self.handler(.didUpdate(.visit($0)))
            }

            self.locationManager.delegate = self.adapter
        }

        private let adapter: LocationManagerDelegateAdapter
        private let handler: (Event) -> Void
        private let locationManager: LocationManagerProtocol
        private let queue: OperationQueue

        override public func cleanupMonitor() {
            locationManager.stopMonitoringVisits()

            super.cleanupMonitor()
        }

        override public func configureMonitor() {
            super.configureMonitor()

            locationManager.startMonitoringVisits()
        }
    }

#endif
