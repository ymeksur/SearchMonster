//
//  DetailViewController.swift
//  SearchMonster
//
//  Created by Y. Murat EKSÜR on 24.03.2022.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    var contentId = 0
    var parsedJson: ApiResult?
    var contentUrlString: String?
    var previewUrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(contentId)")
        fetchData(from: url!)
    }
    
    
    // MARK: - HELPERS
    func fetchData(from url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            do {
                let result = try JSONDecoder().decode(ApiResult.self, from: jsonData)
                parsedJson = result
                
                contentImage.image = UIImage(data: try Data(contentsOf: URL(string: (parsedJson?.results[0].contentImageUrlString)!)!))
                name.text = parsedJson?.results[0].name
                artist.text = parsedJson?.results[0].artist
                kind.text = parsedJson?.results[0].type
                genre.text = "(\(parsedJson!.results[0].genre))"
                priceButton.setTitle(parsedJson?.results[0].contentPrice, for: .normal)
                contentUrlString = parsedJson?.results[0].contentUrl
                previewUrlString = parsedJson?.results[0].contentPreviewUrl
            } catch {
                showAlert(title: "Servis Hatası !", message: "Lütfen servisten gelen veri yapısında değişiklik olmadığından emin olunuz.")
                print(error)
            }
        } catch {
            showAlert(title: "Bağlantı Hatası !", message: "Lütfen internet bağlantınızın olduğundan emin olunuz.")
            print(error)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK", style: .default, handler: closeView)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func closeView(alert: UIAlertAction!) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - USER ACTIONS
    @IBAction func priceButtonTapped(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: contentUrlString!)!)
        present(safariVC, animated: true)
    }
    @IBAction func previewButtonTapped(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: previewUrlString!)!)
        present(safariVC, animated: true)
    }
}
