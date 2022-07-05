//
//  ConversationView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 01.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationView: View {

    @State var secondUser: User
    @Binding var isFindChat: Bool

    @Namespace var animation

    @State var isExpandedProfile: Bool = false
    @State var profileImage: WebImage = WebImage(url: URL(string: ""))
    @State var loadExpandedContent = false
    @State var imageOffset: CGSize = .zero

    @EnvironmentObject var messagingViewModel: MessagingViewModel
    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    TitleRow(user: secondUser,
                             animationNamespace: animation,
                             isExpandedProfile: $isExpandedProfile,
                             profileImage: $profileImage
                    )
                        .environmentObject(chattingViewModel)

                    if isFindChat {
                        ScrollViewReader { _ in
                            ScrollView {
                                ForEach(
                                    self.messagingViewModel.currentChat.messages ?? [],
                                    id: \.id) { message in
                                        MessageBubble(message: message)
                                    }
                            }
                            .padding(.top, 10)
                            .background(.white)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                        }
                    } else {
                        createChatButton
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color("Peach"))
                MessageField(messagingViewModel: messagingViewModel)
            }
            .navigationBarBackButtonHidden(loadExpandedContent)
        }
        .overlay(content: {
                Rectangle()
                    .fill(.black)
                    .opacity(loadExpandedContent ? 1 : 0)
                    .opacity(imageOffsetProgress())
                    .ignoresSafeArea()
        })
        .overlay {
            if isExpandedProfile {
                expandedPhoto(image: profileImage)
            }
        }
    }

    @ViewBuilder func expandedPhoto (image: WebImage ) -> some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(loadExpandedContent ? 0 : size.height)
                    .offset(y: loadExpandedContent ? imageOffset.height : .zero)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                imageOffset = value.translation
                            }).onEnded({ value in
                                let height = value.translation.height
                                if height > 0 && height > 100 {

                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        loadExpandedContent = false
                                    }

                                    withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
                                        isExpandedProfile = false
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        imageOffset = .zero
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        imageOffset = .zero
                                    }
                                }
                            })
                    )
            }
            .matchedGeometryEffect(id: "profilePhoto", in: animation)
            .frame(height: 300)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top, content: {
            HStack(spacing: 10) {
                Button {

                    withAnimation(.easeInOut(duration: 0.3)) {
                        loadExpandedContent = false
                    }
                    withAnimation(.easeInOut(duration: 0.3).delay(0.05)) {
                        isExpandedProfile = false
                    }

                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                Text(viewModel.secondUser.name)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer(minLength: 10)
            }
            .padding()
            .opacity(loadExpandedContent ? 1 : 0)
            .opacity(imageOffsetProgress())
        })
        .transition(.offset(x: 0, y: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                loadExpandedContent = true
            }
        }
    }

    func imageOffsetProgress() -> CGFloat {
        let progress = imageOffset.height / 100
        if imageOffset.height < 0 {
            return 1
        } else {
            return 1  - (progress < 1 ? progress : 1)
        }
    }

    @ViewBuilder var createChatButton: some View {

        VStack {
            Button {
                chattingViewModel.createChat { chat in
                    messagingViewModel.currentChat = chat
                    messagingViewModel.getMessages(competition: { _ in })
                    isFindChat = true
                }
            } label: {
                Text("Start Chat")
                    .font(.title)
                    .padding()
                    .background(.white)
                    .cornerRadius(20)
            }
        }.frame(maxHeight: .infinity)

    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(secondUser: User(chats: [],
                                          channels: [],
                                          gmail: "",
                                          id: "",
                                          name: ""),
                         isFindChat: .constant(true))
            .environmentObject(MessagingViewModel())
            .environmentObject(UserViewModel())
    }
}
