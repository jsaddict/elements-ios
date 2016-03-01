//
//  ProfileViewController.swift
//  Pods
//
//  Created by John Rikard Nilsen on 8/2/16.
//
//

import UIKit
import Tapglue

public class ProfileViewController: UIViewController, ProfileBiographyDelegate {

    let cellProfileBiographyReusableIdentifier = "ProfileBiographyView"
    let cellFollowEventReusableIdentifier = "FollowEventCell"
    let cellLikeEventReusableIdentifier = "LikeEventCell"
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    var events = [TGEvent]()
    var tapConnectionType: ConnectionType?
    var userId: String?
    var user: TGUser? {
        didSet {
            if user?.isCurrentUser ?? false {
                let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTapped")
                navigationItem.rightBarButtonItem = edit
            }
        }
    }
    public var delegate: ProfileViewDelegate? {
        didSet {
            user = delegate?.referenceUserInProfileViewController(self)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNibs(nibNames: [cellProfileBiographyReusableIdentifier, cellFollowEventReusableIdentifier, cellLikeEventReusableIdentifier])
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "popViewController")
        navigationItem.leftBarButtonItem = backButton
    }
    
    override public func viewWillAppear(animated: Bool) {
        if let userId = userId {
            retrieveAndSetUserWithId(userId)
        } else if let currentUser = TGUser.currentUser() {
            user = currentUser
            tableView.reloadData()
            if let user = user {
                retrieveAndSetUserWithId(user.userId)
            }
        }
    }
    
    func retrieveAndSetUserWithId(userId: String) {
        Tapglue.retrieveUserWithId(userId, withCompletionBlock:{(retrievedUser, error) -> Void in
            if error != nil {
                AlertFactory.defaultAlert(self)
            } else {
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.user = retrievedUser
                    self.retrieveActivity()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func editTapped() {
        performSegueWithIdentifier("toEditProfile", sender: nil)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        if let user = user {
            retrieveAndSetUserWithId(user.userId)
        } else {
            refreshControl.endRefreshing()
        }
    }

    
    func retrieveActivity() {
        Tapglue.retrieveEventsForUser(user) { (events: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {() -> Void in
                    self.events = events as! [TGEvent]
                    self.tableView.reloadData()
                    print("fetched events:  \(self.events)")
                }
            } else {
                AlertFactory.defaultAlert(self)
            }
        }
    }
    
    // MARK: - ProfileBiographyView
    
    func profileBiographyViewFollowersSelected() {
        tapConnectionType = ConnectionType.Followers
        if delegate?.defaultNavigationEnabledInProfileViewController(self) ?? true {
            performSegueWithIdentifier("toConnections", sender: user)
        } else {
            delegate?.profileViewController(self, didSelectConnectionsOfType: .Followers, forUser: user!)
        }
    }
    
    func profileBiographyViewFollowingSelected() {
        tapConnectionType = ConnectionType.Following
        if delegate?.defaultNavigationEnabledInProfileViewController(self) ?? true {
            performSegueWithIdentifier("toConnections", sender: user)
        } else {
            delegate?.profileViewController(self, didSelectConnectionsOfType: .Following, forUser: user!)
        }
    }
    
    func profileBiographyViewErrorOcurred(profileBiographyView: ProfileBiographyView) {
        let alert = UIAlertController(title: "Something went wrong", message: "please try again later", preferredStyle: .Alert)
        let action = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated:true, completion: nil)
    }

    // MARK: - Navigation

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toConnections" {
            let connectionsVC = segue.destinationViewController as! ConnectionsViewController
            connectionsVC.type = tapConnectionType
            connectionsVC.referenceUser = sender as? TGUser
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user != nil ? 1:0) + events.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellProfileBiographyReusableIdentifier) as! ProfileBiographyView
            cell.delegate = self
            cell.user = user
            return cell
        }
        if events[indexPath.row - 1].type == "tg_follow" {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellFollowEventReusableIdentifier) as! FollowEventCell
            cell.event = events[indexPath.row - 1]
            return cell
        }
        if events[indexPath.row-1].type == "tg_like" {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellLikeEventReusableIdentifier) as! LikeEventCell
            cell.event = events[indexPath.row - 1]
            return cell
        }
        return UITableViewCell()
    }
}

extension ProfileViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

public protocol ProfileViewDelegate {
    func defaultNavigationEnabledInProfileViewController(profileViewController: ProfileViewController) -> Bool
    func referenceUserInProfileViewController(profileViewController: ProfileViewController) -> TGUser
    func profileViewController(profileViewController: ProfileViewController, didSelectConnectionsOfType: ConnectionType, forUser: TGUser)
}
