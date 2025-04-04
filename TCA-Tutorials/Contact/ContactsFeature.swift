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
    @Presents var addContact: AddContactFeature.State?
    var contacts: IdentifiedArrayOf<Contact> = []
  }
  
  enum Action {
    case addButtonTapped
    case addContact(PresentationAction<AddContactFeature.Action>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.addContact = AddContactFeature.State(
          contact: Contact(id: UUID(), name: "")
        )
        return .none
        
      case let .addContact(.presented(.delegate(.saveContact(contact)))):
        state.contacts.append(contact)
        return .none
        
      case .addContact:
        return .none
      }
    }
    // State.addContact, Action.addContact
    // State.addContact가 nil이 아니면 AddContactView 띄우고 nil이면 dismiss
    // AddContactView 내에서 수행된 Action을 부모 리듀서에서 처리 가능
    .ifLet(\.$addContact, action: \.addContact) {
      AddContactFeature()
    }
  }
}
