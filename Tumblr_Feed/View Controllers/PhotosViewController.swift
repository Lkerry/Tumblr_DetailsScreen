//
//  PhotosViewController.swift
//  Tumblr_Feed
//
//  Created by Kerry LEVEILLE on 9/15/18.
//  Copyright © 2018 Kerry LEVEILLE. All rights reserved.
//



import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var image: UIImage!
    
    //Initialize an empty array
    var posts: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 168
        tableView.estimatedRowHeight = 200
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        fetchPhotos()
        didPullToRefresh(refreshControl)
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        
        fetchPhotos()
    }
    
    func fetchPhotos(){
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) {(data, response, error) in
            if let error = error{
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                print(dataDictionary)
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1    //no. of rows in the section
    }
    
    
    
    
    // -------
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        let dateLabel = UILabel(frame: CGRect(x: 50, y: 5, width: 250, height: 15))
        let post = posts[section]
        if let date = post["date"] as? String {
            dateLabel.text = date
        }
        
        headerView.addSubview(dateLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.section]
        if let photos = post["photos"] as? [[String: Any]]{
            // photos is NOT nil, we can use it!
            // todo: get the photo url
            // Get the first photo in the photos array
            let photo = photos[0]
            // Get the original size dictionary from the photo
            let originalSize =  photo["original_size"] as! [String: Any]
            // Get the url string from the original size dictionary
            let urlString = originalSize["url"] as! String
            // Create a URL using the urlString
            let url = URL(string: urlString)
            
            // call the AlamofireImage method
            cell.PhotoImageView.af_setImage(withURL: url!)
        }
        // Configure PhotoCell using the outlets that you've defined.
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoDetailsViewController
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let post = posts[indexPath.section]
        let photos = post["photos"] as! [[String: Any]]
        let photo = photos[0]
        let originalSize = photo["original_size"] as! [String: Any]
        let urlString = originalSize["url"] as! String
        vc.imageURL = URL(string: urlString)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
