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
    
    //    @Presents var addContact: AddContactFeature.State?
    //    @Presents var alert: AlertState<Action.Alert>?
    @Presents var destination: Destination.State?
  }
  
  enum Action {
    case addButtonTapped
    case deleteButtonTapped(id: Contact.ID)
    
    //    case addContact(PresentationAction<AddContactFeature.Action>)
    //    case alert(PresentationAction<Alert>)
    case destination(PresentationAction<Destination.Action>)
    
    enum Alert: Equatable {
      case confirmDeletion(id: Contact.ID)
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.destination = .addContact(
          AddContactFeature.State(contact: Contact(id: UUID(), name: ""))
        )
        return .none
        
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
        state.destination = .alert(.init(title: {
          TextState("Are you sure?")
        }, actions: {
          ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
            TextState("Delete")
          }
        }))
        
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
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
