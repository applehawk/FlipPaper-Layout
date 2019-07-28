import UIKit

class BookLayout: UICollectionViewFlowLayout {
    private let PageWidth: CGFloat = 181
    private let PageHeight: CGFloat = 284
    
    private var numberOfItems = 0
    
    override func prepare() {
        super.prepare()
        
        collectionView?.decelerationRate = .fast
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
        collectionView?.isPagingEnabled = true
        
        collectionView?.alwaysBounceVertical = false
        
        //2
        collectionView?.contentInset = UIEdgeInsets(
            top: 0,
            left: collectionView!.bounds.width / 2 - PageWidth / 2,
            bottom: 0,
            right: collectionView!.bounds.width / 2 - PageWidth / 2
        )
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: CGFloat(numberOfItems / 2) * collectionView!.bounds.width, height: collectionView!.bounds.height)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //1
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        //2
        let frame = getFrame(collectionView!)
        layoutAttributes.frame = frame
        
        //3
        let ratio = getRatio(collectionView!, indexPath: indexPath)
        
        //4
        if ratio > 0 && indexPath.item % 2 == 1
            || ratio < 0 && indexPath.item % 2 == 0 {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
        //5
        let rotation = getRotation(with: indexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation
        
        //6
        if indexPath.row == 0 {
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //1
        var array: [UICollectionViewLayoutAttributes] = []
        
        //2
        for i in 0 ... max(0, numberOfItems - 1) {
            //3
            let indexPath = IndexPath(item: i, section: 0)
            //4
            if let attributes = layoutAttributesForItem(at: indexPath) {
                //5
                array += [attributes]
            }
        }
        //6
        return array
    }
    
    //MARK: - Attribute Logic Helpers
    
    func getFrame(_ collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()
        
        frame.origin.x = (collectionView.bounds.width / 2) - (PageWidth / 2) + collectionView.contentOffset.x
        frame.origin.y = (collectionViewContentSize.height - PageHeight) / 2
        frame.size.width = PageWidth
        frame.size.height = PageHeight
        
        return frame
    }
    
    func getRatio(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        //1
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5
        
        //2
        var ratio: CGFloat = -0.5 + page - (collectionView.contentOffset.x / collectionView.bounds.width)
        
        //3
        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
            
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }
        
        return ratio
    }
    
    func getAngle(with indexPath: IndexPath, ratio: CGFloat) -> CGFloat {
        // Set rotation
        var angle: CGFloat = 0
        
        //1
        if indexPath.item % 2 == 0 {
            // The book's spine is on the left of the page
            angle = (1-ratio) * CGFloat(-Double.pi * 0.5)
        } else {
            //2
            // The book's spine is on the right of the page
            angle = (1 + ratio) * CGFloat(Double.pi * 0.5)
        }
        //3
        // Make sure the odd and even page don't have the exact same angle
        angle += CGFloat(indexPath.row % 2) / 1000
        //4
        return angle
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    
    func getRotation(with indexPath: IndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(with: indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }

}
