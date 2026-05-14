//
//  NetworkManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import Foundation

protocol INetworkManager {
    @discardableResult
    func sendRequest<T: IEndpoint>(
        endpoint: T,
        body: Data?,
        authorization: NetworkManager.Authorization?
    ) async throws(NetworkError) -> Data?
    
    func connectWebsocket(url: URL?)
    func sendWithWebsocket(data: Data?)
}

final class NetworkManager: NSObject, INetworkManager {
    
    private var websocketTask: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private var isConnecting = false
    private var url: URL?
    private var session: URLSession?
    
    func connectWebsocket(url: URL?) {
        guard let url = url else { return }
        self.url = url
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        isConnecting = true
        self.websocketTask = session?.webSocketTask(with: url)
        self.websocketTask?.resume()
        startPinging()
    }
    
    func sendWithWebsocket(data: Data?) {
        guard let data = data, let jsonData = String(data: data, encoding: .utf8) else { return }
        
        print(jsonData)
        
        let message = URLSessionWebSocketTask.Message.string(jsonData)
        websocketTask?.send(message) { error in
            if let error = error {
                print("ERROR SENDING" + error.localizedDescription)
                print("DOWN DOWN DOWN")
            } else {
                print("send succeed")
            }
        }
    }
    
    private func stopPinging() {
        self.pingTimer?.invalidate()
        self.pingTimer = nil
    }
    
    private func startPinging() {
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        let message = URLSessionWebSocketTask.Message.string("{\"action\": \"ping\"}")
        self.websocketTask?.send(message) { error in
            if let error = error {
                print("ERROR PING" + error.localizedDescription)
                print("DOWN DOWN DOWN")

                self.stopPinging()

            } else {
                print("ping succeed")
            }
        }
        self.websocketTask?.receive { result in
            switch result {
            case .success(let success):
                print("----------\(success)")
            case .failure(let failure):
                print("+++++++++\(failure.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func sendRequest<T: IEndpoint>(endpoint: T, body: Data?, authorization: Authorization?) async throws(NetworkError) -> Data? {
        guard let url = endpoint.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.toString
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let auth = authorization {
            request.addValue(auth.httpHeader, forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.unknown(message: "No response") }
            
            guard (200...300).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        }
        catch let error {
            print(error.localizedDescription)
            throw .networkError(error)
        }
    }
}

extension NetworkManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("DOWN DOWN DOWN")

        stopPinging()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.connectWebsocket(url: self?.url)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("CONNECTED")
        self.isConnecting = false
    }
}

extension NetworkManager {
    enum Authorization {
        case bearer(token: String)
        
        var httpHeader: String {
            self.title + " " + self.token
        }
        
        private var title: String {
            switch self {
            case .bearer:
                "Bearer"
            }
        }
        
        private var token: String {
            switch self {
            case .bearer(let token):
                token
            }
        }
    }
}
