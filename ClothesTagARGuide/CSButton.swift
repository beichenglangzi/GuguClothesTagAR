//
//  CSButton.swift
//  ClothesTagARGuide
//
//  Created by Yujin Lee on 2021/11/16.
//

import UIKit

public enum CSButtonType {
    case btnFabric
    case btnWash
    case btnSupport
}

class CSButton: UIButton {

    convenience init(type: CSButtonType) {
        self.init()

        self.backgroundColor = .lightGray
        self.layer.borderWidth = 3 // 두꺼운 테두리
        self.layer.borderColor = UIColor.lightGray.cgColor // 테두리 색
        self.layer.cornerRadius = 0 // 모서리는 둥글지 않게
        self.setTitleColor(.darkGray, for: .normal)
        self.titleLabel?.font =  UIFont(name: "Academy Engraved LET", size: 20)
        self.titleEdgeInsets.top = 5
        self.alpha = 0.70
        
        switch type {
        case .btnFabric :
            self.setTitle("Fabric", for: .normal)
        case .btnWash:
            self.setTitle("Wash", for: .normal)
        case .btnSupport:
            self.setTitle("Support", for: .normal)
        }
    }
}
