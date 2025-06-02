//
//  AssetDetailViewModel.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import Combine

class AssetDetailViewModel: ObservableObject {
    
    @Published var overviewStats: [InfoStat] = []
    @Published var extraStats: [InfoStat] = []
    @Published var assetDescription: String? = nil
    @Published var homepageURL: String? = nil
    @Published var redditLink: String? = nil

    @Published var asset: CryptoAsset
    private let assetDetailService: AssetDetailService
    private var subscriptions = Set<AnyCancellable>()
    
    init(asset: CryptoAsset) {
        self.asset = asset
        self.assetDetailService = AssetDetailService(asset: asset)
        self.setupSubscribers()
    }
    
    private func setupSubscribers() {
        assetDetailService.$assetDetails
            .combineLatest($asset)
            .map(mapDataToStats)
            .sink { [weak self] (result) in
                self?.overviewStats = result.overview
                self?.extraStats = result.extra
            }
            .store(in: &subscriptions)
        
        assetDetailService.$assetDetails
            .sink { [weak self] (details) in
                self?.assetDescription = details?.plainDescription
                self?.homepageURL = details?.assetLinks?.homepage?.first
                self?.redditLink = details?.assetLinks?.subreddit
            }
            .store(in: &subscriptions)
    }
    
    private func mapDataToStats(assetDetail: AssetDetailInfo?, asset: CryptoAsset) -> (overview: [InfoStat], extra: [InfoStat]) {
        let overviewArray = createOverviewArray(asset: asset)
        let extraArray = createExtraArray(assetDetail: assetDetail, asset: asset)
        return (overviewArray, extraArray)
    }
    
    private func createOverviewArray(asset: CryptoAsset) -> [InfoStat] {
        let price = asset.priceUSD.asCurrencyWith6Decimals()
        let pricePercentChange = asset.changePercentDay
        let priceStat = InfoStat(label: "Current Price", data: price, percentDelta: pricePercentChange)
        let cap = "$" + (asset.cap?.formattedWithAbbreviations() ?? "")
        let capPercentChange = asset.capChangePercentDay
        let capStat = InfoStat(label: "Market Capitalization", data: cap, percentDelta: capPercentChange)
        let rank = "\(asset.assetRank)"
        let rankStat = InfoStat(label: "Rank", data: rank)
        let volume = "$" + (asset.volume?.formattedWithAbbreviations() ?? "")
        let volumeStat = InfoStat(label: "Volume", data: volume)
        let overviewArray: [InfoStat] = [priceStat, capStat, rankStat, volumeStat]
        return overviewArray
    }
    
    private func createExtraArray(assetDetail: AssetDetailInfo?, asset: CryptoAsset) -> [InfoStat] {
        let high = asset.highDay?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = InfoStat(label: "24h High", data: high)
        let low = asset.lowDay?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = InfoStat(label: "24h Low", data: low)
        let priceChange = asset.changeDay?.asCurrencyWith6Decimals() ?? "n/a"
        let pricePercentChange = asset.changePercentDay
        let priceChangeStat = InfoStat(label: "24h Price Change", data: priceChange, percentDelta: pricePercentChange)
        let capChange = "$" + (asset.capChangeDay?.formattedWithAbbreviations() ?? "")
        let capPercentChange = asset.capChangePercentDay
        let capChangeStat = InfoStat(label: "24h Market Cap Change", data: capChange, percentDelta: capPercentChange)
        let blockTime = assetDetail?.blockIntervalMins ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = InfoStat(label: "Block Time", data: blockTimeString)
        let hashing = assetDetail?.hashAlgo ?? "n/a"
        let hashingStat = InfoStat(label: "Hashing Algorithm", data: hashing)
        let extraArray: [InfoStat] = [highStat, lowStat, priceChangeStat, capChangeStat, blockStat, hashingStat]
        return extraArray
    }
}
