//
//  LoginView.swift
//  RSApp
//
//  Created by Augustin Diabira on 18/12/2022.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var alert = false
    @State var createAccount = false
    @State var showError = false
    @State var errorMsg = ""
    
  
    var body: some View {
        VStack {
            Text("Sign In").font(.largeTitle.bold()).abscisse(.leading)
            
            Text("It's great to see you again. Hope you've been doin well").font(.title3).abscisse(.leading).padding(.bottom)
            
          
            TextField("here we go", text: $email).padding().background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
                Divider()
            SecureField("Password here ", text: $password).padding().background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            
            
           
            VStack {
                Button {
                    alert.toggle()
                    
                } label: {
                    Text("Reset Password ? ").abscisse(.leading).foregroundColor(alert ? .purple:.black)
                   
            }.alert("Link sent", isPresented: $alert) {}
                Button {
                    loginUser()
                } label: {
                    Text("Sign In").foregroundColor(.white).abscisse(.center).buttoncustom( .black)
                }.padding(10)
            }
            
            HStack {
                Text("Don't have an account yet ?").foregroundColor(.gray)
                Button {
                    createAccount.toggle()
                } label: {
                    Text("Register Now").fontWeight(.bold).foregroundColor(.black)
                }

            }.ordonnee(.bottom)
                .font(.callout)
            
            
                

             
        }.ordonnee(.top)
            .padding(15).fullScreenCover(isPresented: $createAccount) {                SignUPView()
            }.alert(errorMsg, isPresented: $showError) {}
    }
    func loginUser() {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User:\(email) found")
            }catch {
               await displayErrorMsg(error)
            }
        }
    }
    func displayErrorMsg(_ error: Error)async {
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }

}

struct SignUPView: View {
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @Environment(\.dismiss) var dismiss
    @State var alert = false
    @State var userbio = ""
    @State var userProfilePic:Data?
    @State var showImagePicker = false
    @State var photoItem:PhotosPickerItem?
    @State var showError = false
    @State var errorMsg = ""
  
    var body: some View {
        VStack {
            Text("Sign UP").font(.largeTitle.bold()).abscisse(.leading)
            
            Text("It's great to see new faces here. Do not be shy and join us in this great journey.").font(.title3).abscisse(.leading).padding(.bottom)
            
          
           
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false){
                    AdjustView()
                }
                AdjustView()
            }
            
           
            VStack {
                
                Button {
                    registerAccount()
                } label: {
                    Text("Sign UP").foregroundColor(.white).abscisse(.center).buttoncustom( .black)
                }.disablewithOpacity(username == "" || userbio == "" || email == "" || password == "" || userProfilePic == nil).padding(10)
                    
            }
            
            HStack {
                Text("Already have an account ?").foregroundColor(.gray)
                Button {
                    dismiss()
                } label: {
                    Text("Sign In").fontWeight(.bold).foregroundColor(.black)
                }

            }.ordonnee(.bottom)
                .font(.callout)
            
            
                

             
        }.ordonnee(.top)
            .padding(15)
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem) { newValue in
                if let newValue {
                    Task {
                        do {
                            guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                            
                            await MainActor.run(body: {
                                userProfilePic = imageData
                            })
                        }catch {
                            
                        }
                    }
                }
            }.alert(errorMsg,isPresented: $showError) {
                
            }
       
    }
    func registerAccount(){
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                
                //Upload profile pic in firestore
                guard let userID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePic else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userID)
                let _ = try await storageRef.putDataAsync(imageData )
                // Download URL
                let downloadUrl = try await storageRef.downloadURL()
                //Create Firestore Object
                let user = User(username: username, userbio: userbio, userProfileURL: downloadUrl, userEmail: email, userUID: userID)
                //Saving into Firestore
                let _ =  try Firestore.firestore().collection("Users").document(userID).setData(from: user,completion: { Err in
                    if Err == nil {
                        print("Saved successfully")
                    }
                })
            }catch {
              await  displayErrorMsg(error)
            
            }
        }
    }
    func displayErrorMsg(_ error: Error)async {
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }
    @ViewBuilder
    func AdjustView()->some View {
        VStack (spacing: 12){
            
            ZStack {
                if let userProfilePic, let image = UIImage(data: userProfilePic){
                    Image(uiImage: image).resizable().aspectRatio( contentMode: .fill)
                }else {
                    Image( "billGates").resizable().aspectRatio(contentMode: .fill)
                }
            }.frame(width: 85, height: 85)
                .clipShape(Circle())
                .onTapGesture {
                    showImagePicker.toggle()
                }
                .contentShape(Circle())
            TextField("username", text: $username).padding().textContentType(.username).background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2))
            TextField("email", text: $email).padding().background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            Divider()
            SecureField("Password here ", text: $password).padding().textContentType(.password).background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            
            TextField("type your bio right here", text: $userbio, axis: .vertical).padding().frame(minHeight: 100).textContentType(.emailAddress).background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    
    func disablewithOpacity(_ condition: Bool) -> some View {
        self.disabled(condition).opacity(condition ? 0.6:1 )
    }
    func abscisse(_ alignment: Alignment) -> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
        
    }
    
    func ordonnee(_ alignment: Alignment)-> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func buttoncustom(_ color: Color)-> some View {
        self.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(color))
        
        
    }
    
}

