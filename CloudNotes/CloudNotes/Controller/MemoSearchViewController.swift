//
//  MemoSearchViewController.swift
//  CloudNotes
//
//  Created by 이차민 on 2022/02/24.
//

import UIKit

class MemoSearchViewController: UISearchController {

    init(resultVC: UIViewController) {
        super.init(searchResultsController: resultVC)
        searchBar.placeholder = "메모를 검색해보세요!"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
}
