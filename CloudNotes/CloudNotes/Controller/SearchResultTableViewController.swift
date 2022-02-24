//
//  SearchResultTableViewController.swift
//  CloudNotes
//
//  Created by 이차민 on 2022/02/24.
//

import UIKit

class SearchResultTableViewController: UITableViewController {
    var filteredMemo = [Memo]() {
        didSet {
            filteredMemo.sort { $0.lastModified > $1.lastModified }
        }
    }
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellWithClass: MemoTableViewCell.self)
        configLayout()
    }
    
    func configResultLabel(with text: String) {
        resultLabel.text = text
    }
    
    func configLayout() {
        let backgroundView = UIView()
        backgroundView.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.centerYAnchor)
        ])
        tableView.backgroundView = backgroundView
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMemo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MemoTableViewCell.self, for: indexPath)
        
        let data = filteredMemo[indexPath.row]

        cell.configureCellContent(from: data)
        
        return cell
    }
}
