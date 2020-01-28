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
        let controller1 = newVc(viewController: "DeckGameViewController")
        let controller2 = newVc(viewController: "PlayerCardDeckViewController")
        return [controller1, controller2]
    }()
    var pageControl = UIPageControl()
    var isHost: Bool!
    var game: Game!
    var deckController: DeckGameViewController!
    var quit: (() -> Void)!

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
        
        let imageBarButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left.2"), style: .plain, target: self, action: #selector(quitGame))
        navigationItem.leftBarButtonItem = imageBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        quit()
        AppUtility.lockOrientation(.all)
        super.viewWillDisappear(animated)
    }
    
    //MARK:- ViewController Methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Custom Methods
    
    @objc func quitGame() {
        alert(title: "Confirm disconnection:", message: "Are you sure you want to disconnect?") {  [weak self] response in
            if response {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func swipeGestureEnabled(enable: Bool) {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = enable
            }
        }
    }
    
    func changeNavigationBarTitle(newTitle: String) {
        title = newTitle
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Private Methods
    
    private func newVc(viewController: String) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        if let gameVC = vc as? DeckGameViewController {
            gameVC.game = game
            gameVC.isHost = isHost
            gameVC.changeNavigationBarTitle = self.changeNavigationBarTitle
            gameVC.dismissVC = self.dismissVC
            self.quit = gameVC.quitGame
            deckController = gameVC
        } else if let gameVC = vc as? PlayerCardDeckViewController {
            gameVC.swipeGestureEnabled = self.swipeGestureEnabled
            deckController.setDeck = gameVC.setDeck
            deckController.enablePlayer = gameVC.enablePlayer
            deckController.setColor = gameVC.setColor
        }
        return vc
    }

    private func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(pageControl)
    }
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
//             return nil
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
//             return nil
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
        pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
        pageControl.currentPageIndicatorTintColor = Constants.Colors.color[GameManager.shared.colorKey[gameService.colorIndex]!]!
        swipeGestureEnabled(enable: true)
    }
}
