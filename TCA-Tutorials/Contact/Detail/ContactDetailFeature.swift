//
//  ContactDetailFeature.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/5/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ContactDetailFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    let contact: Contact
  }
  
  enum Action {
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case deleteButtonTapped
    
    /// Alert에서 사용될 액션을 정의
    enum Alert {
      case confirmDeletion
    }
    
    /// 부모가 수신할 수 있는 액션을 정의
    enum Delegate {
      case confirmDeletion
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .alert(.presented(.confirmDeletion)):
        return .run { send in
          await send(.delegate(.confirmDeletion))
          await self.dismiss()
        }
        
      case .alert:
        return .none
        
      case .delegate:
        return .none
        
      case .deleteButtonTapped:
        state.alert = .confirmDeletion
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

extension AlertState where Action == ContactDetailFeature.Action.Alert {
  static let confirmDeletion = Self {
    TextState("Are you sure?")
  } actions: {
    ButtonState(role: .destructive, action: .confirmDeletion) {
      TextState("Delete")
    }
  }
}
