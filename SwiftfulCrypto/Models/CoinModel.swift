//
//  CryptoAssetModel.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation

// CoinGecko API info
/*
 URL: https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h
 
 JSON Response:
 {
     "id": "bitcoin",
     "symbol": "btc",
     "name": "Bitcoin",
     "image": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
     "current_price": 58908,
     "market_cap": 1100013258170,
     "market_cap_rank": 1,
     "fully_diluted_valuation": 1235028318246,
     "total_volume": 69075964521,
     "high_24h": 59504,
     "low_24h": 57672,
     "price_change_24h": 808.94,
     "price_change_percentage_24h": 1.39234,
     "market_cap_change_24h": 13240944103,
     "market_cap_change_percentage_24h": 1.21837,
     "circulating_supply": 18704250,
     "total_supply": 21000000,
     "max_supply": 21000000,
     "ath": 64805,
     "ath_change_percentage": -9.24909,
     "ath_date": "2021-04-14T11:54:46.763Z",
     "atl": 67.81,
     "atl_change_percentage": 86630.1867,
     "atl_date": "2013-07-06T00:00:00.000Z",
     "roi": null,
     "last_updated": "2021-05-09T04:06:09.766Z",
     "sparkline_in_7d": {
       "price": [
         57812.96915967891,
         57504.33531773738,
       ]
     },
     "price_change_percentage_24h_in_currency": 1.3923423473152687
   }
 
 */

struct CryptoAsset: Identifiable, Codable {
    let id, ticker, fullName: String
    let iconURL: String
    let priceUSD: Double
    let cap, capRank, dilutedValuation: Double?
    let volume, highDay, lowDay: Double?
    let changeDay: Double?
    let changePercentDay: Double?
    let capChangeDay: Double?
    let capChangePercentDay: Double?
    let supplyCirculating, supplyTotal, supplyMax, allTimeHigh: Double?
    let athChangePercent: Double?
    let athTimestamp: String?
    let allTimeLow, atlChangePercent: Double?
    let atlTimestamp: String?
    let lastRefreshed: String?
    let weekSparkline: SevenDaySparkline?
    let changePercentDayCurrency: Double?
    let ownedAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ticker = "symbol"
        case fullName = "name"
        case iconURL = "image"
        case priceUSD = "current_price"
        case cap = "market_cap"
        case capRank = "market_cap_rank"
        case dilutedValuation = "fully_diluted_valuation"
        case volume = "total_volume"
        case highDay = "high_24h"
        case lowDay = "low_24h"
        case changeDay = "price_change_24h"
        case changePercentDay = "price_change_percentage_24h"
        case capChangeDay = "market_cap_change_24h"
        case capChangePercentDay = "market_cap_change_percentage_24h"
        case supplyCirculating = "circulating_supply"
        case supplyTotal = "total_supply"
        case supplyMax = "max_supply"
        case allTimeHigh = "ath"
        case athChangePercent = "ath_change_percentage"
        case athTimestamp = "ath_date"
        case allTimeLow = "atl"
        case atlChangePercent = "atl_change_percentage"
        case atlTimestamp = "atl_date"
        case lastRefreshed = "last_updated"
        case weekSparkline = "sparkline_in_7d"
        case changePercentDayCurrency = "price_change_percentage_24h_in_currency"
        case ownedAmount = "currentHoldings"
    }
    
    func withUpdatedHoldings(_ amount: Double) -> CryptoAsset {
        return CryptoAsset(id: id, ticker: ticker, fullName: fullName, iconURL: iconURL, priceUSD: priceUSD, cap: cap, capRank: capRank, dilutedValuation: dilutedValuation, volume: volume, highDay: highDay, lowDay: lowDay, changeDay: changeDay, changePercentDay: changePercentDay, capChangeDay: capChangeDay, capChangePercentDay: capChangePercentDay, supplyCirculating: supplyCirculating, supplyTotal: supplyTotal, supplyMax: supplyMax, allTimeHigh: allTimeHigh, athChangePercent: athChangePercent, athTimestamp: athTimestamp, allTimeLow: allTimeLow, atlChangePercent: atlChangePercent, atlTimestamp: atlTimestamp, lastRefreshed: lastRefreshed, weekSparkline: weekSparkline, changePercentDayCurrency: changePercentDayCurrency, ownedAmount: amount)
    }
    
    var ownedValue: Double {
        return (ownedAmount ?? 0) * priceUSD
    }
    
    var assetRank: Int {
        return Int(capRank ?? 0)
    }
}

struct SevenDaySparkline: Codable {
    let price: [Double]?
}
