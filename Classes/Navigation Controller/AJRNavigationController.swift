//
//  AJRNavigationController.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/2/26.
//

import Cocoa

public protocol AJRNavigationControllerDelegate: AnyObject {
    func navigationController(_ navigationController: AJRNavigationController,
                              didPop viewController: NSViewController,
                              newViewController: NSViewController?)
    func navigationController(_ navigationController: AJRNavigationController,
                              willPop viewController: NSViewController,
                              newViewController: NSViewController?) -> Bool
    func navigationController(_ navigationController: AJRNavigationController,
                              didPush viewController: NSViewController)
    func navigationController(_ navigationController: AJRNavigationController,
                              willPush viewController: NSViewController) -> Bool
}

public extension AJRNavigationControllerDelegate {
    func navigationController(_ navigationController: AJRNavigationController,
                              didPop viewController: NSViewController,
                              newViewController: NSViewController?) { }
    func navigationController(_ navigationController: AJRNavigationController,
                              willPop viewController: NSViewController,
                              newViewController: NSViewController?) -> Bool { return true }
    func navigationController(_ navigationController: AJRNavigationController,
                              didPush viewController: NSViewController) { }
    func navigationController(_ navigationController: AJRNavigationController,
                              willPush viewController: NSViewController) -> Bool { return true }
}

@MainActor
open class AJRNavigationController: NSViewController {

    public class EmptyController : NSViewController {

        internal var label : NSTextField!

        public override func loadView() {
            label = NSTextField.init(labelWithString: "No\nContent")
            label.translatesAutoresizingMaskIntoConstraints = true
            label.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
            label.font = NSFont.boldSystemFont(ofSize: 18.0)
            label.sizeToFit()
            label.textColor = .secondaryLabelColor
            label.alignment = .center
            label.frame = label.frame.insetBy(dx: -4.0, dy: -4.0)
            view = NSView(frame: label.bounds)
            view.translatesAutoresizingMaskIntoConstraints = true
            view.autoresizingMask = [.width, .height]
            view.addSubview(label)
        }

    }

    public enum NavigationError: Error {
        case emptyStack
        case transitionInProgress
        case viewControllerAlreadyInStack
        case delegateCancelled
    }

    internal enum TransitionState {
        case none
        case pushing
        case popping
    }

    private var viewControllerStack: [NSViewController] = []
    private var transitionState: TransitionState = .none

    public var delegate : AJRNavigationControllerDelegate? = nil
    public var emptyViewController: NSViewController? = nil
    public private(set) var topViewController: NSViewController? {
        get { viewControllerStack.last }
        set { }
    }

    public var viewControllers: [NSViewController] {
        return viewControllerStack
    }

    // MARK: - Init

