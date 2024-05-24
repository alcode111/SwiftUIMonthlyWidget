//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Ismaïl on 18/05/2024.
//

import WidgetKit
import SwiftUI

struct Provider: IntentTimelineProvider {
    func getSnapshot(for configuration: ChangeFontIntent, in context: Context, completion: @escaping (DayEntry) -> Void) {
        let entry = DayEntry(date: Date(), showFunFont: false)
        completion(entry)
    }
    
    func getTimeline(for configuration: ChangeFontIntent, in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        var entries: [DayEntry] = []
        
        let showFunFont = configuration.funFont == 1
        
        // Generate a timeline consisting of seven entries a day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate, showFunFont: showFunFont)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), showFunFont: false)
    }
    
}

struct DayEntry: TimelineEntry {
    let date: Date
    let showFunFont: Bool
}

struct MonthlyWidgetEntryView : View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    
    var entry: DayEntry
    var config: MonthConfig
    let fontName = "Chalkduster"
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text(config.emojiText)
                    .font(.title)
                
                Text(entry.date.weekdayDisplayFormat)
                    .font(entry.showFunFont ? .custom(fontName, size: 24) : .title3)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(showsBackground ? config.weekdayTextColor : .white)
                
                Spacer()
            }
            .id(entry.date)
            .transition(.push(from: .trailing))
            .animation(.bouncy, value: entry.date)
            
            Text(entry.date.dayDisplayFormat)
                .font(entry.showFunFont ? .custom(fontName, size: 80) : .system(size: 80, weight: .heavy))
                .foregroundStyle(showsBackground ? config.dayTextColor : .white)
                .contentTransition(.numericText())
        }
        .containerBackground(for: .widget) {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
        }
    }
}

struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ChangeFontIntent.self, provider: Provider()) { entry in
            MonthlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Monthly Style Widget:")
        .description("The theme of the widget changes based on month.")
        .supportedFamilies([.systemSmall])
        .disfavoredLocations([.standBy], for: [.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MonthlyWidget()
} timeline: {
    MockData.dayOne
    MockData.dayTwo
    MockData.dayThree
    MockData.dayFour
}

extension Date {
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}

extension Date {
    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}

struct MockData {
    static let dayOne = DayEntry(date: dateToDisplay(month: 5, day: 4), showFunFont: false)
    static let dayTwo = DayEntry(date: dateToDisplay(month: 6, day: 5), showFunFont: true)
    static let dayThree = DayEntry(date: dateToDisplay(month: 7, day: 6), showFunFont: false)
    static let dayFour = DayEntry(date: dateToDisplay(month: 8, day: 7), showFunFont: false)


    static func dateToDisplay(month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current,
                                        year: 2022,
                                        month: month,
                                        day: day)

        return Calendar.current.date(from: components)!
    }
}
