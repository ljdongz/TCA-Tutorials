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
    
    /// 부모가 들을 수 있고 해석할 수 있는 모든 action
    case delegate(Delegate)
    case saveButtonTapped
    case setName(String)
    
    @CasePathable
    /// 부모가 수신할 수 있는 action을 정의
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
        
      /// 부모만이 위임된 action을 수신하고 응답할 수 있도록 어떤 로직도 실행하지 않음
      case .delegate:
        return .none
        
      case .saveButtonTapped:
        return .run { [contact = state.contact] send in
          await send(.delegate(.saveContact(contact)))
          
          /// dismiss()가 호출되면 부모 Feature의 PresentationState가 자동으로 nil로 설정됨
          await self.dismiss()
        }
        
      case let .setName(name):
        state.contact.name = name
        return .none
      }
    }
  }
}
