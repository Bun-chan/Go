import Foundation
import Combine
import CoreLocation

protocol HomeUseCase {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus()
    var locationPublisher: PassthroughSubject<MyLocation, Never> { get }
    func getUserDefaultsLocations() -> [MyLocation] //MARK: to do -> Replace this with Core Data.
}

class HomeDefaultUseCase: HomeUseCase {
    
    var homerepository: HomeRepository
    var cancellables = Set<AnyCancellable>()
    var locationPublisher = PassthroughSubject<MyLocation, Never>()
    
    init(homerepository: HomeRepository) {
        self.homerepository = homerepository
        homerepository.locationPublisher
            .flatMap { location in
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-M-d HH:mm"
                print("date: \(dateFormatter.string(from: date))")
                return Just(MyLocation(id: UUID(), name: "\(dateFormatter.string(from: date))", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] location in
                guard let self else { return }
                print("location...:\(location)")
                self.locationPublisher.send(location)
                self.homerepository.saveToUserDefaults(location: location)
            }
            .store(in: &cancellables)
    }
    
    func requestWhenInUseAuthorization() {
        homerepository.requestWhenInUseAuthorization()
    }
    
    func observeAuthorizationStatus() {
        homerepository.observeAuthorizationStatus()
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("000 - Starting location updates.")
                    self.startGettingLocation() // Start location updates
                case .denied, .restricted:
                    print("111 - Permission denied or restricted.")
                    // Handle denial (e.g., show alert to the user)
                case .notDetermined:
                    print("111 - Requesting permission.")
                    self.homerepository.requestWhenInUseAuthorization() // Request permission
                @unknown default:
                    print("Unknown authorization status.")
                    // Handle unknown case (e.g., request permission)
                }
            }
            .store(in: &cancellables)
    }
    
    private func startGettingLocation() {
        homerepository.startUpdatingLocation()
    }
    
    //    private func askForPermission() {
    //        homerepository.requestWhenInUseAuthorization()
    //        return Just(()).eraseToAnyPublisher() //MARK: FIX
    //    }
    
    func getUserDefaultsLocations() -> [MyLocation] { //MARK: to do -> Replace this with Core Data.
        return homerepository.getUserDefaultsLocations()
    }
}

enum LocationError: Error {
    case couldNotGetLocation
}

