//
//  TCA_TutorialsTests.swift
//  TCA-TutorialsTests
//
//  Created by 이정동 on 3/29/25.
//

import ComposableArchitecture
import Testing

@testable import TCA_Tutorials

@MainActor
struct CounterFeatureTests {
    
    @Test
    func basics() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
    
    @Test
    func timer() async throws {
        let clock = TestClock()
        
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        
        // 타이머를 n초 앞으로 미리 진행 시킴
        await clock.advance(by: .seconds(1))
        
        // n초동안 전달 받은 timerTick action 중 첫 번째 action만 처리
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        
//        // 10초 동안 받은 timerTick action들을 테스트
//        for i in 1...10 {
//            await store.receive(\.timerTick) {
//                $0.count = i
//            }
//        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    @Test
    func numberFact() async throws {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { dependencyValues in
            dependencyValues.numberFact.fetch = { number in
                "\(number) is a good number."
            }
        }
        
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        await store.receive(\.factResponse, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
    
}
