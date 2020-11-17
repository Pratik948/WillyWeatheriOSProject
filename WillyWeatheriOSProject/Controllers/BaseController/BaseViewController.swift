//
//  BaseViewController.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 17/11/20.
//

import UIKit

enum ControllerAPIStatus {
    case fetching
    case completed
}

protocol Pagination {
    var totalPage: Int { get set}
    var currentPage: Int { get set}
    var apiStatus: ControllerAPIStatus { get set}
}

class BaseViewController: UIViewController {
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView.init(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
