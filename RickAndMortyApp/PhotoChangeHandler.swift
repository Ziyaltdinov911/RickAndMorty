//
//  PhotoChangeHandler.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 11.08.2024.
//

import UIKit
import AVFoundation
import Photos

class PhotoChangeHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private weak var viewController: UIViewController?
    private let imageView: UIImageView

    init(viewController: UIViewController, imageView: UIImageView) {
        self.viewController = viewController
        self.imageView = imageView
    }

    func handleChangePhotoTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Настраиваем заголовок
        let titleString = "Загрузите изображение"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        let attributedTitle = NSAttributedString(string: titleString, attributes: titleAttributes)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        
        // Настраиваем действия
        let cameraAction = UIAlertAction(title: "Камера", style: .default) { [weak self] _ in
            self?.requestCameraPermissions()
        }
        let galleryAction = UIAlertAction(title: "Галерея", style: .default) { [weak self] _ in
            self?.requestPhotoLibraryPermissions()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        viewController?.present(alertController, animated: true)
    }

    private func requestCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.presentImagePicker(sourceType: .camera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.presentImagePicker(sourceType: .camera)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAccessDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            self.showAccessDeniedAlert()
        @unknown default:
            break
        }
    }

    private func requestPhotoLibraryPermissions() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            self.presentImagePicker(sourceType: .photoLibrary)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized || status == .limited {
                    DispatchQueue.main.async {
                        self?.presentImagePicker(sourceType: .photoLibrary)
                    }
                } else {
                    self?.showAccessDeniedAlert()
                }
            }
        case .denied, .restricted:
            self.showAccessDeniedAlert()
        @unknown default:
            break
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        viewController?.present(imagePicker, animated: true)
    }

    private func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Доступ запрещён", message: "Пожалуйста, разрешите доступ в настройках", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        viewController?.present(alert, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            // Сохранение изображения, если нужно
            // Например, сохранение в UserDefaults или файловую систему
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
