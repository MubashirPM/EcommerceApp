//
//  MyCart.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 25/10/23.
//

import SwiftUI

struct MyCart: View {
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    //    @StateObject var addressVM = AddressViewModel()
    @EnvironmentObject var addressVM: AddressViewModel
    
    var product: Product
    
    @State private var totalPrice: Double = 0
    @State private var promoCode: String = ""
    @Binding var isFav: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AccentColor")
                    .ignoresSafeArea(.all)
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("My Cart")
                            .font(.custom("PlayfairDisplay-Bold", size: 32).bold())
                            .foregroundStyle(Color("AccentColor2"))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Cart Items
                    if productManagerVM.cartProducts.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image("Cart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                            Text("Your cart is empty")
                                .font(.custom("PlayfairDisplay-Regular", size: 20))
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(productManagerVM.cartProducts, id: \.id) { item in
                                    NavigationLink {
                                        ProductView(isFav: $isFav, product: item.product)
                                            .environmentObject(productManagerVM)
                                    } label: {
                                        CartItemView(product: item.product)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    // Bottom Section - Only show if cart has items
                    if !productManagerVM.cartProducts.isEmpty {
                        VStack(spacing: 12) {
                            // Promo Code Section
                            HStack {
                                TextField("Promo Code", text: $promoCode)
                                    .padding(.leading, 16)
                                    .foregroundColor(.gray)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                
                                Button(action: {
                                    // Apply promo code logic here
                                }) {
                                    Text("Apply")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("AccentColor"))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color("AccentColor2"))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Total Price
                            HStack {
                                Text("Total:")
                                    .font(.system(size: 20).bold())
                                    .foregroundStyle(Color("Dark"))
                                Spacer()
                                Text("$\(productManagerVM.cartTotal)")
                                    .font(.system(size: 22).bold())
                                    .foregroundStyle(Color("Dark"))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            
                            // Proceed to Pay Button
                            NavigationLink {
                                DeliveryAddress()
                                    .environmentObject(addressVM)
                            } label: {
                                HStack {
                                    Text("Proceed to Pay")
                                        .font(.system(size: 20).bold())
                                        .foregroundStyle(Color("AccentColor"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("AccentColor2"))
                                .cornerRadius(15)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                        .background(Color("AccentColor"))
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}


#Preview {
    MyCart(product: productList[1], isFav: .constant(false))
        .environmentObject(ProductManagerViewModel())
        .environmentObject(AddressViewModel())
}
#Preview {
    MyCart(product: productList[1], isFav: .constant(false))
        .environmentObject(ProductManagerViewModel())
        .environmentObject(AddressViewModel())
        .preferredColorScheme(.dark)
}
struct CartItemView: View {
    var product: Product
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color("Light").opacity(0.8))
                    .shadow(radius: 5, x: 2, y: 5)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 110)
            }
            .overlay(alignment: .leading) {
                HStack(spacing: 12) {
                    // Product Image
                    productImageView
                    
                    // Product Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.custom("PlayfairDisplay-Bold", size: 20))
                            .lineLimit(2)
                            .foregroundStyle(Color("Dark"))
                        
                        Text(product.suppliers)
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                        
                        HStack {
                            Text("$\(product.price)")
                                .fontWeight(.heavy)
                                .foregroundStyle(Color("Dark"))
                            Spacer()
                            ItemQuantityView(product: product)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private var productImageView: some View {
        Group {
            if let firstImage = product.imageName.first, !firstImage.isEmpty {
                if let url = URL(string: firstImage), firstImage.hasPrefix("http") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image("Cart")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        @unknown default:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
                } else {
                    // Local image
                    Image(firstImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .clipped()
                }
            } else {
                // Fallback image
                Image("Cart")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            }
        }
    }
}
