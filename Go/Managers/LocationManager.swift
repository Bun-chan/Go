import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: LocationManagerProtocol
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    init(locationManager: LocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("auth: \(manager.authorizationStatus)")
        authorizationStatus = manager.authorizationStatus
    }
    
}

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
extension CLLocationManager: LocationManagerProtocol {}
