import Foundation
import CoreLocation

struct MyLocation: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String?
    var latitude: Double
    var longitude: Double
    
    //Set the name as the date. The user can modify it later on.
    static func locationToMyLocation(_ location: CLLocation) -> MyLocation {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        return MyLocation(id: UUID(), name: dateFormatter.string(from: date), description: "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
    
//Test Data
class LocationTestData {
    static let locations: [MyLocation] = [
        MyLocation(id: UUID(), name: "Yokohama Landmark Tower", description: "Iconic skyscraper with a 69th-floor observatory.", latitude: 35.4546, longitude: 139.6310),
        MyLocation(id: UUID(), name: "Minato Mirai 21", description: "Waterfront urban area with shopping and entertainment.", latitude: 35.4577, longitude: 139.6340),
        MyLocation(id: UUID(), name: "Yamashita Park", description: "Scenic park by the sea with views of Yokohama Bay.", latitude: 35.4443, longitude: 139.6489),
        MyLocation(id: UUID(), name: "Cup Noodles Museum", description: "Interactive museum dedicated to instant ramen.", latitude: 35.4575, longitude: 139.6357),
        MyLocation(id: UUID(), name: "Yokohama Chinatown", description: "Largest Chinatown in Japan, filled with restaurants.", latitude: 35.4438, longitude: 139.6426),
        MyLocation(id: UUID(), name: "Red Brick Warehouse", description: "Historic warehouses turned into cultural and shopping space.", latitude: 35.4514, longitude: 139.6405),
        MyLocation(id: UUID(), name: "Sankeien Garden", description: "Traditional Japanese garden with historic buildings.", latitude: 35.4055, longitude: 139.6566),
        MyLocation(id: UUID(), name: "Nogeyama Zoo", description: "Free zoo with a variety of animals in a relaxed setting.", latitude: 35.4431, longitude: 139.6217),
        MyLocation(id: UUID(), name: "Yokohama Cosmo World", description: "Amusement park with a famous Ferris wheel.", latitude: 35.4570, longitude: 139.6367),
        MyLocation(id: UUID(), name: "NYK Hikawamaru", description: "Historic ocean liner turned into a museum.", latitude: 35.4473, longitude: 139.6504)
    ]
}
