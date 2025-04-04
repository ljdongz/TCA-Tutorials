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
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    Text(contact.name)
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
            .sheet(item: $store.scope(
                state: \.addContact,
                action: \.addContact
            )) { addContactStore in
                NavigationStack {
                    AddContactView(store: addContactStore)
                }
            }
        }
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
