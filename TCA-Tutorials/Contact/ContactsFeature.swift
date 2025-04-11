//
//  ContactsFeature.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/4/25.
//

import Foundation
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
  let id: UUID
  var name: String
}

@Reducer
struct ContactsFeature {
  @ObservableState
  struct State: Equatable {
    var contacts: IdentifiedArrayOf<Contact> = []
    
    /// [@presents]
    /// 내비게이션을 유도하기 위한 상태
    // @Presents var addContact: AddContactFeature.State?
    // @Presents var alert: AlertState<Action.Alert>?
    @Presents var destination: Destination.State?
    
    var path = StackState<ContactDetailFeature.State>()
  }
  
  enum Action {
    case addButtonTapped
    case deleteButtonTapped(id: Contact.ID)
    
    /// [PresentationAction]
    /// 자식 Feature에서 전송된 모든 Action을 관찰할 수 있음
    //  case addContact(PresentationAction<AddContactFeature.Action>)
    //  case alert(PresentationAction<Alert>)
    case destination(PresentationAction<Destination.Action>)
    
    case path(StackActionOf<ContactDetailFeature>)
    
    @CasePathable
    enum Alert: Equatable {
      case confirmDeletion(id: Contact.ID)
    }
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      // MARK: - Destination 열거형을 사용하지 않은 예제
      // case .addButtonTapped:
      //   state.addContact = AddContactFeature.State(
      //     contact: Contact(id: UUID(), name: "")
      //   )
      //   return .none
      //
      // case let .addContact(.presented(.delegate(.saveContact(contact)))):
      //   state.contacts.append(contact)
      //   return .none
      //
      // case .addContact:
      //   return .none
      // }
      
      // MARK: - Destination을 사용한 예제
      case .addButtonTapped:
        state.destination = .addContact(
          AddContactFeature.State(
            contact: Contact(id: self.uuid(), name: "")
          )
        )
        return .none
        
      /// [delegate]
      /// 자식 Feature가 부모에게 원하는 작업을 알려주는 "위임 작업"
      case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
        state.contacts.append(contact)
        return .none
        
      case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
        state.contacts.remove(id: id)
        return .none
        
        // 다른 destination 작업을 수행할 필요가 없음을 알림
      case .destination:
        return .none
        
      case let .deleteButtonTapped(id: id):
        state.destination = .alert(.deleteConfirmation(id: id))
        
        return .none
        
      case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
        guard let detailState = state.path[id: id] else { return .none }
        state.contacts.remove(id: detailState.contact.id)
        return .none
        
      case .path:
        return .none
      }
    }
    /// [ifLet]
    /// 부모 state의 옵셔널 프로퍼티에 대해 작동하는 부모 도메인에 자식 리듀서를 포함
    /// 부모 Feature와 자식 Feature를 통합
    // .ifLet(\.addContact, action: \.addContact) {
    //   AddContactFeature()
    // }
    .ifLet(\.$destination, action: \.destination)
    
    .forEach(\.path, action: \.path) {
      ContactDetailFeature()
    }
  }
}

extension ContactsFeature {
  @Reducer
  enum Destination {
    case addContact(AddContactFeature)
    case alert(AlertState<ContactsFeature.Action.Alert>)
  }
}

extension ContactsFeature.Destination.State: Equatable {}

extension AlertState where Action == ContactsFeature.Action.Alert {
  static func deleteConfirmation(id: UUID) -> Self {
    AlertState {
      TextState("Are you sure?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
        TextState("Delete")
      }
    }

  }
}
