import SwiftUI

struct LocationEditSheet: View {
    @Binding var locationName: String
    let onSave: () -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack {
            HStack {
                TextField("Enter the location's name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button() {
                    locationName = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 34))
                        .padding()
                }
            }
            VStack {
                Button("Save") {
                    onSave()
                }
                .buttonStyle(PrimaryButtonStyle())
                Button("Delete") {
                    onDelete()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 300, height: 260)
        .background(Color.yellow)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    LocationEditSheet(locationName: .constant("Bermuda Triangle"), onSave: { print("save") }, onDelete: { print("save") })
}
