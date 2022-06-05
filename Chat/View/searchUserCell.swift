//
//  searchUserCell.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 05.06.2022.
//

import SwiftUI



struct searchUserCell: View {
    var user:String
    var userGmail:String
    var body: some View {
        
            HStack{
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
                VStack(alignment: .leading){
                    Text(user)
                        .font(.title)
                    Text(userGmail)
                        .font(.caption)
                }
            }
           
    }
}

struct searchUserCell_Previews: PreviewProvider {
    static var previews: some View {
        searchUserCell(user: "Georgy", userGmail: "georgy@gmail.com")
    }
}
