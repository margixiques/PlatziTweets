//
//  PhotoViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 31/08/22.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class PhotoViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableview: UITableView!
    
    // MARK: - PROPERTIES
    private let cellID = "TweetsTableViewCell"
    private var dataSource = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPosts()
    
    }
    
    private func setupUI() {
        // 1. Asignar datasource
        // 2. Registrar celda
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    private func getPosts() {
        // 1. Asignar datasource
        SVProgressHUD.show()
        
        // 2. Consumir el servicio
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Tweet], ErrorResponse>) in
            // Cerramos el indicador de carga
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let posts):
                for tweet in posts {
                    if tweet.hasImage == true {
                        self.dataSource.append(tweet)
                    }
                }
                self.tableview.reloadData()
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
    
    let emailKey = UserDefaults.Keys.email.rawValue
    let storage = UserDefaults.standard
}

// MARK: - UITableViewDelegate
extension PhotoViewController: UITableViewDelegate {
     
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Guardar el correo del usuario y validar contra uno real
        return dataSource[indexPath.row].author.email == storage.string(forKey: emailKey)
    }
}


// MARK: - UITableViewDataSource
extension PhotoViewController: UITableViewDataSource {
    // nùmero total de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // Configurar celda deseada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    
        if let cell = cell as? TweetsTableViewCell {
            // configurar la celda
            cell.setupCellWith(post: dataSource[indexPath.row])
//            cell.needsToShowVideo = { url in
//                // Aquí SI deberiamos abrir un viewcontroller
//                let avPlayer = AVPlayer(url: url)
//
//                let avPlayerController = AVPlayerViewController()
//                avPlayerController.player = avPlayer
//
//                self.present(avPlayerController, animated: true) {
//                    avPlayerController.player?.play()
//                }
//            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


