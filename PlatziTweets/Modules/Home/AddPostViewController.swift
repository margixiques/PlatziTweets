//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 22/08/22.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices


enum MediaType {
    case photo
    case video
}

extension MediaType {
    var contentType: String {
        switch self {
        case .photo:
            return "image.jpg"
        case .video:
            return "video/MP4"
        }
    }
    
    var folderPath: String {
        // 5. Crear nombre de la imagen al subir
        let mediaName = Int.random(in: 100...1000)
        switch self {
        case .photo:
            return "fotos-tweets/\(mediaName).jpg"
        case .video:
            return "video-tweets/\(mediaName).mp4"
        }
    }
}

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func openCameraAction() {
        let alert = UIAlertController(title: "Cámara",
                                      message:"Selecciona una opción",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.mediaType = .photo
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.mediaType = .video
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { _ in
            self.mediaType = nil
        }))
        
        present(alert, animated: true, completion: nil)
        
        openCamera()
    }
    
    // 1. Asegurarnos de que la foto exista
    // 2. Comprimir la imagen y convertirla en Data
    private func getMediaData() -> Data? {
        switch mediaType {
        case .photo:
            return previewImageView.image?.jpegData(compressionQuality: 0.1)
        case .video:
            return try? Data(contentsOf: currentVideoURL ?? URL(fileURLWithPath: ""))
        case .none:
            return nil
        }
    }
    
    @IBAction func addPostAction() {
        guard let mediaType = mediaType,
            let mediaData = getMediaData()
        else { return }
        
        
//        uploadVideoToFirebase()
        
        uploadMediaToFirebase(media: mediaType, data: mediaData)
        
        //openVideoCamera()
        //uploadPhotoToFirebase()
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL
        else {
            return
        }
        let avPlayer = AVPlayer(url: currentVideoURL)
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    
    var mediaType: MediaType?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoButton.isHidden = true
    }
    
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.cameraFlashMode = .off
        imagePicker.cameraCaptureMode = .video
        imagePicker.videoQuality = .typeMedium
        imagePicker.videoMaximumDuration = TimeInterval(5)
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    private func openCamera() {
        
        imagePicker = UIImagePickerController()
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.cameraCaptureMode = .photo
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    private func uploadMediaToFirebase(media: MediaType, data: Data) {
        
        SVProgressHUD.show()
        
        // 3. Configuración para guardar la foto en el Firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = media.contentType
        
        // 4. Referencia al storage de firebase
        let storage = Storage.storage()
        
        // 6. Referencia a la caperta donde se va a guaradr la foto
        let folderReference = storage.reference(withPath: media.folderPath)
        
        // 7. Subir la foto a Firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(data, metadata: metaDataConfig) { metaData, error in
                
                DispatchQueue.main.async {
                    //Detener la carga
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        NotificationBanner(title: "Error",
                                           subtitle: error.localizedDescription,
                                           style: .warning).show()
                        return
                    }
                    
                    //obtener la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageURL: downloadUrl, videoURL: nil)
                    }
                }
            }
        }
        
    }
    
    private func savePost(imageURL: String?, videoURL: String?) {
        
        // 1. Crear request
        guard let post = postTextView.text, !post.isEmpty
        else {
            NotificationBanner(title: "Verifica",
                               subtitle: "Por favor ingresa un texto",
                               style: .warning).show()
            
            return
        }
        
        let request = PostRequest(text: postTextView.text,
                                  imageUrl: imageURL,
                                  videoUrl: videoURL,
                                  location: nil)
        
        // 2. Indicar carga al usuario
        SVProgressHUD.show()
        
        // 3. LLamar al servicio del post
        SN.post(endpoint: Endpoints.post,
                model: request) { (response: SNResultWithEntity<Tweet, ErrorResponse>) in
            
            //4. Cerrar indicador de carga
            SVProgressHUD.dismiss()
            
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
                
            case .error(let error):
                NotificationBanner(title: "Error",
                                   subtitle: error.localizedDescription,
                                   style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(title: "Intentalo de nuevo",
                                   subtitle: entity.error,
                                   style: .warning).show()
            }
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Close camera
        imagePicker?.dismiss(animated: true, completion: nil)
        
        // Capturar la imagen
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            
            //Obtenemos la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        // Obtain video from URL
        if info.keys.contains(.mediaURL),
           let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoUrl
        }
    }
}
