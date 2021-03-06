//
//  editProfileView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.06.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import UIKit

struct EditProfileView: View {

    @State var profileImage: UIImage?
    @State var isShowingImagePicker = false
    @State var isShowingChangeName = false
    @State var newName: String = ""

    @State var imageUrl = URL(string: "")
    @State var isFindUserImage = true
    @State var isChangedImage = false

    @EnvironmentObject var viewModel: UserViewModel
    @ObservedObject var editProfileView = EditProfileViewModel()

    var body: some View {
        ZStack {

            Color("Peach")
            .ignoresSafeArea()

            ZStack(alignment: .top) {
                Color.white
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(x: 0, y: 50)
                VStack {
                    changeProfileImageButton
                    changeProfileNameButton

                    if isShowingChangeName {
                        HStack {
                            TextField("Enter your new name!", text: $newName)
                                .underlineTextField(text: newName, underlineOn: 4)
                                .padding(.leading, 20)
                            saveButton
                                .padding(.horizontal, 20)
                        }
                    }

                    Text(viewModel.currentUser.gmail)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding()

                }
            }
        }
        .onChange(of: profileImage ?? UIImage(), perform: { newImage in
            editProfileView.user = self.viewModel.currentUser
            editProfileView.saveImage(image: newImage)
        })
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $profileImage)
        }
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.black.opacity(0.70))
            .background(.white)
            .cornerRadius(50)

    }

    var changeProfileImageButton: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if isFindUserImage {
                if self.profileImage != nil {
                    ZStack {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
                    }
                } else {
                    ZStack {
                        WebImage(url: imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
                    }
                }
            } else {
                if self.profileImage != nil {
                        Image(uiImage: self.profileImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(.black, lineWidth: 3)
                                    .shadow(radius: 10)
                            )
                } else {
                        emptyImage
                }
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            let ref = Storage.storage().reference(withPath: viewModel.currentUser.id )
            ref.downloadURL { url, err in
                if err != nil {
                    self.isFindUserImage = false
                    return
                }
                withAnimation(.easeInOut) {
                    self.imageUrl = url
                }
            }
        }
    }

    var changeProfileNameButton: some View {
        Button {
            withAnimation(.interactiveSpring()) {
                isShowingChangeName.toggle()
            }
        } label: {
            HStack {
                Text(viewModel.currentUser.name)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.vertical)
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
        }
        .padding(.top)
    }

    var saveButton: some View {
        Button {
            editProfileView.changeName(newName: newName, userId: viewModel.currentUser.id )
        } label: {
            Text("save")
                .frame(width: 60)
                .padding(10)
                .foregroundColor(.white)
                .background(newName.count < 4 ? .gray : .orange)
                .cornerRadius(10)
                .shadow(color: newName.count < 4 ? .gray : .orange, radius: 3)
        }
        .disabled(newName.count > 3 ? false : true)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(UserViewModel())
    }
}

extension View {
    func underlineTextField(text: String, underlineOn: Int) -> some View {
        self
            .padding(.vertical, 10)
            .overlay(
                Rectangle()
                    .frame(height: 2).padding(.top, 35)
                    .foregroundColor(text.count >= underlineOn ? .orange : .black)
            )
            .padding(10)
    }
}
