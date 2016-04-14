//
//  MyTableViewController.swift
//  TreeHole
//
//  Created by David on 16/4/11.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate {

    lazy var documentsPath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first! as! String
        }()
    
    var uid:Int!
    
    var cellAry:[UITableViewCell!] = []
    var curId = 0
    var fetchCell:UITableViewCell!
    var fetching = false
    var bottom = false
    var refreshing = false
    
    var refreshText:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let user = "\(documentsPath)/user.plist"
        uid = NSDictionary(contentsOfFile: user)?.objectForKey("uid") as! Int
        println("uid:\(uid)")
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        refresh()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer.delegate = nil
    }
    
    //显示数据
    func refresh(){
        println("refresh")
        refreshControl?.beginRefreshing()
        refreshing = true
        curId = 0
        
        
        //下拉加载更多
        fetchCell = UITableViewCell(frame: CGRectMake(0, 0, view.frame.width, 50))
        refreshText = UILabel(frame: CGRectMake(view.frame.width/2 - 100, 5, 200, 20))
        refreshText.text = "上拉加载更多"
        refreshText.font = UIFont.systemFontOfSize(12)
        refreshText.textAlignment = NSTextAlignment.Center
        fetchCell.addSubview(refreshText)
        
        
        fetch()
    }
    func fetch(){
        println("fetch")
        fetching = true
        var dataAry:NSArray!
        println("curId:\(curId)")
        var url = "http://45.78.19.76/treehole/fetchlike.php?index=\(curId)&userid=\(uid)"
        if segSelect == 1{
            url = "http://45.78.19.76/treehole/fetchmine.php?index=\(curId)&userid=\(uid)"
        }
        
        refreshText.text = "正在加载"
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: url)!), queue: NSOperationQueue()) { (resp:NSURLResponse!, data:NSData!, err:NSError!) -> Void in
            if err == nil{
                dataAry = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
                self.fetching = false
                for i in 0..<10{
                    if dataAry.objectAtIndex(i) is NSDictionary{
                        var dic = dataAry.objectAtIndex(i) as! NSDictionary
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            if self.refreshing && self.cellAry.count > 0{
                                self.cellAry.removeAll()
                            }
                            self.refreshing = false
                            self.showItem(dic)
                            
                        })
                        
                    }else{
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            self.refreshText.text = "没有更多了"
                            self.bottom = true
                        })
                        
                        break
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                })
                
            }
            
        }
        
        
        
    }
    
    
    
    func showItem(dic:NSDictionary){
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
        cellAry.append(cell)
        cell.frame = CGRectMake(0, 0, view.frame.width, 225)
        
        //tColor
        cell.backgroundColor = colorID((dic.objectForKey("tColor") as! NSString).integerValue)
        
        var label = UITextView(frame: CGRectMake(cell.frame.width*0.1, (cell.frame.height-16)*0.1, cell.frame.width*0.8, (cell.frame.height-16)*0.8))
        
        //tContent
        label.text = dic.objectForKey("tCon") as! String
        
        label.editable = false
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor(white: 1, alpha: 0)
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        cell.addSubview(label)
        
        var timeLabel = UILabel(frame: CGRectMake(16, cell.frame.height-24, 100, 16))
        
        //tTime
        var dateStr = dic.objectForKey("tDate") as! NSString
        var dateFomate = NSDateFormatter()
        dateFomate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date = dateFomate.dateFromString(dateStr as String)
        
        
        timeLabel.text = showTime(date!)
        
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.font = UIFont.systemFontOfSize(12)
        cell.addSubview(timeLabel)
        
        var likeIcon = UIButton(frame: CGRectMake(cell.frame.width-80, cell.frame.height-24, 48, 16))
        
        //isLiked
        
        likeIcon.setImage(UIImage(named: "liked"), forState: UIControlState.Normal)
        if segSelect == 1{
            let isLike: AnyObject? = dic.objectForKey("ulike")
            if isLike != nil{
                likeIcon.setImage(UIImage(named: "liked"), forState: UIControlState.Normal)
            }else{
                likeIcon.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
            }
        }
        //like
        let like = (dic.objectForKey("tlike") as! NSString).integerValue
        likeIcon.setTitle("  \(like)", forState: UIControlState.Normal)
        
        likeIcon.titleLabel?.font = UIFont.systemFontOfSize(12)
        likeIcon.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        //tid
        likeIcon.tag = (dic.objectForKey("tid") as! NSString).integerValue
        curId++
        
        likeIcon.addTarget(self, action: "likeTouch:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //点赞
        cell.addSubview(likeIcon)
        
        //more
        var moreBtn = moreButton(frame: CGRectMake(cell.frame.width - 32, 16, 16, 16), uid: (dic.objectForKey("ubelong") as! NSString).integerValue, tid: (dic.objectForKey("tid") as! NSString).integerValue)
        moreBtn.setImage(UIImage(named: "more"), forState: UIControlState.Normal)
        moreBtn.addTarget(self, action: "moreMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.addSubview(moreBtn)
    }
    
    var selectMine = false
    var selectTid = 0
    var selectUid = 0
    //更多菜单
    func moreMenu(sender:moreButton){
        
        var actionStr = "举报"
        if uid == sender.ubelong{
            actionStr = "删除"
            selectMine = true
            selectTid = sender.textid
            selectUid = sender.ubelong
        }
        var acs = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: actionStr)
        acs.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0{
            if selectMine{ //删除
                NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://45.78.19.76/treehole/delete.php?tid=\(selectTid)")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse!, data:NSData!, err:NSError!) -> Void in
                    if err == nil{
                        println("delete success")
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            self.refresh()
                        })
                    }else{
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            UIAlertView(title: "删除失败", message: "", delegate: self, cancelButtonTitle: "好").show()
                        })
                    }
                    
                    
                })
            }else{ // 举报
                NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://45.78.19.76/treehole/tipoff.php?tid=\(selectTid)")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse!, data:NSData!, err:NSError!) -> Void in
                    if err == nil{
                        println("delete success")
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            UIAlertView(title: "举报成功", message: "", delegate: self, cancelButtonTitle: "好").show()
                        })
                    }else{
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            UIAlertView(title: "举报失败", message: "", delegate: self, cancelButtonTitle: "好").show()
                        })
                    }
                    
                    
                })
            }
        }
    }
    
    //点赞
    func likeTouch(sender:UIButton){
        if sender.imageForState(UIControlState.Normal) == UIImage(named: "like"){
            var btnTitle = sender.titleLabel?.text!
            var nss = (btnTitle! as NSString).substringFromIndex(2)
            var likes = nss.toInt()!
            likes++
            sender.setTitle("  \(likes)", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "liked"), forState: UIControlState.Normal)
            
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.Autoreverse, animations: {
                sender.transform = CGAffineTransformMakeScale(2, 2)
                }) { (finished) -> Void in
                    sender.transform = CGAffineTransformMakeScale(1, 1)
            }
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://45.78.19.76/treehole/like.php?userid=\(uid)&textid=\(sender.tag)")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse!, data:NSData!, err:NSError!) -> Void in
                if err == nil{
                    println("like success")
                }
            })
        }else{
            var btnTitle = sender.titleLabel?.text!
            var nss = (btnTitle! as NSString).substringFromIndex(2)
            var likes = nss.toInt()!
            likes--
            sender.setTitle("  \(likes)", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://45.78.19.76/treehole/unlike.php?userid=\(uid)&textid=\(sender.tag)")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse!, data:NSData!, err:NSError!) -> Void in
                if err == nil{
                    println("unlike success")
                }
            })
        }
        
    }
    
    
    
    func showTime(date:NSDate) ->String{
        let now = NSDate()
        
        let das = NSCalendar.currentCalendar()
        //new 一个 NSCalendar
        let flags: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit
        //设置格式
        let nowCom = das.components(flags, fromDate: now)
        let timeCom = das.components(flags, fromDate: date)
        //创建当前和需要计算的components
        //components有之前设置的格式的各种参数
        if timeCom.year == nowCom.year{
            if timeCom.month == nowCom.month {
                if timeCom.day == nowCom.day{
                    if timeCom.hour == nowCom.hour{
                        return "\(nowCom.minute - timeCom.minute)分钟前"
                    }else{
                        var zero = ""
                        timeCom.hour = (timeCom.hour+12)%24
                        if timeCom.minute < 10{
                            zero = "0"
                        }
                        return "今天 \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }
                }else{
                    if nowCom.day - timeCom.day == 1{
                        timeCom.hour = (timeCom.hour+12)%12
                        var zero = ""
                        if timeCom.minute < 10{
                            zero = "0"
                        }
                        return "昨天 \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }else{
                        return "\(nowCom.day - timeCom.day)天前"
                    }
                }
            }else{
                return "\(timeCom.month)-\(timeCom.day)"
            }
            
        }else{
            return "\(timeCom.year)-\(timeCom.month)-\(timeCom.day)"
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    var segSelect = 0
    @IBAction func segChange(sender: UISegmentedControl) {
        segSelect = sender.selectedSegmentIndex
        tableView.setContentOffset(CGPointMake(0, -75), animated: true)
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0{
            return cellAry.count
        }else{
            return 1
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 225
        }else{
            return 40
        }
        
    }
    
    
    func colorID(id:Int) ->UIColor{
        switch id{
        case 0:
            return UIColor(red: 27.0/255.0, green: 188/255.0, blue: 155/255.0, alpha: 1)
        case 1:
            return UIColor(red: 70.0/255.0, green: 179/255.0, blue: 158/255.0, alpha: 1)
        case 2:
            return UIColor(red: 88/255.0, green: 214/255.0, blue: 141/255.0, alpha: 1)
        case 3:
            return UIColor(red: 39/255.0, green: 174/255.0, blue: 97/255.0, alpha: 1)
        case 4:
            return UIColor(red: 53/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1)
        case 5:
            return UIColor(red: 41/255.0, green: 127/255.0, blue: 184/255.0, alpha: 1)
        case 6:
            return UIColor(red: 154/255.0, green: 89/255.0, blue: 181/255.0, alpha: 1)
        case 7:
            return UIColor(red: 141/255.0, green: 68/255.0, blue: 173/255.0, alpha: 1)
        case 8:
            return UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1)
        case 9:
            return UIColor(red: 45/255.0, green: 62/255.0, blue: 80/255.0, alpha: 1)
        case 10:
            return UIColor(red: 243/255.0, green: 156/255.0, blue: 17/255.0, alpha: 1)
        case 11:
            return UIColor(red: 230/255.0, green: 127/255.0, blue: 34/255.0, alpha: 1)
        case 12:
            return UIColor(red: 210/255.0, green: 84/255.0, blue: 0/255.0, alpha: 1)
        default:
            return UIColor.blackColor()
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if cellAry.count > 0{
                return cellAry[indexPath.row]
            }
            return UITableViewCell()
        }else{
            return fetchCell
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
