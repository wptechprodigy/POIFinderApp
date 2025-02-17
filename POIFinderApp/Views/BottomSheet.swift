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

                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .ignoresSafeArea(.all, edges: .bottom)
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
