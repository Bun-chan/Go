import Foundation
import CoreLocation
import Combine

protocol HomeRepository {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never>
    func startUpdatingLocation()
    var locationPublisher: PassthroughSubject<CLLocation, Never> { get }
    func saveToUserDefaults(location: MyLocation) //MARK: to do -> Replace this with Core Data.
    func getUserDefaultsLocations() -> [MyLocation] //MARK: to do -> Replace this with Core Data.
}
