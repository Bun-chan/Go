import Foundation
import CoreLocation

struct MyLocation: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var latitude: Double
    var longitude: Double
}
