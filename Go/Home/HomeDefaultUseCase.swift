import Foundation
import Combine
import CoreLocation

protocol HomeUseCase {
    func requestWhenInUseAuthorization()
    func save(_ myLocation: MyLocation)
    var locationPublisher: PassthroughSubject<MyLocation, Never> { get }
    func updateLocation(_ location: MyLocation) //When the user changes the location name, description etc.
    func getUserDefLocs()
    var locationsPublisher: AnyPublisher<[MyLocation], Never> { get }
    func deleteLocation(_ location: MyLocation)
    func getCurrentLocation()
    func addPin(_ location: MyLocation) -> AnyPublisher<MyLocation, Error>
}
class HomeDefaultUseCase: HomeUseCase {
    var locationPublisher = PassthroughSubject<MyLocation, Never>()
    var homerepository: HomeRepository
    var cancellables = Set<AnyCancellable>()
    @Published private var myLocationsForReal: [MyLocation] = []
    var locationsPublisher: AnyPublisher<[MyLocation], Never> {
        $myLocationsForReal.eraseToAnyPublisher()
    }
    
    init(homerepository: HomeRepository) {
        self.homerepository = homerepository
        
        homerepository.locationsPublisher
            .sink { completion in
            } receiveValue: { value in
                self.myLocationsForReal = value
            }
            .store(in: &cancellables)
        
        homerepository.locationPublisher
            .sink { [weak self] myLocation in
                guard let self else { return }
                self.locationPublisher.send(myLocation)
            }
            .store(in: &cancellables)
    }
    
    func requestWhenInUseAuthorization() {
        homerepository.requestWhenInUseAuthorization()
    }
    
    //Need to track the user's location to show it on the map.
    func getCurrentLocation() {
        observeAuthorizationStatus()
    }
    
    func save(_ myLocation: MyLocation) {
        homerepository.saveLocation(myLocation)
    }
    
    private func observeAuthorizationStatus() {
        homerepository.observeAuthorizationStatus()
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.startGettingLocation() // Start location updates
                case .denied, .restricted:
                    //MARK: to do: handle the status case
                    break
                case .notDetermined:
                    self.homerepository.requestWhenInUseAuthorization() // Request permission
                @unknown default:
                    //MARK: to do: handle the unknown case
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func startGettingLocation() {
        homerepository.startUpdatingLocation()
    }
    
    func updateLocation(_ location: MyLocation) {
        homerepository.updateLocation(location)
    }
    
    func getUserDefLocs() {
        homerepository.getUserDefLocs()
    }
    
    func deleteLocation(_ location: MyLocation) {
        homerepository.deleteLocation(location)
    }
    
    func addPin(_ location: MyLocation) -> AnyPublisher<MyLocation, Error> {
        return homerepository.addPin(location)
    }
}

enum LocationError: Error {
    case couldNotGetLocation
}
