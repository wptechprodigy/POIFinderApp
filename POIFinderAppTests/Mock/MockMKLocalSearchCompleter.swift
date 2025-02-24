//
//  MockMKLocalSearchCompleter.swift
//  POIFinderAppTests
//
//  Created by waheedCodes on 17/02/2025.
//

import MapKit

class MockMKLocalSearchCompleter: MKLocalSearchCompleterProtocol {
    weak var delegate: MKLocalSearchCompleterDelegate?
    var queryFragment: String = ""
    var resultTypes: MKLocalSearchCompleter.ResultType = .address
    var results: [MKLocalSearchCompletion] = []
    
    private var mockResults: [MockSearchCompletion] = [
        MockSearchCompletion(title: "Restaurant A", subtitle: "123 Main St"),
        MockSearchCompletion(title: "Restaurant B", subtitle: "456 Elm St"),
        MockSearchCompletion(title: "Rest Area", subtitle: "789 Oak St")
    ]
    
    func simulateSearch() {
        // Simulate results based on the query fragment
        results = mockResults
            .filter { $0.title.lowercased().contains(queryFragment.lowercased()) }
            .map { _ in
                let completion = MKLocalSearchCompletion()
                // Use private APIs or other techniques if needed (not recommended for production)
                return completion
            }
        // delegate?.completerDidUpdateResults(self)
    }
}

struct MockSearchCompletion {
    let title: String
    let subtitle: String
}

extension MockSearchCompletion {
    var asMKLocalSearchCompletion: MKLocalSearchCompletion {
        let completion = MKLocalSearchCompletion()
        // Use private APIs or other techniques if needed (not recommended for production)
        return completion
    }
}
