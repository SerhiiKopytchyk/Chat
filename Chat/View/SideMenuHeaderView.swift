//
//  SideMenuHeaderView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 20.05.2022.
//

import SwiftUI

struct SideMenuHeaderView: View {
    
    @Binding var isShowingSideMenu: Bool
    @EnvironmentObject var viewModel:AppViewModel

    var body: some View {
        
        

        ZStack(alignment: .topTrailing) {
            Button {
                withAnimation(.spring()){
                    isShowingSideMenu.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 32, height: 32)
                    
                    .padding()
            }

            
            VStack(alignment: .leading){
                Image("profileImage")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .padding(.bottom, 16)
                
                Text(viewModel.username)
                    .font(.system(size: 24, weight: .semibold))
                    
                Text(viewModel.gmail)
                    .font(.system(size: 14 ))
                    .padding(.bottom, 24)
                HStack{
                    HStack{
                        Text("12").bold()
                        Text("Following")
                    }
                    HStack{
                        Text("4").bold()
                        Text("Followers")
                    }
                    Spacer()
                }
                Spacer()
            }.padding()
        }
    }
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(isShowingSideMenu: .constant(true))
    }
}
