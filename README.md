# PremierSwiftUI

A SwiftUI application for browsing movies using The Movie Database (TMDB) API. TCA is used for the architecture.

## Features

- Browse top-rated movies
- View movie details
- Pagination support
- Clean SwiftUI architecture

## Setup

### API Key Configuration

This app requires a TMDB API key to function. Follow these steps to set it up:

1. Get an API key from [The Movie Database](https://www.themoviedb.org/documentation/api)
2. Add the API key to your Xcode environment:
   - In Xcode, click on your project name in the toolbar
   - Select "Edit Scheme..." from the dropdown
   - In the scheme editor, select the "Run" action on the left
   - Go to the "Arguments" tab
   - In the "Environment Variables" section, click "+" to add a new variable
   - Set the name to `TMDB_API_KEY` and the value to your actual API key

### Running the App

1. Clone the repository
2. Open `PremierSwiftUI.xcodeproj` in Xcode
3. Configure your API key as described above
4. Build and run the app

## Architecture

This app follows a clean architecture approach with:
- SwiftUI views for the UI layer
- Dedicated API client for network requests
- Environment-based dependency injection

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+