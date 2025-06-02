//
//  AssetListService.swift
//  CryptoLauncher
//
//  
//

import Foundation
import Combine

class AssetListService {
    
    @Published var allAssets: [CryptoAsset] = []
    
    var assetSubscription: AnyCancellable?
    
    init() {
        fetchAssets()
    }
    
    func fetchAssets() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else { return }

        assetSubscription = NetworkingManager.download(url: url)
            .decode(type: [CryptoAsset].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedAssets) in
                self?.allAssets = returnedAssets
                self?.assetSubscription?.cancel()
            })
    }
}
