//
//  Model.swift
//  SearchMonster
//
//  Created by Y. Murat EKSÜR on 24.03.2022.
//

import Foundation

struct ApiResult: Decodable {
    var results = [Result]()
}

struct Result: Decodable {
    var artistName: String? = ""
    var sellerName: String? = ""
    var trackName: String? = ""
    var trackId: Int? = 0
    var trackViewUrl: String?
    var previewUrl: String?
    var kind: String? = ""
    var contentImageUrlString: String? = ""
    var currency: String? = ""
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionId: Int? = 0
    var formattedPrice: String?
    var trackPrice: Double?
    var price: Double?
    var collectionPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    enum CodingKeys: String, CodingKey {
        case artistName, sellerName, trackName, trackId, trackViewUrl, previewUrl, kind, currency, collectionName, collectionViewUrl, collectionId, formattedPrice, trackPrice, price, collectionPrice
        case contentImageUrlString = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
    }
    
    var contentPreviewUrl: String {
        return previewUrl ?? collectionViewUrl ?? trackViewUrl ?? ""
    }
    
    var contentId: Int {
        return trackId ?? collectionId ?? 0
    }
    
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var artist: String {
        return artistName ?? sellerName ?? ""
    }
    
    var contentUrl: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var contentPrice: String {
        if let trackPrice = trackPrice {
            return "\(trackPrice) \(currency!)"
        } else if let formattedPrice = formattedPrice {
            return formattedPrice
        } else if let collectionPrice = collectionPrice {
            return "\(collectionPrice) \(currency!)"
        }
        return "0.00"
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album":
            return "Albüm"
        case "audiobook":
            return "Sesli Kitap"
        case "book":
            return "Kitap"
        case "ebook":
            return "E-Kitap"
        case "feature-movie":
            return "Sinema"
        case "music-video":
            return "Muzik Video"
        case "podcast":
            return "Podcast"
        case "software":
            return "Uygulama"
        case "song":
            return "Şarkı"
        case "tv-episode":
            return "Dizi"
        default:
            break
        }
        return "Bilinmiyor"
    }
}
