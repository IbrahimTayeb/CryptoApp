//
//  CryptoLauncherApp.swift
//  CryptoLauncher
//
//  Adapted by AI Assistant
//

import SwiftUI

@main
struct CryptoLauncherApp: App {
    
    @StateObject private var homeVM = MainHomeViewModel()
    @State private var isLaunchScreenVisible: Bool = true
    
    init() {
        let accentColor = UIColor(Color.theme.accent)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : accentColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : accentColor]
        UINavigationBar.appearance().tintColor = accentColor
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    HomeView()
                        .navigationBarHidden(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(homeVM)
                
                if isLaunchScreenVisible {
                    ZStack {
                        LaunchView(showLaunchView: $isLaunchScreenVisible)
                            .transition(.move(edge: .leading))
                    }
                    .zIndex(2.0)
                }
            }
        }
    }
}
