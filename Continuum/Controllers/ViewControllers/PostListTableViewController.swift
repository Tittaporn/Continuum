//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [Post] {
        return isSearching ? resultsArray : PostController.shared.posts
    }
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        postSearchBar.delegate = self
        //fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
//        tableView.reloadData()
        fetchPosts()
    }
    
    // MARK: - Helper Fuctions
    func fetchPosts(){
        self.activityView.isHidden = false
        self.activityIndicator.startAnimating()
        PostController.shared.fetchPosts { (result) in
            switch result {
            case .success(let posts):
                guard let posts = posts else {return}
                self.resultsArray = posts
                self.activityView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        
        let post = dataSource[indexPath.row]
        cell.post = post
        
        return cell
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinaionVC = segue.destination as? PostDetailTableViewController else { return }
            let post = dataSource[indexPath.row]
            destinaionVC.post = post
        }
    }
}

extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = PostController.shared.posts.filter({ (post) -> Bool in
            return post.matches(searchTerm: searchText)
        })
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //  using it to set the results array equal to PostController.shared.posts
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}


