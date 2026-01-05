import SwiftUI

enum MainTab: Int {
    case citySelection = 0
    case history = 1
}

struct MainTabView: View {
    let citySelectionView: CitySelectionView
    let historyView: HistoryView
    @Binding var selectedTab: MainTab

    var body: some View {
        TabView(selection: $selectedTab) {
            citySelectionView
                .tabItem {
                    Label("추첨", systemImage: "shuffle")
                }
                .tag(MainTab.citySelection)

            historyView
                .tabItem {
                    Label("기록", systemImage: "map.fill")
                }
                .tag(MainTab.history)
        }
    }
}
