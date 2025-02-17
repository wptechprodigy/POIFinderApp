//
//  SearchService.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import MapKit
import Combine

class SearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
    }

    // Update the query fragment as the user types
    func search(query: String) {
        completer.queryFragment = query
    }

    // MKLocalSearchCompleterDelegate method
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
    }
}
