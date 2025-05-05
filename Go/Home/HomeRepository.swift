import Foundation
import CoreLocation
import Combine

protocol HomeRepository {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never>
    func startUpdatingLocation()
    func updateLocation(_ location: MyLocation)
    func getUserDefLocs()
    var locationsPublisher: AnyPublisher<[MyLocation], Never> { get }
    func deleteLocation(_ location: MyLocation)
    var locationPublisher: PassthroughSubject<MyLocation, Never> { get } //Used to track the users location and keep the map centered on them.
    func saveLocation(_ myLocation: MyLocation)
    func addPin(_ location: MyLocation)-> AnyPublisher<MyLocation, AddPinError>
}
