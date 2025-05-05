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
        } else {
            //MARK: to do: handle the error
        }
    }
 
    func saveLocation(_ myLocation: MyLocation) {
        getUserDefLocs()
        locations.append(myLocation)
        saveLocations(locations)
    }
    
    private func saveLocations(_ locations: [MyLocation]) {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: locationKey)
        } else {
            //MARK: to do: handle the error
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
    
    func addPin(_ location: MyLocation) -> AnyPublisher<MyLocation, AddPinError> { //MARK to do: set up the correct error type and error handling.
        //MARK to do: save the location to UserDefaults and then return the location so the pin is added to the map.
        //Save
        saveLocation(location)
        
        //return the location
        return Just(location)
            .setFailureType(to: AddPinError.self)
            .eraseToAnyPublisher()
    }
}
