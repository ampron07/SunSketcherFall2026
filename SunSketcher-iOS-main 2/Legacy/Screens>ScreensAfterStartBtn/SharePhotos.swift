//
//  SharePhotos.swift
//  Sunsketcher
//
//  Created by Ferguson, Tameka on 2/9/24.
//

import SwiftUI

struct SharePhotos: View {
    @Environment(\.dismiss) private var dismiss
    let prefs = UserDefaults.standard
    let metadataArray = MetadataDB.shared.retrieveImageMeta()
    @StateObject private var viewModel = AppViewModel()
    
    
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
                                
                                Text("Ok to Share Photos?")
                                  .font(
                                    Font.custom("Oswald", size: geo.size.width * 0.09)
                                      .weight(.semibold)
                                  )
                                  .multilineTextAlignment(.center)
                                  .foregroundColor(.white)
                                  .frame(width: geo.size.width * 1, alignment: .top)
                                
                                ScrollView {
                                    Text("Scroll left and right for more images.\nThey might look a little boring, but they can still be valuable to us! ")
                                      .font(
                                        Font.custom("Montserrat", size: geo.size.width * 0.04)
                                          .weight(.light)
                                      )
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(.white)
                                      .frame(maxWidth: .infinity)
                                }.frame(width: geo.size.width * 0.9, height: geo.size.height * 0.1)
                                
                                
                                // Cropped Image display
                                ScrollView(.horizontal) {
                                    LazyHStack(spacing: 5) {
                                        ForEach(metadataArray, id: \.id) { metadata in
                                            if let image = loadImageFromPath(filepath: metadata.filepath) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geo.size.width * 1, height: geo.size.height * 0.3) 
                                                    .padding()
                                            }
                                        }
                                        
                                        
                                        // TODO: remove for actual release
                                        /*ForEach(0..<images.count, id: \.self) { index in Image(images[index])
                                         .resizable()
                                         .scaledToFit()
                                         .frame(width: geo.size.width * 1, height: geo.size.height * 0.3)
                                         .padding()
                                         }*/
                                    }
                                }.frame(width: geo.size.width * 1, height: geo.size.height * 0.34)
                                
                                // For buttons
                                NavigationLink(destination: YesSharePhotosResponse(), label: {
                                    Text("Yes")
                                        .font(Font.custom("Montserrat", size: geo.size.width * 0.14))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.09)
                                        .background(Color(red: 0.05, green: 0.58, blue: 0))
                                        .clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                        .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                            .inset(by: -geo.size.width * 0.01)
                                            .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                                })
                                .frame(width: geo.size.width * 0.62, height: geo.size.height * 0.16)
                                
                                
                                NavigationLink(destination: ReaffirmNoDecision(), label: {
                                    Text("No")
                                        .font(Font.custom("Montserrat", size: geo.size.width * 0.09))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: geo.size.width * 0.4, height: geo.size.height * 0.065)
                                        .background(Color(red: 0.47, green: 0, blue: 0))
                                        .clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.04))
                                        .overlay(RoundedRectangle(cornerRadius: geo.size.width * 0.04)
                                            .inset(by: -geo.size.width * 0.01)
                                            .strokeBorder(.white, lineWidth: geo.size.width * 0.008))
                                }).frame(width: geo.size.width * 0.62, height: geo.size.height * 0.07)
                                
                                
                            }// VStack
                        }// ZStack
                        .padding(.top, geo.size.width * 0.01)
                        
                        // This is for the bottom white line of the background overlay
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: geo.size.width, height: geo.size.height * 0.004)
                            .background(Color(red: 1, green: 1, blue: 1))
                            .padding(.top, geo.size.height * 0.025)
                    }// VStack
                    
                }// Zstack
            }// Navigation stack
            .navigationBarBackButtonHidden()
            .onAppear {
                // I am setting these so that if the app is closed and reopened it will take the user to the correct screen they
                // should be on.
                //viewModel.SharePhotosScreen = true
            }
            
        }// Geometry reader
    }
    
    func loadImageFromPath(filepath: String) -> UIImage? {
        print("Loading image from path: \(filepath)\n")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documents Directory: \(documentsDirectory)")
        
        let appendPath1 = filepath.components(separatedBy: "/Documents/")
        print("Append path: \(appendPath1[1])")
        
        let newFilepath = documentsDirectory.appendingPathComponent(appendPath1[1])
        print("New filepath: \(newFilepath)\n")
        
        let newPathString = "\(newFilepath.relativePath)"
        print("New filepath as a string: \(newPathString)")
        
        MetadataDB.shared.updateImageFilepathOnly(filepath: filepath, newFilepath: newPathString)
        
        for metadata in metadataArray {
            print("ID: \(metadata.id), Filepath: \(metadata.filepath)")
        }
        
        guard let image = UIImage(contentsOfFile: newPathString) else {
            print("Image not found at path: \(newPathString)")
            
            return nil
        }
        return image
    }
    
    


    
    
}



#Preview {
    SharePhotos()
}
