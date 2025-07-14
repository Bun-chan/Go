import Combine
import CoreLocation

class HomeDefaultRepository: HomeRepository {
    
    let locationManager: LocationManager
    var cancellables = Set<AnyCancellable>()
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    @Published private var locationsCoreData: [LocModel] = []
    var locationsPublisherCoreData: AnyPublisher<[LocModel], Never> {
        $locationsCoreData.eraseToAnyPublisher()
    }
    private let coreDataDataSource: CoreDataDataSource
    
    init(locationManager: LocationManager = LocationManager(), coreDataDataSource: CoreDataDataSource) {
        self.locationManager = locationManager
        self.coreDataDataSource = coreDataDataSource
        locationManager.$locationPublisher
            .sink { [weak self] location in
                guard let self, let location else { return }
                self.locationPublisher.send(location)
            }
            .store(in: &cancellables)
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never> {
        return locationManager.$authorizationStatus
            .eraseToAnyPublisher()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func getUserDefLocs() {
        locationsCoreData = coreDataDataSource.fetchLocations()
    }
    
    func saveLocationCoreData(_ location: CLLocation) -> AnyPublisher<Void, Error> {
        return coreDataDataSource.saveLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, notes: nil)
    }
    
    func deleteLocationCoreData(_ location: LocModel) -> AnyPublisher<Void, Error> {
        let context = coreDataDataSource.context
        context.delete(location)
        return coreDataDataSource.save()
    }
    
    func addPinCoreData(_ location: CLLocation) -> AnyPublisher<Void, Error> {
        return saveLocationCoreData(location)
    }
}
