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
            
        }
        .onAppear {
            homeViewModel.getLocations()
        }
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
    /*
    var body: some View {
        
        Map(position: $position, selection: $selectedItem, scope: mapScope) { //Map content builder closure.
            
            ForEach(locations) { location in
                Annotation(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Image(systemName: "location.circle.fill")
                        .onTapGesture {
                            selectedItem = location
//                            isSelected = true
//                                locationName = location.name //Sets the textfield value.
//                                print("Selected Location: \(location.name)")//REMOVE
                        }
                }
            }
        }
//        .overlay(alignment: .bottomTrailing) {
//            VStack {
//                MapUserLocationButton(scope: mapScope)
//                MapPitchToggle(scope: mapScope)
//                MapCompass(scope: mapScope)
//                    .mapControlVisibility(.visible)
//            }
//            .padding(.trailing, 10)
//            .buttonBorderShape(.circle)
//        }
//        .mapScope(mapScope)
//        .onMapCameraChange { context in
//            print("VIEW onMapCameraChange")
//        }
//        .onChange(of: position) {
//            print("positionedByUser: ", position.positionedByUser)
//        }
//        .onReceive(homeViewModel.$myLocation) { location in
//            print("VIEW received location")
//            guard let location else { return }
//            self.currentLocation = location
//            self.position = .camera(
//                MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),distance: 500))
//        }
//        .mapStyle(.standard(elevation: .flat))
        .sheet(item: $selectedItem) { item in //Show the sheet when the user selects a pin.
            VStack {
                Text("Edit Location \(item)")
                    .font(.headline)
//                TextField("Enter the location's name", text: item.name)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                Button("Save") {
//                    selectedItem?.name = locationName
//                    if let selectedItem {
//                        homeViewModel.updateLocation(selectedItem) //This is to change the Location's name, detail etc.
//                    }
//                    selectedItem = nil
//                    homeViewModel.getUserDefLocs()
//                }
//                Spacer().frame(height: 10)
//                Button("Cancel") {
//                    selectedItem = nil
//                }
//                Spacer().frame(height: 10)
//                Button("Delete") {
//                    if let selectedItem {
//                        homeViewModel.deleteLocation(selectedItem)
//                    }
//                    isSelected = false
//                }
            }
            .frame(width: 300, height: 260)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
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
        .onReceive(homeViewModel.$myPins) { locations in
            self.locations = locations
        }
        .onAppear {
            homeViewModel.getLocations()
        }
    }
}









    
    

    var body: some View {
        VStack {
            Map(position: $cameraPosition)
            {
                if let myLocations = myLocations {
                    ForEach(myLocations) { location in
                        Annotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                            Image(systemName: "mappin")
                                .onTapGesture {
                                    selectedLocation = location
                                    locationName = location.name //Sets the textfield value.
                                    print("Selected Location: \(location.name)")//REMOVE
                                }
                        } label: {//is there a better api? i do not need label...
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            
//            .onChange(of: cameraPosition, initial: false, { oldValue, newValue in //this gets called when the map needs to change region. not ONLY when the user touches the map. How to stop recentering the map only when the user starts interacting with the map???
//                shouldRecenterMapAutomatically = false
//            })
//            Map(coordinateRegion: $region, showsUserLocation: true) // Display map and follow user location
            .sheet(item: $selectedLocation) { location in
                VStack {
                    Text("Edit Location")
                        .font(.headline)
                    TextField("Enter the location's name", text: $locationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Save") {
                        selectedLocation?.name = locationName
                        if let selectedLocation {
                            homeViewModel.updateLocation(selectedLocation) //This is to change the Location's name, detail etc.
                        }
                        selectedLocation = nil
                        homeViewModel.getUserDefLocs()
                    }
                    Spacer().frame(height: 10)
                    Button("Cancel") {
                        selectedLocation = nil
                    }
                    Spacer().frame(height: 10)
                    Button("Delete") {
                        if let selectedLocation {
                            homeViewModel.deleteLocation(selectedLocation)
                        }
                        selectedLocation = nil
                    }
                }
                .frame(width: 300, height: 260)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
            }
            Spacer()
            HStack {
                Button(action: {
                    guard let myLocation else { return }
                    homeViewModel.save(myLocation) //This is to add a new pin.
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                Button(action: {
                    homeViewModel.show()
                }) {
                    Text("Show")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10)
            }
        }
        .alert("Location Error", isPresented: $shouldShowLocationError) {
            Button("ok", role: .cancel) { shouldShowLocationError = false }
        } message: {
            Text(locationErrorMessage)
        }
        .onReceive(homeViewModel.$locationError) { error in
            if let error = error {
                shouldShowLocationError = true
                switch error {
                case .couldNotGetLocation:
                    locationErrorMessage = "Unable to determine your location."
                }
            }
        }
        .onReceive(homeViewModel.$myLocations) { locations in
            myLocations = locations
            showAlert = true
        }
        .onReceive(homeViewModel.$myLocation) { location in
            //center the map on the user's location
            print("got the LOC")
            guard let location else { return }
            myLocation = location
//            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
//            if shouldRecenterMapAutomatically {
//                cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), latitudinalMeters: 300, longitudinalMeters: 300))
//            }
        }
        .onAppear {
            homeViewModel.getUserDefLocs()
        }
        .alert(isPresented: $showAlert) {
            if let count = myLocations?.count {
                return Alert(
                    title: Text("Locations"),
                    message: Text("Total \(count) locations"),
                    dismissButton: .default(Text("OK"))
                )
            }
            return Alert(
                title: Text("Locations"),
                message: Text("retrieved 0000 locations"),
                dismissButton: .default(Text("OK"))
            )
        }
    }*/


#Preview {
    let repo = HomeDefaultRepository()
    let useCase = HomeDefaultUseCase(homerepository: repo)
    let model = HomeViewModel(useCase: useCase)
    HomeView()
        .environmentObject(model)
}
