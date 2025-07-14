import Foundation
import CoreData
import Combine

class CoreDataDataSource { //should this also have a protocol so it can be injected?
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveLocation(name: String = "unnamed", latitude: Double, longitude: Double, notes: String?) -> AnyPublisher<Void, Error> {
        let newLocation = LocModel(context: context)
        newLocation.name = name
        newLocation.latitude = latitude
        newLocation.longitude = longitude
        newLocation.notes = notes
        return save()
    }
    
    func save() -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            do {
                try self?.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchLocations() -> [LocModel] { //Handle the failure case.
        let fetchRequest: NSFetchRequest<LocModel> = LocModel.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
}
