import SwiftUI
import MapKit
import CoreData

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedItemCoreData: LocModel?
    @State var currentLocation: CLLocation?
    @State var locationsCoreData: [LocModel] = []
    @State var locationName: String = ""
    @Namespace var mapScope
    
    var body: some View {
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
            VStack {
                TextField("Enter the location's name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Save") {
                    updateLocation()
                    selectedItemCoreData = nil
                }
                Button("Delete") {
                    deleteLocation()
                    selectedItemCoreData = nil
                }
            }
            .frame(width: 300, height: 260)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
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
        VStack {
            Button(action: {
                guard let currentLocation else { return }
                self.homeViewModel.addPin(currentLocation)
            }) {
                Text("Add a pin")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
        }
    }
    
    //Save the updated location when the user edits the location's name, or other property.
    private func updateLocation() {
        if var updatedItem = selectedItemCoreData {
            updatedItem.name = locationName
//            homeViewModel.updateLocation(updatedItem) Rewrite this for coreData
        }
    }
    
    private func deleteLocation() {
        if let selectedItemCoreData {
            homeViewModel.deleteLocationCoreData(selectedItemCoreData)
        }
    }
}

#Preview {
    let persistentContainer = NSPersistentContainer(name: "GoLocModel") // Replace with your model name
    let coreDataDataSource = CoreDataDataSource(context: persistentContainer.viewContext)
    let repo = HomeDefaultRepository(coreDataDataSource: coreDataDataSource)
    let useCase = HomeDefaultUseCase(homerepository: repo)
    let model = HomeViewModel(useCase: useCase)
    HomeView()
        .environmentObject(model)
}
