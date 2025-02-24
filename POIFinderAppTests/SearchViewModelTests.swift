//
//  SearchViewModelTests.swift
//  POIFinderAppTests
//
//  Created by waheedCodes on 17/02/2025.
//

import XCTest
import Combine
@testable import POIFinderApp

final class SearchViewModelTests: XCTestCase {
    private var searchViewModel: SearchViewModel!
    private var mockCompleter: MockMKLocalSearchCompleter!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockCompleter = MockMKLocalSearchCompleter()
        searchViewModel = SearchViewModel(completer: mockCompleter)
        searchViewModel.setupSearchDebouncer()
    }

    override func tearDown() {
        searchViewModel = nil
        mockCompleter = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testAutocompleteSuggestions() {
        let expectation = XCTestExpectation(description: "Autocomplete suggestions fetched")
        
        searchViewModel.search(query: "rest")
        mockCompleter.simulateSearch() // Simulate search results
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Wait for debounce
            XCTAssertFalse(self.searchViewModel.searchResults.isEmpty, "Autocomplete results should not be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testDebouncingBehavior() {
        let expectation = XCTestExpectation(description: "Debouncing works")
        
        searchViewModel.search(query: "res")
        searchViewModel.search(query: "rest") // Overwrite previous query
        mockCompleter.simulateSearch() // Simulate search results
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Wait for debounce
            XCTAssertTrue(self.searchViewModel.searchResults.contains(where: { $0.title.lowercased().contains("rest") }),
                          "Debounced query should fetch results for 'rest'")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
