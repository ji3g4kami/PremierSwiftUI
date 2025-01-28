// TopRatedFeatureTests.swift
import ComposableArchitecture
import Foundation
import Testing

@testable import PremierSwiftUI

struct TopRatedFeatureTests {
    
    @Test
    func topRated() async throws {
        let store = await TestStore(initialState: TopRatedFeature.State()) {
            TopRatedFeature()
        } withDependencies: {
            $0.movieClient.topRated = { @Sendable _ in .mock }
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
            $0.movieClient.topRated = { @Sendable _ in throw error }
        }
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesResponse.failure) {
            $0.isLoading = false
        }
    }
    
    @Test
    func loadNextPage() async throws {
        let store = await TestStore(initialState: TopRatedFeature.State(
            movies: IdentifiedArrayOf(uniqueElements: TopRated.mock.results),
            currentPage: 1,
            hasMorePages: true
        )) {
            TopRatedFeature()
        } withDependencies: {
            $0.movieClient.topRated = { @Sendable page in
                if page == 2 {
                    return TopRated.mockPage2
                }
                return TopRated.mock
            }
        }
        
        await store.send(.loadNextPage) {
            $0.isLoadingNextPage = true
        }
        
        await store.receive(\.nextPageResponse.success) {
            $0.isLoadingNextPage = false
            $0.currentPage = 2
            $0.movies.append(contentsOf: TopRated.mockPage2.results)
            $0.hasMorePages = false
        }
    }
}
