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
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesResponse.success) {
            $0.isLoading = false
            $0.movies.append(contentsOf: TopRated.mock.results)
        }
    }
    
    @Test
    func topRated_failure() async throws {
        let error = NSError(domain: "test", code: 1)
        
        let store = await TestStore(initialState: TopRatedFeature.State()) {
            TopRatedFeature()
        } withDependencies: {
            $0.movieClient.topRated = { throw error }
        }
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesResponse.failure) {
            $0.isLoading = false
        }
    }
}
