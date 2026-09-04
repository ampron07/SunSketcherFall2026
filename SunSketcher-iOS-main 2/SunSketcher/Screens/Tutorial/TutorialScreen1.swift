//
//  TutorialScreen1.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 2/2/24.
//

import SwiftUI

struct TutorialScreen1: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var shouldRefreshView: Bool
    
    let prefs = UserDefaults.standard
    
    let txt = "In order to ensure smooth operation, please turn on the 'Do Not Disturb' feature on your phone. You can turn it off after your images have been taken, soon after the total eclipse ends."
    
    var body: some View {
            GeometryReader { geo in
                NavigationStack{
                    
                    ZStack {
                        // For background
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(Color(red: 0.04, green: 0.04, blue: 0.03))
                            .offset(x: 0, y: 0)
                        
                        // For logo
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.14)
                            .background(
                                Image("img-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.07)
                                    .clipped()
                                
                            )
                            .offset(x: 0, y: -geo.size.height * 0.45)
                            .padding(.top, 20)
                        
                        // For eclipse image
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 1)
                            .background(
                                Image("img-eclipse")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width * 1, height: geo.size.height * 1.4)
                                
                            )
                            .offset(x: 0, y: geo.size.height * 0.22)
                        
                    
                        VStack {
                            // This is for the top white line of the background overlay
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geo.size.width, height: geo.size.height * 0.004)
                                .background(Color(red: 1, green: 1, blue: 1))
                                .padding(.top, geo.size.height * 0.11)
                            
                            ZStack {
                                // For dark somewhat clear background overlay
                                Color.black.opacity(0.4)
                                    .frame(width: geo.size.width * 1, height: geo.size.height * 0.8)
                                    .offset(x: 0, y: geo.size.height * 0.04)
                                
                                
                                VStack {
                                    
                                    ScrollView {
                                        Text("Before you start..")
                                          .font(
                                            Font.custom("Oswald", size: geo.size.width * 0.12)
                                              .weight(.bold)
                                          )
                                          .multilineTextAlignment(.center)
                                          .foregroundColor(.white)
                                          .frame(maxWidth: .infinity)
                                          .padding(.top, -geo.size.height * 0)
                                    }.frame(width: geo.size.width * 1, height: geo.size.height * 0.15, alignment: .top)
                                    /*Text("Before you start..")
                                      .font(
                                        Font.custom("Oswald", size: geo.size.width * 0.12)
                                          .weight(.bold)
                                      )
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(.white)
                                      .frame(maxWidth: .infinity)
                                      .padding(.top, -geo.size.height * 0)*/
                                    
                                    // For DND image
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.24)
                                        .background(
                                            Image("img-dndtutorial")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width * 0.73, height: geo.size.height * 0.01)
                                        ).padding(.bottom, geo.size.height * 0.06)
                                    
                                    ScrollView {
                                        Text(txt)
                                            .font(
                                                Font.custom("Montserrat", size: geo.size.width * 0.049)
                                                    .weight(.medium)
                                            )
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            //.frame(width: geo.size.width * 0.8, height: geo.size.height * 0.23, alignment: .top)
                                    }.frame(width: geo.size.width * 1, height: geo.size.height * 0.22)
                                    
                                    // For button
                                    NavigationLink(destination: TutorialScreen2(shouldRefreshView: $shouldRefreshView), label: {
                                        Image("ic-rightarrow")
                                            .frame(width: geo.size.width * 0.10, height: geo.size.width * 0.08)
                                            .padding(.leading, geo.size.width * 0.7)
                                            .offset(x: geo.size.width * 0.0, y: geo.size.height * 0.03)
                                    })
                                    
                                }// VStack
                            }// ZStack
                            .padding(.top, geo.size.width * 0.01)
                            
                            // This is for the bottom white line of the background overlay
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geo.size.width, height: geo.size.height * 0.004)
                                .background(Color(red: 1, green: 1, blue: 1))
                                .padding(.top, geo.size.height * 0.028)
                        }// VStack
                        
                    }// Zstack
                }// Navigation stack
                .navigationBarBackButtonHidden()
                .onAppear {
                    if prefs.bool(forKey: "Checked") {
                        prefs.removeObject(forKey: "Checked")
                        dismiss()
                    }
                }
                
            }// Geometry reader
        }// body view
    }

struct TutorialScreen1_Previews: PreviewProvider {
    
    static var previews: some View {
        TutorialScreen1(shouldRefreshView: .constant(false))
    }
}
