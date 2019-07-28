import UIKit

extension BooksViewController {
    func animationController(forPresentController vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 1
        let transition = BookOpeningTransition()
        // 2
        transition.isPush = true
        transition.interactionController = interactionController

        // 3
        self.transition = transition
        // 4
        return transition
    }
    func animationController(forDismissController vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        
        self.transition = transition
        return transition
    }
    
    // MARK: Gesture recognizer action
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            //1
            interactionController = UIPercentDrivenInteractiveTransition()
            //2
            if recognizer.scale >= 1 {
                //3
                if recognizer.view == collectionView {
                    //4
                    let book = self.selectedCell()?.book
                    //5
                    self.openBook(book)
                }
                //6
            } else {
                //7
                navigationController?.popViewController(animated: true)
            }
        case .changed:
            //8
            if transition!.isPush {
                //9
                let progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                //10
                
                interactionController?.update(progress)
                //11
            } else {
                //12
                let progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                //13
                interactionController?.update(progress)
            }
        case .ended:
            //14
            interactionController?.finish()
            //15
            interactionController = nil
        default:
            break
        }
    }
}

class BooksViewController: UICollectionViewController {
    var transition: BookOpeningTransition?
    //1
    var interactionController: UIPercentDrivenInteractiveTransition?
    //2
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(with: "Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    }
    
    // MARK: Helpers
    
    func openBook(_ book: Book?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        
        if let book = book {
            vc.book = book
        } else { //Try set selectedCell
            vc.book = selectedCell()?.book
        }
        
        //1
        vc.view.snapshotView(afterScreenUpdates: true)
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    func selectedCell() -> BookCoverCell? {
        if let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width / 2, y: collectionView!.bounds.height / 2)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
            }
        }
        return nil
    }
    
}

// MARK: UICollectionViewDelegate

extension BooksViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //4
        let book = selectedCell()?.book
        openBook(book)
    }
}

// MARK: UICollectionViewDataSource

extension BooksViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let books = books {
            return books.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath) as! BookCoverCell
        
        cell.book = books?[indexPath.row]
        
        return cell
    }
}
