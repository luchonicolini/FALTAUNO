//
//  Profile.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 14/12/2024.
//

import SwiftUI

struct Profile: View {
    @State private var user: String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("Email", text: $user)
            }
        }
    }
}

#Preview {
    Profile()
}

struct CircleImage: View {
    var body: some View {
        Image("M")
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.gray, lineWidth: 1)
            }
    }
}
