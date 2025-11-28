//
//  SettingsView.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 20/10/23.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: ProductManagerViewModel
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled: Bool = false
    @ObservedObject var LogicVM : LoginRegisterViewModel
    

    @Environment(\.presentationMode) var presentationMode
    @State var showLogin: Bool = false
    @State private var isImageSelected: PhotosPickerItem? = nil
    @State var imageData: Data? = nil
    @State var userName: String = ""
    @State private var email: String = ""
    @State var retriveImage: [UIImage] = []
    
    var body: some View {
        ZStack {
            Color(Color("AccentColor"))
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("AccentColor").opacity(0.8))
                        .shadow(radius: 15, x: 5, y: 10)
                        .frame(width: 360, height: 120)
                }
                .overlay(
                    HStack {
                        ForEach(viewModel.profileImage.prefix(1), id: \.self) { image in
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(20)
                            } else {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(20)
                            }
                            
                        }
                        Button(action: {
                            if isImageSelected != nil {
                                viewModel.profileImage.removeAll()
                                viewModel.profileImage.append(retriveImage[0])
                            }
                        }, label: {
                            
                                ZStack {
                                    PhotosPicker(selection: $isImageSelected, matching: .images, photoLibrary: .shared()){
                                        Image(systemName: "pencil.line")
                                            .foregroundStyle(Color(isDarkModeEnabled ? "Light" : "Dark"))
                                            .font(.footnote).bold()
                                    }
                                }
                            
                            .padding()
                            .frame(width: 25, height: 25)
                            .background(Color("AccentColor").opacity(0.8))
                            .cornerRadius(7)
                        })
                        .offset(x: -20, y: 40)
                        
                        VStack(alignment: .leading) {
                            TextField("userName", text: $userName)
                                .font(.custom("PlayfairDisplay-Regular", size: 25)).bold()
                            Text(email).opacity(0.4)
                                .font(.custom("PlayfairDisplay-Regular", size: 18)).bold()
                        }
                    }
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .padding(.top)
                ScrollView(showsIndicators: false) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("AccentColor").opacity(0.8))
                                .frame(width: 360, height: 350)
                        }
                        .overlay {
                            VStack {
                                NavigationLink {
                                    PersonalDetailsView()
                                        .environmentObject(authViewModel)
                                        .environmentObject(viewModel)
                                } label: {
                                    SettingBTViewForNavigation(imageSF: "person.fill", title: "Personal Details")
                                }
                                NavigationLink {
                                    OrdersListView()
                                        .environmentObject(viewModel)
                                } label: {
                                    SettingBTViewForNavigation(imageSF: "bag.fill", title: "My Order")
                                }
                                NavigationLink {
                                    DeliveryAddress()
                                } label: {
                                    SettingBTViewForNavigation(imageSF: "box.truck.fill", title: "Shipping Address")
                                }
                                NavigationLink {
                                    
                                } label: {
                                    SettingBTView(imageSF: "creditcard.fill", title: "My Card", action: {})
                                }
                                HStack(spacing: 20) {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .opacity(0.3)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .overlay(
                                            HStack {
                                                Image(systemName: isDarkModeEnabled ? "moon.fill" : "sun.max.fill")
                                                    .resizable()
                                                    .frame(width: 27, height: 25)
                                            }
                                        )
                                    Text("Dark Mode")
                                        .font(.custom("PlayfairDisplay-Bold", size: 20))
                                    Spacer()
                                    Toggle("", isOn: $isDarkModeEnabled)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2).opacity(0.5))
                        .padding(35)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("AccentColor").opacity(0.8))
                                .frame(width: 360, height: 215)
                        }
                        .overlay {
                            VStack {
                                SettingBTView(imageSF: "exclamationmark.octagon.fill", title: "FAQs", action: {})
                                SettingBTView(imageSF: "checkmark.shield.fill", title: "Privacy Policy", action: {
                                    print("Order Details")
                                })
                                SettingBTView(imageSF: "gear", title: "Settings", action: {})
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2).opacity(0.5))
                    }
                    Button(action: {
                        authViewModel.signOut()
                    }, label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                                .foregroundStyle(Color("AccentColor"))
                                .font(.caption)
                            Text("LogOut").foregroundStyle(Color("AccentColor"))
                        }
                        .alert(isPresented: $authViewModel.showAlert) {
                            Alert(
                                title: Text(authViewModel.alertTittle),
                                message: Text(authViewModel.alertMessage),
                                dismissButton: .default(
                                    Text("OK"),
                                    action: {
                                        showLogin = true
                                        LogicVM.showLogin = true
                                    }
                                )
                            )
                        }
                        .frame(width: UIScreen.main.bounds.width - 23, height: 50)
                        .background(Color("AccentColor2"))
                        .cornerRadius(17)
                        .padding()
                    })
                }
                .fullScreenCover(isPresented: $showLogin) {
                    NavigationView {
                        Signin(viewModel: LogicVM)
                    }
                }
                
            }
            .onAppear {
                guard let auth = try? authViewModel.getAuthUser() else { return }
                userName = auth.userName ?? "Loading.."
                email = auth.email ?? ""
                // Load profile image if not already loaded
                if viewModel.profileImage.isEmpty {
                    viewModel.getImage()
                }
            }
            .task {
                if (authViewModel.currentUser != nil),
                   let path = authViewModel.currentUser?.imagePath {
                    let data = try? await StorageManager.shared.getData(path: path)
                    self.imageData = data
                    
                }
            }
            .onChange(of: isImageSelected) { value in
                if let value {
                    viewModel.saveProfileImage(item: value)
                }
            }
        }
    }
}



