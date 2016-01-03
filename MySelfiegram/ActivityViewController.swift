//
//  ActivityViewController.swift
//  MySelfiegram
//
//  Created by Daniel Mathews on 2015-12-12.
//  Copyright © 2015 Daniel Mathews. All rights reserved.
//

import UIKit

class ActivityViewController: UITableViewController {
    
    var activites = [Activity]()
    
    override func viewDidLoad() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "Selfigram-logo"))
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        if let query = Activity.query() {
            query.orderByDescending("createdAt")
            // we need to get the details inside user (like username). so we include it in this query
            query.includeKey("user")
            // ditto for post.user to get the username of the user that submitted the post.
            query.includeKey("post.user")
            query.findObjectsInBackgroundWithBlock({ (activites, error) -> Void in
                
                if let activites = activites as? [Activity]{
                    self.activites = activites
                    self.tableView.reloadData()
                }
                
            })
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activites.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
        
        // get the specific activity we should layout based on where we are (indexPath.row)
        let activity = activites[indexPath.row]
        
        // get info on the liker and the userBeingLiked
        if let liker = activity.user.username,
            userBeingliked = activity.post.user.username {
                cell.textLabel?.text = "❤️" + " \(liker) liked \(userBeingliked)'s photo"
        }
        
        return cell
    }
    
    

}
