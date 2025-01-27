// TopRatedFeature.swift
import ComposableArchitecture
import Foundation

@Reducer
struct TopRatedFeature {
    @ObservableState
    struct State: Equatable {
        var results: [Movie] = []
        var isLoading = false
    }
    
    enum Action {
        case loadTopRated
        case topRatedResponse(TopRated)
    }
    
    @Dependency(\.movieClient) var movieClient
    
//    private enum CancelID { case }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action{
            case .loadTopRated:
                state.isLoading = true
                return .run { send in
                    try await send(.topRatedResponse(self.movieClient.topRated()))
                }
            case .topRatedResponse(let topRated):
                state.isLoading = false
                state.results = topRated.results
                return .none
            }
        }
    }
}
