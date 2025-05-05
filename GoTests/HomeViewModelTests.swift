import XCTest
import Combine
import CoreLocation

@testable import Go

final class HomeViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    var mockUseCase: MockHomeUseCase!
    var viewModel: HomeViewModel!
    let testLocation = MyLocation(id: UUID(), name: "test name", latitude: 123.456, longitude: 456.789)
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockHomeUseCase()
        viewModel = HomeViewModel(useCase: mockUseCase)
    }
    
    func testSave_Success() {
        mockUseCase.testLocation = testLocation
        viewModel.save(testLocation)
    }
    
    func testUpdateLocation_Success() {
        mockUseCase.testLocation = testLocation
        viewModel.updateLocation(testLocation)
    }
    
    func testDeleteLocation_Success() {
        mockUseCase.testLocation = testLocation
        viewModel.deleteLocation(testLocation)
    }
    
    func testAddPin_Success() {
        mockUseCase.isAddPinSuccessful = true
        mockUseCase.testLocation = testLocation
        let expectation = expectation(description: "addPin completes")
        viewModel.$myPins
            .dropFirst()
            .sink { myLocation in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.addPin(self.testLocation)
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(self.viewModel.myPins.count, 1)
        XCTAssertEqual(self.testLocation, self.viewModel.myPins.first)
    }
    
    func testAddPin_Fail() {
        mockUseCase.isAddPinSuccessful = false
        mockUseCase.testLocation = testLocation
        let expectation = expectation(description: "addPin completes")
        var returnedError: AddPinError?
        viewModel.$addPinError
            .dropFirst()
            .sink(receiveValue: { addPinError in
                returnedError = addPinError
                expectation.fulfill()
            })
            .store(in: &cancellables)
        viewModel.addPin(self.testLocation)
        waitForExpectations(timeout: 1)
        XCTAssertEqual(self.viewModel.myPins.count, 0)
        XCTAssertEqual(AddPinError.couldNotAddPin, returnedError)
    }
}

class MockHomeUseCase: HomeUseCase {
    @Published private var myLocationsForReal: [MyLocation] = []
    var locationsPublisher: AnyPublisher<[MyLocation], Never> {
        $myLocationsForReal.eraseToAnyPublisher()
    }
    var locationPublisher = PassthroughSubject<MyLocation, Never>()
    var testLocation: MyLocation!
    var isAddPinSuccessful = false
    
    func requestWhenInUseAuthorization() {
        
    }
    
    func save(_ myLocation: MyLocation) {
        XCTAssertEqual(myLocation, testLocation, "these 2 locations should be equal")
    }
    
    
    func updateLocation(_ myLocation: MyLocation) {
        XCTAssertEqual(myLocation, testLocation, "these 2 locations should be equal")
    }
    
    func getUserDefLocs() {
        
    }
    
    
    func deleteLocation(_ myLocation: MyLocation) {
        XCTAssertEqual(myLocation, testLocation, "these 2 locations should be equal")
    }
    
    func getCurrentLocation() {
        
    }
    
    func addPin(_ myLocation: MyLocation) -> AnyPublisher<MyLocation, AddPinError> {
        if isAddPinSuccessful {
            return Just(testLocation)
                .setFailureType(to: AddPinError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(outputType: MyLocation.self, failure: AddPinError.couldNotAddPin)
                .eraseToAnyPublisher()
        }
    }
}
