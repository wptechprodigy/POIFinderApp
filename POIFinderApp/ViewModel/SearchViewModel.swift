//
//  SearchViewModel.swift
//  POIFinderApp
//
//  Created by waheedCodes on 17/02/2025.
//

import Foundation
import Combine
import MapKit

class SearchViewModel: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private let completer: MKLocalSearchCompleterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(completer: MKLocalSearchCompleterProtocol = MKLocalSearchCompleter()) {
        self.completer = completer
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    // Debounced search query publisher
    private let searchQueryPublisher = PassthroughSubject<String, Never>()
    
    func setupSearchDebouncer() {
        searchQueryPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.completer.queryFragment = query
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        searchQueryPublisher.send(query)
    }
}

// MKLocalSearchCompleterDelegate implementation
extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
    }
}

// Protocol for mocking MKLocalSearchCompleter
protocol MKLocalSearchCompleterProtocol: AnyObject {
    var delegate: MKLocalSearchCompleterDelegate? { get set }
    var queryFragment: String { get set }
    var resultTypes: MKLocalSearchCompleter.ResultType { get set }
    var results: [MKLocalSearchCompletion] { get }
}

extension MKLocalSearchCompleter: MKLocalSearchCompleterProtocol {}
