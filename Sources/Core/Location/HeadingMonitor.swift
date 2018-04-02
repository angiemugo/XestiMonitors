//
//  HeadingMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

#if os(iOS)

    import CoreLocation

    ///
    /// An `HeadingMonitor` instance monitors ...
    ///
    public class HeadingMonitor: BaseMonitor {
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
        /// Encapsulates information associated with a heading monitor event.
        ///
        public enum Info {
            ///
            ///
            ///
            case error(Error)

            ///
            ///
            ///
            case heading(CLHeading)
        }

        ///
        /// Initializes a new `HeadingMonitor`.
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

            self.adapter.didUpdateHeading = { [unowned self] in
                self.handler(.didUpdate(.heading($0)))
            }

            self.locationManager.delegate = self.adapter
        }

        ///
        ///
        ///
        public var filter: CLLocationDegrees {
            get { return locationManager.headingFilter }
            set { locationManager.headingFilter = newValue }
        }

        ///
        ///
        ///
        public var heading: CLHeading? {
            return locationManager.heading
        }

        ///
        /// A Boolean value indicating whether ...
        ///
        public var isAvailable: Bool {
            return type(of: locationManager).headingAvailable()
        }

        ///
        ///
        ///
        public var orientation: CLDeviceOrientation {
            get { return locationManager.headingOrientation }
            set { locationManager.headingOrientation = newValue }
        }

        ///
        ///
        ///
        public func dismissCalibrationDisplay() {
            locationManager.dismissHeadingCalibrationDisplay()
        }

        private let adapter: LocationManagerDelegateAdapter
        private let handler: (Event) -> Void
        private let locationManager: LocationManagerProtocol
        private let queue: OperationQueue

        override public func cleanupMonitor() {
            locationManager.stopUpdatingHeading()

            super.cleanupMonitor()
        }

        override public func configureMonitor() {
            super.configureMonitor()

            locationManager.startUpdatingHeading()
        }
    }

#endif
