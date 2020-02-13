//
// Created by Bunny Wong on 2020/2/13.
//

import Foundation
import PlaygroundSupport

private enum EventPayloadType: String {

    case rgbFilterRequest
    case grayScaleRequest

}

private protocol EventPayload {

    var payloadType: EventPayloadType { get }

}

private struct RGBFilterRequest: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return EventPayloadType.rgbFilterRequest
    }

    let redEnabled: Bool
    let greenEnabled: Bool
    let blueEnabled: Bool

}

private struct GrayScaleFilterRequest: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return EventPayloadType.grayScaleRequest
    }

    let enabled: Bool

}

public enum EventMessage {

    case rgbFilterRequest(redEnabled: Bool, greenEnabled: Bool, blueEnabled: Bool)
    case grayScaleRequest(enabled: Bool)

    public static func from(playgroundValue: PlaygroundValue) -> EventMessage? {
        guard case .dictionary(let dict) = playgroundValue else {
            return nil
        }
        return decodeFromDictionary(dict)
    }

    public var playgroundValue: PlaygroundValue {
        get {
            return PlaygroundValue.dictionary(encodeToDictionary())
        }
    }

    func encodeToDictionary() -> Dictionary<String, PlaygroundValue> {
        let encoder = JSONEncoder()

        var jsonData: Data?
        let payloadToEncode: EventPayload

        switch self {
        case .rgbFilterRequest(let red, let green, let blue):
            payloadToEncode = RGBFilterRequest(redEnabled: red, greenEnabled: green, blueEnabled: blue)
            jsonData = try? encoder.encode(payloadToEncode as! RGBFilterRequest)
        case .grayScaleRequest(let enabled):
            payloadToEncode = GrayScaleFilterRequest(enabled: enabled)
            jsonData = try? encoder.encode(payloadToEncode as! GrayScaleFilterRequest)
        }
        var dict = [
            "type": PlaygroundValue.string(payloadToEncode.payloadType.rawValue),
        ]
        if let jsonData = jsonData {
            dict["data"] = PlaygroundValue.data(jsonData)
        }
        return dict
    }

    static func decodeFromDictionary(_ dictionary: Dictionary<String, PlaygroundValue>) -> Self? {
        guard case .string(let typeStr) = dictionary["type"],
              let type = EventPayloadType(rawValue: typeStr),
              case .data(let data) = dictionary["data"] else {
            return nil
        }

        let decoder = JSONDecoder()

        switch type {
        case .rgbFilterRequest:
            guard let rgbFilterRequest = try? decoder.decode(RGBFilterRequest.self, from: data) else {
                return nil
            }
            return Self.rgbFilterRequest(redEnabled: rgbFilterRequest.redEnabled,
                                         greenEnabled: rgbFilterRequest.greenEnabled,
                                         blueEnabled: rgbFilterRequest.blueEnabled
            )
        case .grayScaleRequest:
            guard let grayscaleFilterRequest = try? decoder.decode(GrayScaleFilterRequest.self, from: data) else {
                return nil
            }
            return Self.grayScaleRequest(enabled: grayscaleFilterRequest.enabled)
        }
    }

}
