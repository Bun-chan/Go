import Combine
import CoreLocation

class HomeDefaultRepository: HomeRepository {
    
    var locationPublisher = PassthroughSubject<MyLocation, Never>()
    let locationManager: LocationManager
    var cancellables = Set<AnyCancellable>()
    private let locationKey = "location"
    @Published private var locations: [MyLocation] = []
    var locationsPublisher: AnyPublisher<[MyLocation], Never> {
        $locations.eraseToAnyPublisher()
    }
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        locationManager.$locationPublisher
            .sink { [weak self] location in
                guard let self, let location else { return }
                let myLocation = MyLocation.locationToMyLocation(location)
                self.locationPublisher.send(myLocation)
//                self.saveLocation(myLocation)
//                self.getUserDefLocs()
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
        locationManager.startUpdatingLocation()
    }
    
    func getUserDefLocs() {
        if let data = UserDefaults.standard.data(forKey: locationKey),
           let retrievedLocations = try? JSONDecoder().decode([MyLocation].self, from: data) {
            locations = retrievedLocations
            //            myLocationsForReal.append(contentsOf: LocationTestData.locations) //Use this after deleting the app to re-add the test locations
            //            saveLocations(myLocationsForReal) //this too
        } else {
            print("getting locations failed...oops")
        }
    }
 
    func saveLocation(_ location: MyLocation) {
        getUserDefLocs()
        locations.append(location)
        saveLocations(locations)
    }
    
    private func saveLocations(_ locations: [MyLocation]) {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: locationKey)
        } else {
            print("saving failed")
        }
    }
    
    //This is when the user changes the name, description etc on an existing MyLocation instance.
    func updateLocation(_ location: MyLocation) {
        getUserDefLocs()
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index] = location
        }
        saveLocations(locations)
    }
    
    func deleteLocation(_ location: MyLocation) {
        getUserDefLocs()
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations.remove(at: index)
        }
        saveLocations(locations)
    }
}
