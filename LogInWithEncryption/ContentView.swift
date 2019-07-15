//
//  ContentView.swift
//  LogInWithEncryption
//
//  Created by Manenga Mungandi on 2019/07/14.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//
//  Rules:
//  Check if any users are saved in local defaults
//      - if so, display login view
//      - else display sign up view
//      - both shoudld have the option to switch to the other view
//

import SwiftUI

let key = "rosesR3dS0m3A3eBlu3Oth3S@R3N0Tee"
let iv  = "ThisIsATestYaKno"

struct ContentView : View {
    
    @State var isLoggedIn: Bool = false

    var body: some View {
//        if self.$isLoggedIn {
//            LoggedInView.init()
//        } else {
            SignInView()
//        }
    }
}

struct SignInView : View {
    
    @State var typedUsername: String = ""
    @State var typedPassword: String = ""
    
    var availableUsers = ["Manenga", "Mungandi"]
    
    var body: some View {
        VStack {
            Text("Status: You are not signed in!").color(.red)
            Spacer()
            
            VStack {
                VStack(spacing: 18) {
                    TextField($typedUsername, placeholder: Text("Username"), onEditingChanged: { changed in
                        print("onEditing: \(changed)")
                    }).textFieldStyle(.roundedBorder)
                    
                    SecureField($typedPassword, placeholder: Text("Password")).textFieldStyle(.roundedBorder)
                    Button(action: login) {
                        HStack{
                            Text("Login")
                                .color(.white)
                                .frame(width: UIScreen.main.bounds.width - 80 ,height: 45)
                        }
                        }.background(Color.blue)
                    }
                    .padding().cornerRadius(16)
                    .background(Color.gray.opacity(0.05))
                    .frame(height: 80, alignment: .center)
                Spacer()
            }
            List {
                Section(header: Text("Available users").bold().color(.blue), footer: Text("\(self.availableUsers.count) users signed up").italic()) {
                    ForEach(0..<availableUsers.count) {
                        Text("\(self.availableUsers[$0])")
                    }
                }
            }.listStyle(.grouped)
             .frame(height: 160, alignment: .top)
        }.padding(25)
    }
    
    func doCredentialsMatch() -> Bool {
        // check if typed credentials match stored credentials
        
        let dbEncryptedUsername = UserDefaults.standard.string(forKey: "encryptedUsername") ?? ""
        let dbEncryptedPassword = UserDefaults.standard.string(forKey: "encryptedPassword") ?? ""
        
        do {
            let decryptedUsername = try dbEncryptedUsername.decrypt(key: key, iv: iv)
            let decryptedPassword = try dbEncryptedPassword.decrypt(key: key, iv: iv)
            print("Successfully decrypted username and password.")
            return (typedUsername == decryptedUsername && typedPassword == decryptedPassword)
        } catch {
            print("Could not decrypt username and password.")
            return false
        }
    }
    
    func login() {
        if typedUsername.isEmpty {
            Alert(title: Text("Please enter a username"))
        } else if typedPassword.isEmpty {
            Alert(title: Text("Please enter a password"))
        } else {
            // encrypt data, store in NS defaults and log in
            
            //show loading
            do {
                let encryptedUsername = try typedUsername.encrypt(key: key, iv: iv)
                let encryptedPassword = try typedPassword.encrypt(key: key, iv: iv)
                UserDefaults.standard.set(encryptedUsername, forKey: "encryptedUsername")
                UserDefaults.standard.set(encryptedPassword, forKey: "encryptedPassword")
                print("Successfully encrypted username and password.")
            } catch {
                print("Could not encrypt username and password.")
                
//                print("Could not decrypt username and password.")
//                self.loadingView.isHidden = true
//                isLoggedIn = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                // if doCredentialsMatch:
                // dismiss loading
                // isLoggedIn = true
            })
        }
    }
}

struct SignUpView : View {
    
    var body: some View {
        VStack {
            Text("Status: You do not have any accounts").color(.blue)
            Spacer()
            Text("Create an account")
        }
    }
}

struct LoggedInView : View {
    
    var body: some View {
        VStack {
            Text("Status: You are signed in!").color(.green)
            Spacer()
            Button(action: logout) {
                Text("Logout")
            }.foregroundColor(.purple).padding(7)
        }.padding(25)
    }
    
    func logout() {
        // log user out
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        SignInView()
//        LoggedInView()
    }
}
#endif
