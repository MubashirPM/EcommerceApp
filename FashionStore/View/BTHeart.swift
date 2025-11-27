//
//  BTHeart.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 15/10/23.
//

import SwiftUI

struct BTHeart: View {
    @EnvironmentObject var productManagerVM: ProductManagerViewModel
    @State var isFav: Bool = false
    var product: Product
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button {
                isFav.toggle()
                action()
                if isFav {
                    productManagerVM.addToWishlist(product: product)
                } else {
                    productManagerVM.removeFromWishlist(product: product)
                }
            } label: {
                Image(systemName: isFav ? "heart.fill" : "heart")
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
#Preview {
    BTHeart(isFav: true, product: productList[1], action: {})
        .environmentObject(ProductManagerViewModel())
        .preferredColorScheme(.dark)
}





