//
//  NicooLoadedFailedView.swift
//  NicooPlayer
//
//  Created by 小星星 on 2018/6/19.
//

import UIKit
import SnapKit

class NicooLoadedFailedView: UIView {
    
    fileprivate var loadFailedTitle: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .center
        lable.text = "网络不可用，请检查网络设置"
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textColor = UIColor.white
        
        
        return lable
    }()
    var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点击重试", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(retryButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    var retryButtonClickBlock: ((_ sender: UIButton) ->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius  = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.loadUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func loadUI() {
        addSubview(loadFailedTitle)
        addSubview(retryButton)
        layoutAllSubviews()
    }
    @objc func retryButtonClick(_ sender: UIButton) {
        if retryButtonClickBlock != nil {
            retryButtonClickBlock!(sender)
        }
        self.removeFromSuperview()
    }
    fileprivate func layoutAllSubviews() {
        loadFailedTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-25)
            make.height.equalTo(30)
        }
        retryButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(25)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
    }
    
}
