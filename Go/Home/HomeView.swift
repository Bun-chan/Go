import SwiftUI
import MapKit

struct HomeView: View {
    
    @State private var shouldShowLocationError = false
    @State private var locationErrorMessage = ""
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.4546, longitude: 139.6310), latitudinalMeters: 5000, longitudinalMeters: 5000))
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var myLocations: [MyLocation]? = nil
    @State private var selectedLocation: MyLocation?
    @State private var locationName: String = ""
    @State private var locationDescription: String = ""
    @State private var showAlert = false //just for debugging.

    var body: some View {
        VStack {
//            Map(position: $cameraPosition) {
//                if let myLocations = myLocations {
//                    ForEach(myLocations) { location in
//                        Annotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
//                            Image(systemName: "mappin")
//                                .onTapGesture {
//                                    selectedLocation = location
//                                    locationName = location.name //Sets the textfield value.
//                                    print("Selected Location: \(location.name)")//REMOVE
//                                }
//                        } label: {//is there a better api? i do not need label...
//                        }
//                    }
//                }
//            }
            Map(coordinateRegion: $region, showsUserLocation: true) // Display map and follow user location
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
                    homeViewModel.save() //This is to add a new pin.
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
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        }
        .onAppear {
            homeViewModel.getUserDefLocs()
        }
        .alert(isPresented: $showAlert) {
            if let count = myLocations?.count {
                return Alert(
                    title: Text("Locations"),
                    message: Text("retrieved \(count) locations"),
                    dismissButton: .default(Text("OK"))
                )
            }
            return Alert(
                title: Text("Locations"),
                message: Text("retrieved 0000 locations"),
                dismissButton: .default(Text("OK"))
            )
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
