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
        /// The minimum angular change (measured in degrees) required to generate new heading events.
        /// The angular distance is measured relative to the last delivered heading event. Use the value kCLHeadingFilterNone to be notified of all movements. The default value of this property is 1 degree.
        ///
        public var filter: CLLocationDegrees {
            get { return locationManager.headingFilter }
            set { locationManager.headingFilter = newValue }
        }

        ///
        /// The most recently reported heading.
        /// The value of this property is nil if heading updates have never been initiated.
        ///
        public var heading: CLHeading? {
            return locationManager.heading
        }

        ///
        /// A Boolean value indicating whether ...
        /// Returns a Boolean value indicating whether the location manager is able to generate heading-related events.
        ///
        public var isAvailable: Bool {
            return type(of: locationManager).headingAvailable()
        }

        ///
        /// The device orientation to use when computing heading values.
        /// When computing heading values, the location manager assumes that the top of the device in portrait mode represents due north (0 degrees) by default. For apps that run in other orientations, this may not always be the most convenient orientation. This property allows you to specify which device orientation you want the location manager to use as the reference point for due north.
        ///
        /// Although you can set the value of this property to unknown, faceUp, or faceDown, doing so has no effect on the orientation reference point. The original reference point is retained instead.
        ///
        /// Changing the value in this property affects only those heading values reported after the change is made.
        ///
        public var orientation: CLDeviceOrientation {
            get { return locationManager.headingOrientation }
            set { locationManager.headingOrientation = newValue }
        }

        ///
        /// Dismisses the heading calibration view from the screen immediately.
        /// Core Location uses the heading calibration alert to calibrate the available heading hardware as needed. The display of this view is automatic, assuming your delegate supports displaying the view at all. If the view is displayed, you can use this method to dismiss it after an appropriate amount of time to ensure that your app’s user interface is not unduly disrupted.
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
