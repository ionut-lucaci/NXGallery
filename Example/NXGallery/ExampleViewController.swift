//
//  ViewController.swift
//  NXGallery
//
//  Created by ionut-lucaci on 08/24/2022.
//  Copyright © 2022. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources
import NXGallery


// MARK: - View Controller
class ExampleViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout { 
    lazy var viewModel = ExampleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ds = RxCollectionViewSectionedReloadDataSource<ExampleSection>(configureCell: { ds, cv, ip, item in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: ip)
            (cell as? ExampleCell)?.setup(item: item)
            
            return cell
        })
        
        guard let cv = collectionView else { return }
        cv.dataSource = nil
        
        viewModel
            .sections
            .bind(to: cv.rx.items(dataSource: ds))
            .disposed(by: viewModel.disposeBag)
        
        cv.rx
            .modelSelected(ExampleItem.self)
            .bind(to: viewModel.itemSelected)
            .disposed(by: viewModel.disposeBag)
        
        viewModel
            .navigation
            .subscribe(onNext: { [weak self] nav in  
                switch nav { 
                case .segue(let segue):
                    self?.performSegue(withIdentifier: segue.id, sender: self?.viewModel)
                    
                case .alert(let title, let message):                    
                    // the gallery could be already presented, or not, the view controller doesn't care
                    // (shhh... it's always the gallery who sends alerts in this example app)
                    let presenter = (self?.presentedViewController ?? self)
                    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak alertVC] _ in
                        alertVC?.dismiss(animated: true)
                    }))
                    
                    presenter?.present(alertVC, animated: true)
                }
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? GalleryContainerViewController { 
            viewModel
                .navigation
                .map { $0.segue?.gallery }
                .unwrap()
                .bind(to: dest.gallery)
                .disposed(by: dest.disposeBag)
            
            dest
                .actionSelected
                .bind(to: viewModel.actionSelected)
                .disposed(by: dest.disposeBag)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupItemSize()
    }
    
    func setupItemSize() { 
        // force 2 columns on all devices, resizing the cells, instead of respecting a standard item size
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout  else { return }
        
        let columnCount: CGFloat = 2
        let availableWidth = view.frame.width - layout.minimumInteritemSpacing * (columnCount - 1)
        let itemSize = availableWidth / columnCount
        
        let size = CGSize(width: itemSize,
                          height: itemSize)
        if layout.itemSize != size {
            layout.itemSize = size
        }
    }
}

// MARK: - Cell

class ExampleCell: UICollectionViewCell { 
    @IBOutlet weak var imageView: UIImageView!
    
    var recycleBin = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recycleBin = DisposeBag()
    }
    
    func setup(item: ExampleItem) { 
        item
            .image
            .bind(to: imageView.rx.image)
            .disposed(by: recycleBin)
    }
}
