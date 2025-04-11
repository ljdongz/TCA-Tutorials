//
//  AppFeature.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 3/31/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
  struct State: Equatable {
    var tab1 = CounterFeature.State()
    var tab2 = CounterFeature.State()
  }
  
  enum Action {
    case tab1(CounterFeature.Action)
    case tab2(CounterFeature.Action)
  }
  
  var body: some ReducerOf<Self> {
    /// [Scope]
    /// 부모 도메인의 하위 도메인(여기서는 tab1, tab2)에 집중하여 자식 리듀서를 실행
    /// 도메인 = Feature 구성 요소 (State, Action, Reducer, Environment)
    Scope(state: \.tab1, action: \.tab1) {
      CounterFeature()
    }
    
    Scope(state: \.tab2, action: \.tab2) {
      CounterFeature()
    }
    
    Reduce { state, action in
      return .none
    }
  }
}

