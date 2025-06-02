//
//  AssetImageService.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import Foundation
import SwiftUI
import Combine

class AssetImageService {
    
    @Published var image: UIImage? = nil
    
    private var imageSubscription: AnyCancellable?
    private let asset: CryptoAsset
    private let fileManager = LocalFileManager.instance
    private let folderName = "asset_images"
    private let imageName: String
    
    init(asset: CryptoAsset) {
        self.asset = asset
        self.imageName = asset.id
        fetchAssetImage()
    }
    
    private func fetchAssetImage() {
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName) {
            image = savedImage
        } else {
            downloadAssetImage()
        }
    }
    
    private func downloadAssetImage() {
        guard let url = URL(string: asset.iconURL) else { return }
        
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedImage) in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
            })
    }
}
