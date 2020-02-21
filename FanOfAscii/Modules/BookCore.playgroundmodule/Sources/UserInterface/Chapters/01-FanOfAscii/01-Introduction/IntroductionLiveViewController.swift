//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import AVFoundation
import Accelerate

class IntroductionLiveViewController: BaseViewController {

    @IBOutlet private weak var sessionSetupResultLabel: UILabel!

    private enum CameraOrientation {
        case front, back
    }

    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    private var setupResult: SessionSetupResult = .success

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "SessionQueue", attributes: [], autoreleaseFrequency: .workItem)

    private let dataOutputQueue = DispatchQueue(label: "VideoDataQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    private let backCameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.back).devices
    private let frontCameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.front).devices

    private var cameraOrientation: CameraOrientation = .back

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

    private var cgImageFormat = vImage_CGImageFormat(bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: nil,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue),
            version: 0,
            decode: nil,
            renderingIntent: .defaultIntent)

    private var shouldRecreateDestinationBuffer = true

    deinit {
        if destinationBuffer.data != nil {
            free(destinationBuffer.data)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sessionSetupResultLabel.isHidden = true

        requestAuthorization()
        sessionQueue.async {
            self.reconfigureSession()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }

        super.viewWillDisappear(animated)
    }

    private func requestAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            }
        default:
            setupResult = .notAuthorized
        }
    }

    private func reconfigureSession() {
        guard setupResult == .success else {
            return
        }

        session.beginConfiguration()
        defer  {
            if setupResult != .success {
                session.commitConfiguration()
            }
        }

        session.inputs.forEach { input in
            session.removeInput(input)
        }

        session.sessionPreset = AVCaptureSession.Preset.photo

        let cameraOptional: AVCaptureDevice?
        switch cameraOrientation {
        case .front:
            cameraOptional = frontCameras.first
        case .back:
            cameraOptional = backCameras.first
        }
        guard let cameraDevice = cameraOptional else {
            print("No camera found")
            setupResult = .configurationFailed
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
            guard session.canAddInput(videoInput) else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                return
            }
            session.addInput(videoInput)
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }

        if session.outputs.isEmpty {
            let videoDataOutput = AVCaptureVideoDataOutput()
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
                let format_420v = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                if videoDataOutput.availableVideoPixelFormatTypes.contains(format_420v) {
                    videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(format_420v)]
                } else {
                    print("Pixel format used (420v) is not supported.")
                    setupResult = .configurationFailed
                    return
                }
                videoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            } else {
                print("Could not add video data output to the session")
                setupResult = .configurationFailed
                return
            }
        }

        session.commitConfiguration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.adjustVideoOrientation()

                self.session.startRunning()

                DispatchQueue.main.async {
                    self.sessionSetupResultLabel.isHidden = true
                }
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = "AVCamFilter doesn't have permission to use the camera, please change privacy settings"
                    self.sessionSetupResultLabel.isHidden = false
                    self.sessionSetupResultLabel.text = message
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = "Unable to capture media"
                    self.sessionSetupResultLabel.isHidden = false
                    self.sessionSetupResultLabel.text = message
                }
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.adjustVideoOrientation()
        }
    }

    func adjustVideoOrientation() {
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

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {

    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {

    }

}

extension IntroductionLiveViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        processYpCbCrToRGB(pixelBuffer: pixelBuffer)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }

    func processYpCbCrToRGB(pixelBuffer: CVPixelBuffer) {
        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let lumaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let lumaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)

        var sourceLumaBuffer = vImage_Buffer(data: lumaBaseAddress,
                height: vImagePixelCount(lumaHeight),
                width: vImagePixelCount(lumaWidth),
                rowBytes: lumaRowBytes)

        let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
        let chromaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
        let chromaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        let chromaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)

        var sourceChromaBuffer = vImage_Buffer(data: chromaBaseAddress,
                height: vImagePixelCount(chromaHeight),
                width: vImagePixelCount(chromaWidth * 2),
                rowBytes: chromaRowBytes)

        if destinationBuffer.data == nil || shouldRecreateDestinationBuffer {
            if destinationBuffer.data != nil {
                free(destinationBuffer.data)
            }
            guard vImageBuffer_Init(&destinationBuffer,
                    sourceLumaBuffer.height,
                    sourceLumaBuffer.width,
                    cgImageFormat.bitsPerPixel,
                    vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
                return
            }
            shouldRecreateDestinationBuffer = false
        }

        guard vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer,
                &sourceChromaBuffer,
                &destinationBuffer,
                &info420vToARGB!,
                nil,
                255,
                vImage_Flags(kvImagePrintDiagnosticsToConsole)) == kvImageNoError else {
            return
        }

        var error = kvImageNoError

        let cgImage = vImageCreateCGImageFromBuffer(&destinationBuffer,
                &cgImageFormat,
                nil,
                nil,
                vImage_Flags(kvImageNoFlags),
                &error)

        if let cgImage = cgImage, error == kvImageNoError {
            DispatchQueue.main.async {
                self.updateShowcaseImage(image: UIImage(cgImage: cgImage.takeRetainedValue()))
            }
        }
    }

}

extension AVCaptureVideoOrientation {

    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            return nil
        }
    }

}
