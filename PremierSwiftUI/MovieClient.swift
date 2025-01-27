// MovieClient.swift
import ComposableArchitecture
import Foundation

// MARK: - API models

struct TopRated: Decodable, Equatable, Sendable {
    var results: [Movie]
}

extension TopRated {
    
    static let superLong2 = String(repeating: "overview 2 ", count: 20)
    
    static let mock = Self(results: [
        Movie(id: 1, title: "One", overview: "overview 1", posterPath: nil, voteAverage: 1),
        Movie(id: 2, title: "Two", overview: superLong2, posterPath: nil, voteAverage: 2),
        Movie(id: 3, title: "Three", overview: "overview 3", posterPath: nil, voteAverage: 3)
    ])
}

struct Movie: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185/\(posterPath)")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
}

// MARK: - API client interface

@DependencyClient
struct MovieClient {
    var topRated: @Sendable () async throws -> TopRated
}

extension MovieClient: TestDependencyKey {
    static let previewValue = Self(topRated: { .mock })
    
    static let testValue = Self()
}

extension DependencyValues {
    var movieClient: MovieClient {
        get { self[MovieClient.self] }
        set { self[MovieClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension MovieClient: DependencyKey {
    static let liveValue = MovieClient(
        topRated: {
            let apiKey: String = "***REMOVED***"
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.themoviedb.org"
            components.path = "/3/movie/top_rated"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: apiKey)
            ]
            
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(TopRated.self, from: data)
        }
    )
}

