//
//  ImageSelector.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import SwiftUI

/// Image and Placeholder with image picker
struct ImageSelector: View {
    
    /// Selected Image
    @Binding var image: UIImage?
    
    /// Indicates image upload progress
    @Binding var uploadProgress: Double?
    
    /// Completion handler
    let completionHandler: (() -> Void)?
    
    /// Indicate if image picker is shown
    @State var showImagePicker = false
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Init with image and upload progress binding
    init(image: Binding<UIImage?>, uploadProgress: Binding<Double?> = .constant(nil), completionHandler: (() -> Void)? = nil) {
        _image = image
        _uploadProgress = uploadProgress
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                
                // image
                VStack(spacing: 0) {
                    
                    // Image
                    if let inputImage = image {
                        Image(uiImage: inputImage)
                            .resizable()
                            .aspectRatio(inputImage.size, contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.custom.gray, lineWidth: settings.style == .default ? 4 : 2)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        
                    // No image
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .font(.system(size: geometry.size.width * 0.6, weight: settings.style == .default ? .thin : .ultraLight))
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.6)
                            .scaledToFit()
                            .offset(y: -6)
                            .foregroundColor(Color.custom.gray)
                            .overlay(
                                Circle()
                                    .stroke(Color.custom.gray, lineWidth: settings.style == .default ? 4 : 2)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    
                    // Change image text
                    if uploadProgress == nil {
                        Text("Bild ändern")
                            .foregroundColor(Color.custom.gray)
                            .font(.custom("Futura-Medium", size: geometry.size.width / 7.5))
                            .frame(width: geometry.size.width)
                            .lineLimit(1)
                            .padding(.top, 5)
                    }
                    
                }.onTapGesture {
                        if uploadProgress == nil {
                            showImagePicker = true
                        }
                    }
                    .sheet(isPresented: self.$showImagePicker) {
                        ImagePicker($image) { _, _ in
                            if let completionHandler = completionHandler { completionHandler() }
                        }
                    }
                
                // remove image button
                if image != nil && uploadProgress == nil {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.custom.red)
                        .font(.system(size: geometry.size.width / 3, weight: settings.style == .default ? .light : .thin))
                        .padding(.leading, geometry.size.width / 10)
                        .onTapGesture {
                            withAnimation {
                                image = nil
                            }
                        }
                }
            }
            
        }
    }
}

/// Pickes an image from photo library
struct ImagePicker: UIViewControllerRepresentable {
    
    /// Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Selected Image
    @Binding var image: UIImage?
    
    /// Completion handler
    let completionHandler: ((UIImage, Bool) -> ())?
    
    init(_ image: Binding<UIImage?>, completionHandler: ((UIImage, Bool) -> ())? = nil) {
        self._image = image
        self.completionHandler = completionHandler
    }
    
    /// Image Picker Coordinator
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        /// Image picker
        let parent: ImagePicker
        
        /// Completion handler
        let completionHandler: ((UIImage, Bool) -> ())?
        
        init(_ parent: ImagePicker, completionHandler: ((UIImage, Bool) -> ())?) {
            self.parent = parent
            self.completionHandler = completionHandler
        }
        
        /// delegation function
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let isFirstImage = parent.image == nil
                parent.image = uiImage
                if let completionHandler = completionHandler { completionHandler(uiImage, isFirstImage) }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// make coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self, completionHandler: completionHandler)
    }
    
    /// make controller
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    /// update controller
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

