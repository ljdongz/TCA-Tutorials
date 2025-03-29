//
//  TCA_TutorialsApp.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 1/12/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_TutorialsApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: TCA_TutorialsApp.store)
        }
    }
}
