import UIKit

class BookPageCell: UICollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	var book: Book?
	var isRightPage: Bool = false
	var shadowLayer: CAGradientLayer = CAGradientLayer()
	
	override var bounds: CGRect {
		didSet {
			shadowLayer.frame = bounds
		}
	}
	
	var image: UIImage? {
		didSet {
			let corners: UIRectCorner = isRightPage ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft]
            imageView.image = image//!.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
		}
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let corners: UIRectCorner = isRightPage ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft]
        roundCorners(corners: corners, radius: 20.0)
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupAntialiasing()
		initShadowLayer()
	}
	
	func setupAntialiasing() {
		layer.allowsEdgeAntialiasing = true
		imageView.layer.allowsEdgeAntialiasing = true
	}
	
	func initShadowLayer() {
		let shadowLayer = CAGradientLayer()
		
		shadowLayer.frame = bounds
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
		
		self.imageView.layer.addSublayer(shadowLayer)
		self.shadowLayer = shadowLayer
	}
	
	func getRatioFromTransform() -> CGFloat {
		var ratio: CGFloat = 0
		
        let rotationY = layer.value(forKeyPath: "transform.rotation.y") as! CGFloat
        
		if !isRightPage {
            let progress = -(1 - rotationY / CGFloat(Double.pi / 2.0))
			ratio = progress
		}
			
		else {
			let progress = 1 - rotationY / CGFloat(-Double.pi / 2.0)
			ratio = progress
		}
		
		return ratio
	}
	
	func updateShadowLayer(animated: Bool = false) {
        //let _: CGFloat = 0
		
		// Get ratio from transform. Check BookCollectionViewLayout for more details
		let inverseRatio = 1 - abs(getRatioFromTransform())
		
		if !animated {
			CATransaction.begin()
			CATransaction.setDisableActions(!animated)
		}
		
		if isRightPage {
			// Right page
			shadowLayer.colors = NSArray(objects:
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor,
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
			) as! [CGColor]
			shadowLayer.locations = NSArray(objects:
				NSNumber(value: 0.00),
				NSNumber(value: 0.02),
				NSNumber(value: 1.00)
			) as? [NSNumber]
		} else {
			// Left page
			shadowLayer.colors = NSArray(objects:
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.30).cgColor,
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.50).cgColor,
				UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
			) as! [CGColor]
			shadowLayer.locations = NSArray(objects:
                NSNumber(value: 0.00),
				NSNumber(value: 0.50),
				NSNumber(value: 0.98),
				NSNumber(value: 1.00)
            ) as? [NSNumber]
		}
		
		if !animated {
			CATransaction.commit()
		}
	}
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        //1
        if layoutAttributes.indexPath.item % 2 == 0 {
            //2
            layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            isRightPage = true
        } else { //3
            //4
            layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            isRightPage = false
        }
        //5
        self.updateShadowLayer()
    }
}
