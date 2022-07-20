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
import SwiftUI

class ChannelViewModel: ObservableObject {

    // MARK: - vars

    @Published var currentUser: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var owner: User = User(chats: [], channels: [], gmail: "", id: "", name: "")
    @Published var searchText = ""

    @Published var channels: [Channel] = []
    @Published var searchChannels: [Channel] = []
    @Published var currentChannel: Channel = Channel(id: "",
                                                     name: "",
                                                     description: "",
                                                     ownerId: "",
                                                     ownerName: "",
                                                     subscribersId: [],
                                                     messages: [],
                                                     lastActivityTimestamp: Date(),
                                                     isPrivate: true)

    @Published var usersToAddToChannel: [User] = []
    @Published var channelSubscribers: [User] = []

    let dataBase = Firestore.firestore()

    // MARK: - functions

    // MARK: - to editChannelViewModel

    func removeUserFromSubscribersList(id: String) {

        for index in currentChannel.subscribersId?.indices.reversed() ?? [] {
            if id == currentChannel.subscribersId?[index] {
                currentChannel.subscribersId?.remove(at: index)
            }
        }

        for index in channelSubscribers.indices.reversed() {
            if id == channelSubscribers[index].id {
                channelSubscribers.remove(at: index)
                return
            }
        }
    }

    func getChannelSubscribers() {
        dataBase.collection("users").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }

            self.channelSubscribers = documents.compactMap { document -> User? in
                do {

                    let user = try document.data(as: User.self)

                    return self.filterRemoveUsers(user: user)
                } catch {
                    print("error deconding documet into User: \(error)")
                    return nil
                }
            }
        }
    }

    private func filterRemoveUsers(user: User) -> User? {
        if self.currentChannel.subscribersId?.contains(user.id) ?? false {
            return user
        }
        return nil
    }

    func subscribeUsersToChannel(usersId: [String]) {
        for userId in usersId {

            self.currentChannel.subscribersId?.append(userId)

            self.dataBase.collection("channels").document(currentChannel.id ?? "some ChannelId")
                .updateData(["subscribersId": FieldValue.arrayUnion([userId])])

            self.dataBase.collection("users").document(userId)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

        }
    }

    func getUsersToAddToChannel() {
        dataBase.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documets: \(String(describing: error))")
                return
            }

            self.usersToAddToChannel = documents.compactMap { document -> User? in
                do {

                    let user = try document.data(as: User.self)

                    return self.addUserToChannelFilter(user: user)
                } catch {
                    print("error deconding documet into User: \(error)")
                    return nil
                }
            }
        }
    }

    private func addUserToChannelFilter(user: User) -> User? {
        if doesUserNameContains(user: user) != nil {
            if self.currentChannel.subscribersId?.contains(user.id) ?? false {
                return nil
            }
            return user
        }
        return nil
    }

    // to class fucn
    private func doesUserNameContains(user: User) -> User? {
        if user.name.contains(self.searchText) && user.name != currentUser.name {
            return user
        }
        return nil
    }

    // MARK: - channelViewModel

    func subscribeToChannel() {
        DispatchQueue.main.async {

            self.dataBase.collection("users").document(self.currentUser.id)
                .updateData(["channels": FieldValue.arrayUnion([self.currentChannel.id ?? "someChatId"])])

            self.dataBase.collection("channels").document(self.currentChannel.id ?? "SomeChannelId")
                .updateData(["subscribersId": FieldValue.arrayUnion([self.currentUser.id ])])

        }
    }

    func doesUsesSubscribed () -> Bool {
        for id in currentChannel.subscribersId ?? [] where id == currentUser.id {
            return true
        }
        if currentChannel.ownerId == currentUser.id {
            return true
        }
        return false
    }

    func getSearchChannels() {

        dataBase.collection("channels").whereField("isPrivate", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }

                self.searchChannels = documents.compactMap {document -> Channel? in
                    do {
                        let channel = self.filterChannel(channel: try document.data(as: Channel.self))
                        return channel
                    } catch {
                        print("error decoding document into Channel: \(error)")
                        return nil
                    }
                }
            }
    }

    private func filterChannel(channel: Channel) -> Channel? {
        if channel.name.contains(self.searchText) {
            return channel
        }
        return nil
    }

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
                       isPrivate: Bool,
                       competition: @escaping (Channel) -> Void) {
        do {

            try creatingChannel(subscribersId: subscribersId,
                                name: name,
                                description: description,
                                isPrivate: isPrivate,
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
                                     isPrivate: Bool,
                                     competition: @escaping (Channel) -> Void) throws {

        let newChannel = Channel(id: "\(UUID())",
                                 name: name,
                                 description: description,
                                 ownerId: currentUser.id,
                                 ownerName: currentUser.name,
                                 subscribersId: subscribersId,
                                 messages: [],
                                 lastActivityTimestamp: Date(),
                                 isPrivate: isPrivate)

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

                    if userLocal.channels.count != self.channels.count {
                        self.getChannels(fromUpdate: true,
                                         channelPart: userLocal.channels)
                    }
                }
        }
    }

    func getChannels(fromUpdate: Bool = false, channelPart: [String] = []) {

        withAnimation {

            self.channels = []

            if channelPart.isEmpty {
                for channelId in currentUser.channels {
                    dataBase.collection("channels").document(channelId)
                        .toChannel { channel in
                            self.channels.append(channel)
                            self.sortChannels()

                        }
                }
            } else {
                for channelId in channelPart {
                    dataBase.collection("channels").document(channelId)
                        .toChannel { channel in
                            self.channels.append(channel)
                            self.sortChannels()
                        }
                }
            }

        }

        if !fromUpdate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateChannels()
            }
        }
    }

    func sortChannels() {
        self.channels.sort { $0.lastActivityTimestamp > $1.lastActivityTimestamp }
    }

    func deleteChannel() {
        removeChannelFromSubscribersAndOwner()
        dataBase.collection("channels").document("\(currentChannel.id ?? "someId")").delete { err in
            if self.isError(error: err) { return }
        }
    }

    fileprivate func removeChannelFromSubscribersAndOwner() {
        for id in currentChannel.subscribersId ?? [] {
            removeChannelFromUserSubscriptions(id: id)
        }

        removeChannelFromUserSubscriptions(id: owner.id)
    }

    func removeChannelFromUserSubscriptions(id: String) {
        removeCurrentUserFromChannelSubscribers()
        dataBase.collection("users").document(id).updateData([
            "channels": FieldValue.arrayRemove(["\(currentChannel.id ?? "someId")"])
        ])
    }

    fileprivate func removeCurrentUserFromChannelSubscribers() {
        dataBase.collection("channels").document(currentChannel.id ?? "some ID").updateData([
            "subscribersId": FieldValue.arrayRemove(["\(currentUser.id )"])
        ])
    }

    // MARK: - to editChannelViewModel

    func removeChannelFromSubscriptionsWithCertainUser(id: String) {
        removeCertainFromChannelSubscribers(id: id)
        dataBase.collection("users").document(id).updateData([
            "channels": FieldValue.arrayRemove(["\(currentChannel.id ?? "someId")"])
        ])
    }

    fileprivate func removeCertainFromChannelSubscribers(id: String) {
        dataBase.collection("channels").document(currentChannel.id ?? "some ID").updateData([
            "subscribersId": FieldValue.arrayRemove(["\(id)"])
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
