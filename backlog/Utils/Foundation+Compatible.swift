import Foundation

public struct FoundationEx<T> {
  public let t: T
  public init(_ t: T) {
    self.t = t
  }
}

public protocol FoundationExCompatible {
  associatedtype E
  static var ex: FoundationEx<E>.Type { get set }
  var ex: FoundationEx<E> { get set }
}

public extension FoundationExCompatible {
  static var ex: FoundationEx<Self>.Type {
    get { FoundationEx<Self>.self }
    set {}
  }
  var ex: FoundationEx<Self> {
    get { FoundationEx(self) }
    set {}
  }
}

extension String: FoundationExCompatible {}
extension Double: FoundationExCompatible {}
extension Int: FoundationExCompatible {}
extension UInt8: FoundationExCompatible {}
extension UInt16: FoundationExCompatible {}
extension Date: FoundationExCompatible {}
extension Data: FoundationExCompatible {}

extension FoundationEx where T == UInt8 {
  var hex: String {
    String(format: "%02X", t)
  }
}

extension FoundationEx where T == String {
  var with86: String { "+86\(t)" }

  var plus86: String { "+86 \(t)" }

  var date: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.date(from: t)
  }

  func time(dateFormat: String = "yyyy/MM/dd") -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    return formatter.date(from: t)
  }

  var masked: String {
    let countryCodeRegex = try! NSRegularExpression(pattern: #"^\+(?<code>\d{1,2})"#, options: [])
    let fullRange = NSRange(location: 0, length: t.utf16.count)
    var countryCode: String? = .none

    if let match = countryCodeRegex.firstMatch(in: t, options: [], range: fullRange) {
      if let codeRange = Swift.Range(match.range(withName: "code"), in: t) {
        countryCode = String(t[codeRange])
      }
    }

    var phonePartsRegex: NSRegularExpression
    if countryCode == "86" {
      phonePartsRegex = try! NSRegularExpression(pattern: #"^\+(86)(\d{3})(\d{4})(\d{4})$"#, options: [])
    } else {
      return t
    }

    if let phonePartsMatch = phonePartsRegex.firstMatch(in: t, options: [], range: fullRange) {
      guard let group2Range = Swift.Range(phonePartsMatch.range(at: 2), in: t),
            let group3Range = Swift.Range(phonePartsMatch.range(at: 3), in: t),
            let group4Range = Swift.Range(phonePartsMatch.range(at: 4), in: t)
      else {
        return t
      }

      let group2 = String(t[group2Range])
      let group3 = String(t[group3Range])
      let group4 = String(t[group4Range])

      let maskedPart = String(repeating: "*", count: group3.count)
      return "\(group2) \(maskedPart) \(group4)"
    }
    return t
  }

  var chunk: [UInt8]? {
    if t.count % 2 == 0 {
      var current = t.startIndex
      var result: [UInt8] = []
      while current < t.endIndex {
        let next = t.index(current, offsetBy: 2)
        let pair = String(t[current ..< next])
        if let byte = UInt8(pair, radix: 16) {
          result.append(byte)
        } else {
          return .none
        }
        current = next
      }
      return result
    } else {
      return .none
    }
  }
}

enum TimeKind {
  case year(Int)
  case month(Int)
  case day(Int)
  case hour(Int)
  case minute(Int)
  case second(Int)
}

extension FoundationEx where T == Date {
  func stringify(_ dateFormat: String = "yyyy/MM/dd", locale: Locale = Locale(identifier: "en_US")) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = locale
    return formatter.string(from: t)
  }

  func isSameDay(_ other: Date) -> Bool {
    Calendar.current.isDate(t, inSameDayAs: other)
  }

  func age(_ components: Set<Calendar.Component>? = [.year]) -> String {
    let calendar = Calendar.current
    let d = calendar.dateComponents(components!, from: t, to: Date())
    if let year = d.year {
      if year == 0, let month = d.month {
        return "\(month) 个月"
      } else {
        return "\(year) 岁"
      }
    }
    return ""
  }

  func add(_ kind: TimeKind) -> Date {
    let (component, value): (Calendar.Component, Int) = switch kind {
    case let .year(value): (.year, value)
    case let .month(value): (.month, value)
    case let .day(value): (.day, value)
    case let .hour(value): (.hour, value)
    case let .minute(value): (.minute, value)
    case let .second(value): (.second, value)
    }
    return Calendar.current
      .date(byAdding: component, value: value, to: t)!
  }

  func add(component: Calendar.Component, value: Int) -> Date {
    Calendar.current.date(byAdding: component, value: value, to: t)!
  }

  func timeInterval(_ date: Date, component: Calendar.Component) -> Int {
    t
      .timeIntervalSince(date)
      .ex
      .toDateComponents(component: component)
      .value(for: component)!
  }

  func subtract(_ kind: TimeKind) -> Date {
    let (component, value): (Calendar.Component, Int) = switch kind {
    case let .year(value): (.year, value)
    case let .month(value): (.month, value)
    case let .day(value): (.day, value)
    case let .hour(value): (.hour, value)
    case let .minute(value): (.minute, value)
    case let .second(value): (.second, value)
    }
    return Calendar.current
      .date(byAdding: component, value: -value, to: t)!
  }

  func numberAge(_ components: Set<Calendar.Component>? = [.year]) -> String {
    let calendar = Calendar.current
    let d = calendar.dateComponents(components!, from: t, to: Date())
    if let year = d.year {
      return String(year)
    }
    return ""
  }

  func from(hm: (Int, Int)) -> Date? {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: t)
    var dateComponents = components
    dateComponents.hour = hm.0
    dateComponents.minute = hm.1
    return calendar.date(from: dateComponents)
  }

  /// 判断是否是儿童（暂定 0-7 岁指儿童）
  var isChild: Bool {
    let calendar = Calendar.current
    let d = calendar.dateComponents([.year], from: t, to: Date())
    return if let year = d.year, year <= 7 { true } else { false }
  }

  var months: Int {
    let now = Date()
    return t.ex.year == now.ex.year
      ? now.ex.month
      : Calendar.current.range(of: .month, in: .year, for: t)!.count
  }

  var days: Int {
    let now = Date()
    return (t.ex.year, t.ex.month) == (now.ex.year, now.ex.month)
      ? now.ex.day
      : Calendar.current.range(of: .day, in: .month, for: t)!.count
  }

  var dayList: [Date] {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: t)!
    return range.map {
      calendar.date(byAdding: .day, value: $0 - 1, to: calendar.date(from: calendar.dateComponents([.year, .month], from: t))!)!
    }
  }

  func listTo(end: Date, step: TimeInterval) -> [Date] {
    var dates: [Date] = []
    var currentDate = t
    while currentDate <= end {
      dates.append(currentDate)
      currentDate = currentDate.addingTimeInterval(step)
    }
    return dates
  }

  func list(to end: Date, step: Int = 8) -> [Date] {
    let total = end.timeIntervalSince(t)
    let interval = total / Double(step)
    return t.ex.listTo(end: end, step: interval)
  }

  func list(for range: ClosedRange<Int>, step: Int = 8) -> [Date] {
    let calendar = Calendar.current
    let start = calendar.date(byAdding: .hour, value: range.lowerBound, to: t)!
    let totalHours = range.upperBound - range.lowerBound
    let interval: TimeInterval = 60 * 60 * (Double(totalHours) / Double(step))
    let endOfDay = calendar.date(byAdding: .hour, value: range.upperBound, to: t)!
    return start.ex.listTo(end: endOfDay, step: interval)
  }

  var ymd: (Int, Int, Int) {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: t)
    guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else {
      fatalError("Failed to get ymd")
    }
    return (year, month, day)
  }

  var hm: (Int, Int) {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.hour, .minute], from: t)
    guard let hour = dateComponents.hour, let minute = dateComponents.minute else {
      fatalError("Failed to get hm")
    }
    return (hour, minute)
  }

  var second: Int {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.second], from: t)
    guard let s = dateComponents.second else {
      fatalError("Failed to get second")
    }
    return s
  }

  var year: Int { t.ex.ymd.0 }

  var month: Int { t.ex.ymd.1 }

  var day: Int { t.ex.ymd.2 }

  var hour: Int { t.ex.hm.0 }

  var minute: Int { t.ex.hm.1 }

  var startOfDay: Date {
    Calendar.current.startOfDay(for: t)
  }

  var startOfMonth: Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month], from: t)
    return calendar.date(from: dateComponents)!
  }

  var endOfMonth: Date {
    let calendar = Calendar.current
    var dateComponents = calendar.dateComponents([.year, .month], from: t)
    dateComponents.day = 0
    dateComponents.month! += 1
    return calendar.date(from: dateComponents)!
  }

  var startOfHour: Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: t)
    return calendar.date(from: dateComponents)!
  }

  static func from(ymd: (Int, Int, Int)) -> Date? {
    var dateComponents = DateComponents()
    dateComponents.year = ymd.0
    dateComponents.month = ymd.1
    dateComponents.day = ymd.2
    return Calendar.current.date(from: dateComponents)
  }

  static func from(hm: (Int, Int)) -> Date? {
    let now = Date.now
    var dateComponents = DateComponents()
    dateComponents.year = now.ex.year
    dateComponents.month = now.ex.month
    dateComponents.day = now.ex.day
    dateComponents.hour = hm.0
    dateComponents.minute = hm.1
    return Calendar.current.date(from: dateComponents)
  }

  func to(hm: (Int, Int)) -> Date? {
    var dateComponents = DateComponents()
    dateComponents.year = t.ex.year
    dateComponents.month = t.ex.month
    dateComponents.day = t.ex.day
    dateComponents.hour = hm.0
    dateComponents.minute = hm.1
    return Calendar.current.date(from: dateComponents)
  }

  func to(hms: (Int, Int, Int)) -> Date? {
    var dateComponents = DateComponents()
    dateComponents.year = t.ex.year
    dateComponents.month = t.ex.month
    dateComponents.day = t.ex.day
    dateComponents.hour = hm.0
    dateComponents.minute = hm.1
    dateComponents.second = hms.2
    return Calendar.current.date(from: dateComponents)
  }

  static func from(hms: (Int, Int, Int)) -> Date? {
    let now = Date.now
    var dateComponents = DateComponents()
    dateComponents.year = now.ex.year
    dateComponents.month = now.ex.month
    dateComponents.day = now.ex.day
    dateComponents.hour = hms.0
    dateComponents.minute = hms.1
    dateComponents.second = hms.2
    return Calendar.current.date(from: dateComponents)
  }

  var dayRange: (Date, Date) {
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: t)
    let end = calendar.date(byAdding: .day, value: 1, to: start)!
    return (start, end)
  }

  var timeIntervalSinceStartOfDay: TimeInterval {
    t.timeIntervalSince(Calendar.current.startOfDay(for: t))
  }

  static var tomorrow: Date { Date().ex.dayRange.1 }

  var weekday: Int {
    Calendar.current.component(.weekday, from: t)
  }
}

