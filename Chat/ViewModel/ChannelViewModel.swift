//
//  ChannelViewModel.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 26.06.2022.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ChannelViewModel: ObservableObject {

    // MARK: - vars

    @Published var currentUser: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var owner: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var subscribers: [String] = []

    @Published var channels: [Channel] = []
    @Published var currentChannel: Channel = Channel(id: "",
                                                     name: "",
                                                     description: "",
                                                     ownerId: "",
                                                     subscribersId: [],
                                                     messages: [])

    let dataBase = Firestore.firestore()

    // MARK: - functions

    func getCurrentChannel( channelId: String, competition: @escaping (Channel) -> Void) {

        dataBase.collection("channels").document(channelId).getDocument { document, error in

            if self.isError(error: error) { return }

            if let channel = try? document?.data(as: Channel.self) {
                competition(channel)
            }

        }
    }

    func getCurrentChannel( name: String, ownerId: String,
                            competition: @escaping (Channel) -> Void,
                            failure: @escaping (String) -> Void) {

        dataBase.collection("channels")
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("name", isEqualTo: name)
            .queryToChannel { channel in
                self.currentChannel = channel
                competition(channel)
                return

            } failure: { text in
                failure(text)
                return
            }

    }

    func createChannel(subscribersId: [String],
                       name: String,
                       description: String,
                       competition: @escaping (Channel) -> Void) {
        do {

            try creatingChannel(subscribersId: subscribersId,
                                name: name,
                                description: description,
                                competition: { channel in
                competition(channel)
            })

        } catch {
            print("error creating chat to Firestore:: \(error)")
        }
    }

    fileprivate func creatingChannel(subscribersId: [String],
                                     name: String,
                                     description: String,
                                     competition: @escaping (Channel) -> Void) throws {

        let newChannel = Channel(id: "\(UUID())",
                                 name: name,
                                 description: description,
                                 ownerId: currentUser.id,
                                 subscribersId: subscribersId,
                                 messages: [])

        try dataBase.collection("channels").document().setData(from: newChannel)

        getCurrentChannel(name: name, ownerId: currentUser.id) { channel in
            self.currentChannel = channel
            self.addChannelsIdToUsers(usersId: subscribersId)
            competition(channel)
        } failure: { _ in
            print("failure")
        }

    }

    fileprivate func addChannelsIdToUsers(usersId: [String]) {
        DispatchQueue.main.async {

            for userId in self.currentChannel.subscribersId ?? [] {
                self.dataBase.collection("users").document(userId)
                    .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])
            }

            self.dataBase.collection("users").document(self.owner.id)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

        }
    }

    private func updateChannels() {
        DispatchQueue.main.async {

            self.dataBase.collection("users").document(self.currentUser.id)
                .addSnapshotListener { document, error in

                    if self.isError(error: error) { return }

                    guard let userLocal = try? document?.data(as: User.self) else {
                        return
                    }

                    if userLocal.channels.count != self.currentUser.channels.count {
                        self.getChannels(fromUpdate: true, channelPart: userLocal.channels)
                    }

                }
        }
    }

    func getChannels(fromUpdate: Bool = false, channelPart: [String] = []) {
        self.channels = []
        if channelPart.isEmpty {

            for channelId in currentUser.channels {
                dataBase.collection("channels").document(channelId)
                    .toChannel { channel in
                        self.channels.append(channel)
                    }
            }

        } else {

            for channelId in channelPart {
                dataBase.collection("channels").document(channelId)
                    .toChannel { channel in
                        self.channels.append(channel)
                    }
            }

        }

        if !fromUpdate {
            self.updateChannels()
        }
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