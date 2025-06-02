//
//  DashboardView.swift
//  CryptoLauncher
//
//  
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject private var vm: MainHomeViewModel
    @State private var showHoldings: Bool = false // animate right
    @State private var showHoldingsSheet: Bool = false // new sheet
    @State private var showSettingsSheet: Bool = false // new sheet
    @State private var selectedAsset: CryptoAsset? = nil
    @State private var showAssetDetail: Bool = false
    
    var body: some View {
        ZStack {
            // background layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showHoldingsSheet, content: {
                    HoldingsView()
                        .environmentObject(vm)
                })
            // content layer
            VStack {
                dashboardHeader
                StatsOverviewView(showHoldings: $showHoldings)
                SearchBarView(searchText: $vm.query)
                columnHeaders
                if !showHoldings {
                    allAssetsList
                        .transition(.move(edge: .leading))
                }
                if showHoldings {
                    ZStack(alignment: .top) {
                        if vm.holdings.isEmpty && vm.query.isEmpty {
                            holdingsEmptyText
                        } else {
                            holdingsList
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
                Spacer(minLength: 0)
            }
            .sheet(isPresented: $showSettingsSheet, content: {
                SettingsView()
            })
        }
        .background(
            NavigationLink(
                destination: AssetDetailLoadingView(asset: $selectedAsset),
                isActive: $showAssetDetail,
                label: { EmptyView() })
        )
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension DashboardView {
    private var dashboardHeader: some View {
        HStack {
            CircleButtonView(iconName: showHoldings ? "plus" : "info")
                .animation(.none)
                .onTapGesture {
                    if showHoldings {
                        showHoldingsSheet.toggle()
                    } else {
                        showSettingsSheet.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showHoldings)
                )
            Spacer()
            Text(showHoldings ? "Holdings" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showHoldings ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showHoldings.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    private var allAssetsList: some View {
        List {
            ForEach(vm.allAssets) { asset in
                AssetRowView(asset: asset, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(asset: asset)
                    }
                    .listRowBackground(Color.theme.background)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var holdingsList: some View {
        List {
            ForEach(vm.holdings) { asset in
                AssetRowView(asset: asset, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(asset: asset)
                    }
                    .listRowBackground(Color.theme.background)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var holdingsEmptyText: some View {
        Text("You haven't added any assets to your holdings yet. Click the + button to get started! 🧐")
            .font(.callout)
            .foregroundColor(Color.theme.accent)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .padding(50)
    }
    
    private func segue(asset: CryptoAsset) {
        selectedAsset = asset
        showAssetDetail.toggle()
    }
    
    private var columnHeaders: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Asset")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortMode == .byRank || vm.sortMode == .byRankDesc) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortMode == .byRank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortMode = vm.sortMode == .byRank ? .byRankDesc : .byRank
                }
            }
            Spacer()
            if showHoldings {
                HStack(spacing: 4) {
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortMode == .byHoldings || vm.sortMode == .byHoldingsDesc) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortMode == .byHoldings ? 0 : 180))
                }
                .onTapGesture {
                    withAnimation(.default) {
                        vm.sortMode = vm.sortMode == .byHoldings ? .byHoldingsDesc : .byHoldings
                    }
                }
            }
            HStack(spacing: 4) {
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortMode == .byPrice || vm.sortMode == .byPriceDesc) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortMode == .byPrice ? 0 : 180))
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortMode = vm.sortMode == .byPrice ? .byPriceDesc : .byPrice
                }
            }
            Button(action: {
                withAnimation(.linear(duration: 2.0)) {
                    vm.refreshData()
                }
            }, label: {
                Image(systemName: "goforward")
            })
            .rotationEffect(Angle(degrees: vm.loading ? 360 : 0), anchor: .center)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}
