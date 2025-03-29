import Foundation

import Combine

class HomeViewModel: ObservableObject {
    
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
    @Published var myLocations = [MyLocation]() //MARK: to do -> implement this using CoreData.
    @Published var myLocation: MyLocation?
    
    init(useCase: HomeUseCase) {
        self.useCase = useCase
        useCase.locationPublisher
            .sink { [weak self] location in
                guard let self else { return }
//                self.myLocations.append(location)
                self.myLocation = location
                print("new loc")
            }
            .store(in: &cancellables)
        
        useCase.locationsPublisher
            .sink { [weak self] locations in
                guard let self else { return }
                self.myLocations = locations
            }
            .store(in: &cancellables)
        
        useCase.getCurrentLocation()
    }
    
    func save() {
        useCase.save()
    }
    
    func show() {
        
    }
    
    func updateLocation(_ location: MyLocation) {
        useCase.updateLocation(location)
    }
    
    func getUserDefLocs() {
        useCase.getUserDefLocs()
    }
    
    func deleteLocation(_ location: MyLocation) {
        useCase.deleteLocation(location)
    }
}
