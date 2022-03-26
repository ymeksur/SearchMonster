//
//  TableViewSuccessCell.swift
//  SearchMonster
//
//  Created by Y. Murat EKSÜR on 24.03.2022.
//

import UIKit

class TableViewSuccessCell: UITableViewCell {
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentName: UILabel!
    @IBOutlet weak var contentArtist: UILabel!
    @IBOutlet weak var contentType: UILabel!
    
    var content: Result! {
        didSet {
            contentImage.image = UIImage(data: try! Data(contentsOf: URL(string: content.contentImageUrlString!)!))
            contentName.text = content.name
            contentArtist.text = content.artistName!
            contentType.text = "(\(content.genre))"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentImage.layer.cornerRadius = 15
        contentImage.clipsToBounds = true
    }
}
