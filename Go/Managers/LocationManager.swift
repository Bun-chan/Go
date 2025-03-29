import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: LocationManagerProtocol
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationPublisher: CLLocation?
    private var firstCalled = false
    
    init(locationManager: LocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 10
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("auth: \(manager.authorizationStatus)")
        authorizationStatus = manager.authorizationStatus
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        locationManager.stopUpdatingLocation()
        locationPublisher = location
        
        
        
        /*
        if let timestamp = locationPublisher?.timestamp {
            if abs(timestamp.timeIntervalSince(location.timestamp)) > 7 { //User must wait 7 seconds between location events. This should prevent most duplicates.
                if firstCalled { //Used to stop the double event being saved the first time the user uses the locationManager.
                    firstCalled = false
                } else {
                    locationPublisher = location
                }
            }
        } else {
            firstCalled = true
            locationPublisher = location
        }*/
    }
}

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    var location: CLLocation? { get }
    var distanceFilter: CLLocationDistance { get set }
}
extension CLLocationManager: LocationManagerProtocol {}
