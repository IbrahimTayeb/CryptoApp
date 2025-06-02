//
//  AssetDetailService.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import Combine

class AssetDetailService {
    
    @Published var assetDetails: AssetDetailInfo? = nil
    
    var assetDetailSubscription: AnyCancellable?
    let asset: CryptoAsset
    
    init(asset: CryptoAsset) {
        self.asset = asset
        fetchAssetDetails()
    }
    
    func fetchAssetDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(asset.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else { return }

        assetDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: AssetDetailInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedAssetDetails) in
                self?.assetDetails = returnedAssetDetails
                self?.assetDetailSubscription?.cancel()
            })
    }
}
