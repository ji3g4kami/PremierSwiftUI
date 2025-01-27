// MovieClient.swift
import ComposableArchitecture
import Foundation

// MARK: - API models

struct TopRated: Decodable, Equatable, Sendable {
    var results: [Movie]
}

extension TopRated {
    static let mock = Self(results: [
        Movie(id: 1, title: "One", overview: "overview 1", posterPath: nil, voteAverage: 1),
        Movie(id: 2, title: "Two", overview: "overview 2", posterPath: nil, voteAverage: 2),
        Movie(id: 3, title: "Three", overview: "overview 3", posterPath: nil, voteAverage: 3)
    ])
}

struct Movie: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    
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
            let host = "https://api.themoviedb.org/3"
            let apiKey: String = "***REMOVED***"
            let apiKeyQueryItem = URLQueryItem(name: "api_key", value: apiKey)
            
            var components = URLComponents(string: "https://api.themoviedb.org/3")!
            components.path = "top_rated"
            components.queryItems = [
                apiKeyQueryItem
            ]
            
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try JSONDecoder().decode(TopRated.self, from: data)
        }
    )
}

