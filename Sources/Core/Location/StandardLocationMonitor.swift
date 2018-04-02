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
    /// The type of user activity associated with the location updates.
    ///
    @available(watchOS 4.0, *)
    public var activityType: CLActivityType {
        get { return locationManager.activityType }
        set { locationManager.activityType = newValue }
    }
    #endif

    #if os(iOS) || os(watchOS)

    ///
    /// A Boolean value indicating whether the app should receive location updates when suspended.
    ///
    @available(watchOS 4.0, *)
    public var allowsBackgroundLocationUpdates: Bool {
        get { return locationManager.allowsBackgroundLocationUpdates }
        set { locationManager.allowsBackgroundLocationUpdates = newValue }
    }
    #endif

    #if os(iOS) || os(macOS)

    ///
    /// Returns a Boolean value indicating whether the device supports deferred location updates.
    ///
    public var canDeferUpdates: Bool {
        return type(of: locationManager).deferredLocationUpdatesAvailable()
    }
    #endif

    ///
    /// The accuracy of the location data.
    ///
    public var desiredAccuracy: CLLocationAccuracy {
        get { return locationManager.desiredAccuracy }
        set { locationManager.desiredAccuracy = newValue }
    }

    ///
    /// The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
    ///
    public var distanceFilter: CLLocationDistance {
        get { return locationManager.distanceFilter }
        set { locationManager.distanceFilter = newValue }
    }

    ///
    /// The most recently retrieved user location.
    /// The value of this property is nil if no location data has ever been retrieved.
    ///
    public var location: CLLocation? {
        return locationManager.location
    }

    #if os(iOS)

    ///
    /// A Boolean value indicating whether the location manager object may pause location updates.
    ///
    public var pausesLocationUpdatesAutomatically: Bool {
        get { return locationManager.pausesLocationUpdatesAutomatically }
        set { locationManager.pausesLocationUpdatesAutomatically = newValue }
    }
    #endif

    #if os(iOS)

    ///
    /// A Boolean indicating whether the status bar changes its appearance when location services are used in the background.
    /// This property affects only apps that received always authorization. When such an app moves to the background, the system uses this property to determine whether to change the status bar appearance to indicate that location services are in use. Displaying a modified status bar gives the user a quick way to return to your app. The default value of this property is false.
    ///
    /// For apps with when-in-use authorization, the system always changes the status bar appearance when the app uses location services in the background.
    ///
    @available(iOS 11.0, *)
    public var showsBackgroundLocationIndicator: Bool {
        get { return locationManager.showsBackgroundLocationIndicator }
        set { locationManager.showsBackgroundLocationIndicator = newValue }
    }
    #endif

    #if os(iOS)

    ///
    /// Asks the location manager to defer the delivery of location updates until the specified criteria are met.
    /// distance
    /// The distance (in meters) from the current location that must be travelled before event delivery resumes. To specify an unlimited distance, pass the CLLocationDistanceMax constant.
    ///
    /// timeout
    /// The amount of time (in seconds) from the current time that must pass before event delivery resumes. To specify an unlimited amount of time, pass the CLTimeIntervalMax constant.
    ///
    public func allowDeferredUpdates(untilTraveled distance: CLLocationDistance,
                                     timeout: TimeInterval) {
        locationManager.allowDeferredLocationUpdates(untilTraveled: distance,
                                                     timeout: timeout)
    }
    #endif

    #if os(iOS)

    ///
    /// Cancels the deferral of location updates for this app.
    ///
    public func disallowDeferredUpdates() {
        locationManager.disallowDeferredLocationUpdates()
    }
    #endif

    #if os(iOS) || os(tvOS) || os(watchOS)

    ///
    /// Requests the one-time delivery of the user’s current location.
    /// This method returns immediately. Calling it causes the location manager to obtain a location fix (which may take several seconds) and call the delegate’s locationManager(_:didUpdateLocations:) method with the result. The location fix is obtained at the accuracy level indicated by the desiredAccuracy property. Only one location fix is reported to the delegate, after which location services are stopped. If a location fix cannot be determined in a timely manner, the location manager calls the delegate’s locationManager(_:didFailWithError:) method instead and reports a locationUnknown error.
    ///
    /// Use this method when you want the user’s current location but do not need to leave location services running. This method starts location services long enough to return a result or report an error and then stops them again. Calling the startUpdatingLocation() or allowDeferredLocationUpdates(untilTraveled:timeout:) method cancels any pending request made using this method. Calling this method while location services are already running does nothing. To cancel a pending request, call the stopUpdatingLocation() method.
    ///
    /// If obtaining the desired accuracy would take too long, the location manager delivers a less accurate location value rather than reporting an error.
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
