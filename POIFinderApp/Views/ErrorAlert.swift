//
//  ErrorAlert.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import SwiftUI

struct ErrorAlert: View {
    var message: String
    var dismissAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
            Button("OK") {
                dismissAction()
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

#Preview {
    ErrorAlert(message: "This is an error message", dismissAction: {})
}
