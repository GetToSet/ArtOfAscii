//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/13.
//

import Foundation
import PlaygroundSupport

import BookCore

public class EventListener: PlaygroundRemoteLiveViewProxyDelegate {

    public typealias EventHandler = (EventMessage) -> Void

    private let eventHandler: EventHandler

    public init(proxy: PlaygroundRemoteLiveViewProxy?, eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
        proxy?.delegate = self
    }

    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        if let message = EventMessage.from(playgroundValue: message) {
            eventHandler(message)
        }
    }

    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {

    }

}
