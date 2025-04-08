//
//  ContactDetailView.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/5/25.
//

import SwiftUI
import ComposableArchitecture

struct ContactDetailView: View {
  @Bindable var store: StoreOf<ContactDetailFeature>
  
  var body: some View {
    Form {
      Button("Delete") {
        store.send(.deleteButtonTapped)
      }
    }
    .navigationTitle(Text(store.contact.name))
    .alert($store.scope(state: \.alert, action: \.alert))
  }
}

#Preview {
  NavigationStack {
    ContactDetailView(
      store: Store(
        initialState: ContactDetailFeature.State(
          contact: Contact(id: UUID(), name: "test")
        ),
        reducer: {
          ContactDetailFeature()
        }
      )
    )
  }
}
