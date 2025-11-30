import Foundation
import CoreLocation

import Combine

class HomeViewModel: ObservableObject {
    
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
    @Published var location: CLLocation?
    @Published var myPins2: [CLLocation] = []
    @Published var addPinError: AddPinError?
    @Published var myPinsCoreData: [LocModel] = []
    @Published var alertMessage: AlertItem? = nil
    
    init(useCase: HomeUseCase) {
        self.useCase = useCase
        
        useCase.locationPublisher
            .sink { [weak self] location in
                self?.location = location
            }
            .store(in: &cancellables)
        
        useCase.locationsPublisherCoreData
            .sink { [weak self] completion in
                print("VM completion \(completion)")
            } receiveValue: { [weak self] value in
                print("VM value \(value)")
                self?.myPinsCoreData = value
            }
            .store(in: &cancellables)
        
        useCase.getCurrentLocation()
    }
    
    func deleteLocationCoreData(_ location: LocModel) { //maybe this needs to handle a failure case. and then update the map when successfully deleting a pin
        useCase.deleteLocationCoreData(location)
            .sink { [weak self] completion in
                print("delete completion \(completion)") //deletion failed... handle it
            } receiveValue: { [weak self] value in
                print("delete value \(value)") //deletion was successful
            }
            .store(in: &cancellables)
        getLocations() //refresh the locations on the map
    }
    
    func addPin(_ location: CLLocation) {
        useCase.addPin(location)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alertMessage = AlertItem(message: error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] value in //void means successful
                print("add pin location \(value)")
                self?.myPins2.append(location)
                self?.getLocations()
            }
            .store(in: &cancellables)
    }
    
    func getLocations() {
        useCase.getUserDefLocs()
    }
    
    func updateLocation() {
        useCase.updateLocation()
            .sink { completion in
                print("update completion \(completion)") //Handle the error.
            } receiveValue: { [weak self] _ in
                print("update location successful")
                self?.getLocations()
            }
            .store(in: &cancellables)
    }
}


struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
