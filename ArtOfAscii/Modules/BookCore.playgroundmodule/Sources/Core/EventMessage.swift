//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/13.
//

import UIKit
import PlaygroundSupport

private enum EventPayloadType: String {

    case rgbFilterRequest
    case grayscaleFilterRequest
    case equalizationRequest
    case shrinkingRequest
    case asciificationRequest
    case imageProcessingResponse

}

private protocol EventPayload {

    var payloadType: EventPayloadType { get }

}

private struct RGBFilterRequest: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return .rgbFilterRequest
    }

    let redEnabled: Bool
    let greenEnabled: Bool
    let blueEnabled: Bool

}

public enum EventMessage {

    case rgbFilterRequest(redEnabled: Bool, greenEnabled: Bool, blueEnabled: Bool, image: UIImage?)
    case grayscaleFilterRequest(image: UIImage?)
    case equalizationRequest(image: UIImage?)
    case shrinkingRequest(image: UIImage?)
    case asciificationRequest(image: UIImage?)
    case imageProcessingResponse(image: UIImage?)

    public static func from(playgroundValue: PlaygroundValue) -> EventMessage? {
        guard case .dictionary(let dict) = playgroundValue else {
            return nil
        }
        return decodeFromDictionary(dict)
    }

    public var playgroundValue: PlaygroundValue {
        return PlaygroundValue.dictionary(encodeToDictionary())
    }

    private func encodeToDictionary() -> [String: PlaygroundValue] {
        let encoder = JSONEncoder()

        var jsonData: Data?
        var imageData: Data?
        var payloadToEncode: EventPayload?
        var payloadType: EventPayloadType?

        switch self {
        case .rgbFilterRequest(let red, let green, let blue, let image):
            payloadToEncode = RGBFilterRequest(redEnabled: red, greenEnabled: green, blueEnabled: blue)
            jsonData = try? encoder.encode(payloadToEncode as! RGBFilterRequest)
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .grayscaleFilterRequest(let image):
            payloadType = .grayscaleFilterRequest
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .equalizationRequest(let image):
            payloadType = .equalizationRequest
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .shrinkingRequest(let image):
            payloadType = .shrinkingRequest
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .asciificationRequest(let image):
            payloadType = .asciificationRequest
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .imageProcessingResponse(let image):
            payloadType = .imageProcessingResponse
            imageData = image?.jpegData(compressionQuality: 1.0)
        }
        payloadType = payloadType ?? payloadToEncode!.payloadType
        var dict = [
            "type": PlaygroundValue.string(payloadType!.rawValue)
        ]
        if let jsonData = jsonData {
            dict["data"] = PlaygroundValue.data(jsonData)
        }
        if let imageData = imageData {
            dict["image"] = PlaygroundValue.data(imageData)
        }
        return dict
    }

    private static func decodeFromDictionary(_ dictionary: [String: PlaygroundValue]) -> Self? {
        guard case .string(let typeStr) = dictionary["type"],
              let type = EventPayloadType(rawValue: typeStr) else {
            return nil
        }

        let decoder = JSONDecoder()

        var image: UIImage?

        if case .data(let imageData) = dictionary["image"] {
            image = UIImage(data: imageData)
        }
        switch type {
        case .rgbFilterRequest:
            guard case .data(let data) = dictionary["data"],
                  let rgbFilterRequest = try? decoder.decode(RGBFilterRequest.self, from: data) else {
                return nil
            }
            return Self.rgbFilterRequest(
                    redEnabled: rgbFilterRequest.redEnabled,
                    greenEnabled: rgbFilterRequest.greenEnabled,
                    blueEnabled: rgbFilterRequest.blueEnabled,
                    image: image
            )
        case .grayscaleFilterRequest:
            return Self.grayscaleFilterRequest(image: image)
        case .equalizationRequest:
            return Self.equalizationRequest(image: image)
        case .shrinkingRequest:
            return Self.shrinkingRequest(image: image)
        case .asciificationRequest:
            return Self.asciificationRequest(image: image)
        case .imageProcessingResponse:
            return Self.imageProcessingResponse(image: image)
        }
    }

}
