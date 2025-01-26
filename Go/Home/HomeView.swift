import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedItem: MyLocation?
    @State var currentLocation: MyLocation?
    @State var locations: [MyLocation] = []
    @State var locationName: String = ""
    @Namespace var mapScope
    
    var body: some View {
        Map(position: $position, scope: mapScope) { //Map content builder closure.
            ForEach(locations) { location in
                Annotation(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Image(systemName: "location.circle.fill")
                        .foregroundStyle(.red)
                        .imageScale(.large)
                        .onTapGesture {
                            selectedItem = location
                            locationName = location.name
                        }
                }
            }
        }
        .sheet(item: $selectedItem) { item in //Show the sheet when the user selects a pin.
            VStack {
                TextField("Enter the location's name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Save") {
                    updateLocation()
                    selectedItem = nil
                }
                Button("Delete") {
                    deleteLocation()
                    selectedItem = nil
                }
            }
            .frame(width: 300, height: 260)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        .onReceive(homeViewModel.$myPins) { locations in
            self.locations = locations
        }
        .onReceive(homeViewModel.$myLocation) { myLocation in
            self.currentLocation = myLocation
            print("updating my current location")
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
        if var updatedItem = selectedItem {
            updatedItem.name = locationName
            homeViewModel.updateLocation(updatedItem)
        }
    }
    
    private func deleteLocation() {
        if let selectedItem {
            homeViewModel.deleteLocation(selectedItem)
        }
    }
}

#Preview {
    let repo = HomeDefaultRepository()
    let useCase = HomeDefaultUseCase(homerepository: repo)
    let model = HomeViewModel(useCase: useCase)
    HomeView()
        .environmentObject(model)
}
