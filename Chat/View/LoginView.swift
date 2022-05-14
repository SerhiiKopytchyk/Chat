//
//  LoginView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 14.05.2022.
//

import SwiftUI

struct LoginView: View {

    @State var email:String = ""
    @State var password:String = ""
    
    @State var isButtonDisabled: Bool = true

//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
private func updateButton() {
    let time:Double = 0.3
    //check if enable button
    if email.isEmpty || password.isEmpty{
        withAnimation(.easeInOut(duration: time)) {
            isButtonDisabled = true
        }
        
    }else{

            if password.count >= 8{
                if email.contains("@gmail.com") || email.contains("@email.com"){
                    withAnimation(.easeInOut(duration: time)) {
                        isButtonDisabled = false
                    }
                }else{
                    withAnimation(.easeInOut(duration: time)) {
                        isButtonDisabled = true
                    }
                }
            }else{
                withAnimation(.easeInOut(duration: time)) {
                    isButtonDisabled = true
                }
            }
    }
}
    
    var body: some View {
        VStack(spacing: 30){
            HStack{
                Text("Log In")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                    .padding()
                    .foregroundColor(.orange)
                Spacer()
                
            }
            VStack{
                Group {
                    HStack{
                        Image(systemName: "mail")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email.onUpdate(updateButton))
                    }
                    
                    HStack{
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password.onUpdate(updateButton))
                    }
                }
                .padding()
                .padding(.leading, 10)
                .padding(.trailing, 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                        .padding(.leading, 10)
                        .padding(.trailing, 20)
                        .padding(5)
                )
            }
            
            VStack {
                Button("Log in") {
                    //how to automaticly change prop
                }
                .foregroundColor(.white)
                .padding(.leading, 80)
                .padding(.trailing, 80)
                .padding()
                .background(isButtonDisabled ? Color.gray : Color.orange)
                .cornerRadius(30)
                .disabled(isButtonDisabled)
                .shadow(color:isButtonDisabled ? .gray : .orange, radius: isButtonDisabled ? 0 : 8, x: 0, y: 0)
                

                
                
                Text("OR")
                    .padding(.top, 50)
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(.gray)
                    
                

                Button("Google Log In") {
                    //how to automaticly change prop
                }
                .foregroundColor(.brown)
                .padding()
                .overlay(
                        RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.brown, lineWidth: 2)
                        )
                .background(.clear)
               
                .cornerRadius(30)
                .padding(.top, 50)

                
                

            }
        }

           
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
