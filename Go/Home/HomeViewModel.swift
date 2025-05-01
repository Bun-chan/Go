import Foundation

import Combine

class HomeViewModel: ObservableObject {
    
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
    @Published var myLocation: MyLocation?
    @Published var myPins: [MyLocation] = []
    
    init(useCase: HomeUseCase) {
        self.useCase = useCase
        useCase.locationPublisher
            .sink { [weak self] location in
                guard let self else { return }
                self.myLocation = location
//                print("VIEWMODEL new loc received")
            }
            .store(in: &cancellables)
        
        useCase.locationsPublisher
            .sink { [weak self] locations in
                guard let self else { return }
                self.myPins = locations
//                print("VM locations count: \(locations.count)")
                for location in locations {
//                    print("name \(location.name)")
                }
            }
            .store(in: &cancellables)
        
        useCase.getCurrentLocation()
    }
    
    func save(_ myLocation: MyLocation) {
        useCase.save(myLocation)
    }
    
    func show() {
        
    }
    
    func updateLocation(_ location: MyLocation) {
        useCase.updateLocation(location)
    }
    
    func deleteLocation(_ location: MyLocation) {
        useCase.deleteLocation(location)
    }
    
    func addPin(_ location: MyLocation) {
        useCase.addPin(location)
            .sink { completion in
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
