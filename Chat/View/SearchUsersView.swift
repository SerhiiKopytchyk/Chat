//
//  SearchUsersView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 03.06.2022.
//

import SwiftUI

struct SearchUsersView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @State var imageViewModel = ImageViewModel()
    @State var showSearchBar = false
    @State var searchText = ""
    @State var goToConversation = false
    @State var userWithConversation = User(chats: [], gmail: "", id: "", name: "")

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search users", text: $searchText).onChange(of: searchText, perform: { newValue in
                    viewModel.searchText = newValue
                    viewModel.getAllUsers()
                })
                    .textFieldStyle(DefaultTextFieldStyle())

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)

            }
            .padding()
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    SearchUserCell(user: user.name, userGmail: user.gmail, id: user.id, rowTapped: {
                        self.userWithConversation = user
                        viewModel.secondUser = user
                        viewModel.getCurrentChat(secondUser: user) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                goToConversation = true
                            }
                            // why with dispathchQueu.main.asynkAfter its working, but not with clusures?
                        } failure: { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                goToConversation = true
                            }
                        }
                    })
                }
            }
        }
        NavigationLink(isActive: $goToConversation) {
            ConversationView(user: self.userWithConversation)
        }label: {}
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
            .environmentObject(AppViewModel())
    }
}