extension FoundationEx where T == Data {
  func toMap() -> [UInt16: [UInt8]]? {
    guard t.count >= 1 else { return .none }
    return [UInt16(t[0]) | UInt16(t[1]) << 8: t.dropFirst(2).map { $0 }]
  }

  struct HexEncodingOptions: OptionSet {
    public static let upperCase = HexEncodingOptions(rawValue: 1)
    public static let reverseEndianness = HexEncodingOptions(rawValue: 2)

    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue << 0
    }
  }

  func hexEncodedString(options: HexEncodingOptions = [], separator: String = "")
    -> String {
    let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"

    var bytes = t
    if options.contains(.reverseEndianness) {
      bytes.reverse()
    }
    return bytes
      .map { String(format: format, $0) }
      .joined(separator: separator)
  }
}

extension FoundationEx where T == Double {
  func toDateComponents(component: Calendar.Component) -> DateComponents {
    Calendar
      .current
      .dateComponents(
        [component],
        from: Date(timeIntervalSinceNow: t)
      )
  }

  var date: Date {
    Date(timeIntervalSince1970: t)
  }
}

extension FoundationEx where T == UInt16 {}

protocol Binary {
  var bin: [UInt8] { get }
}

extension UInt16: Binary {
  var bin: [UInt8] {
    [
      UInt8((self >> 8) & 0xFF),
      UInt8(self & 0xFF),
    ]
  }
}

extension UInt32: Binary {
  var bin: [UInt8] {
    [
      UInt8((self >> 24) & 0xFF),
      UInt8((self >> 16) & 0xFF),
      UInt8((self >> 8) & 0xFF),
      UInt8(self & 0xFF),
    ]
  }
}
