import Foundation

import Combine

class HomeViewModel: ObservableObject {
   
    let useCase: HomeUseCase
    var cancellables = Set<AnyCancellable>()
    @Published var locationError: LocationError?
        
    init(useCase: HomeUseCase) {
        self.useCase = useCase
    }

    func save() {
        useCase.observeAuthorizationStatus()
        
            
//        useCase.requestWhenInUseAuthorization()
    }
    
    func show() {
        
    }
}
