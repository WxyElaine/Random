//
//  ListTableViewCell.swift
//  Random
//
//  Created by Xinyi Wang on 11/6/18.
//  Copyright © 2018 Xinyi Wang. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    // holds the content of the entry
    public var label: UITextField = UITextField(frame: CGRect.null)

    private let leftMarginForLabel: CGFloat = 15.0

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpTextField()
        addSubview(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUpTextField()
        addSubview(label)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    // Set up the textfield in label
    private func setUpTextField() {
        label.textColor = UIColor.black
        label.clearButtonMode = .whileEditing
        label.contentVerticalAlignment = UIControlContentVerticalAlignment.center
    }

}
