import Foundation
import Combine
import CoreLocation

protocol HomeUseCase {
    func requestWhenInUseAuthorization()
    var locationPublisher: PassthroughSubject<CLLocation, Never> { get }
    func getUserDefLocs()
    func deleteLocationCoreData(_ location: LocModel) -> AnyPublisher<Void, Error>
    func getCurrentLocation()
    func addPin(_ location: CLLocation) -> AnyPublisher<Void, Error>
    var locationsPublisherCoreData: PassthroughSubject<[LocModel], Never> { get }
}
class HomeDefaultUseCase: HomeUseCase {
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    var homerepository: HomeRepository
    var cancellables = Set<AnyCancellable>()
    var locationsPublisherCoreData = PassthroughSubject<[LocModel], Never>()

    init(homerepository: HomeRepository) {
        self.homerepository = homerepository
        
        homerepository.locationsPublisherCoreData
            .sink { completion in
            } receiveValue: { [weak self] value in
                self?.locationsPublisherCoreData.send(value)
            }
            .store(in: &cancellables)
        
        homerepository.locationPublisher
            .sink { [weak self] location in
                self?.locationPublisher.send(location)
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
    
    func getUserDefLocs() {
        homerepository.getUserDefLocs()
    }
    
    func deleteLocationCoreData(_ location: LocModel) -> AnyPublisher<Void, Error> {
        return homerepository.deleteLocationCoreData(location)
    }
    
    func addPin(_ location: CLLocation) -> AnyPublisher<Void, Error> {
        return homerepository.addPinCoreData(location)
    }
}

enum LocationError: Error {
    case couldNotGetLocation
}

enum AddPinError: Error {
    case couldNotAddPin
}
