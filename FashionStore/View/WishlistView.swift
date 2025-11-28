//
//  WhishlistView.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 30/10/23.
//

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    var product: Product
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Wishlist")
                        .font(.custom("PlayfairDisplay-Bold", size: 32).bold())
                        .foregroundStyle(Color("AccentColor2"))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Search Bar
                SearchBar()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Wishlist Items
                if productManagerVM.wishlistProducts.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image("Cart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        Text("Your wishlist is empty")
                            .font(.custom("PlayfairDisplay-Regular", size: 20))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(productManagerVM.wishlistProducts, id: \.id) { item in
                                WhishlistCardView(product: item.product)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Total Price
                        HStack {
                            Text("Total:")
                                .font(.custom("PlayfairDisplay-Bold", size: 20))
                            Text("$\(productManagerVM.wishlistTotal)")
                                .font(.custom("PlayfairDisplay-Bold", size: 20))
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WishlistView(product: productList[0])
        .environmentObject(ProductManagerViewModel())
}

struct WhishlistCardView: View {
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    var product: Product
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 17)
                .fill(Color("Light").opacity(0.8))
                .shadow(radius: 5, x: 1, y: 1)
                .frame(width: UIScreen.main.bounds.width - 30, height: 110)
        }
        .overlay(alignment: .leading) {
            HStack(spacing: 12) {
                // Product Image
                productImageView
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.name)
                            .font(.custom("PlayfairDisplay-Bold", size: 20))
                            .lineLimit(2)
                            .foregroundStyle(Color("Dark"))
                        Spacer()
                        BTHeart(product: product, action: {})
                            .environmentObject(productManagerVM)
                    }
                    
                    Text(product.suppliers)
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack {
                        Text("$\(product.price)")
                            .fontWeight(.heavy)
                            .foregroundStyle(Color("Dark"))
                        Spacer()
                        Button {
                            productManagerVM.addtoCart(product: product)
                            productManagerVM.removeFromWishlist(product: product)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "bag")
                                Text("Add to Cart")
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(Color("Light"))
                            .background(Color("Dark"))
                            .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
#Preview {
    WhishlistCardView(product: productList[1])
}
