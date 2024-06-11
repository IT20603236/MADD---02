

import XCTest
@testable import IssueManagment

final class IssueManagmentTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddIssue() throws {
            let viewModel = IssuesViewModel()
            
            let title = "Test Issue"
            let date = Date()
            let district = "Test District"
            let province = "Test Province"
            let affectedArea = "Test Area"
            let issueDescription = "Test Description"
            let expectedSolution = "Test Solution"
            let createdBy = "Test User"
            
            viewModel.addIssue(
                title: title,
                date: date,
                district: district,
                province: province,
                affectedArea: affectedArea,
                issueDescription: issueDescription,
                expectedSolution: expectedSolution,
                createdBy: createdBy
            )
            
            XCTAssertEqual(viewModel.issues.count, 1)
            let addedIssue = viewModel.issues.first!
            XCTAssertEqual(addedIssue.title, title)
            XCTAssertEqual(addedIssue.date, date)
            XCTAssertEqual(addedIssue.district, district)
            XCTAssertEqual(addedIssue.province, province)
            XCTAssertEqual(addedIssue.affectedArea, affectedArea)
            XCTAssertEqual(addedIssue.issueDescription, issueDescription)
            XCTAssertEqual(addedIssue.expectedSolution, expectedSolution)
            XCTAssertEqual(addedIssue.createdBy, createdBy)
        }

        // Test case for deleting an issue
        func testDeleteIssue() throws {
            let viewModel = IssuesViewModel()
            
            let issue = Issue(
                title: "Test Issue",
                date: Date(),
                district: "Test District",
                province: "Test Province",
                affectedArea: "Test Area",
                issueDescription: "Test Description",
                expectedSolution: "Test Solution",
                createdBy: "Test User"
            )
            
            viewModel.issues.append(issue)
            XCTAssertEqual(viewModel.issues.count, 1)
            
            viewModel.deleteIssue(issue)
            XCTAssertEqual(viewModel.issues.count, 0)
        }

        // Test case for editing an issue
        func testEditIssue() throws {
            let viewModel = IssuesViewModel()
            
            let issue = Issue(
                title: "Test Issue",
                date: Date(),
                district: "Test District",
                province: "Test Province",
                affectedArea: "Test Area",
                issueDescription: "Test Description",
                expectedSolution: "Test Solution",
                createdBy: "Test User"
            )
            
            viewModel.issues.append(issue)
            XCTAssertEqual(viewModel.issues.count, 1)
            
            let updatedTitle = "Updated Issue"
            let updatedIssueDescription = "Updated Description"
            let updatedExpectedSolution = "Updated Solution"
            let updatedAffectedArea = "Updated Area"
            
            viewModel.editIssue(
                issue,
                updatedTitle: updatedTitle,
                updatedIssueDescription: updatedIssueDescription,
                updatedExpectedSolution: updatedExpectedSolution,
                updatedaffectedArea: updatedAffectedArea
            )
            
            XCTAssertEqual(viewModel.issues.count, 1)
            let editedIssue = viewModel.issues.first!
            XCTAssertEqual(editedIssue.title, updatedTitle)
            XCTAssertEqual(editedIssue.issueDescription, updatedIssueDescription)
            XCTAssertEqual(editedIssue.expectedSolution, updatedExpectedSolution)
            XCTAssertEqual(editedIssue.affectedArea, updatedAffectedArea)
        }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
