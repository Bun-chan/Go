import SwiftUI

@main
struct GoApp: App {
    init() {
        let homeViewModel = HomeViewModel(useCase: HomeDefaultUseCase(homerepository: HomeDefaultRepository(locationManager: LocationManager())))
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
