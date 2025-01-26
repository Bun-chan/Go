import SwiftUI

struct HomeView: View {
    
    @State private var shouldShowLocationError = false
    @State private var locationErrorMessage = ""
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    homeViewModel.save()
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
    }
}

#Preview {
    let repo = HomeDefaultRepository()
    let useCase = HomeDefaultUseCase(homerepository: repo)
    let model = HomeViewModel(useCase: useCase)
    HomeView()
        .environmentObject(model)
}
