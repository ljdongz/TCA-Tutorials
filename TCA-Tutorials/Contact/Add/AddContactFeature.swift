//
//  AddContactFeature.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AddContactFeature {
  @ObservableState
  struct State: Equatable {
    var contact: Contact
  }
  
  enum Action {
    case cancelButtonTapped
    case delegate(Delegate)
    case saveButtonTapped
    case setName(String)
    
    @CasePathable
    // 부모가 수신할 수 있는 액션을 정의
    enum Delegate: Equatable {
      case saveContact(Contact)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .cancelButtonTapped:
        return .run { _ in
          await self.dismiss()
        }
        
      case .delegate:
        return .none
        
      case .saveButtonTapped:
        return .run { [contact = state.contact] send in
          await send(.delegate(.saveContact(contact)))
          await self.dismiss()
        }
        
      case let .setName(name):
        state.contact.name = name
        return .none
      }
    }
  }
}
