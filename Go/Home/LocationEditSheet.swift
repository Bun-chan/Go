import SwiftUI

struct LocationEditSheet: View {
    @Binding var locationName: String
    let onSave: () -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack {
            TextField("Enter the location's name", text: $locationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save") {
                onSave()
            }
            Button("Delete") {
                onDelete()
            }
        }
        .frame(width: 300, height: 260)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    LocationEditSheet(locationName: .constant("Bermuda Triangle"), onSave: { print("save") }, onDelete: { print("save") })
}
