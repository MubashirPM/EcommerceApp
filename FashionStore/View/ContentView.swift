//
//  ContentView.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 21/10/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                TabBar()
            } else {
                OnBoardingTapView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
