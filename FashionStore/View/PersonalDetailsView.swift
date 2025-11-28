//
//  PersonalDetailsView.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 25/12/23.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct PersonalDetailsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: ProductManagerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var isImageSelected: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header
                    Text("Personal Details")
                        .font(.custom("PlayfairDisplay-Bold", size: 32).bold())
                        .foregroundStyle(Color("AccentColor2"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Profile Image Section
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color("AccentColor2").opacity(0.2))
                                .frame(width: 150, height: 150)
                            
                            if let image = viewModel.profileImage.first, let uiImage = image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .foregroundStyle(Color("AccentColor2").opacity(0.5))
                            }
                            
                            // Edit Image Button
                            PhotosPicker(selection: $isImageSelected, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    Circle()
                                        .fill(Color("AccentColor2"))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "camera.fill")
                                        .foregroundStyle(Color("AccentColor"))
                                        .font(.system(size: 18))
                                }
                            }
                            .offset(x: 50, y: 50)
                        }
                        
                        Text("Tap to change profile picture")
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical)
                    
                    // User Information Section
                    VStack(spacing: 20) {
                        // User Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User Name")
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundStyle(Color("AccentColor2"))
                            
                            TextField("Enter your name", text: $userName)
                                .font(.custom("PlayfairDisplay-Regular", size: 18))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Light").opacity(0.8))
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Email Field (Read-only)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundStyle(Color("AccentColor2"))
                            
                            Text(email)
                                .font(.custom("PlayfairDisplay-Regular", size: 18))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Light").opacity(0.5))
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundStyle(.gray)
                        }
                        
                        // User ID (Read-only)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User ID")
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundStyle(Color("AccentColor2"))
                            
                            if let userId = authViewModel.currentUser?.id {
                                Text(userId)
                                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("Light").opacity(0.5))
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: {
                        saveUserDetails()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                                .font(.custom("PlayfairDisplay-Bold", size: 20))
                        }
                        .foregroundStyle(Color("AccentColor"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor2"))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissView()
            }
        }
        .onAppear {
            loadUserDetails()
        }
        .onChange(of: isImageSelected) { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        }
        .alert("Profile Updated", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadUserDetails() {
        guard let auth = try? authViewModel.getAuthUser() else { return }
        userName = auth.userName ?? ""
        email = auth.email ?? ""
        
        // Load profile image if not already loaded
        if viewModel.profileImage.isEmpty {
            viewModel.getImage()
        }
    }
    
    private func saveUserDetails() {
        guard let uid = authViewModel.currentUser?.id else {
            alertMessage = "Unable to update profile. Please try again."
            showSaveAlert = true
            return
        }
        
        Task {
            do {
                // Update user data in Firestore
                let updatedUser = User(
                    id: uid,
                    userName: userName.isEmpty ? nil : userName,
                    email: email,
                    imagePath: authViewModel.currentUser?.imagePath
                )
                
                let encodedUser = try Firestore.Encoder().encode(updatedUser)
                try await Firestore.firestore()
                    .collection("user")
                    .document(uid)
                    .setData(encodedUser, merge: true)
                
                // Refresh user data
                await authViewModel.fetchUser()
                
                alertMessage = "Your profile has been updated successfully!"
                showSaveAlert = true
            } catch {
                alertMessage = "Failed to update profile: \(error.localizedDescription)"
                showSaveAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonalDetailsView()
            .environmentObject(AuthViewModel())
            .environmentObject(ProductManagerViewModel())
    }
}

