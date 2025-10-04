//
//  MockNetworkManagerSwift.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 04/10/2025.
//

// MARK: - Mock NetworkManager
final actor MockNetworkManager: NetworkManagerProtocol {
    private var shouldThrowError = false
    private var mockError: Error?
    private var mockData: Decodable?
    
    func setMockData(_ data: Decodable) {
        self.mockData = data
        self.shouldThrowError = false
        self.mockError = nil
    }
    
    func setError(_ error: Error) {
        self.shouldThrowError = true
        self.mockError = error
        self.mockData = nil
    }
    
    func reset() {
        self.shouldThrowError = false
        self.mockError = nil
        self.mockData = nil
    }
    
    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        if shouldThrowError {
            throw mockError ?? NetworkError.unknown
        }
        
        guard let data = mockData as? T else {
            throw NetworkError.decodingError
        }
        
        return data
    }
}
