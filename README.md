<a href="https://github.com/ueshun109/CDAsyncImage/blob/main/LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-green.svg"></a>
<a href="https://github.com/apple/swift-package-manager" alt="Firestore on Swift Package Manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" /></a>

# CDAsyncImage

`CDAsyncImage` has the following two features.
- Cache
- Downsampling

> [!NOTE]
> `CD` is an acronym for Cache and Downsampling.

## Usage
```swift
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
```

## Reference
This repository is very much based on the following
- [swiftui-cached-async-image](https://github.com/lorenzofiamingo/swiftui-cached-async-image)
- [AsyncDownSamplingImage](https://github.com/fummicc1/AsyncDownSamplingImage)
