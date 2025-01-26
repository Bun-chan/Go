import Foundation
import Combine
import CoreLocation

protocol HomeUseCase {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus()
}

class HomeDefaultUseCase: HomeUseCase {
    
    let homerepository: HomeRepository
    var cancellables = Set<AnyCancellable>()
    
    init(homerepository: HomeRepository) {
        self.homerepository = homerepository
    }
    
    func requestWhenInUseAuthorization() {
        homerepository.requestWhenInUseAuthorization()
    }
    
    func observeAuthorizationStatus() {
        homerepository.observeAuthorizationStatus()
            .flatMap { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    return self.startGettingLocation()
                case .denied, .restricted, .notDetermined:
                    return self.askForPermission()
                @unknown default:
                    return self.askForPermission()
                }
            }
            .sink { completion in
                print("auth completion: \(completion)")
            } receiveValue: { value in
                print("auth value :\(value)")
            }
            .store(in: &cancellables)
    }
    
    private func startGettingLocation() -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher() //MARK: FIX
    }
    
    private func askForPermission() -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher() //MARK: FIX
    }
}

enum LocationError: Error {
    case couldNotGetLocation
}

