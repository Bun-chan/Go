import Foundation

import Combine

class HomeViewModel: ObservableObject {
    
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
    @Published var myLocation: MyLocation?
    @Published var myPins: [MyLocation] = []
    @Published var addPinError: AddPinError?
    
    init(useCase: HomeUseCase) {
        self.useCase = useCase
        useCase.locationPublisher
            .sink { [weak self] location in
                guard let self else { return }
                self.myLocation = location
            }
            .store(in: &cancellables)
        
        useCase.locationsPublisher
            .sink { [weak self] locations in
                guard let self else { return }
                self.myPins = locations
                for location in locations {
                }
            }
            .store(in: &cancellables)
        
        useCase.getCurrentLocation()
    }
    
    func save(_ myLocation: MyLocation) {
        useCase.save(myLocation)
    }
    
    func updateLocation(_ myLocation: MyLocation) {
        useCase.updateLocation(myLocation)
    }
    
    func deleteLocation(_ myLocation: MyLocation) {
        useCase.deleteLocation(myLocation)
    }
    
    func addPin(_ myLocation: MyLocation) {
        useCase.addPin(myLocation)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let addPinError):
                    self.addPinError = addPinError
                }
            } receiveValue: { [weak self] location in
                guard let self else { return }
                self.myPins.append(location)
            }
            .store(in: &cancellables)
    }
    
    func getLocations() {
        useCase.getUserDefLocs()
    }
}
