import Foundation

import Combine

class HomeViewModel: ObservableObject {
   
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
    @Published var myLocations = [MyLocation]() //MARK: to do -> implement this using CoreData.
        
    init(useCase: HomeUseCase) {
        self.useCase = useCase
        useCase.locationPublisher
            .sink { [weak self] location in
                guard let self else { return }
                self.myLocations.append(location)
                print("new loc: \(self.myLocations.count)")
            }
            .store(in: &cancellables)
        
        myLocations = useCase.getUserDefaultsLocations()
    }

    func save() {
        useCase.observeAuthorizationStatus()
        
            
//        useCase.requestWhenInUseAuthorization()
    }
    
    func show() {
        
    }
}
