import Foundation

extension Date {
    static func startOfMonth(for date: Date = Date()) -> Date {
        Calendar.current.dateInterval(of: .month, for: date)?.start ?? date
    }

    static func endOfMonth(for date: Date = Date()) -> Date {
        Calendar.current.dateInterval(of: .month, for: date)?.end ?? date
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .month)
    }

    var arabicMonthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    var arabicDayLabel: String {
        if Calendar.current.isDateInToday(self) { return "اليوم" }
        if Calendar.current.isDateInYesterday(self) { return "أمس" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: self)
    }

    var englishDayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: self)
    }

    var previousMonth: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }

    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self) ?? self
    }
}
