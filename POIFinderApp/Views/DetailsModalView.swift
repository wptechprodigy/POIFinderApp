//
//  DetailsModalView.swift
//  POIFinderApp
//
//  Created by waheedCodes on 16/02/2025.
//

import SwiftUI
import MapKit

struct DetailsModalView: View {
    let place: MKMapItem
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(place.name ?? "Unknown Place")
                .font(.title)
                .padding()

            Text(place.placemark.title ?? "No Address")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button("Close") {
                isPresented = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

//#Preview {
//    DetailsModalView(place: <#MKMapItem#>, isPresented: <#Binding<Bool>#>)
//}
