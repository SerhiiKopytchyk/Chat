//
//  ChattingViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 23.06.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ChattingViewModel: ObservableObject {

    // MARK: - vars

    @Published var user: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var secondUser = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var currentChat: Chat = Chat(id: "", user1Id: "", user2Id: "", messages: [])

    @Published private(set) var chats: [Chat] = []

    let dataBase = Firestore.firestore()

    // MARK: - functions

    func getCurrentChat( secondUser: User, competition: @escaping (Chat) -> Void, failure: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).sync {
            self.dataBase.collection("chats")
            .whereField("user1Id", isEqualTo: secondUser.id)
            .whereField("user2Id", isEqualTo: self.user.id)
            .queryToChat { chat in
                self.currentChat = chat
                competition(chat)
                return
            }

            self.dataBase.collection("chats")
            .whereField("user2Id", isEqualTo: secondUser.id)
            .whereField("user1Id", isEqualTo: self.user.id)
            .queryToChat { chat in
                self.currentChat = chat
                competition(chat)
                return
            } failure: { error in
                failure(error)
                return
            }
        }
    }

    func getCurrentChat(chat: Chat, userNumber: Int, competition: @escaping (Chat) -> Void) {
        if userNumber == 1 {

            dataBase.collection("chats")
                .whereField("user1Id", isEqualTo: chat.user1Id)
                .whereField("user2Id", isEqualTo: chat.user2Id)
                .queryToChat { chat in
                    self.currentChat = chat
                    competition(chat)
                    return
                }

        } else {

            dataBase.collection("chats")
                .whereField("user1Id", isEqualTo: chat.user1Id)
                .whereField("user2Id", isEqualTo: chat.user2Id)
                .queryToChat { chat in
                    self.currentChat = chat
                    competition(chat)
                    return
                }

        }
    }

    func createChat(competition: @escaping (Chat) -> Void) {
        do {

            try chatCreating(competition: { chat in
                competition(chat)
                return
            })

        } catch {
            print("error creating chat to FireStore: \(error)")
        }
    }

    fileprivate func chatCreating(competition: @escaping (Chat) -> Void) throws {

        let newChat = Chat(id: "\(UUID())", user1Id: user.id, user2Id: secondUser.id)

        try dataBase.collection("chats").document().setData(from: newChat)

        getCurrentChat(secondUser: secondUser) { chat in
            self.addChatsIdToUsers()
            competition(chat)
        } failure: { _ in }

    }

    fileprivate func addChatsIdToUsers() {
        dataBase.collection("users").document(user.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])
        dataBase.collection("users").document(secondUser.id)
            .updateData(["chats": FieldValue.arrayUnion([currentChat.id ?? "someChatId"])])

    }

    func getChats(fromUpdate: Bool = false, chatsId: [String] = []) {
        self.chats = []

        if chatsId.isEmpty {

            for chatId in user.chats {
                dataBase.collection("chats").document(chatId)
                    .toChat { chat in
                        self.chats.append(chat)
                    }
            }

        } else {

            for chatId in chatsId {
                dataBase.collection("chats").document(chatId)
                    .toChat { chat in
                        self.chats.append(chat)
                    }
            }

        }

        if !fromUpdate {
            self.updateChats()
        }

    }

    fileprivate func updateChats() {
        dataBase.collection("users").document(user.id)
            .addSnapshotListener { document, error in

                if self.isError(error: error) { return }

                guard let userLocal = try? document?.data(as: User.self) else {
                    return
                }
                if userLocal.chats.count != self.user.chats.count {
                    self.getChats(fromUpdate: true, chatsId: userLocal.chats)
                }

            }
    }

    func deleteChat() {
        deleteChatIdFromUsersChats()
        dataBase.collection("chats").document("\(currentChat.id ?? "someId")").delete { err in
            if self.isError(error: err) { return }
        }
    }

    fileprivate func deleteChatIdFromUsersChats() {
        dataBase.collection("users").document(currentChat.user1Id).updateData([
            "chats": FieldValue.arrayRemove(["\(currentChat.id ?? "someId")"])
        ])

        dataBase.collection("users").document(currentChat.user2Id).updateData([
            "chats": FieldValue.arrayRemove(["\(currentChat.id ?? "someId")"])
        ])
    }

    fileprivate func isError(error: Error?) -> Bool {
        if error != nil {
            print(error?.localizedDescription ?? "error")
            return true
        } else {
            return false
        }
    }

}
