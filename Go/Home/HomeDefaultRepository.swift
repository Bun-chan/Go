import Combine
import CoreLocation

class HomeDefaultRepository: HomeRepository {
    let locationManager: LocationManager
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never> {
        return locationManager.$authorizationStatus
            .eraseToAnyPublisher()
    }
}
