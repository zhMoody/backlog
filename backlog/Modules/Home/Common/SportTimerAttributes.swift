import ActivityKit

struct SportTimerAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var remainingSeconds: Int
  }
  var totalSeconds: Int
}

