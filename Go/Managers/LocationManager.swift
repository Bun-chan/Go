import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: LocationManagerProtocol
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    
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
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations \(String(describing: locations.last))")
        guard let location = locations.last else { return }
        locationPublisher.send(location)
        locationManager.stopUpdatingLocation()
    }
}

protocol LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate? { get set }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
extension CLLocationManager: LocationManagerProtocol {}
