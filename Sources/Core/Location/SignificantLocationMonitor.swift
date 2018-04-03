//
//  SignificantLocationMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

#if os(iOS) || os(macOS)

import CoreLocation

///
/// A `SignificantLocationMonitor` instance monitors ...
/// This framework provides several services that you can use to get and monitor the device’s current location.
/// The significant-change location service provides a way to get the current location and be notified when significant changes occur, but it’s critical to use it correctly to avoid using too much power.
/// Two services can give you the user’s current location:
///
/// The standard location service is a configurable, general-purpose solution for getting location data and tracking location changes for the specified level of accuracy.
/// The significant-change location service delivers updates only when there has been a significant change in the device’s location, such as 500 meters or more.
///
/// - Note:
///   Significant-change location updates require an authorization status of
///   `authorizedAlways`.
///
public class SignificantLocationMonitor: BaseMonitor {
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
    /// Encapsulates information associated with a significant location monitor
    /// event.
    ///
    public enum Info {
        ///
        ///
        ///
        case error(Error)

        ///
        ///
        ///
        case locations([CLLocation])
    }

    ///
    /// Initializes a new `SignificantLocationMonitor`.
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

        self.adapter.didUpdateLocations = { [unowned self] in
            self.handler(.didUpdate(.locations($0)))
        }

        self.locationManager.delegate = self.adapter
    }

    ///
    /// A Boolean value indicating whether the significant-change location
    /// service is available.
    ///
    public var isAvailable: Bool {
        return type(of: locationManager).significantLocationChangeMonitoringAvailable()
    }

    private let adapter: LocationManagerDelegateAdapter
    private let handler: (Event) -> Void
    private let locationManager: LocationManagerProtocol
    private let queue: OperationQueue

    override public func cleanupMonitor() {
        locationManager.stopMonitoringSignificantLocationChanges()

        super.cleanupMonitor()
    }

    override public func configureMonitor() {
        super.configureMonitor()

        locationManager.startMonitoringSignificantLocationChanges()
    }
}

#endif
