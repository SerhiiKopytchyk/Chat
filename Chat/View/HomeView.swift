//
//  HomeView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 21.05.2022.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @EnvironmentObject var viewModel: AppViewModel
    @State var currentTab: Tab = .chats
    @State var goToConversation = false

    init() {
        UITabBar.appearance().isHidden = true
        UITableView.appearance().backgroundColor = .white
        // can we make bg of list like this?
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $currentTab) {

                    VStack {
                        List {
                            ForEach(viewModel.chats, id: \.id) { chat in

                                ConversationListRow(chat: chat) {
                                    _ = viewModel.getUser(
                                        id: viewModel.user.id != chat.user1Id ? chat.user1Id : chat.user2Id
                                    ) { _ in
                                        goToConversation.toggle()
                                    }

                                    viewModel.getCurrentChat(
                                        chat: chat, userNumber: viewModel.user.id != chat.user1Id ? 1 : 2
                                    ) { _ in }

                                }
                            }
                        }

                    }.tag(Tab.chats)

                    Text("Chanels")
                        .tag(Tab.chanels)
                }
                CustomTabBar(currentTab: $currentTab)
                    .background(.white)
                NavigationLink(isActive: $goToConversation) {
                    ConversationView(user: viewModel.secondUser)
                } label: {

                }

            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppViewModel())
    }
}

extension View {
}