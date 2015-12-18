//
//  SelfieCell.swift
//  MySelfiegram
//
//  Created by Daniel Mathews on 2015-11-08.
//  Copyright © 2015 Daniel Mathews. All rights reserved.
//

import UIKit
import Parse

class SelfieCell: UITableViewCell {

    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var post:Post? {
        didSet{
            if let post = post {
                // I've added this line to prevent flickering of images
                // We are inside the cellForRowAtIndexPath method that gets called everytime we lay out a cell
                // This always resets the image to blank, waits for the image to download, and then sets it
                selfieImageView.image = nil
                
                // set it defaulted to false
                self.likeButton.selected = false
                
                let imageFile = post.image
                imageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                    if let data = data {
                        let image = UIImage(data: data)
                        self.selfieImageView.image = image
                    }
                }
                
                usernameLabel.text = post.user.username
                commentLabel.text = post.comment
                
                let query = post.likes.query()
                query.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                    
                    if let users = users as? [PFUser]{
                        for user in users {
                            if user.objectId == PFUser.currentUser()?.objectId {
                                self.likeButton.selected = true
                            }
                        }
                        
                    }
                })
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func likeButtonClicked(sender: UIButton) {
        
        // the ! symbol means NOT
        // We are therefore setting the button's selected state to
        // the opposite of what it was. This is a great way to toggle
        //
        sender.selected = !sender.selected
        
        if let post = post,
           let user = PFUser.currentUser() {
            
            if sender.selected {
                // should add like
                
                post.likes.addObject(user)
                post.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("likes successfully saved")
                        self.likeButton.selected = true
                        let activity = Activity(type: "like", post: post, user: user)
                        activity.saveInBackgroundWithBlock({ (success, error) -> Void in
                            print("actvity successfully saved")
                        })
                    }else{
                        print("error is \(error)")
                    }
                })

                
            } else {
                // should remove like
                
                post.likes.removeObject(user)
                post.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("likes successfully removed")
                        self.likeButton.selected = false
                        if let activityQuery = Activity.query(){
                            activityQuery.whereKey("post", equalTo: post)
                            activityQuery.whereKey("type", equalTo: "like")
                            activityQuery.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
                                
                                if let activities = activities {
                                    for activity in activities {
                                        activity.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                            print("deleted activity")
                                        })
                                    }
                                }
                                
                            })
                        }
                    }else{
                        print("error is \(error)")
                    }
                })
                
            }

        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
