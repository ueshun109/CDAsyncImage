//
//  AsyncImageLoader.swift
//
//
//  Created by shun uematsu on 2024/04/30.
//

import SwiftUI

struct AsyncImageLoader {
  let urlRequest: URLRequest?
  let urlSession: URLSession
  let urlCache: URLCache
  let downsampleSize: CGSize

  func load(with scaleFactor: CGFloat) async -> AsyncImagePhase {
    do {
      guard let urlRequest else { return .empty }

      if let image = try await cachedImage(from: urlRequest, cache: urlCache, scaleFactor: scaleFactor) {
        return .success(image)
      } else {
        let image = try await remoteImage(from: urlRequest, session: urlSession, scaleFactor: scaleFactor)
        return .success(image)
      }
    } catch {
      return .failure(error)
    }
  }

  private func remoteImage(
    from request: URLRequest,
    session: URLSession,
    scaleFactor: CGFloat
  ) async throws -> Image {
    let (data, _, metrics) = try await session.data(for: request)
    if metrics.redirectCount > 0, let lastResponse = metrics.transactionMetrics.last?.response {
      let requests = metrics.transactionMetrics.map { $0.request }
      requests.forEach(session.configuration.urlCache!.removeCachedResponse)
      let lastCachedResponse = CachedURLResponse(response: lastResponse, data: data)
      session.configuration.urlCache!.storeCachedResponse(lastCachedResponse, for: request)
    }
    return try await image(with: data, scaleFactor: scaleFactor)
  }

  private func cachedImage(
    from request: URLRequest,
    cache: URLCache,
    scaleFactor: CGFloat
  ) async throws -> Image? {
    guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
    return try await image(with: cachedResponse.data, scaleFactor: scaleFactor)
  }

  private func image(with data: Data, scaleFactor: CGFloat) async throws -> Image {
    do {
      let cgImage = try await DownSampling.perform(with: data, size: downsampleSize, scaleFactor: scaleFactor)
      let uiImage = UIImage(cgImage: cgImage)
      return Image(uiImage: uiImage)
    } catch {
      throw error
    }
  }
}

// MARK: - AsyncImageURLSession

private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
  var metrics: URLSessionTaskMetrics?

  func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    self.metrics = metrics
  }
}

private extension URLSession {
  func data(for request: URLRequest) async throws -> (Data, URLResponse, URLSessionTaskMetrics) {
    let controller = URLSessionTaskController()
    let (data, response) = try await data(for: request, delegate: controller)
    return (data, response, controller.metrics!)
  }
}
