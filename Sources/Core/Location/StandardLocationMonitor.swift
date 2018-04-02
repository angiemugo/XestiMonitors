//
//  StandardLocationMonitor.swift
//  XestiMonitors
//
//  Created by J. G. Pusey on 2018-03-21.
//
//  © 2018 J. G. Pusey (see LICENSE.md)
//

import CoreLocation

///
/// An `StandardLocationMonitor` instance monitors ...
///
@available(watchOS 3.0, *)
public class StandardLocationMonitor: BaseMonitor {
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
    /// Encapsulates information associated with a standard location monitor
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
    /// Initializes a new `StandardLocationMonitor`.
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

    //    var activityType: CLActivityType

    //    var allowsBackgroundLocationUpdates: Bool

    //    var desiredAccuracy: CLLocationAccuracy

    //    var distanceFilter: CLLocationDistance

    //    var location: CLLocation? { get }

    //    var pausesLocationUpdatesAutomatically: Bool

    //    var showsBackgroundLocationIndicator: Bool

    //    static func deferredLocationUpdatesAvailable() -> Bool

    //    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance,
    //                                      timeout: TimeInterval)

    //    func disallowDeferredLocationUpdates()

    #if os(iOS) || os(tvOS) || os(watchOS)

    ///
    ///
    ///
    public func requestLocation() {
        locationManager.requestLocation()
    }
    #endif

    private let adapter: LocationManagerDelegateAdapter
    private let handler: (Event) -> Void
    private let locationManager: LocationManagerProtocol
    private let queue: OperationQueue

    override public func cleanupMonitor() {
        locationManager.stopUpdatingLocation()

        super.cleanupMonitor()
    }

    override public func configureMonitor() {
        super.configureMonitor()

        #if os(iOS) || os(macOS) || os(watchOS)
        locationManager.startUpdatingLocation()
        #endif
    }
}
