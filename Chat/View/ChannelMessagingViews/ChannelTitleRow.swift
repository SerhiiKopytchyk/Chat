//
//  ChannelTitleRow.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 28.06.2022.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct ChannelTitleRow: View {
    var channel: Channel

    let animationNamespace: Namespace.ID
    @Binding var isExpandedProfile: Bool
    @Binding var isExpandedDetails: Bool
    @Binding var profileImage: WebImage

    @EnvironmentObject var channelViewModel: ChannelViewModel

    @State var isOwner: Bool

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true

    var body: some View {
        HStack(spacing: 20) {
            if isFindUserImage {
                VStack {
                    if isExpandedProfile {
                        WebImage(url: imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                            .opacity(0)
                    } else {
                        WebImage(url: imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                            .matchedGeometryEffect(id: "channelPhoto", in: animationNamespace)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpandedProfile.toggle()
                    }
                }
            } else {
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            }

            VStack(alignment: .leading) {
                Text(channel.name)
                    .font(.title).bold()

                Text(channel.description)
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedDetails.toggle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                let ref = Storage.storage().reference(withPath: channel.id ?? "someId" )
                ref.downloadURL { url, err in
                    if err != nil {
                        self.isFindUserImage = false
                        return
                    }
                    withAnimation(.easeInOut) {
                        self.profileImage = WebImage(url: url)
                        self.imageUrl = url
                    }
                }
            }
        }
        .padding()
    }
}
