//
//  NXGallery.swift
//
//  Created by Ionut Lucaci on 18.05.2022.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import UIKit
import WebKit

import RxSwift
import RxCocoa
import RxSwiftExt

import ImageScrollView
import Toast


public struct Gallery { 
    public let items: [Item]
    public let initialIndex: Int
    
    public init(items: [Item] = [], initialIndex: Int = 0) { 
        self.items = items
        self.initialIndex = initialIndex
    }
    
    public struct Item { 
        public let identifier: String
        public let content: Observable<Content>
        public let actions: [Action]
        
        public init(identifier: String, content: Observable<Content>, actions: [Action] = []) { 
            self.identifier = identifier
            self.content = content
            self.actions = actions
        }
        
        public enum Content { 
            case image(_: UIImage)
            case video(url: URL)
            case document(url: URL)
        }
        
        public struct Action { 
            public let identifier: String
            public let icon: Observable<UIImage>
            
            public init(identifier: String, icon: Observable<UIImage>) { 
                self.identifier = identifier
                self.icon = icon
            }
                        
            public struct Selection {
                public let actionId: String
                public let itemId: String
                
                public init(actionId: String, itemId: String) { 
                    self.actionId = actionId
                    self.itemId = itemId
                }
            }
        }                
    }
}

public class GalleryContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - In
    public let gallery = BehaviorRelay<Gallery?>(value: nil)    
    
    // MARK: - Out
    public let actionSelected = PublishRelay<Gallery.Item.Action.Selection>()
    
    // MARK: - Boilerplate
    public let disposeBag = DisposeBag()
    
    // MARK: - PageViewController delegate
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = (viewController as? GalleryItemViewController)?.index ?? 0
        return viewControllerAt(index - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as? GalleryItemViewController)?.index ?? 0
        return viewControllerAt(index + 1)
    }
    
    // MARK: - Public Methods
    public func presentPopover(_ presented: UIViewController, fromSelection selection: Gallery.Item.Action.Selection) {
        let children = viewControllers as? [GalleryItemViewController]
        let presenter = children?.first(where: { $0.item.value?.identifier == selection.itemId })
        presenter?.presentPopover(presented, fromAction: selection.actionId)
    }
    
    
    // MARK: - Private Helpers
    private func viewControllerAt(_ index: Int) -> UIViewController? {
        guard let galleryItems = gallery.value?.items, 
              index >= 0 && index < galleryItems.count 
        else { return nil }   
                
        let storyboard = UIStoryboard(name: "NXGallery", bundle: nil)          
        guard let result = storyboard.instantiateViewController(withIdentifier: "GalleryItemViewController") as? GalleryItemViewController else { 
            return nil
        }

        let currentItem = galleryItems[index]        
        result.index = index
        result.item.accept(currentItem)
        result
            .actionSelected
            .bind(to: actionSelected)
            .disposed(by: result.disposeBag)
        
        return result
    }
    
    // MARK: - Overrides
    override public func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        gallery
            .unwrap()
            .subscribe(onNext: { [weak self] g in 
                guard let initialVC = self?.viewControllerAt(g.initialIndex) else {
                    self?.dismiss(animated: true)
                    return 
                }  
                
                self?.setViewControllers([initialVC], direction: .forward, animated: false)
            })
            .disposed(by: disposeBag)
    }        
}

public class GalleryItemViewController: UIViewController {
    // MARK: - In
    public var index = 0    
    public let item = BehaviorRelay<Gallery.Item?>(value: nil)
    
    // MARK: - Out
    public let actionSelected = PublishRelay<Gallery.Item.Action.Selection>()
    
    // MARK: - Outlets
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    // MARK: - Boilerplate
    public let disposeBag = DisposeBag()
    
    // MARK: - Public Methods
    public func presentPopover(_ vc: UIViewController, fromAction id: String) { 
        if let index = item.value?.actions.firstIndex(where: { $0.identifier == id }) {             
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            
            let button = buttonStackView.subviews[index + 1]
            vc.popoverPresentationController?.sourceView = button
            vc.popoverPresentationController?.sourceRect = button.bounds
            vc.popoverPresentationController?.permittedArrowDirections = .up            
        }
        
        present(vc, animated: true)
    }
    
    // MARK: - Overrides
    override public func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.setup()
        
        view.makeToastActivity(CSToastPositionCenter)

        item
            .unwrap()
            .flatMap { $0.content }
            .subscribe(onNext: { [weak self] content in
                self?.view.hideToastActivity()
                switch content { 
                case .image(let img):
                    self?.imageScrollView?.display(image: img)
                    self?.imageScrollView.isHidden = false
                    self?.webView.isHidden = true
                case .video(url: let url), .document(url: let url):
                    self?.webView.loadFileURL(url, allowingReadAccessTo: url)
                    self?.imageScrollView.isHidden = true
                    self?.webView.isHidden = false                
                }                
            })
            .disposed(by: disposeBag)
        
        item
            .unwrap()
            .subscribe(onNext: { [weak self] item in     
                guard let welf = self else { return }
                for action in item.actions { 
                    let b = UIButton(type: .custom)
                    b.frame.size = welf.closeButton.frame.size
                    
                    action
                        .icon
                        .bind(to: b.rx.image(for: .normal))
                        .disposed(by: welf.disposeBag)                                                                  
                    
                    self?.buttonStackView.addArrangedSubview(b)
                    
                    b.rx.tap
                        .map { Gallery.Item.Action.Selection(actionId: action.identifier,
                                                             itemId: item.identifier) }
                        .bind(to: welf.actionSelected)
                        .disposed(by: welf.disposeBag)
                }                
            })      
            .disposed(by: disposeBag)
                                
        closeButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in  
                self?.parent?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    } 
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.reload()
    }
}

// MARK: - Extensions

extension GalleryItemViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
