import Foundation
import CoreData
import Combine

protocol CoreDataProtocol {
    func saveLocation(name: String, latitude: Double, longitude: Double, notes: String?) -> AnyPublisher<Void, Error>
    func save() -> AnyPublisher<Void, Error>
    func delete(_ location: LocModel) -> AnyPublisher<Void, Error>
    func fetchLocations() -> AnyPublisher<[LocModel], Error>
}

class CoreDataDataSource: CoreDataProtocol {
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveLocation(name: String, latitude: Double, longitude: Double, notes: String?) -> AnyPublisher<Void, Error> {
        let newLocation = LocModel(context: context)
        newLocation.name = name == "" ? "unnamed" : name //Default name is unnamed.
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
    
    func fetchLocations() -> AnyPublisher<[LocModel], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            let fetchRequest: NSFetchRequest<LocModel> = LocModel.fetchRequest()
            do {
                let results = try self.context.fetch(fetchRequest)
                promise(.success(results))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(_ location: LocModel) -> AnyPublisher<Void, any Error> {
        context.delete(location)
        return save()
    }
}