struct SettingBTView: View {
    let imageSF: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Rectangle()
                .fill(Color.gray)
                .opacity(0.3)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    HStack {
                        Image(systemName: imageSF)
                            .resizable()
                            .frame(width: 27, height: 25)
                            .foregroundStyle(Color("AccentColor2"))
                    }
                )
            Text(title)
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(Color("AccentColor2"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color("AccentColor2"))
                .padding(.trailing)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

struct SettingBTViewForNavigation: View {
    let imageSF: String
    let title: String
    
    var body: some View {
        HStack(spacing: 20) {
            Rectangle()
                .fill(Color.gray)
                .opacity(0.3)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    HStack {
                        Image(systemName: imageSF)
                            .resizable()
                            .frame(width: 27, height: 25)
                            .foregroundStyle(Color("AccentColor2"))
                    }
                )
            Text(title)
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(Color("AccentColor2"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color("AccentColor2"))
                .padding(.trailing)
        }
    }
}

struct OrdersListView: View {
    @EnvironmentObject var viewModel: ProductManagerViewModel
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea(.all)
            
            VStack {
                Text("My Orders")
                    .font(.custom("PlayfairDisplay-Bold", size: 32).bold())
                    .foregroundStyle(Color("AccentColor2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                if viewModel.orderList.isEmpty {
                    Spacer()
                    Image("Cart")
                        .resizable()
                        .frame(width: 550, height: 550)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.orderList, id: \.id) { cartProduct in
                                NavigationLink {
                                    MyOrder(product: cartProduct.product)
                                        .environmentObject(viewModel)
                                } label: {
                                    OrderCardView(cartProduct: cartProduct)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissView()
            }
        }
    }
}

struct OrderCardView: View {
    let cartProduct: CartProduct
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("Light").opacity(0.8))
                .shadow(radius: 10, x: 5, y: 10)
                .frame(width: UIScreen.main.bounds.width - 40, height: 130)
        }
        .overlay(alignment: .leading) {
            HStack(spacing: 16) {
                if let imagePath = cartProduct.product.imageName.first,
                   let url = URL(string: imagePath), imagePath.hasPrefix("http") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                } else if let imageName = cartProduct.product.imageName.first, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                } else {
                    Image("Cart")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(cartProduct.product.name)
                        .font(.custom("PlayfairDisplay-Bold", size: 20))
                        .foregroundStyle(Color("Dark"))
                    Text(cartProduct.product.suppliers)
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundStyle(.gray)
                    HStack {
                        Text("Quantity:")
                            .opacity(0.6)
                        Text("\(cartProduct.productCount)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Price:")
                            .opacity(0.6)
                        Text("$\(cartProduct.product.price)")
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

