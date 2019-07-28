import UIKit

class BookCoverCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book? {
        didSet {
            image = book?.coverImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            let corners: UIRectCorner = [.topRight, .bottomRight]
            
            imageView.image = image//!.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let corners: UIRectCorner = [.topRight, .bottomRight]
        roundCorners(corners: corners, radius: 20.0)
    }
	
}
