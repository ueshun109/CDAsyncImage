//
//  DownSampling.swift
//
//
//  Created by shun uematsu on 2024/04/30.
//

import Foundation
import ImageIO

struct DownSampling {
  enum Error: LocalizedError {
    case failedToFetchImage
    case failedToDownsample
  }

  static func perform(
    with data: Data,
    size: CGSize,
    scale: CGFloat = 1
  ) async throws -> CGImage {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
      throw Error.failedToFetchImage
    }
    let maxDimensionsInPixels = max(size.width, size.height) * scale
    let downsampledOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels,
    ] as CFDictionary
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(
      imageSource,
      0,
      downsampledOptions
    ) else {
      throw Error.failedToDownsample
    }
    return downsampledImage
  }
}
