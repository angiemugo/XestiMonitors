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

    #if os(iOS) || os(watchOS)

    ///
    ///
    ///
    @available(watchOS 4.0, *)
    public var activityType: CLActivityType {
        get { return locationManager.activityType }
        set { locationManager.activityType = newValue }
    }
    #endif

    #if os(iOS) || os(watchOS)

    ///
    ///
    ///
    @available(watchOS 4.0, *)
    public var allowsBackgroundLocationUpdates: Bool {
        get { return locationManager.allowsBackgroundLocationUpdates }
        set { locationManager.allowsBackgroundLocationUpdates = newValue }
    }
    #endif

    #if os(iOS) || os(macOS)

    ///
    ///
    ///
    public var canDeferUpdates: Bool {
        return type(of: locationManager).deferredLocationUpdatesAvailable()
    }
    #endif

    ///
    ///
    ///
    public var desiredAccuracy: CLLocationAccuracy {
        get { return locationManager.desiredAccuracy }
        set { locationManager.desiredAccuracy = newValue }
    }

    ///
    ///
    ///
    public var distanceFilter: CLLocationDistance {
        get { return locationManager.distanceFilter }
        set { locationManager.distanceFilter = newValue }
    }

    ///
    ///
    ///
    public var location: CLLocation? {
        return locationManager.location
    }

    #if os(iOS)

    ///
    ///
    ///
    public var pausesLocationUpdatesAutomatically: Bool {
        get { return locationManager.pausesLocationUpdatesAutomatically }
        set { locationManager.pausesLocationUpdatesAutomatically = newValue }
    }
    #endif

    #if os(iOS)

    ///
    ///
    ///
    @available(iOS 11.0, *)
    public var showsBackgroundLocationIndicator: Bool {
        get { return locationManager.showsBackgroundLocationIndicator }
        set { locationManager.showsBackgroundLocationIndicator = newValue }
    }
    #endif

    #if os(iOS)

    ///
    ///
    ///
    public func allowDeferredUpdates(untilTraveled distance: CLLocationDistance,
                                     timeout: TimeInterval) {
        locationManager.allowDeferredLocationUpdates(untilTraveled: distance,
                                                     timeout: timeout)
    }
    #endif

    #if os(iOS)

    ///
    ///
    ///
    public func disallowDeferredUpdates() {
        locationManager.disallowDeferredLocationUpdates()
    }
    #endif

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
