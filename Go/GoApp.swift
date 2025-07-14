import SwiftUI
import CoreData

@main
struct GoApp: App {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "GoLocModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        let coreDataDataSource = CoreDataDataSource(context: persistentContainer.viewContext)
        let homeViewModel = HomeViewModel(useCase: HomeDefaultUseCase(homerepository: HomeDefaultRepository(locationManager: LocationManager(), coreDataDataSource: coreDataDataSource)))
        Container.shared.register(service: homeViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(resolveViewModel())
        }
    }
    func resolveViewModel() -> HomeViewModel {
        // Resolve the ViewModel from the container
        guard let viewModel = Container.shared.resolve() as HomeViewModel? else {
            fatalError("HomeViewModel not registered in the container")
        }
        return viewModel
    }
}
