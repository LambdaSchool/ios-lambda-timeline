//
//  DetailViewController.swift
//  VideoCollection
//
//  Created by Bhawnish Kumar on 6/3/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var videoClip: URL!
    var delegate: VideosCollectionViewController!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func updateViews() {
      
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
