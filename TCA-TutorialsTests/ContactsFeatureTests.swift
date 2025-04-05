//
//  ContactsFeatureTests.swift
//  TCA-TutorialsTests
//
//  Created by 이정동 on 4/5/25.
//

import Testing
import ComposableArchitecture
import Foundation

@testable import TCA_Tutorials

@MainActor
struct ContactsFeatureTests {
  
  @Test
  func addFlow() async throws {
    let store = TestStore(initialState: ContactsFeature.State()) {
      ContactsFeature()
    } withDependencies: {
      $0.uuid = .incrementing
    }
    
    await store.send(.addButtonTapped) {
      $0.destination = .addContact(
        AddContactFeature.State(
          contact: Contact(id: UUID(0), name: "")
        )
      )
    }
    
    // AddContactFeature의 State.contact.name이 변경됨에 따라
    // ContactFeature의 State.destination.addContact의 연관값도 변경됨을 테스트
    await store.send(\.destination.addContact.setName, "Blob jr") {
      $0.destination?.modify(\.addContact) {
        $0.contact.name = "Blob jr"
      }
    }
    
    await store.send(\.destination.addContact.saveButtonTapped)
    await store.receive(
      \.destination.addContact.delegate.saveContact,
       Contact(id: UUID(0), name: "Blob jr")
    ) {
      $0.contacts = [
        Contact(id: UUID(0), name: "Blob jr")
      ]
    }
    
    await store.receive(\.destination.dismiss) {
      $0.destination = nil
    }
  }
  
  // 모든 상태 변화를 추적하지 않음
  @Test
  func addFlowNonExhaustive() async {
    let store = TestStore(initialState: ContactsFeature.State()) {
      ContactsFeature()
    } withDependencies: {
      $0.uuid = .incrementing
    }
    
    store.exhaustivity = .off
    
    await store.send(.addButtonTapped)
    await store.send(\.destination.addContact.setName, "Blob jr")
    await store.send(\.destination.addContact.saveButtonTapped)
    
//    // 가능
//    await store.receive(
//      \.destination.addContact.delegate.saveContact,
//       Contact(id: UUID(0), name: "Blob jr")
//    ) {
//      $0.contacts = [
//        Contact(id: UUID(0), name: "Blob jr")
//      ]
//    }
    
    await store.skipReceivedActions()
    
    store.assert { state in
      state.contacts = [
        Contact(id: UUID(0), name: "Blob jr")
      ]
      
      state.destination = nil
    }
  }
  
  @Test
  func deleteContact() async {
    let store = TestStore(
      initialState: ContactsFeature.State(
        contacts: [
          Contact(id: UUID(0), name: "Blob"),
          Contact(id: UUID(1), name: "Blob jr")
        ]
      )
    ) {
      ContactsFeature()
    }
    
    await store.send(.deleteButtonTapped(id: UUID(0))) {
      $0.destination = .alert(.deleteConfirmation(id: UUID(0)))
    }
  
    // @CasePathable 사용한 경우 가능
    await store.send(\.destination.alert.confirmDeletion, UUID(0)) {
      $0.contacts = [
        Contact(id: UUID(1), name: "Blob jr")
      ]
      $0.destination = nil
    }
    
//    // @CasePathable 사용하지 않으면 아래와 같이 사용해야 함
//    await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(0)))))) {
//      $0.contacts = [
//        Contact(id: UUID(1), name: "Blob jr")
//      ]
//      $0.destination = nil
//    }
  }
}
