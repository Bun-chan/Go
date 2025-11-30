import SwiftUI
import CoreData

@main
struct GoApp: App {
    init() {
        let coreDataDataSource = CoreDataDataSource(context: CoreDataManager.shared.viewContext)
        let homeViewModel = HomeViewModel(useCase: HomeDefaultUseCase(homeRepository: HomeDefaultRepository(locationManager: LocationManager(), coreDataDataSource: coreDataDataSource)))
        Container.shared.register(service: homeViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(resolveViewModel())
        }
    }
    
    func resolveViewModel() -> HomeViewModel {
        guard let viewModel = Container.shared.resolve() as HomeViewModel? else {
            fatalError("HomeViewModel not registered in the container")
        }
        return viewModel
    }
}
