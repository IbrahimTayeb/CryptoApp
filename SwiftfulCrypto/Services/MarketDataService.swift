//
//  GlobalStatsService.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import Combine

class GlobalStatsService {
    
    @Published var globalStats: GlobalMarketStats? = nil
    var statsSubscription: AnyCancellable?
    
    init() {
        fetchStats()
    }
    
    func fetchStats() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else { return }
        
        statsSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalStats.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedStats) in
                self?.globalStats = returnedStats.info
                self?.statsSubscription?.cancel()
            })
    }
}
