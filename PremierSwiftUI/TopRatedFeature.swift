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
        var isLoadingNextPage = false
        var hasMorePages = true
        @Presents var destination: Destination.State?
        var path = StackState<MovieDetailFeature.State>()
    }
    
    enum Action {
        case onAppear
        case moviesResponse(Result<TopRated, Error>)
        case loadNextPage
        case nextPageResponse(Result<TopRated, Error>)
        case destination(PresentationAction<Destination.Action>)
        case path(StackActionOf<MovieDetailFeature>)
        enum Alert: Equatable {
            case dismiss
        }
    }
    
    @Dependency(\.movieClient) var movieClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.movies.isEmpty else { return .none }
                state.isLoading = true
                return .run { send in
                    let result = await Result { try await movieClient.topRated(nil) }
                    await send(.moviesResponse(result))
                }
                
            case let .moviesResponse(.success(topRated)):
                state.isLoading = false
                state.movies.append(contentsOf: topRated.results)
                return .none
                
            case let .moviesResponse(.failure(error)):
                state.isLoading = false
                
                state.destination = .alert(
                    AlertState {
                        TextState("Error")
                    } actions: {
                        ButtonState(role: .cancel, action: .send(.none)) {
                            TextState("OK")
                        }
                    } message: {
                        TextState(error.localizedDescription)
                    }
                )
                return .none
                
            case .loadNextPage:
                guard !state.isLoadingNextPage && state.hasMorePages else { return .none }
                state.isLoadingNextPage = true
                let nextPage = state.currentPage + 1
                return .run { send in
                    let result = await Result { try await movieClient.topRated(page: nextPage) }
                    await send(.nextPageResponse(result))
                }
                
            case let .nextPageResponse(.success(topRated)):
                state.isLoadingNextPage = false
                state.currentPage = topRated.page
                state.movies.append(contentsOf: topRated.results)
                state.hasMorePages = topRated.page < topRated.totalPages
                return .none
                
            case .nextPageResponse(.failure):
                state.isLoadingNextPage = false
                return .none
                
            case .destination:
                return .none
                
            case .path:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path) {
            MovieDetailFeature()
        }
    }
}

extension TopRatedFeature {
    @Reducer
    enum Destination {
        case alert(AlertState<TopRatedFeature.Action.Alert>)
    }
}
extension TopRatedFeature.Destination.State: Equatable {}
