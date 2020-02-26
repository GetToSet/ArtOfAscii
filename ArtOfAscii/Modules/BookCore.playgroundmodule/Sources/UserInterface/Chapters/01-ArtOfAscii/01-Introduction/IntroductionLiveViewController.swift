//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport
import AVFoundation
import Accelerate

public class IntroductionLiveViewController: BaseViewController, PhotoAlbumSavable {

    private enum CameraOrientation {
        case front, back
    }

    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    @IBOutlet private weak var cameraFlashView: UIView!
    @IBOutlet private weak var sessionSetupResultLabel: UILabel!
    @IBOutlet private weak var captureButton: ToolBarButtonView!
    @IBOutlet private weak var cameraSwitchButton: ToolBarButtonView!

    var photoAlbumAccess = false

    private var setupResult: SessionSetupResult = .success

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "SessionQueue", qos: .userInteractive, autoreleaseFrequency: .workItem)
    private let dataOutputQueue = DispatchQueue(label: "VideoDataQueue", qos: .userInteractive, autoreleaseFrequency: .workItem)
    private let effectTypeAccessQueue = DispatchQueue(label: "EffectTypeAccessQueue", qos: .userInteractive, autoreleaseFrequency: .workItem)

    private let backCameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.back).devices
    private let frontCameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.front).devices

    private var cameraOrientation = CameraOrientation.back
    private var currentEffectType = AsciiEffects.plain

    private lazy var info420vToARGB: vImage_YpCbCrToARGB? = {
        var info = vImage_YpCbCrToARGB()
        var pixelRange = vImage_YpCbCrPixelRange(
                Yp_bias: 16,
                CbCr_bias: 128,
                YpRangeMax: 235,
                CbCrRangeMax: 240,
                YpMax: 235,
                YpMin: 16,
                CbCrMax: 240,
                CbCrMin: 16)
        if vImageConvert_YpCbCrToARGB_GenerateConversion(
                kvImage_YpCbCrToARGBMatrix_ITU_R_601_4,
                &pixelRange,
                &info,
                kvImage420Yp8_CbCr8,
                kvImageARGB8888,
                vImage_Flags(kvImageNoFlags)) == kvImageNoError {
            return info
        }
        return nil
    }()

    private var destinationBuffer = vImage_Buffer()
    private var shouldRecreateDestinationBuffer = true

    deinit {
        if destinationBuffer.data != nil {
            free(destinationBuffer.data)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        registerFonts()

        imagePickerController.enableCameraRollPicking = false
        sessionSetupResultLabel.isHidden = true

        cameraSwitchButton.state = .disabled
        cameraSwitchButton.delegate = self

        captureButton.state = .disabled
        captureButton.delegate = self

        imagePickerController.sampleImageType = .effectsPreview

        imagePickerController.selectFirstImage(animated: true)

        cameraFlashView.alpha = 0
    }

    public override func viewWillDisappear(_ animated: Bool) {
        stopSession()
        super.viewWillDisappear(animated)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        sessionQueue.async {
            if self.session.isRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    self.adjustVideoOrientation()
                }
            }
        }
    }

    override func didPickNamedItem(name: String, pickerController: ImagePickerViewController) {
        if let effect = AsciiEffects(rawValue: name) {
            effectTypeAccessQueue.async {
                self.currentEffectType = effect
            }
        }
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        buttonView.state = .normal
        switch buttonView {
        case cameraSwitchButton:
            cameraOrientation = cameraOrientation == .front ? .back : .front
            reconfigureSession()
        case captureButton:
            if let imageToSave = showcaseImageView.image {
                saveImage(imageToSave)
                cameraFlashView.alpha = 1.0
                UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseOut, animations: {
                    self.cameraFlashView.alpha = 0.0
                }, completion: nil)
            }
        default:
            break
        }
    }

    public override func liveViewMessageConnectionOpened() {
        requestAuthorization()
        reconfigureSession()
        startSessionAndUpdateUI()
    }

    public override func liveViewMessageConnectionClosed() {
        stopSession()
    }

    public override func receive(_ message: PlaygroundValue) {

    }

    private func registerFonts() {
        FontResourceProvider.FiraCode.register()
        FontResourceProvider.CourierPrime.register()
        FontResourceProvider.JoystixMonospace.register()
    }

}

extension IntroductionLiveViewController {

