import SwiftUI
import SwiftData

@MainActor
enum PreviewContainer {
    static let container: ModelContainer = {
        let schema = Schema([Profile.self, Transaction.self, Category.self, Person.self, PersonTransaction.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        insertSampleData(into: container.mainContext)
        return container
    }()

    static func insertSampleData(into context: ModelContext) {
        DefaultData.seedCategories(context: context)

        let profile = Profile(name: "محفظتي", type: .personal, currencyCode: "₪", colorHex: "#1B4FFF", sortOrder: 0)
        let biz = Profile(name: "التجاري", type: .business, currencyCode: "₪", colorHex: "#2ECC71", sortOrder: 1)
        context.insert(profile)
        context.insert(biz)

        let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        let salarycat  = categories.first { $0.nameAr == "راتب" }
        let foodCat    = categories.first { $0.nameAr == "طعام وشراب" }
        let fuelCat    = categories.first { $0.nameAr == "وقود" }
        let shopCat    = categories.first { $0.nameAr == "تسوق" }

        let t1 = Transaction(amount: 8000, kind: .income,  note: "راتب شهر أبريل", date: Date(), categoryName: salarycat?.nameAr ?? "راتب", categoryIcon: salarycat?.icon ?? "briefcase.fill")
        let t2 = Transaction(amount: 320,  kind: .expense, note: "بقالة الأسبوع",  date: Date(), categoryName: foodCat?.nameAr ?? "طعام وشراب", categoryIcon: foodCat?.icon ?? "fork.knife")
        let t3 = Transaction(amount: 180,  kind: .expense, note: "",               date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, categoryName: fuelCat?.nameAr ?? "وقود", categoryIcon: fuelCat?.icon ?? "fuelpump.fill")
        let t4 = Transaction(amount: 560,  kind: .expense, note: "ملابس",          date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, categoryName: shopCat?.nameAr ?? "تسوق", categoryIcon: shopCat?.icon ?? "bag.fill")

        for t in [t1, t2, t3, t4] { t.profile = profile; context.insert(t) }

        let person = Person(name: "محمد عبدالله", phone: "0501234567")
        person.profile = profile
        context.insert(person)

        let pt1 = PersonTransaction(amount: 500, direction: .theyOweMe, desc: "قرض", date: Date())
        let pt2 = PersonTransaction(amount: 200, direction: .iOweThem,  desc: "عشاء", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)
        pt1.person = person; pt2.person = person
        context.insert(pt1); context.insert(pt2)

        try? context.save()
    }

    static var sampleProfile: Profile {
        (try? container.mainContext.fetch(FetchDescriptor<Profile>()))?.first ?? Profile(name: "محفظتي", type: .personal)
    }

    static var samplePerson: Person {
        (try? container.mainContext.fetch(FetchDescriptor<Person>()))?.first ?? Person(name: "محمد")
    }

    static var sampleTransaction: Transaction {
        (try? container.mainContext.fetch(FetchDescriptor<Transaction>()))?.first
            ?? Transaction(amount: 8000, kind: .income, categoryName: "راتب", categoryIcon: "briefcase.fill")
    }

    static var samplePersonTransaction: PersonTransaction {
        (try? container.mainContext.fetch(FetchDescriptor<PersonTransaction>()))?.first
            ?? PersonTransaction(amount: 500, direction: .theyOweMe, desc: "قرض")
    }

    static var sampleCategory: Category {
        (try? container.mainContext.fetch(FetchDescriptor<Category>()))?.first
            ?? Category(nameAr: "راتب", nameEn: "Salary", icon: "briefcase.fill", kind: .income)
    }
}
