//
//  AddContactView.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 4/4/25.
//

import SwiftUI
import ComposableArchitecture

struct AddContactView: View {
    @Bindable var store: StoreOf<AddContactFeature>
    var body: some View {
        Form {
            TextField("Name", text: $store.contact.name.sending(\.setName))
        }
        Button("Save") {
            store.send(.saveButtonTapped)
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview {
    AddContactView(store: .init(
        initialState: AddContactFeature.State(
            contact: .init(id: UUID(), name: "Blob")
        ), reducer: {
            AddContactFeature()
        }
    ))
}
