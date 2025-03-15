// MovieDetailView.swift

import ComposableArchitecture
import SwiftUI

struct MovieDetailView: View {
    
    let store: StoreOf<MovieDetailFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Movie poster
                CachedAsyncImage(url: store.movie.backdropURL) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                }
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                
                // Movie title
                Text(store.movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Overview
                Text(store.movie.overview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle(store.movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(
            store: Store(
                initialState: MovieDetailFeature.State(
                    movie: Movie(id: 0, title: "The Shawshank Redemption", overview: "Imprisoned in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope.", posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg", backdropPath: "/zfbjgQE1uSd9wiPTX4VzsLi0rGG.jpg", voteAverage: 8.7)),
                reducer: {
                    MovieDetailFeature()
                }))
    }
}
