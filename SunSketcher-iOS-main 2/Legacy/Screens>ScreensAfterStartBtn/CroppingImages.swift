//
//  CroppingImages.swift
//  Sunsketcher
//
//  Created by Tameka Ferguson on 2/13/24.
//

// This view is never seen because the images are cropped in seconds.

import SwiftUI

struct CroppingImages: View {
    @State private var imageCropping = ImageCropping()
    @State var croppingComplete = false
    
    var body: some View {
        if !croppingComplete {
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
                                    
                                    Text("Processing images...")
                                      .font(
                                        Font.custom("Oswald", size: geo.size.width * 0.09)
                                          .weight(.semibold)
                                      )
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(.white)
                                      .frame(width: geo.size.width * 1, alignment: .center)
                                      .offset(x: 0, y: geo.size.height * 0.11)
                                    
                                    
                                    Text("This may take up to two minutes. Please do not close the SunSketcher app.")
                                      .font(
                                        Font.custom("Oswald", size: geo.size.width * 0.09)
                                          .weight(.semibold)
                                      )
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(.white)
                                      .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.5, alignment: .center)
                                    
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
                    imageCropping.cropImages()
                    croppingComplete = true
                }
                
            }// Geometry reader
        } else {
            SharePicsView()
        }
    }
    
}

struct SharePicsView: View {
    var body: some View {
        SharePhotos()
    }
    
}


#Preview {
    CroppingImages()
}
