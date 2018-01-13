//
//  MemeTableViewController.swift
//  memeApp
//
//  Created by Colin Walsh on 1/11/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memeImageView: UIImageView!
    
}

class MemeTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var memes = [Meme]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memes.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memes = appDelegate.memes
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeTVCell", for: indexPath) as! MemeTableViewCell
        
        cell.titleLabel.text = memes[indexPath.row].title
        cell.memeImageView.image = memes[indexPath.row].completedImage
        cell.memeImageView.backgroundColor = .black
        cell.memeImageView.contentMode = .scaleAspectFit
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! MemeDetailViewController
        destinationVC.memeImage = memes[indexPath.row].completedImage
        navigationController?.pushViewController(destinationVC, animated: true)
    }

}
