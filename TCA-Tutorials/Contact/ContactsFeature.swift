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
    @Presents var destination: Destination.State?
    
    /// [StackState]
    /// 현재 스택에 푸시된 데이터 목록 (스택 상태)
    var path = StackState<Path.State>()
  }
  
  enum Action {
    case addButtonTapped
    case deleteButtonTapped(id: Contact.ID)
    
    /// [PresentationAction]
    /// 자식 Feature에서 전송된 모든 Action을 관찰할 수 있음
    case destination(PresentationAction<Destination.Action>)
    
    /// [StackActionOf]
    /// 요소를 스택에 푸시하거나 팝하는 것과 같이
    /// 스택 내에서 발생할 수 있는 작업이나 스택 내 특정 기능에서 발생하는 작업
    case path(StackActionOf<Path>)
    case detailButtonTapped(contact: Contact)
    
    /// [@CasePathable]
    /// key path dot-chaning 구문을 사용할 수 있도록 함 (ContactsFeatureTests.swift)
    @CasePathable
    /// Alert에서 동작될 액션 정의
    enum Alert: Equatable {
      case confirmDeletion(id: Contact.ID)
    }
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      // MARK: - Destination State
      case .addButtonTapped:
        state.destination = .addContact(
          AddContactFeature.State(
            contact: Contact(id: self.uuid(), name: "")
          )
        )
        return .none
        
      case let .deleteButtonTapped(id: id):
        state.destination = .alert(.deleteConfirmation(id: id))
        
        return .none
        
      // MARK: - Destination Action
      case let .destination(action):
        switch action {
          
          /// [delegate]
          /// 자식 Feature가 부모에게 원하는 작업을 알려주는 "위임 작업"
        case let .presented(.addContact(.delegate(.saveContact(contact)))):
          state.contacts.append(contact)
          return .none
          
        case let .presented(.alert(.confirmDeletion(id: id))):
          state.contacts.remove(id: id)
          return .none
          
          /// 다른 destination 작업을 수행할 필요가 없음을 알림
        default:
          return .none
        }
        
        
      // MARK: - Path State
      case .detailButtonTapped(let contact):
        state.path.append(.detail(ContactDetailFeature.State(contact: contact)))
        return .none
        
        
      // MARK: - Path Action
      case let .path(action):
        switch action {
          
          /// id : StackElementID
        case let .element(id: id, action: .detail(.delegate(.confirmDeletion))):
          /// path 배열에서 id가 일치하는 요소를 찾는 StackState의 subscript 문법
          guard let detailFeatureState = state.path[id: id]?.detail
          else { return .none }
          let contactId = detailFeatureState.contact.id
          state.contacts.remove(id: contactId)
          return .none
          
        default:
          return .none
        }
      }
    }
    /// [ifLet]
    /// 트리 기반 Navigate
    /// 부모 state의 옵셔널 프로퍼티(Destination.State?)에 대해 작동하는 부모 도메인(destination)에
    /// 자식 리듀서를 포함
    /// 부모 Feature와 자식 Feature를 통합
    .ifLet(\.$destination, action: \.destination) // {
    /// 명시하지 않아도 Reducer 매크로가 자동으로 추론
    // Destination()
    // }
    
    /// [forEach]
    /// 스택 기반 Navigate
    /// 부모 상태의 내비게이션 스택 요소(StackState)에서 작동하는 부모 도메인(path)에
    /// 자식 리듀서를 포함
    .forEach(\.path, action: \.path) // {
    /// 명시하지 않아도 Reducer 매크로가 자동으로 추론
    // Path()
    // }
  }
}

extension ContactsFeature {
  /// 트리 기반 내비게이션 할 수 있는 모든 기능에 대한 도메인과 로직을 보유하는 열거형
  @Reducer
  enum Destination {
    /// 실제 리듀서를 유지하고 있음
    case addContact(AddContactFeature)
    
    case alert(AlertState<ContactsFeature.Action.Alert>)
  }
  
  /// 스택 기반 내비게이션 할 수 있는 모든 기능에 대한 도메인과 로직을 보유하는 열거형
  @Reducer
  enum Path {
    case detail(ContactDetailFeature)
  }
}

extension ContactsFeature.Destination.State: Equatable {}
extension ContactsFeature.Path.State: Equatable {}

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
