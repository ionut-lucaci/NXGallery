//
//  ExampleViewModel.swift
//  NXGallery_Example
//
//  Created by Ionut Lucaci on 30.08.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources
import NXGallery

typealias ExampleItem = ExampleViewModel.Item
typealias ExampleSection = SectionModel<Void, ExampleItem>  
typealias ExampleSegue = ExampleViewModel.Segue

class ExampleViewModel { 
    // MARK: - In
    let itemSelected = PublishRelay<Item>()
    
    // MARK: - Out
    let sections = BehaviorRelay<[ExampleSection]>(value: [])
    let segue = ReplayRelay<Segue>.create(bufferSize: 1)
    
    // MARK: - Structures
    struct Item {    
        let model: ExampleModel
        let image: Observable<UIImage>      
    }
    
    enum Segue { 
        case gallery(_: Gallery)
    }
    
    // MARK: - Boilerplate
    let disposeBag = DisposeBag()
    
    // MARK: - Methods
    init() {
        
        //faux network/db fetch
        let models = (1...5)
            .map { ExampleModel(id: String($0), 
                                canTrek: ($0 % 2 == 0)) }
        // faux image fetch
        let items = Observable
            .just(models.map { Item(model: $0, 
                                    image: .just(UIImage(named: "image-\($0.id)")!)) })
            .share()
        
        items
            .map { [ExampleSection(model: (), items: $0)]}
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        itemSelected
            .withLatestFrom(items) { selection, items in 
                let index = items.firstIndex(of: selection) ?? 0
                let galleryItems = items.map { item -> Gallery.Item in                     
//                    let actions: [GalleryActionId] = (protected ? [.info, .protected] : [.info])
                    let content = item.image.map { Gallery.Item.Content.image($0) }
                    return Gallery.Item(identifier: item.model.id,
                                        content: content) 
//                                 actions: actions.map { $0.action })
                }
                
                return .gallery(Gallery(items: galleryItems,
                                        initialIndex: index))
            }
            .bind(to: segue)
            .disposed(by: disposeBag)            
    }
}

extension ExampleItem: Equatable {     
    static func == (lhs: ExampleViewModel.Item, rhs: ExampleViewModel.Item) -> Bool {
        return lhs.model == rhs.model
    }       
}

extension ExampleSegue { 
    var id: String { 
        switch self { 
        case .gallery:
            return "showGallery"
        }        
    }
    
    var gallery: Gallery? { 
        switch self { 
        case .gallery(let g):
            return g
        }
    }
}
