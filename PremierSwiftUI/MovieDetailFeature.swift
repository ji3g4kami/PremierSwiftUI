// MovieDetailFeature.swift

import ComposableArchitecture

@Reducer
struct MovieDetailFeature {
    @ObservableState
    struct State: Equatable {
        let movie: Movie
    }
    enum Action {
    }
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self> {
        Reduce { state, action in
                return .none
        }
    }
}
