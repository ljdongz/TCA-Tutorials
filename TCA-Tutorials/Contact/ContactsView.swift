//
//  ContactsView.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/4/25.
//

import SwiftUI
import ComposableArchitecture

struct ContactsView: View {
  @Bindable var store: StoreOf<ContactsFeature>
  
  var body: some View {
    NavigationStack(
      path: $store.scope(
        state: \.path,
        action: \.path
      )
    ) {
      List {
        ForEach(store.contacts) { contact in
          NavigationLink(state: ContactDetailFeature.State(contact: contact)) {
            HStack {
              Text(contact.name)
              Spacer()
              Button {
                store.send(.deleteButtonTapped(id: contact.id))
              } label: {
                Image(systemName: "trash")
                  .foregroundColor(.red)
              }
            }
          }
          .buttonStyle(.borderless)
        }
      }
      .navigationTitle("Contacts")
      .toolbar {
        ToolbarItem {
          Button {
            store.send(.addButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    } destination: { store in
      ContactDetailView(store: store)
    }
    
    /// 이동될 뷰에 전달할 새로운 스토어를 생성하여 전달
    /// 부모 도메인(ContactsFeature)에서
    /// Destination.addContact에 해당하는 도메인에만 집중
    .sheet(item: $store.scope(
      state: \.destination?.addContact,
      action: \.destination.addContact
    )) { addContactStore in
      NavigationStack {
        AddContactView(store: addContactStore)
      }
    }
    
    /// 알림 화면에 전달할 새로운 스토어를 생성하여 전달
    /// 부모 도메인(ContactsFeature)에서
    /// Destination.alert에 해당하는 도메인에만 집중
    .alert($store.scope(
      state: \.destination?.alert,
      action: \.destination.alert
    ))
  }
}

#Preview {
  ContactsView(
    store: Store(initialState: ContactsFeature.State(contacts: [
      .init(id: UUID(), name: "Blob"),
      .init(id: UUID(), name: "Blob jr")
    ]), reducer: {
      ContactsFeature()
    })
  )
}
