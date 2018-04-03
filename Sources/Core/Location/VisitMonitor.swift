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
/// A `VisitMonitor` instance monitors the device for updates to its location
/// during a specific period of time.
///
/// A CLVisit object encapsulates information about places that the user has been.
/// The visit includes the location where the visit occurred and information about
/// the arrival and departure times as relevant.
///
/// The visits service is the most power-efficient way of gathering location data.
/// With this service, the system delivers location updates only when the user’s
/// movements are noteworthy. Each update includes both the location and the amount
/// of time spent at that location.
///
/// - Note:
///   Visit updates require an authorization status of `authorizedAlways`.
///
public class VisitMonitor: BaseMonitor {
    ///
    /// Encapsulates updates to the device’s visit.
    ///
    public enum Event {
        ///
        /// The visit has been updated.
        ///
        case didUpdate(Info)
    }

    ///
    /// Encapsulates information associated with a visit monitor event.
    ///
    public enum Info {
        ///
        /// The error encountered in attempting to obtain the visit.
        ///
        case error(Error)

        ///
        /// The updated visit.
        ///
        case visit(CLVisit)
    }

    ///
    /// Initializes a new `VisitMonitor`.
    ///
    /// - Parameters:
    ///   - queue:      The operation queue on which the handler executes.
    ///   - handler:    The handler to call when the visit of the device is
    ///                 updated.
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
