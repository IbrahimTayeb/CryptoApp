//
//  HoldingsDataService.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import CoreData

class HoldingsDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    
    @Published var storedEntities: [PortfolioEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
            self.fetchHoldings()
        }
    }
    
    // MARK: PUBLIC
    
    func updateHoldings(asset: CryptoAsset, quantity: Double) {
        // check if asset is already in holdings
        if let entity = storedEntities.first(where: { $0.coinID == asset.id }) {
            if quantity > 0 {
                update(entity: entity, quantity: quantity)
            } else {
                remove(entity: entity)
            }
        } else {
            add(asset: asset, quantity: quantity)
        }
    }
    
    // MARK: PRIVATE
    
    private func fetchHoldings() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            storedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
        }
    }
    
    private func add(asset: CryptoAsset, quantity: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = asset.id
        entity.amount = quantity
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, quantity: Double) {
        entity.amount = quantity
        applyChanges()
    }
    
    private func remove(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }
    
    private func applyChanges() {
        save()
        fetchHoldings()
    }
}
