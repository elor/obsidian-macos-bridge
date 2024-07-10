import Foundation
import EventKit

var d = 60.0 // min
var s = EKEventStore()
let c = s.calendars(for: .event)
let t = Date()
let m = Calendar.current.startOfDay(for: t)
let n = Calendar.current.date(byAdding: .day, value: 1, to: m)!

let events = s.events(matching: s.predicateForEvents(withStart: m, end: n, calendars: c)).filter { !$0.isAllDay }

let f = DateComponentsFormatter()
f.allowedUnits = [.hour, .minute]
f.maximumUnitCount = 2
f.unitsStyle = .abbreviated

switch EKEventStore.authorizationStatus(for: .event) {
case .authorized: break
case .denied:
    print("Settings > Privacy & Security > Calendars > Terminal")
    exit(1)
case .notDetermined:
    s.requestFullAccessToEvents { (granted, error) in
        if granted {
            print("granted")
        } else {
            print("access denied")
        }
    }
default:
    fputs("?", stderr)
}

func listEvents() {
    for x in events {
        let time = x.startDate.fmt(f: "HHmm")

        let pattern = "[^a-zA-Z0-9 _-]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let cleanedTitle = regex.stringByReplacingMatches(in: x.title, options: [], range: NSRange(location: 0, length: x.title.utf16.count), withTemplate: "")

        print("- \(time) \(cleanedTitle)")
    }
}

extension Date {
    func fmt(f: String) -> String {
        let x = DateFormatter()
        x.dateFormat = f
        return x.string(from: self)
    }
}

listEvents()
