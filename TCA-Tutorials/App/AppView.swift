//
//  AppView.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
  /// 두 개의 Store가 완전히 격리되어 있음
  /// 즉, 한 탭에서 발생하는 이벤트를 다른 탭에 영향을 줄 수 없음 (탭 간의 상호작용 불가)
  //  let store1: StoreOf<CounterFeature>
  //  let store2: StoreOf<CounterFeature>
  
  /// Feature 간의 통신을 쉽게 해줌
  let store: StoreOf<AppFeature>
  
  var body: some View {
    TabView {
      /// 자식 뷰에 전달할 새로운 스토어를 생성하여 전달
      /// 부모 도메인(AppFeature)에서 tab1에 해당하는 도메인에만 집중
      CounterView(
        store: store.scope(
          state: \.tab1,
          action: \.tab1
        )
      )
      .tabItem {
        Text("Counter 1")
      }
      
      CounterView(
        store: store.scope(
          state: \.tab2,
          action: \.tab2
        )
      )
      .tabItem {
        Text("Counter 2")
      }
    }
  }
}

#Preview {
  AppView(store: Store(initialState: AppFeature.State(), reducer: {
    AppFeature()
  }))
}
