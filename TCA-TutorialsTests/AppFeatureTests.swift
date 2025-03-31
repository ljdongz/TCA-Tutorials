//
//  AppFeatureTests.swift
//  TCA-TutorialsTests
//
//  Created by 이정동 on 3/31/25.
//

import Testing
import ComposableArchitecture

@testable import TCA_Tutorials

struct AppFeatureTests {

    @Test
    func incrementInFirstTab() async throws {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
    }

}
