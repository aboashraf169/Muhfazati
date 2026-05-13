import Foundation
import SwiftData

enum DefaultData {

    // MARK: - Entry Point
    static func seedIfNeeded(context: ModelContext) {
        // Always seed categories if missing
        let catCount = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
        if catCount == 0 { seedCategories(context: context) }

        // Seed demo data whenever there are no profiles at all
        let profileCount = (try? context.fetchCount(FetchDescriptor<Profile>())) ?? 0
        if profileCount == 0 {
            let lang = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "ar") ?? .arabic
            seedDemoData(context: context, lang: lang)
            UserDefaults.standard.set(true,          forKey: "demoDataSeeded")
            UserDefaults.standard.set(lang.rawValue, forKey: "demoDataLanguage")
        }
    }

    // MARK: - Language Switch → re-seed demo data
    static func resetDemoData(context: ModelContext, lang: AppLanguage) {
        let profiles = (try? context.fetch(FetchDescriptor<Profile>())) ?? []
        profiles.forEach { context.delete($0) }
        try? context.save()

        seedDemoData(context: context, lang: lang)
        UserDefaults.standard.set(lang.rawValue, forKey: "demoDataLanguage")
        UserDefaults.standard.set(true, forKey: "demoDataSeeded")
    }

    // MARK: - Categories
    static func seedCategories(context: ModelContext) {
        let income: [(ar: String, en: String, icon: String)] = [
            ("راتب",          "Salary",         "briefcase.fill"),
            ("عمل حر",        "Freelance",       "laptopcomputer"),
            ("استثمار",       "Investment",      "chart.line.uptrend.xyaxis"),
            ("إيجار مقبوض",   "Rent Received",   "building.2.fill"),
            ("هدية مستلمة",   "Gift Received",   "gift.fill"),
            ("مبيعات",        "Sales",           "cart.fill"),
            ("مكافأة",        "Bonus",           "star.fill"),
            ("أخرى — دخل",   "Other Income",    "plus.circle.fill"),
        ]
        let expense: [(ar: String, en: String, icon: String)] = [
            ("طعام وشراب",    "Food & Drink",    "fork.knife"),
            ("مواصلات",       "Transport",       "car.fill"),
            ("سكن",           "Housing",         "house.fill"),
            ("فواتير",        "Bills",           "bolt.fill"),
            ("صحة",           "Health",          "cross.fill"),
            ("تسوق",          "Shopping",        "bag.fill"),
            ("ترفيه",         "Entertainment",   "tv.fill"),
            ("تعليم",         "Education",       "book.fill"),
            ("هدية مدفوعة",   "Gift Given",      "giftcard.fill"),
            ("مطاعم",         "Restaurants",     "takeoutbag.and.cup.and.straw.fill"),
            ("وقود",          "Fuel",            "fuelpump.fill"),
            ("ادخار",         "Savings",         "banknote.fill"),
            ("أخرى — مصروف", "Other Expense",   "minus.circle.fill"),
        ]
        for (i, item) in income.enumerated() {
            context.insert(Category(nameAr: item.ar, nameEn: item.en,
                                    icon: item.icon, kind: .income, isDefault: true, sortOrder: i))
        }
        for (i, item) in expense.enumerated() {
            context.insert(Category(nameAr: item.ar, nameEn: item.en,
                                    icon: item.icon, kind: .expense, isDefault: true, sortOrder: i))
        }
        try? context.save()
    }

    static func seedDefaultProfile(context: ModelContext, lang: AppLanguage) {
        let name = lang == .arabic ? "محفظتي" : "My Wallet"
        let profile = Profile(name: name, type: .personal,
                              currencyCode: "₪", colorHex: "#1F2430", sortOrder: 0)
        context.insert(profile)
        try? context.save()
    }

    // MARK: - Full Demo Data (Arabic & English)
    static func seedDemoData(context: ModelContext, lang: AppLanguage) {
        let ar = lang == .arabic
        let cal = Calendar.current
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: Date()) ?? Date() }

        // ── Profile 1 ──────────────────────────────────────────
        let p1 = Profile(name: ar ? "محفظتي" : "My Wallet",
                         type: .personal, currencyCode: "₪",
                         colorHex: "#1F2430", sortOrder: 0)
        context.insert(p1)

        // (amount, kind, catAr, catEn, icon, daysAgo, noteAr, noteEn)
        typealias TxnRow = (Double, TransactionKind, String, String, String, Int, String, String)
        let p1Txns: [TxnRow] = [
            (8_500, .income,  "راتب",       "Salary",       "briefcase.fill",                    1,  "راتب شهر أبريل",      "April Salary"),
            (1_200, .income,  "عمل حر",     "Freelance",    "laptopcomputer",                    5,  "مشروع تصميم",         "Design Project"),
            (500,   .income,  "هدية مستلمة","Gift Received","gift.fill",                         12, "هدية عيد ميلاد",      "Birthday Gift"),
            (95,    .expense, "طعام وشراب", "Food & Drink", "fork.knife",                        0,  "فطور الصباح",         "Breakfast"),
            (220,   .expense, "مطاعم",      "Restaurants",  "takeoutbag.and.cup.and.straw.fill", 1,  "عشاء العائلة",        "Family Dinner"),
            (85,    .expense, "مواصلات",    "Transport",    "car.fill",                          2,  "تاكسي",               "Taxi"),
            (430,   .expense, "تسوق",       "Shopping",     "bag.fill",                          3,  "ملابس",               "Clothing"),
            (350,   .expense, "فواتير",     "Bills",        "bolt.fill",                         4,  "فاتورة الكهرباء",     "Electricity Bill"),
            (180,   .expense, "ترفيه",      "Entertainment","tv.fill",                           6,  "اشتراك نتفليكس",     "Netflix"),
            (200,   .expense, "وقود",       "Fuel",         "fuelpump.fill",                     7,  "وقود السيارة",        "Car Fuel"),
            (120,   .expense, "صحة",        "Health",       "cross.fill",                        9,  "صيدلية",              "Pharmacy"),
            (650,   .expense, "ادخار",      "Savings",      "banknote.fill",                     10, "توفير شهري",          "Monthly Savings"),
            (75,    .expense, "مطاعم",      "Restaurants",  "takeoutbag.and.cup.and.straw.fill", 11, "غداء العمل",          "Work Lunch"),
            (300,   .expense, "تعليم",      "Education",    "book.fill",                         14, "كتب دراسية",          "Study Books"),
            (160,   .expense, "طعام وشراب", "Food & Drink", "fork.knife",                        15, "بقالة الأسبوع",       "Weekly Grocery"),
        ]
        for (amount, kind, catAr, catEn, icon, days, noteAr, noteEn) in p1Txns {
            let t = Transaction(amount: amount, kind: kind,
                                note: ar ? noteAr : noteEn, date: daysAgo(days),
                                categoryName: ar ? catAr : catEn, categoryIcon: icon)
            context.insert(t); t.profile = p1
        }

        // ── Profile 2 ──────────────────────────────────────────
        let p2 = Profile(name: ar ? "مشروعي" : "My Business",
                         type: .business, currencyCode: "₪",
                         colorHex: "#1F2430", sortOrder: 1)
        context.insert(p2)

        let p2Txns: [TxnRow] = [
            (15_000, .income,  "مبيعات",        "Sales",         "cart.fill",           2,  "مبيعات الأسبوع",    "Weekly Sales"),
            (4_500,  .income,  "مبيعات",        "Sales",         "cart.fill",           8,  "طلبية خاصة",        "Special Order"),
            (2_000,  .income,  "مكافأة",        "Bonus",         "star.fill",           15, "مكافأة مشروع",      "Project Bonus"),
            (800,    .expense, "وقود",           "Fuel",          "fuelpump.fill",       1,  "توصيل البضاعة",     "Delivery Fuel"),
            (450,    .expense, "مواصلات",        "Transport",     "car.fill",            3,  "اجتماع عملاء",      "Client Meeting"),
            (1_200,  .expense, "فواتير",         "Bills",         "bolt.fill",           5,  "إيجار المكتب",      "Office Rent"),
            (300,    .expense, "تسوق",           "Shopping",      "bag.fill",            7,  "أدوات مكتبية",      "Office Supplies"),
            (600,    .expense, "أخرى — مصروف",  "Other Expense", "minus.circle.fill",   10, "مصاريف متنوعة",     "Misc Expenses"),
        ]
        for (amount, kind, catAr, catEn, icon, days, noteAr, noteEn) in p2Txns {
            let t = Transaction(amount: amount, kind: kind,
                                note: ar ? noteAr : noteEn, date: daysAgo(days),
                                categoryName: ar ? catAr : catEn, categoryIcon: icon)
            context.insert(t); t.profile = p2
        }

        // ── Profile 3 ──────────────────────────────────────────
        let p3 = Profile(name: ar ? "شراكة التجارة" : "Business Partnership",
                         type: .partnership, currencyCode: "₪",
                         colorHex: "#1F2430", sortOrder: 2)
        context.insert(p3)

        let p3Txns: [TxnRow] = [
            (25_000, .income,  "مبيعات",        "Sales",         "cart.fill",                     3,  "صفقة كبرى",         "Major Deal"),
            (8_000,  .income,  "استثمار",       "Investment",    "chart.line.uptrend.xyaxis",     10, "عائد استثمار",      "Investment Return"),
            (3_500,  .expense, "سكن",            "Housing",       "house.fill",                    1,  "إيجار المستودع",    "Warehouse Rent"),
            (1_800,  .expense, "مواصلات",        "Transport",     "car.fill",                      4,  "شحن البضاعة",       "Cargo Shipping"),
            (900,    .expense, "فواتير",         "Bills",         "bolt.fill",                     6,  "فواتير الكهرباء",   "Electricity Bills"),
            (2_200,  .expense, "أخرى — مصروف",  "Other Expense", "minus.circle.fill",             8,  "رواتب الموظفين",    "Staff Salaries"),
        ]
        for (amount, kind, catAr, catEn, icon, days, noteAr, noteEn) in p3Txns {
            let t = Transaction(amount: amount, kind: kind,
                                note: ar ? noteAr : noteEn, date: daysAgo(days),
                                categoryName: ar ? catAr : catEn, categoryIcon: icon)
            context.insert(t); t.profile = p3
        }

        // ── People (linked to p1) ──────────────────────────────
        let names: [(ar: String, en: String)] = [
            ("أحمد محمد",      "Ahmed Mohammed"),
            ("سارة العمر",     "Sara Omar"),
            ("محمد علي",       "Mohammed Ali"),
            ("نورة التجارية",  "Noura Trading"),
        ]

        // Person 1
        let per1 = Person(name: ar ? names[0].ar : names[0].en)
        context.insert(per1); per1.profile = p1
        let pt1a = PersonTransaction(amount: 800, direction: .theyOweMe, desc: ar ? "سلفة شخصية" : "Personal loan", date: daysAgo(8))
        context.insert(pt1a); pt1a.person = per1
        let pt1b = PersonTransaction(amount: 300, direction: .theyOweMe, desc: ar ? "تذاكر السفر" : "Travel tickets", date: daysAgo(3))
        context.insert(pt1b); pt1b.person = per1

        // Person 2
        let per2 = Person(name: ar ? names[1].ar : names[1].en)
        context.insert(per2); per2.profile = p1
        let pt2a = PersonTransaction(amount: 450, direction: .iOweThem, desc: ar ? "نصيبي من العشاء" : "My share of dinner", date: daysAgo(5))
        context.insert(pt2a); pt2a.person = per2
        let pt2b = PersonTransaction(amount: 200, direction: .iOweThem, desc: ar ? "اشتراك مشترك" : "Shared subscription", date: daysAgo(2))
        context.insert(pt2b); pt2b.person = per2

        // Person 3 (settled + active)
        let per3 = Person(name: ar ? names[2].ar : names[2].en)
        context.insert(per3); per3.profile = p1
        let pt3a = PersonTransaction(amount: 1_200, direction: .theyOweMe, desc: ar ? "قرض قديم" : "Old loan", date: daysAgo(30))
        pt3a.isSettled = true; pt3a.settledAt = daysAgo(10)
        context.insert(pt3a); pt3a.person = per3
        let pt3b = PersonTransaction(amount: 550, direction: .theyOweMe, desc: ar ? "دفع حفلة" : "Party payment", date: daysAgo(20))
        context.insert(pt3b); pt3b.person = per3

        // Person 4
        let per4 = Person(name: ar ? names[3].ar : names[3].en)
        context.insert(per4); per4.profile = p1
        let pt4a = PersonTransaction(amount: 2_500, direction: .iOweThem, desc: ar ? "بضاعة بالدين" : "Goods on credit", date: daysAgo(7))
        context.insert(pt4a); pt4a.person = per4

        try? context.save()
    }
}
