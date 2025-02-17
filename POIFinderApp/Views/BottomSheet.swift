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
    }
    
    private func saveFavoriteLocation() {
        let coreDataService = CoreDataService(context: context)
        
        do {
            try coreDataService.saveFavoriteLocation(
                name: place.name ?? "Unknown",
                category: "Restaurant", // Replace with actual category if available
                address: place.placemark.title ?? "No Address",
                latitude: place.placemark.coordinate.latitude,
                longitude: place.placemark.coordinate.longitude
            )
            print("Saved favorite location: \(place.name ?? "Unknown")")
        } catch {
            print("Error saving favorite location: \(error.localizedDescription)")
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
