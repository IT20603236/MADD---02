

import Foundation
import CoreData


extension IEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IEntity> {
        return NSFetchRequest<IEntity>(entityName: "IEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var district: String?
    @NSManaged public var province: String?
    @NSManaged public var affectedArea: String?
    @NSManaged public var issueDescription: String?
    @NSManaged public var expectedSolution: String?
    @NSManaged public var createdBy: String?

}

extension IEntity : Identifiable {

}
