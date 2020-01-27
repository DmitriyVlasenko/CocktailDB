//
//  FiltersViewController.swift
//  TestCocktailDB
//
//  Created by Дмитрий Власенко on 25.01.2020.
//  Copyright © 2020 Дмитрий Власенко. All rights reserved.
//

import UIKit
final class FiltersViewController : UIViewController {
    var categories : [FiltersTableViewCellModel] = []
    var cocktailsvc : CocktailsViewController!
    @IBOutlet weak var filtersButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        filtersButton.layer.borderWidth = 2.0
        filtersButton.layer.cornerRadius = 25
    }
    
    @IBAction func applyChangesButtonTapped(_ sender: UIButton) {
        var isAnyCategorySelected = false
        for i in 0...categories.count - 1 {
            if categories[i].isSelected {
                isAnyCategorySelected = true
                break
            }
        }
        
        if isAnyCategorySelected {
            var selectedCategories : [String] = []
        for i in 0...categories.count-1 {
            if categories[i].isSelected {
                selectedCategories.append(categories[i].category)
            }
        }
            self.cocktailsvc.filterApplied(filterCategories: selectedCategories)
            self.cocktailsvc.filtersButton.image = UIImage(systemName: "square.stack.3d.down.right.fill")
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
extension FiltersViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersTableViewCell", for: indexPath) as! FiltersTableViewCell
        cell.categoryName.text = categories[indexPath.row].category
        if categories[indexPath.row].isSelected {
            cell.isSelectedView.image = UIImage(systemName: "checkmark")
        }
        else {
            cell.isSelectedView.image = nil
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categories[indexPath.row].isSelected {
            categories[indexPath.row].isSelected = false
        }
        else {
            categories[indexPath.row].isSelected = true
        }
        tableView.reloadData()
    }
    
}
