// PremierSwiftUIApp.swift
import ComposableArchitecture
import SwiftUI

@main
struct PremierSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            TopMoviesView(store: Store(initialState: TopRatedFeature.State(), reducer: {
                TopRatedFeature()
            }))
        }
    }
}