    private func requestAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            let semaphore = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
                semaphore.signal()
            }
            semaphore.wait()
        default:
            setupResult = .notAuthorized
        }
        requestPhotoAlbumAccess()
    }

    private func reconfigureSession() {
        guard setupResult == .success else {
            return
        }
        sessionQueue.async {
            self.session.beginConfiguration()
            defer {
                if self.setupResult != .success {
                    self.session.commitConfiguration()
                }
            }

            self.session.inputs.forEach { input in
                self.session.removeInput(input)
            }

            self.session.sessionPreset = AVCaptureSession.Preset.photo

            let cameraOptional: AVCaptureDevice?
            switch self.cameraOrientation {
            case .front:
                cameraOptional = self.frontCameras.first
            case .back:
                cameraOptional = self.backCameras.first
            }
            guard let cameraDevice = cameraOptional else {
                print("No camera found")
                self.setupResult = .configurationFailed
                return
            }

            do {
                let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
                guard self.session.canAddInput(videoInput) else {
                    print("Could not add video device input to the session")
                    self.setupResult = .configurationFailed
                    return
                }
                self.session.addInput(videoInput)
            } catch {
                print("Could not create video device input: \(error)")
                self.setupResult = .configurationFailed
                return
            }
            if self.session.outputs.isEmpty {
                let videoDataOutput = AVCaptureVideoDataOutput()
                if self.session.canAddOutput(videoDataOutput) {
                    self.session.addOutput(videoDataOutput)
                    let format_420v = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                    if videoDataOutput.availableVideoPixelFormatTypes.contains(format_420v) {
                        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(format_420v)]
                    } else {
                        print("Pixel format used (420v) is not supported.")
                        self.setupResult = .configurationFailed
                        return
                    }
                    videoDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
                } else {
                    print("Could not add video data output to the session")
                    self.setupResult = .configurationFailed
                    return
                }
            }
            self.session.commitConfiguration()
        }
        DispatchQueue.main.async {
            self.adjustVideoOrientation()
        }
    }

    private func startSessionAndUpdateUI() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.adjustVideoOrientation()
                    self.sessionSetupResultLabel.isHidden = true
                    self.cameraSwitchButton.state = .normal
                    self.captureButton.state = self.photoAlbumAccess ? .normal : .disabled
                    self.cameraSwitchButton.state = self.frontCameras.count > 0 ? .normal : .disabled
                }
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = "Camera access has been denied, try to rerun and grant the permission."
                    self.sessionSetupResultLabel.isHidden = false
                    self.sessionSetupResultLabel.text = message
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = "Failed to setup your camera. :("
                    self.sessionSetupResultLabel.isHidden = false
                    self.sessionSetupResultLabel.text = message
                }
            }
        }
    }

    private func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.cameraSwitchButton.state = .disabled
                self.captureButton.state = .disabled
            }
        }
    }

    private func adjustVideoOrientation() {
        let interfaceOrientation = self.interfaceOrientation
        sessionQueue.async {
            if let interfaceOrientation = AVCaptureVideoOrientation(interfaceOrientation: interfaceOrientation),
               let videoCaptureConnection = self.session.outputs.first?.connection(with: .video) {
                videoCaptureConnection.videoOrientation = interfaceOrientation
                self.dataOutputQueue.async {
                    self.shouldRecreateDestinationBuffer = true
                }
            }
        }
    }

}

extension IntroductionLiveViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        processPixelBufferToAsciiArt(pixelBuffer: pixelBuffer)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }

    func processPixelBufferToAsciiArt(pixelBuffer: CVPixelBuffer) {
        // Use prevent concurrent access to current effect type
        var currentEffect: AsciiEffects!
        effectTypeAccessQueue.sync {
            currentEffect = self.currentEffectType
        }

        let processor: AsciiEffectsProcessor

        switch currentEffect {
        case .plain:
            processor = PlainEffectProcessor()
        case .hacker:
            processor = HackerEffectProcessor()
        case .glitch:
            processor = GlitchEffectProcessor()
        case .bubbles:
            processor = BubblesEffectProcessor()
        case .cloudy:
            processor = CloudyEffectProcessor()
        default:
            return
        }

        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let lumaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let lumaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)

        var lumaBuffer = vImage_Buffer(data: lumaBaseAddress,
                height: vImagePixelCount(lumaHeight),
                width: vImagePixelCount(lumaWidth),
                rowBytes: lumaRowBytes)

        let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
        let chromaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
        let chromaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        let chromaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)

        var chromaBuffer = vImage_Buffer(data: chromaBaseAddress,
                height: vImagePixelCount(chromaHeight),
                width: vImagePixelCount(chromaWidth * 2),
                rowBytes: chromaRowBytes)

        if destinationBuffer.data == nil || shouldRecreateDestinationBuffer {
            if destinationBuffer.data != nil {
                free(destinationBuffer.data)
            }
            guard vImageBuffer_Init(&destinationBuffer,
                    lumaBuffer.height,
                    lumaBuffer.width,
                    32,
                    vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
                return
            }
            shouldRecreateDestinationBuffer = false
        }

        // First step processing — Apply filters to YCbCr image
        guard processor.processYCbCrBuffer(lumaBuffer: &lumaBuffer, chromaBuffer: &chromaBuffer) == kvImageNoError else {
            return
        }

        guard vImageConvert_420Yp8_CbCr8ToARGB8888(&lumaBuffer,
                &chromaBuffer,
                &destinationBuffer,
                &info420vToARGB!,
                nil,
                255,
                vImage_Flags(kvImagePrintDiagnosticsToConsole)) == kvImageNoError else {
            return
        }

        // Flip the image if it's from the front camera
        if cameraOrientation == .front {
            vImageHorizontalReflect_ARGB8888(&destinationBuffer, &destinationBuffer, vImage_Flags(kvImageNoFlags))
        }
        
        // Second step processing — Apply filters to ARGB images & Draw ASCII arts from buffer
        if let image = processor.processArgbBufferToAsciiArt(buffer: &destinationBuffer) {
            DispatchQueue.main.async {
                self.updateShowcaseImage(image: image)
            }
        }
    }

}
