//
//  BottomSheet.swift
//  POIFinderApp
//
//  Created by waheedCodes on 16/02/2025.
//

import SwiftUI
import MapKit

struct BottomSheet: View {
    let place: MKMapItem
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var context
    
    // State for alerts
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 8) // Small gap at the top

            HStack {
                Text("Details")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(place.name ?? "Unknown Place")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(place.placemark.title ?? "No Address")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    saveFavoriteLocation()
                }) {
                    Text("Save to Favorite")
                        .padding()
                        .background(Color.teal)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 18, weight: .semibold))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .ignoresSafeArea(.all, edges: .bottom)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func saveFavoriteLocation() {
        let coreDataService = CoreDataService(context: context)
        
        do {
            try coreDataService.saveFavoriteLocation(
                name: place.name ?? "Unknown",
                category: "Restaurant",
                address: place.placemark.title ?? "No Address",
                latitude: place.placemark.coordinate.latitude,
                longitude: place.placemark.coordinate.longitude
            )
            alertMessage = "Location saved successfully!"
            showAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isPresented = false
            }
        } catch {
            // Cast the error to NSError
            let nsError = error as NSError
            
            if nsError.domain == "DuplicateLocationError" {
                alertMessage = nsError.localizedDescription
            } else {
                alertMessage = "Failed to save location: \(nsError.localizedDescription)"
            }
            showAlert = true
        }
    }
}

// Helper extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    BottomSheet(place: .forCurrentLocation(), isPresented: .constant(true))
}
