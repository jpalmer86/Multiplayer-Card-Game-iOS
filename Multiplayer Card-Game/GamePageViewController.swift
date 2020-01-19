//
//  GamePageViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 19/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

class GamePageViewController: UIPageViewController {
    
    //MARK:- Property Variables
    
    //// Crazy 8 viewcontrollers
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "DeckGameViewController"),
                self.newVc(viewController: "PlayerCardDeckViewController")]
    }()
    var pageControl = UIPageControl()
    var isHost: Bool!
    var game: Game!

    //MARK:- Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        ////  This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        self.delegate = self
        configurePageControl()
    }
    
    //MARK:- Custom Methods
    
    private func newVc(viewController: String) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        if let gameVC = vc as? DeckGameViewController {
            gameVC.game = game
            gameVC.isHost = isHost
        }
        return vc
    }

    private func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK:- UIPageViewController DataSource

extension GamePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        ////  User is on the first view controller and swiped left to loop to
        ////  the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        //// User is on the last view controller and swiped right to loop to
        //// the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

//MARK:- UIPageViewontroller Delegate

extension GamePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
}
