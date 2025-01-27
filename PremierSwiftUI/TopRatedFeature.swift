// TopRatedFeature.swift
import ComposableArchitecture
import Foundation

@Reducer
struct TopRatedFeature {
    @ObservableState
    struct State: Equatable {
        var movies: IdentifiedArrayOf<Movie> = []
        var currentPage: Int = 1
        var isLoading = false
    }
    
    enum Action {
        case onAppear
        case moviesResponse(Result<TopRated, Error>)
    }
    
    @Dependency(\.movieClient) var movieClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action{
            case .onAppear:
                guard state.movies.isEmpty else { return .none }
                state.isLoading = true
                return .run { send in
                    let result = await Result { try await movieClient.topRated() }
                    await send(.moviesResponse(result))
                }
                
            case let .moviesResponse(.success(topRated)):
                state.isLoading = false
                state.movies.append(contentsOf: topRated.results)
                return .none
                
            case let .moviesResponse(.failure(_)):
                state.isLoading = false
                return .none
            }
        }
    }
}
