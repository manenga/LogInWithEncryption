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
import UIKit

let key = "rosesR3dS0m3A3eBlu3Oth3S@R3N0Tee"
let iv  = "ThisIsATestYaKno"

struct ContentView : View {
    
    @State var isLoggedIn: Bool = false
    @State var showUsernameAlert: Bool = false
    @State var showPasswordAlert: Bool = false
    @State var typedUsername: String = ""
    @State var typedPassword: String = ""
    
    var availableUsers = ["Manenga", "Mungandi"]
    
    let dism = Alert.Button.destructive(Text("OK"))
    
    var body: some View {
        
        ZStack {
            HomeView.opacity(isLoggedIn ? 1 : 0)
            AuthView.opacity(isLoggedIn ? 0 : 1)
//            Alert(title: Text("empty username"), dismissButton: dism)
//            Alert(title: Text("Please enter a username")).opacity(showUsernameAlert ? 0 : 1)
//            Alert(title: Text("Please enter a password")).opacity(isLoggedIn ? 0 : 1)
        
        }
    }
    
    @State var isEditingUsers: Bool = false
    
    private let spacing: Length = 18
    private let signInBtnText = Text("Sign In").color(.white).frame(width: UIScreen.main.bounds.width - 80 ,height: 45)
    private let signUpBtnText = Text("Sign up").color(.blue).frame(width: UIScreen.main.bounds.width - 80 ,height: 45)
    
    var AuthView: some View {
        VStack {
            Text("Status: You are not signed in!").color(.red)
            Spacer()
            
            VStack {
                VStack(spacing: spacing) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Username")
                            .font(.system(size: 15))
                            .opacity(0.5)
                        
                        ResponderableTextField(text: $typedUsername,
                                               isFirstResponder: true,
                                               keyboardType: .default)
                            .padding(10)
                            .frame(height: 50)
                            .border(Color.black, width: 0.3, cornerRadius: 10)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.system(size: 15))
                            .opacity(0.5)
                        
                        SecureField($typedPassword, onCommit: {
                            // to do
                        })
                            .padding(10)
                            .frame(height: 50)
                            .border(Color.black, width: 0.3, cornerRadius: 10)
                    }
                    
                    Button(action: login) {
                        signInBtnText
                    }.background(Color.blue)
                    Button(action: signUp) {
                        signUpBtnText
                    }
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
    
    
    
    
    var HomeView: some View {
        VStack {
            Text("Status: You are signed in!").color(.green)
            Spacer()
            Button(action: logout) {
                Text("Logout")
                }.foregroundColor(.purple).padding(7)
            }.padding(25)
    }
    
    func doCredentialsMatch() -> Bool {
        // check if typed credentials match stored credentials
        
        let storedEncryptedPassword = UserDefaults.standard.string(forKey: "encryptedPassword") ?? ""
        
        do {
            let decryptedPassword = try storedEncryptedPassword.decrypt(key: key, iv: iv)
            print("Successfully decrypted password.")
            return (typedPassword == decryptedPassword)
        } catch {
            print("Could not decrypt password.")
            return false
        }
    }
    
    func dismissAlert() {
        showUsernameAlert = false
    }
    
    func encryptData() {
        //show loading
        
//        let users = UserDefaults.standard.dictionary(forKey: "users") ?? [:]
//        availableUsers = users.keys.map({ String($0) })
        
        // encrypt data, store in NS defaults
        do {
            let encryptedPassword = try typedPassword.encrypt(key: key, iv: iv)
            UserDefaults.standard.set(typedPassword, forKey: "username")
            UserDefaults.standard.set(encryptedPassword, forKey: "encryptedPassword")
            print("Successfully encrypted username and password.")
        } catch {
            print("Could not encrypt username and password.")
            //                self.loadingView.isHidden = true
            //                isLoggedIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            // if doCredentialsMatch:
            // dismiss loading
            // isLoggedIn = true
        })
    }
    
    func login() {
        isLoggedIn = true
        
        if typedUsername.isEmpty {
            showUsernameAlert = true
        } else if typedPassword.isEmpty {
            Alert(title: Text("Please enter a password"))
        } else {
            encryptData()
        }
    }
    
    func signUp() {
        if typedUsername.isEmpty {
            Alert(title: Text("Please enter a username"))
        } else if typedPassword.isEmpty {
            Alert(title: Text("Please enter a password"))
        } else {
            encryptData()
        }
    }
    
    func logout() {
        isLoggedIn = false // log user out
    }
}

struct User: Equatable, Hashable, Codable, Identifiable {
    let id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
