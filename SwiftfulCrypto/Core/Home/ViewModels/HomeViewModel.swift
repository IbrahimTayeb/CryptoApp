//
//  MainHomeViewModel.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import Combine

class MainHomeViewModel: ObservableObject {
    
    @Published var stats: [InfoStat] = []
    @Published var allAssets: [CryptoAsset] = []
    @Published var holdings: [CryptoAsset] = []
    @Published var loading: Bool = false
    @Published var query: String = ""
    @Published var sortMode: SortMode = .byHoldings
    
    private let assetListService = AssetListService()
    private let globalStatsService = GlobalStatsService()
    private let holdingsService = HoldingsDataService()
    private var subscriptions = Set<AnyCancellable>()
    
    enum SortMode {
        case byRank, byRankDesc, byHoldings, byHoldingsDesc, byPrice, byPriceDesc
    }
    
    init() {
        setupSubscribers()
    }
    
    func setupSubscribers() {
        // updates allAssets
        $query
            .combineLatest(assetListService.$allAssets, $sortMode)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortAssets)
            .sink { [weak self] (assets) in
                self?.allAssets = assets
            }
            .store(in: &subscriptions)
        
        // updates holdings
        $allAssets
            .combineLatest(holdingsService.$storedEntities)
            .map(mapAllAssetsToHoldings)
            .sink { [weak self] (assets) in
                guard let self = self else { return }
                self.holdings = self.sortHoldingsIfNeeded(assets: assets)
            }
            .store(in: &subscriptions)
        
        // updates global stats
        globalStatsService.$globalStats
            .combineLatest($holdings)
            .map(mapGlobalStats)
            .sink { [weak self] (returnedStats) in
                self?.stats = returnedStats
                self?.loading = false
            }
            .store(in: &subscriptions)
    }
    
    func updateHoldings(asset: CryptoAsset, quantity: Double) {
        holdingsService.updateHoldings(asset: asset, quantity: quantity)
    }
    
    func refreshData() {
        loading = true
        assetListService.fetchAssets()
        globalStatsService.fetchStats()
        HapticManager.notification(type: .success)
    }
    
    private func filterAndSortAssets(text: String, assets: [CryptoAsset], sort: SortMode) -> [CryptoAsset] {
        var filtered = filterAssets(text: text, assets: assets)
        sortAssets(sort: sort, assets: &filtered)
        return filtered
    }
    
    private func filterAssets(text: String, assets: [CryptoAsset]) -> [CryptoAsset] {
        guard !text.isEmpty else {
            return assets
        }
        let lowercased = text.lowercased()
        return assets.filter { asset in
            asset.fullName.lowercased().contains(lowercased) ||
            asset.ticker.lowercased().contains(lowercased) ||
            asset.id.lowercased().contains(lowercased)
        }
    }
    
    private func sortAssets(sort: SortMode, assets: inout [CryptoAsset]) {
        switch sort {
        case .byRank, .byHoldings:
            assets.sort(by: { $0.assetRank < $1.assetRank })
        case .byRankDesc, .byHoldingsDesc:
            assets.sort(by: { $0.assetRank > $1.assetRank })
        case .byPrice:
            assets.sort(by: { $0.priceUSD > $1.priceUSD })
        case .byPriceDesc:
            assets.sort(by: { $0.priceUSD < $1.priceUSD })
        }
    }
    
    private func sortHoldingsIfNeeded(assets: [CryptoAsset]) -> [CryptoAsset] {
        switch sortMode {
        case .byHoldings:
            return assets.sorted(by: { $0.ownedValue > $1.ownedValue })
        case .byHoldingsDesc:
            return assets.sorted(by: { $0.ownedValue < $1.ownedValue })
        default:
            return assets
        }
    }
    
    private func mapAllAssetsToHoldings(allAssets: [CryptoAsset], storedEntities: [PortfolioEntity]) -> [CryptoAsset] {
        allAssets.compactMap { asset in
            guard let entity = storedEntities.first(where: { $0.coinID == asset.id }) else {
                return nil
            }
            return asset.withUpdatedHoldings(entity.amount)
        }
    }
    
    private func mapGlobalStats(globalStats: GlobalMarketStats?, holdings: [CryptoAsset]) -> [InfoStat] {
        var stats: [InfoStat] = []
        guard let data = globalStats else {
            return stats
        }
        let marketCap = InfoStat(label: "Market Cap", data: data.formattedMarketCap, percentDelta: data.capChangePercent24hUSD)
        let volume = InfoStat(label: "24h Volume", data: data.formattedVolume)
        let btcDominance = InfoStat(label: "BTC Dominance", data: data.bitcoinDominance)
        let holdingsValue = holdings.map({ $0.ownedValue }).reduce(0, +)
        let previousValue = holdings.map { asset -> Double in
            let currentValue = asset.ownedValue
            let percentChange = asset.changePercentDay ?? 0 / 100
            let prevValue = currentValue / (1 + percentChange)
            return prevValue
        }.reduce(0, +)
        let percentDelta = ((holdingsValue - previousValue) / previousValue)
        let portfolio = InfoStat(
            label: "Portfolio Value",
            data: holdingsValue.asCurrencyWith2Decimals(),
            percentDelta: percentDelta)
        stats.append(contentsOf: [marketCap, volume, btcDominance, portfolio])
        return stats
    }
}
