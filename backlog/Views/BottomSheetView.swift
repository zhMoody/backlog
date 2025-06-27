//
//  BottomSheetView.swift
//  backlog
//
//  Created by 张浩 on 2025/6/12.
//


import UIKit
import SnapKit
class BottomSheetView: UIView {
    private var bottomConstraint: Constraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var parentHeight: CGFloat = 0
    private var maxHeight: CGFloat = 300
    private var minHeight: CGFloat = 0

    private(set) var isExpanded = false

    init(maxHeight: CGFloat = 300) {
        self.maxHeight = maxHeight
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    func attach(to parent: UIView) {
        parentHeight = parent.bounds.height
        parent.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { make in
              make.leading.trailing.equalToSuperview()
              make.height.equalTo(maxHeight)
              bottomConstraint = make.bottom.equalToSuperview().offset(maxHeight).constraint
          }
        parent.layoutIfNeeded()
    }

    func expand() {
        bottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25, animations: {
            self.superview?.layoutIfNeeded()
        })
        isExpanded = true
    }

    func collapse() {
        bottomConstraint?.update(offset: self.maxHeight)
        UIView.animate(withDuration: 0.25, animations: {
            self.superview?.layoutIfNeeded()
        })
        isExpanded = false
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let bottomConstraint = bottomConstraint else { return }
        let translation = gesture.translation(in: self).y

        switch gesture.state {
        case .changed:
            let newConstant = bottomConstraint.layoutConstraints.first!.constant + translation
            let clampedConstant = max(0, min(maxHeight, newConstant))
            bottomConstraint.update(offset: clampedConstant)
            gesture.setTranslation(.zero, in: self)
            self.superview?.layoutIfNeeded()
        case .ended, .cancelled:
            let midpoint = maxHeight / 2
            if bottomConstraint.layoutConstraints.first!.constant > midpoint {
                collapse()
            } else {
                expand()
            }
        default:
            break
        }
    }
}
