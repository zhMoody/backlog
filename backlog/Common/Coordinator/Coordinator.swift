import CoreData
import UIKit

protocol Coordinator {
  associatedtype T

  func close()
  func close(completion: (() -> Void)?)
  func goBack()

  var viewController: T { get }
}
