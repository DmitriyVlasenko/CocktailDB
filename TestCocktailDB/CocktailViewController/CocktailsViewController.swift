//
//  CocktailsViewController.swift
//  TestCocktailDB
//
//  Created by Дмитрий Власенко on 25.01.2020.
//  Copyright © 2020 Дмитрий Власенко. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
final class CocktailsViewController: UITableViewController {
    
    
    //MARK: - Properties -
    
    var cocktailData = [[CocktailModel]]()
    var categories = [String]()
    var selectedCategories = [String]()
    var isloadingData = false
    
    
    //MARK: - Outlets -
    
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    
    
    //MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories {
            self.selectedCategories = self.categories
            self.loadDrinks(forCategory: self.categories[0]) {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Functions -
    
    func filterApplied(filterCategories: [String]) {
        self.selectedCategories = filterCategories
        self.cocktailData = []
        self.isloadingData = true
        loadDrinks(forCategory: selectedCategories[0]) {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FiltersViewController
        {
            let vc = segue.destination as? FiltersViewController
            for i in 0...categories.count-1 {
                vc?.categories.append(FiltersTableViewCellModel(category: categories[i]))
            }
            vc?.cocktailsvc = self
        }
    }
    
    // MARK: - DataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktailData[section].count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cocktailData.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedCategories[section]
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailTableViewCell", for: indexPath) as! CocktailTableViewCell
        cell.cocktailName.text = cocktailData[indexPath.section][indexPath.row].name
        cell.cocktailImageView.sd_setImage(with:  URL(string: cocktailData[indexPath.section][indexPath.row].imageUrl), placeholderImage: UIImage(systemName: "photo"), options: .progressiveLoad, completed: nil)
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section != selectedCategories.count - 1 {
            if indexPath.section == cocktailData.count - 1 {
                if indexPath.row == cocktailData[indexPath.section].count - 1 {
                    if cocktailData.count < selectedCategories.count {
                        if !isloadingData {
                            loadDrinks(forCategory: selectedCategories[cocktailData.count]) {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
    }
}

extension CocktailsViewController {
    func loadCategories(completion: @escaping () -> Void) {
        Alamofire.request("https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list").responseJSON {
            (response) in
            if let err = response.error {
                print(err.localizedDescription)
            }
            else {
                let value = response.result.value! as! NSDictionary
                guard let arrayOfItems = value["drinks"] as? [[String:AnyObject]]
                else {
                    print("Не могу перевести в массив")
                    return
                }
                for itm in arrayOfItems {
                    self.categories.append(itm["strCategory"] as! String)
                }
                completion()
            }
        }
    }
    
    func loadDrinks(forCategory category : String, completion: @escaping () -> Void ) {
        self.isloadingData = true
        let str = category.replacingOccurrences(of: " ", with: "_")
        Alamofire.request("https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(str)").responseJSON { (response) in
            if let err = response.error {
                print(err.localizedDescription)
            }
            else {
                let value = response.result.value! as! NSDictionary
                guard let arrayOfItems = value["drinks"] as? [[String:AnyObject]]
                else {
                    print("Не могу перевести в массив")
                    return
                }
                var returnedData : [CocktailModel] = []
                for item in arrayOfItems {
                    returnedData.append(CocktailModel(name: item["strDrink"] as! String, imageUrl: item["strDrinkThumb"] as! String))
                }
                self.cocktailData.append(returnedData)
                self.isloadingData = false
                completion()
                
                
            }
        }
    }
}
