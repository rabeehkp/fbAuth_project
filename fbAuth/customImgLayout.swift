//
//  customImgLayout.swift
//  fbAuth
//
//  Created by Rabeeh KP on 21/12/17.
//  Copyright © 2017 Rabeeh KP. All rights reserved.
//

import UIKit
protocol CustomLayOutDelegate: class {
    func collectionView(_ collectionView : UICollectionView, heightForPhotoAtIndexPath indexPath : IndexPath) -> CGFloat
    func collectionView(_ collectionView : UICollectionView, widthForPhotoAtIndexPath indexPath : IndexPath) -> CGFloat
}
class customImgLayout: UICollectionViewLayout {
    weak var delegate : CustomLayOutDelegate!
    
    // 2
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    
    // 3
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    // 4
    fileprivate var contentHeight: CGFloat = 0
    //fileprivate var contentWidth: CGFloat = 0
    fileprivate var contentWidth: CGFloat = 0
    //AutoWidth
    var autoWidth : CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    //autoHeight
    var autoHeight : CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right)
    }
    
    // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    var collectionViewScrollDirection: UICollectionViewScrollDirection{
        return .vertical
    }
    
    override func prepare() {
        // 1
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        // 2
        //width of image comented
        var xOffset = [CGFloat]()
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        var ImgWidth : CGFloat = 0
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            let photoWidth = delegate.collectionView(collectionView, widthForPhotoAtIndexPath: indexPath)
            ImgWidth = photoWidth
            // }
            if ImgWidth > autoWidth{
                contentWidth = ImgWidth
            }
            else{
                contentWidth = autoWidth
            }
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            var ImgHeight : CGFloat = 0
            let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            ImgHeight = photoHeight
            // }
            if ImgHeight > autoHeight{
                contentHeight = ImgHeight
            }
            else{
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
            }
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
