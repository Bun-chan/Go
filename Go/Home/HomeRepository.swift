import Foundation
import CoreLocation
import Combine

protocol HomeRepository {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never>
    func startUpdatingLocation()
    func getUserDefLocs()
    var locationsPublisherCoreData: AnyPublisher<[LocModel], Never> { get }
    func deleteLocationCoreData(_ location: LocModel) -> AnyPublisher<Void, Error>
    var locationPublisher: PassthroughSubject<CLLocation, Never> { get }
    func saveLocationCoreData(_ location: CLLocation) -> AnyPublisher<Void, Error>
    func addPinCoreData(_ location: CLLocation)-> AnyPublisher<Void, Error>
}
