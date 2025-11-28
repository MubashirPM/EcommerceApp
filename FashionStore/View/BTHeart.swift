//
//  BTHeart.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 15/10/23.
//

import SwiftUI

struct BTHeart: View {
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    var product: Product
    let action: () -> Void
    
    private var isInWishlist: Bool {
        productManagerVM.isInWishlist(product: product)
    }

    var body: some View {
        HStack {
            Spacer()
            Button {
                action()
                if isInWishlist {
                    productManagerVM.removeFromWishlist(product: product)
                } else {
                    productManagerVM.addToWishlist(product: product)
                }
            } label: {
                Image(systemName: isInWishlist ? "heart.fill" : "heart")
                    .font(.system(size: 17))
                    .foregroundStyle(Color("AccentColor2"))
                    .cornerRadius(50)
                    .padding(7)
                    .background(Circle())
                    .foregroundStyle(Color("AccentColor"))
            }
        }
    }
}
//#Preview {
//    BTHeart(isFav: true, product: productList[1], action: {})
//        .environmentObject(ProductManagerViewModel())
//        .preferredColorScheme(.dark)
//}
//
//



