//
//  HistoryTableViewCell.swift
//  meh.com
//
//  Created by Kirin Patel on 8/10/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    let card: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }()
    
    let dealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var dealImageViewLeftConstraing: NSLayoutConstraint!
    var dealImageViewWidthContraint: NSLayoutConstraint!
    
    var deal: Deal! {
        didSet {
            titleLabel.text = deal.title
            titleLabel.textColor = deal.theme.accentColor
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            card.backgroundColor = deal.theme.backgroundColor
        }
    }
    var dealImage: UIImage! {
        didSet {
            dealImageView.image = dealImage
            animateLoadedImage()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(card)
        card.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 4).isActive = true
        card.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4).isActive = true
        card.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        card.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        card.addSubview(dealImageView)
        dealImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 8).isActive = true
        dealImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8).isActive = true
        dealImageViewLeftConstraing = dealImageView.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 0)
        dealImageViewLeftConstraing.isActive = true
        dealImageViewWidthContraint = dealImageView.widthAnchor.constraint(equalToConstant: 0)
        dealImageViewWidthContraint.isActive = true
        dealImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        card.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: dealImageView.rightAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -8).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func animateLoadedImage() {
        dealImageViewLeftConstraing.constant = 8
        dealImageViewWidthContraint.constant = 50
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.preferredFramesPerSecond60, .curveEaseOut, .allowUserInteraction],
                       animations: {
                        self.layoutIfNeeded()
        })
    }
}
