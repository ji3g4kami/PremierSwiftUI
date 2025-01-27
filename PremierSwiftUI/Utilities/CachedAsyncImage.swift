// CachedAsyncImage.swift

import Foundation
import SwiftUI
import UIKit

// actor for thread-safe image caching
actor ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache<NSString, UIImage> = NSCache()
    
    func insert(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func get(_ key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @State private var image: UIImage?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        let urlString = url.absoluteString
        
        if let cached = await ImageCache.shared.get(urlString) {
            self.image = cached
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloaded = UIImage(data: data) {
                await ImageCache.shared.insert(downloaded, for: urlString)
                self.image = downloaded
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
}

// Add a convenience initializer for common use case
extension CachedAsyncImage where Content == Image {
    init(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: url,
            content: { $0.resizable() },
            placeholder: placeholder
        )
    }
}
