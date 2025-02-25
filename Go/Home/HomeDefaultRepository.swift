import Combine
import CoreLocation

class HomeDefaultRepository: HomeRepository {
    let locationManager: LocationManager
    var cancellables = Set<AnyCancellable>()
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    private let locationKey = "location"
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        locationManager.locationPublisher
            .sink { [weak self] location in
                guard let self else { return }
                self.locationPublisher.send(location)
            }
            .store(in: &cancellables)
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never> {
        return locationManager.$authorizationStatus
            .eraseToAnyPublisher()
    }
    
    func startUpdatingLocation() {
        return locationManager.startUpdatingLocation()
    }
    
    func saveToUserDefaults(location: MyLocation) {
        var locations = getUserDefaultsLocations()
        locations.append(location)
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: locationKey)
        }
    }
    
    func getUserDefaultsLocations() -> [MyLocation] {
        if let data = UserDefaults.standard.data(forKey: locationKey),
           let decoded = try? JSONDecoder().decode([MyLocation].self, from: data) {
            return decoded
        }
        return []
    }
}
