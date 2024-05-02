//
//  AsyncImageView.swift
//
//
//  Created by shun uematsu on 2024/04/30.
//

import ImageIO
import SwiftUI

public struct CDAsyncImage<Content>: View where Content: View {
  @State private var phase: AsyncImagePhase = .empty
  private let imageLoader: AsyncImageLoader
  private let content: (AsyncImagePhase) -> Content

  public init(
    url: URL?,
    downsampleSize: CGSize,
    urlCache: URLCache = .shared,
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    let urlRequest = url == nil ? nil : URLRequest(url: url!)
    self.init(
      urlRequest: urlRequest,
      downsampleSize: downsampleSize,
      urlCache: urlCache,
      content: content
    )
  }

  public init(
    urlRequest: URLRequest?,
    downsampleSize: CGSize,
    urlCache: URLCache = .shared,
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = urlCache
    self.imageLoader = AsyncImageLoader(
      urlRequest: urlRequest,
      urlSession: URLSession(configuration: configuration),
      urlCache: urlCache,
      downsampleSize: downsampleSize
    )
    self.content = content
  }

  public var body: some View {
    content(phase)
      .task(id: imageLoader.urlRequest) {
        self.phase = await imageLoader.load()
      }
  }
}

#Preview {
  let iconURL: URL? = .init(string: "")
  let downsampleSize: CGSize = .init(width: 60, height: 60)
  CDAsyncImage(url: iconURL, downsampleSize: downsampleSize) { phase in
    switch phase {
    case .empty:
      ProgressView()
    case .success(let image):
      image
        .resizable()
        .scaledToFill()
        .frame(width: 60, height: 60)
    case .failure(let error):
      Text(error.localizedDescription)
    @unknown default:
      fatalError()
    }
  }
}
