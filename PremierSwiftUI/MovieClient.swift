// MovieClient.swift
import ComposableArchitecture
import Foundation

// MARK: - API models

struct TopRated: Decodable, Equatable, Sendable {
    let page: Int
    let totalPages: Int
    var results: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}

extension TopRated {
    
    static let superLong2 = String(repeating: "overview 2 ", count: 20)
    
    static let mock = Self(
        page: 1,
        totalPages: 2,
        results: [
            Movie(id: 1, title: "One", overview: "overview 1", posterPath: nil, voteAverage: 1),
            Movie(id: 2, title: "Two", overview: superLong2, posterPath: nil, voteAverage: 2),
            Movie(id: 3, title: "Three", overview: "overview 3", posterPath: nil, voteAverage: 3)
        ])
    
    static let mockPage2 = Self(
        page: 2,
        totalPages: 2,
        results: [
            Movie(id: 4, title: "Four", overview: "overview 4", posterPath: nil, voteAverage: 4)
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
    var topRated: @Sendable (_ page: Int?) async throws -> TopRated
}

extension MovieClient: TestDependencyKey {
    static let previewValue = Self(topRated: { page in .mock })
    
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
        topRated: { page in
            let apiKey: String = "***REMOVED***"
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.themoviedb.org"
            components.path = "/3/movie/top_rated"
            
            var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            if let page{
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            components.queryItems = queryItems
            
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(TopRated.self, from: data)
        }
    )
}

