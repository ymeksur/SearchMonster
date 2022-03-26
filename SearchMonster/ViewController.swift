//
//  ViewController.swift
//  SearchMonster
//
//  Created by Y. Murat EKSÜR on 23.03.2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var forthButton: UIButton!
    
    var parsedJson: ApiResult?
    var isLoading = false
    var pageNumber: Int = 1
    var pageLimit: Int = 10
    var pageOffset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "SEARCH MONSTER"
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    
    //MARK: - HELPERS
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func nextPageButtonState(numberOfRows: Int) {
        if numberOfRows >= pageLimit {
            forthButton.alpha = 1
            pageLabel.alpha = 1
        } else {
            pageLabel.alpha = 1
            forthButton.alpha = 0
        }
    }
    
    func previousPageButtonState() {
        if pageNumber > 1 {
            backButton.alpha = 1
        } else {
            backButton.alpha = 0
        }
    }
    
    func createURL(searchTerm: String, offset: Int, category: Int) -> URL {
        
        pageOffset = (pageNumber-1)*pageLimit
        
        let kind: String
        switch category {
        case 1:
            kind = "movie"
        case 2:
            kind = "podcast"
        case 3:
            kind = "musicTrack"
        case 4:
            kind = "software"
        case 5:
            kind = "ebook"
        default:
            kind = ""
        }
        
        let encodedTerm = searchTerm.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&limit=\(pageLimit)&offset=\(pageOffset)&entity=\(kind)"
        
        let url = URL(string: urlString)
        return url!
    }
    
    func fetchData(from url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            do {
                let result = try JSONDecoder().decode(ApiResult.self, from: jsonData)
                parsedJson = result
            } catch {
                showAlert(title: "Servis Hatası !", message: "Lütfen servisten gelen veri yapısında değişiklik olmadığından emin olunuz.")
                print(error)
            }
        } catch {
            showAlert(title: "Bağlantı Hatası !", message: "Lütfen internet bağlantınızın olduğundan emin olunuz.")
            print(error)
        }
    }
    
    func search() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            isLoading = true
            tableView.reloadData()
            let url = createURL(searchTerm: searchBar.text!, offset: pageOffset, category: segmentedControl.selectedSegmentIndex)
            fetchData(from: url)
            DispatchQueue.main.async {
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - USER ACTIONS
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        pageNumber = 1
        previousPageButtonState()
        pageLabel.text = "\(pageNumber)"
        search()
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        pageNumber = 1
        previousPageButtonState()
        pageLabel.text = "\(pageNumber)"
        search()
    }
    
    @IBAction func goBack(_ sender: Any) {
        pageNumber -= 1
        pageLabel.text = "\(pageNumber)"
        previousPageButtonState()
        search()
    }
    
    @IBAction func goForth(_ sender: Any) {
        pageNumber += 1
        pageLabel.text = "\(pageNumber)"
        previousPageButtonState()
        search()
    }
    
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let parsedJson = parsedJson else {
            return 0
        }
        
        if isLoading {
            backButton.alpha = 0
            pageLabel.alpha = 0
            forthButton.alpha = 0
            return 1
        } else if parsedJson.results.count == 0 {
            backButton.alpha = 0
            pageLabel.alpha = 0
            forthButton.alpha = 0
            return 1
        } else {
            previousPageButtonState()
            nextPageButtonState(numberOfRows: parsedJson.results.count)
            return parsedJson.results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! TableViewLoadingCell
            let activityIndicator = cell.activityIndicator
            activityIndicator!.startAnimating()
            return cell
        } else if parsedJson?.results.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataCell")!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessCell") as! TableViewSuccessCell
            cell.content = parsedJson?.results[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return tableView.frame.height
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if parsedJson?.results.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    
    // MARK: - SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.contentId = (parsedJson?.results[tableView.indexPathForSelectedRow!.row].contentId)!
        }
    }
}
