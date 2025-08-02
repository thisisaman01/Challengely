//
//  ShareCardView.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import SwiftUI

struct ShareCardView: View {
    let challenge: Challenge
    let streak: Int

    var body: some View {
        ZStack {
            LinearGradient(colors: [DS.Colors.primary, DS.Colors.success],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(spacing: 24) {
                Text("🔥 Day \(streak) Streak!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                
                VStack(spacing: 12) {
                    Text(challenge.title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(challenge.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                Spacer()
                
                HStack {
                    Image("AppLogo").resizable()
                        .frame(width: 40, height: 40)
                    Text("Challengely")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 48)
            .padding(.horizontal, 32)
        }
        .frame(width: 340, height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}
