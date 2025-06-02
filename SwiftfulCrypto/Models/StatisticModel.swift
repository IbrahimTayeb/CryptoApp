//
//  InfoStat.swift
//  CryptoLauncher
//
//  
//

import Foundation

struct InfoStat: Identifiable {
    let id = UUID().uuidString
    let label: String
    let data: String
    let percentDelta: Double?
    
    init(label: String, data: String, percentDelta: Double? = nil) {
        self.label = label
        self.data = data
        self.percentDelta = percentDelta
    }
}
