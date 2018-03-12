//
//  SharingImageTableViewController.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/12/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit

class SharingImageTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var sharingImages = [SharingImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the sample data.
        loadSampleSharingImages()
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
        // #warning Incomplete implementation, return the number of rows
        return sharingImages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SharingImageTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SharingImageTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SharingImageTableViewCell.")
        }

        // Fetches the appropriate meal for the data source layout.
        let sharingImage = sharingImages[indexPath.row]

        cell.nameLabel.text = sharingImage.name
        cell.photoImageView.image = sharingImage.photo
        switch sharingImage.type {
        case SharingImage.sharingImageType.Person:
            cell.typeLabel.text = "Person"
        case SharingImage.sharingImageType.Action:
            cell.typeLabel.text = "Action"
        case SharingImage.sharingImageType.FreeformInput:
            cell.typeLabel.text = "Input"
        }
        cell.descriptionLabel.text = sharingImage.description

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Private Methods
    
    private func loadSampleSharingImages() {
        let obamaPhoto = UIImage(named: "obama")
        let gmailPhoto = UIImage(named: "gmail")
        
        guard let sharingImage1 = SharingImage(name: "obama", photo: obamaPhoto!, description: "president", type: SharingImage.sharingImageType.Person) else {
            fatalError("Unable to instantiate sharingImage1")
        }
        guard let sharingImage2 = SharingImage(name: "gmail", photo: gmailPhoto!, description: "send an email", type: SharingImage.sharingImageType.Action) else {
            fatalError("Unable to instantiate sharingImage2")
        }
        
        sharingImages += [sharingImage1, sharingImage2]
    }
    
    //MARK: Actions
    
    @IBAction func unwindToSharingImageList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SharingImageViewController, let sharingImage = sourceViewController.sharingImage {
            // Add a new meal.
            let newIndexPath = IndexPath(row: sharingImages.count, section: 0)
            sharingImages.append(sharingImage)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
}
