//
//  FeedViewController.swift
//  MySelfiegram
//
//  Created by Daniel Mathews on 2015-11-05.
//  Copyright © 2015 Daniel Mathews. All rights reserved.
//

import UIKit
import Photos

class FeedViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var posts = [Post]()
    
    var words = ["Hello", "my", "name", "is", "Selfigram"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIImage has an initalized where you can pass in the name of an image in your project to create an UIImage
        // UIImage(named: "grumpy-cat") can return nil if there is no image called "grumpy-cat" in your project
        // Our definition of Post did not include the possibility of a nil UIImage
        // so, therefore we have to add a ! at the end of it
        
//        let post0 = Post(image: UIImage(named: "grumpy-cat")!, user: me, comment: "Grumpy Cat 0")
//        let post1 = Post(image: UIImage(named: "grumpy-cat")!, user: me, comment: "Grumpy Cat 1")
//        let post2 = Post(image: UIImage(named: "grumpy-cat")!, user: me, comment: "Grumpy Cat 2")
//        let post3 = Post(image: UIImage(named: "grumpy-cat")!, user: me, comment: "Grumpy Cat 3")
//        let post4 = Post(image: UIImage(named: "grumpy-cat")!, user: me, comment: "Grumpy Cat 4")
        
//        posts = [post0, post1, post2, post3, post4]
        
        ///ra..ur@yahoo.com /
        //API key: db044ae1ff87028755bd70954811597a
        
        let url: URL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&format=json&safe_search=3&nojsoncallback=1&api_key=db044ae1ff87028755bd70954811597a&tags=cat")!
        
//        let url: URL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&format=json&safe_search=3&nojsoncallback=1&api_key=e33dc5502147cf3fd3515aa44224783f&tags=cat")!
//        
        
        
        let sharedURLSession: URLSession = URLSession.shared
        
         /**
         Three type of tasks available: 
         
             1. Data tasks send and receive data using NSData objects. Data tasks are intended for short, often interactive requests to a server.
             
             2. Upload tasks are similar to data tasks, but they also send data (often in the form of a file), and support background uploads while the app is not running.
             
             3. Download tasks retrieve data in the form of a file, and support background downloads and uploads while the app is not running.
         */
        
        
        let dataTask = sharedURLSession.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            print ("inside dataTaskWithURL with data = \(data)")
            if let jsonUnformatted = try? JSONSerialization.jsonObject(with: data!, options: []),
                let json = jsonUnformatted as? [String : AnyObject],
                let photosDictionary = json["photos"] as? [String : AnyObject],
                let photosArray = photosDictionary["photo"] as? [[String : AnyObject]]
            {
                print("json = \(json)")
                print("photosDictionary = \(photosDictionary)")
                print("photosArray = \(photosArray)")
                
                //1: Get arguments
                //2: form photo download url
                //3: Update model object (store in Post)
                //4: Handle errors, edge cases.
                
                
                for photo in photosArray {
                    
                    if let farmID = photo["farm"] as? Int,
                        let serverID = photo["server"] as? String,
                        let photoID = photo["id"] as? String,
                        let secret = photo["secret"] as? String {
                        
                            let photoURLString = "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secret).jpg"
                            //e.g url string: https://farm1.staticflickr.com/582/22992326269_b6c8fdff52.jpg
                            if let photoURL = URL(string: photoURLString){
                                let me = User(aUsername: "danny", aProfileImage: UIImage(named: "Grumpy-Cat")!)
                                let post = Post(imageURL: photoURL, user: me, comment: "A Flickr Selfie")
                                self.posts.append(post)
                            }
                    }
                
                }
                
                // We use dispatch_async because we need update all UI elements on the main thread.
                // This is a rule and you will see if again whenever you are updating UI.
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
                
            } else{
                print("error with response data")
            }
            
        }) 
        
        dataTask.resume()
        print ("outside dataTaskWithURL")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! SelfieCell
        let post = self.posts[indexPath.row]
        

        // I've added this line to prevent flickering of images
        // We are inside the cellForRowAtIndexPath method that gets called everything we lay out a cell
        // This always resets the image to blank, waits for the image to download, and then sets it
        cell.selfieImageView.image = nil
        
        //Remember the three tasks we can use, now we are downloading, hence we use the downloadTask
        
        let downloadTask = URLSession.shared.downloadTask(with: post.imageURL, completionHandler: { (url, response, error) -> Void in
            
            print("Inside download task")
            if let imageURL = url,
                let imageData = try? Data(contentsOf: imageURL) {
                    //Note: All UI updates must happen in the main thread
                    DispatchQueue.main.async(execute: { () -> Void in
                        cell.selfieImageView.image = UIImage(data: imageData)
                        
                    })
            }
        }) 
        
        downloadTask.resume()
        print("Outside download task")
        cell.usernameLabel.text = post.user.username
        cell.commentLabel.text = post.comment
        
        return cell
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        
        // 1: Create an ImagePickerController
        let pickerController = UIImagePickerController()
        
        // 2: Self in this line refers to this View Controller
        //    Setting the Delegate Property means you want to receive a message
        //    from pickerController when a specific event is triggered.
        pickerController.delegate = self
        
        if TARGET_OS_SIMULATOR == 1 {
            // 3. We check if we are running on a Simulator
            //    If so, we pick a photo from the simulators Photo Library
            pickerController.sourceType = .photoLibrary
        } else {
            // 4. We check if we are running on am iPhone or iPad (ie: not a simulator)
            //    If so, we open up the pickerController's Camera (Front Camera)
            pickerController.sourceType = .camera
            pickerController.cameraDevice = .front
            pickerController.cameraCaptureMode = .photo
        }
        
        // Preset the pickerController on screen
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 1. When the delegate method is returned, it passes along a dictionary called info.
        //    This dictionary contains multiple things that maybe useful to us.
        //    We are getting the local URL on the phone where the image is stored 
        //    we are getting this from the UIImagePickerControllerReferenceURL key in that dictionary
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
            
            //2. We create a Post object from the image
            let me = User(aUsername: "danny", aProfileImage: UIImage(named: "grumpy-cat")!)
            let post = Post(imageURL: imageURL, user: me, comment: "My Photo")
            
            //3. Add post to our posts array
            posts.append(post)
            
        }
        
        //4. We remember to dismiss the Image Picker from our screen.
        dismiss(animated: true, completion: nil)
        
        //5. Now that we have added a post, reload our table
        tableView.reloadData()
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
