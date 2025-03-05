// TopMoviesView.swift
import ComposableArchitecture
import SwiftUI

struct TopMoviesView: View {
    
    let store: StoreOf<TopRatedFeature>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.movies) { movie in
                                MovieRow(movie: movie)
                                    .background(Color.white)
                                    .onAppear {
                                        if movie.id == store.movies.last?.id {
                                            store.send(.loadNextPage)
                                        }
                                    }
                            }
                            
                            if store.isLoadingNextPage {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Top Movies")
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}

struct MovieRow: View {
    
    let movie: Movie
    private let columnSpacing: CGFloat = 20
    private let posterSize: CGSize = CGSize(width: 92, height: 134)
    
    var body: some View {
        HStack(alignment: .top, spacing: columnSpacing) {
            VStack(alignment: .leading, spacing: 10) {
                CachedAsyncImage(
                    url: movie.posterURL) {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .frame(width: posterSize.width, height: posterSize.height)
                    .cornerRadius(8)
                
                RatingTagView(rating: movie.voteAverage)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct RatingTagView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(4)
    }
}

#Preview {
    NavigationStack {
        TopMoviesView(
            store: Store(
                initialState: TopRatedFeature.State(
                    movies: IdentifiedArrayOf(uniqueElements: TopRated.mock.results)
                ),
                reducer: {
                    TopRatedFeature()
                }
            )
        )
    }
}
