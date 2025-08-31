#if canImport(Flutter)
  import Flutter
#elseif canImport(FlutterMacOS)
  import FlutterMacOS
#endif

public class VideoOutputManager: NSObject {
  private let registry: FlutterTextureRegistry
  private var videoOutputs = [Int64: VideoOutput]()

  init(registry: FlutterTextureRegistry) {
    self.registry = registry
  }

  public func create(
    handle: Int64,
    configuration: VideoOutputConfiguration,
    textureUpdateCallback: @escaping VideoOutput.TextureUpdateCallback
  ) {
    let videoOutput = VideoOutput(
      handle: handle,
      configuration: configuration,
      registry: self.registry,
      textureUpdateCallback: textureUpdateCallback
    )

    self.videoOutputs[handle] = videoOutput
  }

  public func setSize(
    handle: Int64,
    width: Int64?,
    height: Int64?
  ) {
    let videoOutput = self.videoOutputs[handle]
    if videoOutput == nil {
      return
    }

    videoOutput!.setSize(
      width: width,
      height: height
    )
  }

  public func destroy(
    handle: Int64
  ) {
    let videoOutput = self.videoOutputs[handle]
    if videoOutput == nil {
      return
    }

    self.videoOutputs[handle] = nil
  }

  public func enterPictureInPicture(handle: Int64) -> Bool {
    guard let videoOutput = self.videoOutputs[handle] else {
      return false
    }
    return videoOutput.enterPictureInPicture()
  }

  public func exitPictureInPicture(handle: Int64) -> Bool {
    guard let videoOutput = self.videoOutputs[handle] else {
      return false
    }
    return videoOutput.exitPictureInPicture()
  }

  public func isInPictureInPictureMode(handle: Int64) -> Bool {
    guard let videoOutput = self.videoOutputs[handle] else {
      return false
    }
    return videoOutput.isInPictureInPictureMode()
  }

  public func isPictureInPictureSupported() -> Bool {
    // iOS 14.0+ için PiP desteği kontrol et
    if #available(iOS 14.0, *) {
      return true
    } else {
      return false
    }
  }
}