    public init(rootViewController: NSViewController? = nil) {
        super.init(nibName: nil, bundle: nil)

        if let rootViewController {
            viewControllerStack = [rootViewController]
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View Lifecycle

    open override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if let rootViewController = viewControllerStack.first,
           rootViewController.parent == nil {
            installRootViewController(rootViewController)
        }
    }

    // MARK: - Stack Management

    open var activeViewController : NSViewController? {
        return viewControllerStack.last
    }

    open func setViewControllers(_ viewControllers: [NSViewController], animated: Bool = false) throws {
        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        let oldTop = topViewController
        let newTop = viewControllers.last

        self.viewControllerStack = viewControllers

        guard isViewLoaded else {
            return
        }

        if let oldTop, let newTop, oldTop !== newTop {
            try transition(from: oldTop, to: newTop, state: .pushing, animated: animated)
        } else if let newTop {
            removeAllChildren()
            installRootViewController(newTop)
        } else {
            removeAllChildren()
        }
    }

    open func pushViewController(_ viewController: NSViewController, animated: Bool = true) throws {
        // See if the delegate wants to allow this.
        guard delegate?.navigationController(self, willPush: viewController) ?? true else { return }

        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        guard !viewControllerStack.contains(where: { $0 === viewController }) else {
            throw NavigationError.viewControllerAlreadyInStack
        }

        let oldTop = topViewController
        viewControllerStack.append(viewController)

        guard isViewLoaded else {
            return
        }

        if let oldTop {
            try transition(from: oldTop, to: viewController, state: .pushing, animated: animated)
        } else {
            installRootViewController(viewController)
            delegate?.navigationController(self, didPush: viewController)
        }
    }

    @discardableResult
    open func popViewController(animated: Bool = true) throws -> NSViewController {
        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        guard let viewController = viewControllerStack.last else {
            throw NavigationError.emptyStack
        }

        let newTop : NSViewController
        if let emptyViewController, viewControllerStack.count == 1 {
            newTop = emptyViewController
        } else if viewControllerStack.count > 1 {
            newTop = viewControllerStack[viewControllerStack.count - 2]
        } else {
            throw NavigationError.emptyStack
        }

        // See if the delegate wants to allow this.
        guard delegate?.navigationController(self, willPop: viewController, newViewController: newTop) ?? true else { throw NavigationError.delegateCancelled }

        // Now that the delegate has approved, let's remove the the currently displayed view controller.
        viewControllerStack.removeLast()

        guard isViewLoaded else {
            return viewController
        }

        // And transition to the new view.
        try transition(from: viewController, to: newTop, state: .popping, animated: animated)

        return viewController
    }

    @discardableResult
    open func popToRootViewController(animated: Bool = true) throws -> [NSViewController] {
        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        guard viewControllerStack.count > 1 else {
            return []
        }

        let oldTop = viewControllerStack.last!
        let root = viewControllerStack.first!
        let popped = Array(viewControllerStack.dropFirst())

        viewControllerStack = [root]

        guard isViewLoaded else {
            return popped
        }

        try transition(from: oldTop, to: root, state: .popping, animated: animated)

        return popped
    }

    @discardableResult
    open func popToViewController(_ viewController: NSViewController, animated: Bool = true) throws -> [NSViewController] {
        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        guard let index = viewControllerStack.firstIndex(where: { $0 === viewController }) else {
            return []
        }

        guard index < viewControllerStack.count - 1 else {
            return []
        }

        let oldTop = viewControllerStack.last!
        let popped = Array(viewControllerStack[(index + 1)...])

        viewControllerStack = Array(viewControllerStack[...index])

        guard isViewLoaded else {
            return popped
        }

        try transition(from: oldTop, to: viewController, state: .popping, animated: animated)

        return popped
    }

    // MARK: - Private

    private enum Direction {
        case push
        case pop
    }

    private func installRootViewController(_ viewController: NSViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        constrainToFill(viewController.view)
    }

    private func removeAllChildren() {
        for child in children {
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }

    private var activeFillConstraints: [NSView: [NSLayoutConstraint]] = [:]

    private func constrainToFill(_ childView: NSView) {
        removeFillConstraints(for: childView)

        childView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
        activeFillConstraints[childView] = constraints
    }

    private func removeFillConstraints(for childView: NSView) {
        if let constraints = activeFillConstraints[childView] {
            NSLayoutConstraint.deactivate(constraints)
            activeFillConstraints.removeValue(forKey: childView)
        }
    }

    private func transition(
        from oldViewController: NSViewController,
        to newViewController: NSViewController,
        state: TransitionState,
        animated: Bool
    ) throws {
        guard oldViewController !== newViewController else {
            return
        }

        guard transitionState == .none else {
            throw NavigationError.transitionInProgress
        }

        transitionState = state

        addChild(newViewController)

        let bounds = view.bounds
        let width = bounds.width
        let incomingStartX = transitionState == .pushing ? width : -width
        let oldView = oldViewController.view
        let newView = newViewController.view

        removeFillConstraints(for: oldView)
        removeFillConstraints(for: newView)

        oldView.translatesAutoresizingMaskIntoConstraints = false
        newView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(newView)

        let incomingOffset = transitionState == .pushing ? width : -width
        let outgoingOffset = transitionState == .pushing ? -width : width
        oldView.frame = bounds
        newView.frame = bounds.offsetBy(dx: incomingStartX, dy: 0)

        let newLeading = newView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(incomingOffset))
        let oldLeading = oldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)

        NSLayoutConstraint.activate([
            oldLeading,

            oldView.topAnchor.constraint(equalTo: view.topAnchor),
            oldView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            oldView.widthAnchor.constraint(equalTo: view.widthAnchor),

            newLeading,

            newView.topAnchor.constraint(equalTo: view.topAnchor),
            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        view.layoutSubtreeIfNeeded()

        let finish = { [weak self, oldViewController, newViewController] in
            guard let self else { return }

            oldView.removeFromSuperview()
            oldViewController.removeFromParent()

            NSLayoutConstraint.deactivate([
                oldLeading,
                newLeading
            ])

            self.constrainToFill(newView)

            let completedState = self.transitionState
            self.transitionState = .none

            if completedState == .pushing {
                self.delegate?.navigationController(self, didPush: newViewController)
            } else if completedState == .popping {
                self.delegate?.navigationController(self, didPop: oldViewController, newViewController: newViewController)
            }
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true

                oldLeading.animator().constant = outgoingOffset
                newLeading.animator().constant = 0

                view.layoutSubtreeIfNeeded()
            } completionHandler: {
                Task { @MainActor in
                    finish()
                }
            }
        } else {
            finish()
        }
    }

    // MARK: - State

    public var canGoBack: Bool {
        if emptyViewController == nil {
             return viewControllerStack.count > 1
        }
        return viewControllerStack.count > 0
    }
    
}
