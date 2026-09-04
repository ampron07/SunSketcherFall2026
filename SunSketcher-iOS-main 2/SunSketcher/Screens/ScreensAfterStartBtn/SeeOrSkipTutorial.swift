//
//  SeeOrSkipTutorial.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 2/9/24.
//  Rewritten by Kedenburg, Emily on 4/22/26.
//

import SwiftUI

struct SeeOrSkipTutorial: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("FromSeeTutorial") private var fromSeeTutorial = false
    @AppStorage("Close skiptutorial") private var closeSkipTutorial = false

    @Binding var shouldRefreshView: Bool

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height

                ZStack {
                    backgroundLayer(width: width, height: height)
                    contentLayer(width: width, height: height)
                    logoLayer(width: width, height: height)
                }
                .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                if fromSeeTutorial || closeSkipTutorial {
                    fromSeeTutorial = false
                    closeSkipTutorial = false
                    // dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private func backgroundLayer(width: CGFloat, height: CGFloat) -> some View {
        Color(red: 0.04, green: 0.04, blue: 0.03)
            .overlay {
                Image("img-eclipse")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: width * 1.18,
                        height: height * 1.02
                    )
                    .clipped()
                    .offset(y: height * 0.16)
            }
    }

    @ViewBuilder
    private func logoLayer(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Spacer pushes logo down to sit right above the white line
            Spacer()
                .frame(height: height * 0.13)

            Image("img-logo")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.75)

            Spacer()
        }
    }

    @ViewBuilder
    private func contentLayer(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.white
                .frame(height: max(2, height * 0.004))
                .padding(.top, height * 0.18)

            ZStack {
                Color.black.opacity(0.4)

                VStack(spacing: height * 0.045) {
                    Spacer(minLength: height * 0.06)

                    Text("Are you sure you want to skip the tutorial?")
                        .font(.custom("Montserrat", size: min(width * 0.09, 34)).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(maxWidth: width * 0.8)

                    VStack(spacing: height * 0.03) {
                        NavigationLink {
                            TutorialScreen1(shouldRefreshView: $shouldRefreshView)
                        } label: {
                            actionButtonLabel(
                                title: "See tutorial",
                                width: width,
                                height: height,
                                fillColor: Color(red: 0.05, green: 0.58, blue: 0)
                            )
                        }

                        NavigationLink {
                            LocationVerification()
                                .onAppear {
                                    fromSeeTutorial = true
                                }
                        } label: {
                            actionButtonLabel(
                                title: "Skip tutorial",
                                width: width,
                                height: height,
                                fillColor: Color(red: 0.47, green: 0, blue: 0)
                            )
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, width * 0.1)
                .padding(.vertical, height * 0.05)
            }
            .frame(height: height * 0.8)
            .padding(.top, 0)

            Color.white
                .frame(height: max(2, height * 0.004))
        }
    }

    @ViewBuilder
    private func actionButtonLabel(
        title: String,
        width: CGFloat,
        height: CGFloat,
        fillColor: Color
    ) -> some View {
        Text(title)
            .font(.custom("Montserrat", size: min(width * 0.09, 34)))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: max(56, height * 0.1))
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: width * 0.04))
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.04)
                    .stroke(Color.white, lineWidth: width * 0.008)
            )
            .contentShape(RoundedRectangle(cornerRadius: width * 0.04))
    }
}

#Preview {
    SeeOrSkipTutorial(shouldRefreshView: .constant(false))
}
