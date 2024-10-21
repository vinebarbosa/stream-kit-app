//
//  WebSocketManager.swift
//  Stream Kit
//
//  Created by Vinícios Barbosa on 21/10/24.
//

import Foundation

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private var onDataReceived: (([Pad]) -> Void)?
    private var url: String
    
    init(url: String, onDataReceived: ( ([Pad]) -> Void)? = nil) {
        self.onDataReceived = onDataReceived
        self.url = url
    }
    
    func connect() {
        let url = URL(string: url)!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Desconectado do socket")
    }

    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            return
        }
    }

    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleReceivedData(text)
                case .data(_):
                    break
                @unknown default:
                    fatalError()
                }
            case .failure(_):
                return
            }
            self?.receiveMessage()
        }
    }

    private func handleReceivedData(_ text: String) {
        let newPads = parsePads(from: text)
        onDataReceived?(newPads)
    }

    private func parsePads(from text: String) -> [Pad] {
        guard let data = text.data(using: .utf8) else {
            return []
        }

        do {
            let pads = try JSONDecoder().decode([Pad].self, from: data)
            return pads
        } catch {
            return []
        }
    }

}
