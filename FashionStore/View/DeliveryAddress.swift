//
//  DeliveryAddress.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 27/10/23.
//

import SwiftUI

struct DeliveryAddress: View {
    
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    @EnvironmentObject var addressVM: AddressViewModel
//    @StateObject var addressVM: AddressViewModel = AddressViewModel()
    
    @State private var showOrderSummary = false
    @State private var showRazorPayView = false
    @State private var showEmptyCartAlert = false
    
    @State var showAddAddressView = false
    @State var enableEditAddress = false
    @State var tappedAddress = AddressModel()
    
    var body: some View {
        ZStack {
            Color("AccentColor").ignoresSafeArea(.all)
            VStack {
                if addressVM.addressArray.isEmpty {
                    ContentUnavailableView("No address found", systemImage: "location.fill")
                        .foregroundStyle(Color("AccentColor2"))
                } else {
                    ScrollView(showsIndicators: false) {
                        ForEach(0..<addressVM.addressArray.count, id: \.self) { index in
                            let element = addressVM.addressArray[index]
                            VStack(alignment: .leading) {
                                Text("Delivery Address")
                                    .foregroundStyle(Color("AccentColor2"))
                                    .font(.custom("PlayfairDisplay-Bold", size: 32).bold())
                                    .padding(.bottom, 10)
                                addressCard(for: element)
                                Text("Product List")
                                    .font(.custom("PlayfairDisplay-Regular", size: 26).bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                ForEach(productManagerVM.cartProducts) { item in
                                    ProductListView(product: item.product)
                                }
                            }
                        }
                    }
                    Spacer()
                    checkoutActions
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissView()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddAddressView = true
                    enableEditAddress = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.caption)
                        .padding(7)
                        .foregroundStyle(Color("Dark"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 1)
                                .fill(Color("AccentColor2"))
                        )
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showAddAddressView) {
            AddressEditing(addressViewModel: AddressViewModel(), enableEditAddress: $enableEditAddress, showAddAddressView: $showAddAddressView, tappedAddress: $tappedAddress)
        }
        .sheet(isPresented: $showOrderSummary) {
            NavigationStack {
                Payment()
                    .environmentObject(productManagerVM)
                    .presentationDetents([.medium, .large])
            }
        }
        .fullScreenCover(isPresented: $showRazorPayView) {
            RazorPayView(productManagerViewModel: productManagerVM, totalPrice: productManagerVM.cartTotal)
        }
        .alert("Your cart is empty", isPresented: $showEmptyCartAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add a product before placing an order.")
        }
    }
    
    private func addressCard(for address: AddressModel) -> some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("AccentColor").opacity(0.1))
                    .frame(width: 360, height: 280)
                    .shadow(radius: 5, x: 5, y: 5)
            }
            .overlay {
                VStack(alignment: .leading, spacing: 8) {
                    addressRow(title: "Name", value: address.name)
                    addressRow(title: "Building", value: address.buildingName)
                    addressRow(title: "Landmark", value: address.landmark)
                    addressRow(title: "Street", value: address.street)
                    addressRow(title: "City, State", value: "\(address.city), \(address.state)")
                    addressRow(title: "Country", value: address.country)
                    addressRow(title: "Phone Number 1", value: address.phoneNumber1)
                    addressRow(title: "Phone Number 2", value: address.phoneNumber2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 2).opacity(0.5))
        .padding()
        .padding(.leading, 0)
    }
    
    private func addressRow(title: String, value: String?) -> some View {
        let displayValue = (value?.isEmpty == false) ? value! : "N/A"
        return HStack {
            Text("\(title): ")
                .font(.custom("PlayfairDisplay-Bold", size: 20).bold())
                .foregroundStyle(Color("AccentColor2"))
            Text(displayValue)
                .font(.custom("PlayfairDisplay-Regular", size: 18).bold())
                .foregroundStyle(.gray)
        }
    }
    
    private var checkoutActions: some View {
        HStack {
            Button {
                if productManagerVM.cartProducts.isEmpty {
                    showEmptyCartAlert = true
                } else {
                    showOrderSummary = true
                }
            } label: {
                VStack(alignment: .leading) {
                    Text("Total Price")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .opacity(0.6)
                    Text("$\(productManagerVM.cartTotal)")
                        .font(.title)
                        .fontWeight(.heavy)
                }
                .foregroundStyle(Color("AccentColor2"))
            }
            Spacer()
            Button {
                if productManagerVM.cartProducts.isEmpty {
                    showEmptyCartAlert = true
                } else {
                    showRazorPayView = true
                }
            } label: {
                HStack {
                    Image(systemName: "bag.fill")
                    Text("Place Order")
                }
                .padding(15)
                .foregroundStyle(Color("AccentColor"))
                .background(Color("AccentColor2"))
                .clipShape(Capsule())
            }
        }
        .padding()
        .padding(.horizontal, 10)
    }
}

#Preview {
    DeliveryAddress()
        .environmentObject(AddressViewModel())
        .environmentObject(ProductManagerViewModel())
}

struct ProductListView: View {
    
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    
    var product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("Light").opacity(0.1))
                    .frame(width: 320, height: 75)
                    .shadow(radius: 5, x: 5, y: 5)
                
            }
            .overlay {
                VStack {
                    HStack(spacing: 20) {
                        ForEach(product.imageName, id: \.self){ image in
                            if let url = URL(string: image) {
                                AsyncImage(url: url) { img in
                                    img
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.custom("PlayfairDisplay-Regular", size: 15).bold())
                                .foregroundStyle(Color("AccentColor2"))
                            Text(product.suppliers)
                                .foregroundStyle(.gray)
                                .font(.custom("PlayfairDisplay-Regular", size: 15).bold())
                            Text("$\(product.price)")
                                .foregroundStyle(Color("AccentColor2"))
                                .font(.title3)
                                .fontWeight(.bold)
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            productManagerVM.cartProducts
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 2).opacity(0.5))
        .padding(.leading)
    }
}
