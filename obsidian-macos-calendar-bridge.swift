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
    for event in events {
        let time = event.startDate.fmt(f: "HHmm")

        let pattern = "[^a-zA-Z0-9äöüßÄÖÜ _-]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let cleanedTitle = regex.stringByReplacingMatches(in: event.title, options: [], range: NSRange(location: 0, length: event.title.utf16.count), withTemplate: "")

        print("\(time) \(cleanedTitle)")

        if let attendees = event.attendees {
            let nonSelfAttendees = attendees.filter { !$0.isCurrentUser }
            for attendee in nonSelfAttendees {
                if let attendeeName = attendee.name {
                    var cleanedName = attendeeName.replacingOccurrences(of: "Optional(\"", with: "")
                    cleanedName = cleanedName.replacingOccurrences(of: "\")", with: "")

                    if cleanedName.contains(",") {
                        let components = cleanedName.components(separatedBy: ",")
                        if components.count == 2 {
                            let firstname = components[1].trimmingCharacters(in: .whitespaces)
                            let lastname = components[0].trimmingCharacters(in: .whitespaces)
                            cleanedName = "\(firstname) \(lastname)"
                        }
                    }

                    print("- [[\(cleanedName)]]")
                }
            }
        }
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
