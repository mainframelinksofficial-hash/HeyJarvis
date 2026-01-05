//
//  EventManager.swift
//  HeyJarvisApp
//
//  Manages Calendar and Reminders via EventKit
//

import EventKit
import Foundation

class EventManager: ObservableObject {
    static let shared = EventManager()
    
    private let eventStore = EKEventStore()
    
    func requestAccess() async -> Bool {
        let calendarGranted = await requestCalendarAccess()
        let reminderGranted = await requestReminderAccess()
        return calendarGranted && reminderGranted
    }
    
    private func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Calendar access error: \(error)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    private func requestReminderAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToReminders()
            } catch {
                print("Reminder access error: \(error)")
                return false
            }
        } else {
             return await withCheckedContinuation { continuation in
                 eventStore.requestAccess(to: .reminder) { granted, _ in
                     continuation.resume(returning: granted)
                 }
             }
        }
    }
    
    // MARK: - Calendar
    
    func getTodaysEvents() -> String {
        let calendars = eventStore.calendars(for: .event)
        
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        if events.isEmpty {
            return "Your calendar is clear for the rest of the day, sir."
        }
        
        // Summarize
        let count = events.count
        guard let firstEvent = events.first else {
            return "Your calendar is clear for the rest of the day, sir."
        }
        let title = firstEvent.title ?? "Event"
        let time = DateFormatter.localizedString(from: firstEvent.startDate, dateStyle: .none, timeStyle: .short)
        
        if count == 1 {
            return "You have one event today: \(title) at \(time)."
        } else {
            return "You have \(count) events today. The next one is \(title) at \(time)."
        }
    }
    
    // MARK: - Reminders
    
    func addReminder(title: String) async -> String {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            return "I've added '\(title)' to your reminders."
        } catch {
            return "I failed to create that reminder, sir. Error: \(error.localizedDescription)"
        }
    }
    
    func getIncompleteReminders() async -> String {
        return await withCheckedContinuation { continuation in
            let predicate = eventStore.predicateForReminders(in: nil)
            eventStore.fetchReminders(matching: predicate) { reminders in
                guard let reminders = reminders else {
                    continuation.resume(returning: "")
                    return
                }
                
                let incomplete = reminders.filter { !$0.isCompleted }
                if incomplete.isEmpty {
                    continuation.resume(returning: "")
                    return
                }
                
                let count = incomplete.count
                let topThree = incomplete.prefix(3).map { $0.title ?? "Item" }.joined(separator: ", ")
                
                if count > 3 {
                    continuation.resume(returning: "You have \(count) pending tasks, including: \(topThree).")
                } else {
                    continuation.resume(returning: "You have pending tasks: \(topThree).")
                }
            }
        }
    }
}
