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
    func updateLocation() -> AnyPublisher<Void, Error>
}
class HomeDefaultUseCase: HomeUseCase {
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    var homeRepository: HomeRepository
    var cancellables = Set<AnyCancellable>()
    var locationsPublisherCoreData = PassthroughSubject<[LocModel], Never>()

    init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
        
        homeRepository.locationsPublisherCoreData
            .sink { completion in
            } receiveValue: { [weak self] value in
                self?.locationsPublisherCoreData.send(value)
            }
            .store(in: &cancellables)
        
        homeRepository.locationPublisher
            .sink { [weak self] location in
                self?.locationPublisher.send(location)
            }
            .store(in: &cancellables)
    }
    
    func requestWhenInUseAuthorization() {
        homeRepository.requestWhenInUseAuthorization()
    }
    
    //Need to track the user's location to show it on the map.
    func getCurrentLocation() {
        observeAuthorizationStatus()
    }
    
    private func observeAuthorizationStatus() {
        homeRepository.observeAuthorizationStatus()
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.startGettingLocation() // Start location updates
                case .denied, .restricted:
                    //MARK: to do: handle the status case
                    break
                case .notDetermined:
                    self.homeRepository.requestWhenInUseAuthorization() // Request permission
                @unknown default:
                    //MARK: to do: handle the unknown case
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func startGettingLocation() {
        homeRepository.startUpdatingLocation()
    }
    
    func getUserDefLocs() {
        homeRepository.getUserDefLocs()
    }
    
    func deleteLocationCoreData(_ location: LocModel) -> AnyPublisher<Void, Error> {
        return homeRepository.deleteLocationCoreData(location)
    }
    
    func addPin(_ location: CLLocation) -> AnyPublisher<Void, Error> {
        return homeRepository.addPinCoreData(location)
    }
    
    func updateLocation() -> AnyPublisher<Void, Error> {
        return homeRepository.updateLocation()
    }
}

enum LocationError: Error {
    case couldNotGetLocation
}

enum AddPinError: Error {
    case couldNotAddPin
}
