// PremierSwiftUITests.swift
import ComposableArchitecture
import Foundation
import Testing

@testable import PremierSwiftUI

struct PremierSwiftUITests {

    @Test
    func topRated() async throws {
        let store = await TestStore(initialState: TopRatedFeature.State()) {
            TopRatedFeature()
        } withDependencies: {
            $0.movieClient.topRated = { .mock }
        }
        
        await store.send(.loadTopRated) {
            $0.isLoading = true
        }
        await store.receive(\.topRatedResponse) {
            $0.isLoading = false
            $0.results = TopRated.mock.results
        }
    }

}
