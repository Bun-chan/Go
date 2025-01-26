import XCTest
import Combine
import CoreLocation

@testable import Go

final class HomeViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    
    func testSave_Success() {
        let result: AnyPublisher<CLLocationCoordinate2D, LocationError> = Just(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
            .setFailureType(to: LocationError.self)
            .eraseToAnyPublisher()
        
        let mockUseCase = MockHomeUseCase(result: result)
        let viewModel = HomeViewModel(useCase: mockUseCase)
        viewModel.save()
        XCTAssertNil(viewModel.locationError)
    }
    
    func testSave_Failure() {
        //rewrite
//        let result: AnyPublisher<CLLocationCoordinate2D, LocationError> = Fail(error: LocationError.couldNotGetLocation)
//            .eraseToAnyPublisher()
//        let mockUseCase = MockHomeUseCase(result: result)
//        let viewModel = HomeViewModel(useCase: mockUseCase)
//        viewModel.save()
//        XCTAssertNotNil(viewModel.locationError, "error should not be nil")
    }
}

class MockHomeUseCase: HomeUseCase {
    var result: AnyPublisher<CLLocationCoordinate2D, LocationError>
    
    init(result: AnyPublisher<CLLocationCoordinate2D, LocationError>) {
        self.result = result
    }
    
    func requestWhenInUseAuthorization() {
        //MARK: test this.
    }
}
