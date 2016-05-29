import UIKit

class <#class-name#>: UIViewController {

  // MARK: - Properties

  @IBOutlet weak var tableView: UITableView!


  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    // TableView setup
    tableView.dataSource = self
    tableView.delegate = self
  }

  // MARK: - IBActions



  // MARK: - Helper Functions



}


// MARK: - UITableViewDelegate Extension

extension <#class-name#>: UITableViewDelegate {

}


// MARK: - UITableViewDataSource Extension

extension <#class-name#>: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    <#code#>
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(<#identifier#>, forIndexPath: indexPath) as! <#CellType#>
    
    return cell
  }

}