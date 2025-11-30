import SwiftUI
import MapKit
import CoreData
import Combine

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedItemCoreData: LocModel?
    @State var currentLocation: CLLocation?
    @State var locationsCoreData: [LocModel] = []
    @State var locationName: String = ""
    @Namespace var mapScope
    
    var addPinButton: some View {
        Button {
            guard let currentLocation = currentLocation else { return }
            homeViewModel.addPin(currentLocation)
        } label: {
            Text("Add a pin")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
        .padding(.trailing, 60)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, scope: mapScope) { //Map content builder closure.
                
                ForEach(locationsCoreData) { location in
                    Annotation(location.name ?? "Error", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "location.circle.fill")
                            .foregroundStyle(.red)
                            .imageScale(.large)
                            .onTapGesture {
                                selectedItemCoreData = location
                                locationName = location.name ?? "Error"
                            }
                    }
                }
            }
            .sheet(item: $selectedItemCoreData) { item in //Show the sheet when the user selects a pin.
                LocationEditSheet(
                    locationName: $locationName,
                    onSave: {
                        updateLocation()
                        selectedItemCoreData = nil
                    },
                    onDelete: {
                        deleteLocation()
                        selectedItemCoreData = nil
                    }
                )
            }
            .alert(item: $homeViewModel.alertMessage) { message in
                Alert(
                    title: Text("Error"),
                    message: Text(message.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onReceive(homeViewModel.$myPinsCoreData) { locations in
                self.locationsCoreData = locations
            }
            .onReceive(homeViewModel.$location) { location in
                self.currentLocation = location
            }
            .onAppear {
                homeViewModel.getLocations()
            }
            .onMapCameraChange { context in
                print("VIEW onMapCameraChange")
            }
            .onChange(of: position) {
                print("positionedByUser: ", position.positionedByUser)
            }
            .overlay(alignment: .bottomTrailing) {
                VStack {
                    MapUserLocationButton(scope: mapScope)
                    MapPitchToggle(scope: mapScope)
                    MapCompass(scope: mapScope)
                        .mapControlVisibility(.visible)
                }
                .padding(.trailing, 10)
                .buttonBorderShape(.circle)
            }
            .mapScope(mapScope)
            .overlay(alignment: .bottomLeading) {
                addPinButton
            }
        }
    }
    
    //Save the updated location when the user edits the location's name, or another property.
    private func updateLocation() {
        if let updatedItem = selectedItemCoreData {
            updatedItem.name = locationName
            homeViewModel.updateLocation()
        }
    }
    
    private func deleteLocation() {
        if let selectedItemCoreData {
            homeViewModel.deleteLocationCoreData(selectedItemCoreData)
        }
    }
}

#Preview {
    let persistentContainer = NSPersistentContainer(name: "GoLocModel")
    let coreDataDataSource = CoreDataDataSource(context: persistentContainer.viewContext)
    let repo = HomeDefaultRepository(coreDataDataSource: coreDataDataSource)
    let useCase = HomeDefaultUseCase(homeRepository: repo)
    let model = HomeViewModel(useCase: useCase)
    HomeView()
        .environmentObject(model)
}
