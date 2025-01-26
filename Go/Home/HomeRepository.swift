import Foundation
import CoreLocation
import Combine

protocol HomeRepository {
    func requestWhenInUseAuthorization()
    func observeAuthorizationStatus() -> AnyPublisher<CLAuthorizationStatus, Never>
}
