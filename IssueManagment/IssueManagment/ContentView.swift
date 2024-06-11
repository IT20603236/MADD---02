
import SwiftUI
import CoreData
import Foundation

struct Issue: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var district: String
    var province: String
    var affectedArea: String
    var issueDescription: String
    var expectedSolution: String
    let createdBy: String
}

class IssuesViewModel: ObservableObject {
    @Published var issues: [Issue] = []
    var context: NSManagedObjectContext?
    
    func addIssue(title: String, date: Date, district: String, province: String, affectedArea: String, issueDescription: String, expectedSolution: String, createdBy: String) {
        guard let context = context else { return }
        let newIssue = Issue(title: title, date: date, district: district, province: province, affectedArea: affectedArea, issueDescription: issueDescription, expectedSolution: expectedSolution, createdBy: createdBy)
        issues.append(newIssue)
        
        let IEntity = NSEntityDescription.insertNewObject(forEntityName: "IEntity", into: context) as! IssueManagment.IEntity
        IEntity.title = title
        IEntity.date = date
        IEntity.district = district
        IEntity.province = province
        IEntity.affectedArea = affectedArea
        IEntity.issueDescription = issueDescription
        IEntity.expectedSolution = expectedSolution
        IEntity.createdBy = createdBy
        saveContext()
    }
    
    
    
    func deleteIssue(_ issue: Issue) {
        guard let context = context else { return }
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            issues.remove(at: index)
        }
        
        let fetchRequest: NSFetchRequest<IEntity> = IEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND createdBy == %@", issue.title, issue.createdBy)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let IEntity = result.first {
                context.delete(IEntity)
                saveContext()
            }
        } catch {
            print("Failed to delete issue: \(error)")
        }
    }
    // In your ProjectsViewModel:
    
    func editIssue(_ issue: Issue, updatedTitle: String, updatedIssueDescription: String, updatedExpectedSolution: String, updatedaffectedArea : String) {
        guard let context = context else { return }
        
        // Find the project to be edited in the projects array
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            // Update the project in the projects array
            issues[index].title = updatedTitle
            issues[index].issueDescription = updatedIssueDescription
            issues[index].expectedSolution = updatedExpectedSolution
            issues[index].affectedArea = updatedaffectedArea
            
            // Update the corresponding IEntity object in Core Data
            let fetchRequest: NSFetchRequest<IEntity> = IEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@ AND createdBy == %@", issue.title, issue.createdBy)
            
            do {
                let result = try context.fetch(fetchRequest)
                if let IEntity = result.first {
                    IEntity.title = updatedTitle
                    IEntity.issueDescription = updatedIssueDescription
                    IEntity.expectedSolution = updatedExpectedSolution
                    IEntity.affectedArea = updatedaffectedArea
                    saveContext()
                }
            } catch {
                print("Failed to edit issue: \(error)")
            }
        }
    }
    
    
    func fetchIssues() {
        guard let context = context else { return }
        let fetchRequest: NSFetchRequest<IEntity> = IEntity.fetchRequest()
        
        do {
            let result = try context.fetch(fetchRequest)
            issues = result.map { Issue(title: $0.title ?? "", date: $0.date ?? Date(), district: $0.district ?? "", province: $0.province ?? "", affectedArea: $0.affectedArea ?? "", issueDescription: $0.issueDescription ?? "", expectedSolution: $0.expectedSolution ?? "", createdBy: $0.createdBy ?? "") }
            
        } catch {
            print("Failed to fetch issues: \(error)")
        }
    }
    
    private func saveContext() {
        guard let context = context else { return }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

// Login
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: IssueManagment.UsersEntity.entity(), sortDescriptors: []) var users: FetchedResults<IssueManagment.UsersEntity>
    @StateObject private var viewModel = IssuesViewModel()
    @State private var isShowingAddIssuesSheet = false
    @State private var selectedIssue: Issue?
    @State private var username = ""
    @State private var password = ""
    @State private var repassword = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoggedIn {
                    TabView {
                        MyIssuesView(viewModel: viewModel, username : username)
                            .tabItem {
                                Label(NSLocalizedString("my_issues", comment: ""), systemImage: "folder")
                            }
                        
                        AllIssuesView(viewModel: viewModel, username : username)
                            .tabItem {
                                Label(NSLocalizedString("all_issues", comment: ""), systemImage: "list.bullet")
                            }
                    }
                    .onAppear {
                        viewModel.context = viewContext
                        viewModel.fetchIssues()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showAlert = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text(LocalizedStringKey("logout"))
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                }
                            }
                        }
                    }.alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(LocalizedStringKey("c_logout")),
                            message: Text(LocalizedStringKey("c_logout_msg")),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text(LocalizedStringKey("logout")), action: {
                                isLoggedIn = false
                            })
                        )
                    }
                } else {
                    VStack(spacing: 20) {
                        Text(LocalizedStringKey("welcome_message"))
                            .font(.largeTitle)
                        NavigationLink(destination: LoginView(username: $username, password: $password, isLoggedIn: $isLoggedIn)) {
                            Label(
                                title: {
                                    HStack {
                                        Image("login")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                        Text(LocalizedStringKey("login"))
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                },
                                icon: {
                                    EmptyView() // No icon on the right side
                                }
                            )
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        NavigationLink(destination: RegistrationView(username: $username, password: $password, repassword: $repassword, isLoggedIn: $isLoggedIn)) {
                            Label(
                                title: {
                                    HStack {
                                        Image("register")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                        Text(LocalizedStringKey("register"))
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                },
                                icon: {
                                    EmptyView() // No icon on the right side
                                }
                            )
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                }
            }
        }
    }
}

// My Issues
struct MyIssuesView: View {
    @ObservedObject var viewModel: IssuesViewModel
    var username : String
    @State private var isShowingAddIssueSheet = false
    
    var body: some View {
        NavigationView {
            List(viewModel.issues.filter { $0.createdBy==username }) { issue in
                NavigationLink(destination: IssueDetailView(createdUser: username, issue: issue, viewModel: viewModel)) {
                    Text(issue.title)
                }
            }
            .navigationTitle(NSLocalizedString("my_issues", comment: ""))
            .navigationBarItems(
                leading: Button(action: {
                    isShowingAddIssueSheet = true
                }, label: {
                    Image(systemName: "plus")
                }),
                trailing: Button(action: {
                    viewModel.fetchIssues()
                    
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
            )
            .sheet(isPresented: $isShowingAddIssueSheet, content: {
                AddIssueSheet(
                    createdUser : username,
                    isPresented: $isShowingAddIssueSheet,
                    addIssue: { title, date, district, province, affectedArea, issueDescription, expectedSolution, createdBy in
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
                    }
                )
            })
        }
    }
}

//All Issues
struct AllIssuesView: View {
    @ObservedObject var viewModel: IssuesViewModel
    var username : String
    var body: some View {
        NavigationView {
            List(viewModel.issues) { issue in
                NavigationLink(destination: IssueDetailView(createdUser : username, issue: issue, viewModel: viewModel)) {
                    Text(issue.title)
                }
            }
            .navigationTitle(NSLocalizedString("all_issues", comment: ""))
            .navigationBarItems(trailing: Button(action: {
                viewModel.fetchIssues()
            }, label: {
                Image(systemName: "arrow.clockwise")
            }))
        }
    }
}

//Add Issues
struct AddIssueSheet: View {
    var createdUser: String
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var date = Date()
    @State private var district = ""
    @State private var province = ""
    @State private var affectedArea = ""
    @State private var issueDescription = ""
    @State private var expectedSolution = ""
    @State private var createdBy = ""
    
    
    let districts = [
        NSLocalizedString("ampara", comment: ""),
        NSLocalizedString("anuradhapura", comment: ""),
        NSLocalizedString("badulla", comment: ""),
        NSLocalizedString("batticaloa", comment: ""),
        NSLocalizedString("colombo", comment: ""),
        NSLocalizedString("galle", comment: ""),
        NSLocalizedString("gampaha", comment: ""),
        NSLocalizedString("hambantota", comment: ""),
        NSLocalizedString("jaffna", comment: ""),
        NSLocalizedString("kalutara", comment: ""),
        NSLocalizedString("kandy", comment: ""),
        NSLocalizedString("kegalle", comment: ""),
        NSLocalizedString("kilinochchi", comment: ""),
        NSLocalizedString("kurunegala", comment: ""),
        NSLocalizedString("mannar", comment: ""),
        NSLocalizedString("matale", comment: ""),
        NSLocalizedString("matara", comment: ""),
        NSLocalizedString("moneragala", comment: ""),
        NSLocalizedString("mullaitivu", comment: ""),
        NSLocalizedString("nuwaraeliya", comment: ""),
        NSLocalizedString("polonnaruwa", comment: ""),
        NSLocalizedString("puttalam", comment: ""),
        NSLocalizedString("ratnapura", comment: ""),
        NSLocalizedString("trincomalee", comment: ""),
        NSLocalizedString("vavuniya", comment: "")
    ]
    
    let provinces = [
        NSLocalizedString("eastern", comment: ""),
        NSLocalizedString("northcentral", comment: ""),
        NSLocalizedString("northwestern", comment: ""),
        NSLocalizedString("northern", comment: ""),
        NSLocalizedString("sabaragamuwa", comment: ""),
        NSLocalizedString("southern", comment: ""),
        NSLocalizedString("uva", comment: ""),
        NSLocalizedString("western", comment: "")
    ]
    
    
    var addIssue: (String, Date, String, String, String, String, String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("issue_details"))) {
                    HStack{
                        Text(LocalizedStringKey("title"))
                            .foregroundColor(.blue)
                        TextField("", text: $title)
                    }
                    
                    Picker(NSLocalizedString("provice", comment: ""), selection: $province) {
                        ForEach(Array(provinces.enumerated()), id: \.1) { index, option in
                            Text(option)
                                .foregroundColor(.black)
                                .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.blue)
                    
                    Picker(NSLocalizedString("district", comment: ""), selection: $district) {
                        ForEach(Array(districts.enumerated()), id: \.1) { index, option in
                            Text(option)
                                .foregroundColor(.black)
                                .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.blue)
                    
                    Text(LocalizedStringKey("affected_area"))
                        .foregroundColor(.blue)
                    TextField("", text: $affectedArea)
                    
                    Text(LocalizedStringKey("description"))
                        .foregroundColor(.blue)
                    TextEditor(text: $issueDescription)
                    
                    Text(LocalizedStringKey("expected_solution"))
                        .foregroundColor(.blue)
                    TextEditor(text: $expectedSolution)
                    
                    DatePicker(NSLocalizedString("date", comment: ""), selection: $date, displayedComponents: .date)
                    
                        .padding()
                    
                }
            }
            .navigationBarTitle(NSLocalizedString("add_issue", comment: ""))
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }, label: {
                    Text(LocalizedStringKey("cancel"))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }),
                trailing: Button(action: {
                    addIssue(title, date, district, province, affectedArea, issueDescription, expectedSolution, createdUser)
                    isPresented = false
                }, label: {
                    Text(LocalizedStringKey("save"))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                })
            )
        }
    }
}

// Edit Issues
struct EditIssueSheet: View {
    var createdUser: String
    @State private var updatedTitle: String
    @State private var updatedIssueDescription: String
    @State private var updatedExpectedSolution: String
    @State private var updatedaffectedArea: String
    let issue: Issue
    @ObservedObject var viewModel: IssuesViewModel
    @Binding var isPresented: Bool
    
    init(createdUser: String, issue: Issue, viewModel: IssuesViewModel, isPresented: Binding<Bool>) {
        self.createdUser = createdUser
        self._updatedTitle = State(initialValue: issue.title)
        self._updatedIssueDescription = State(initialValue: issue.issueDescription)
        self._updatedExpectedSolution = State(initialValue: issue.expectedSolution)
        self._updatedaffectedArea = State(initialValue: issue.affectedArea)
        self.issue = issue
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("issue_details"))) {
                    HStack{
                        Text(LocalizedStringKey("title"))
                            .foregroundColor(.blue)
                        TextField("", text: $updatedTitle)
                    }
                    Text(LocalizedStringKey("description"))
                        .foregroundColor(.blue)
                    TextEditor(text: $updatedIssueDescription)
                    
                    Text(LocalizedStringKey("expected_solution"))
                        .foregroundColor(.blue)
                    TextEditor(text: $updatedExpectedSolution)
                    
                    Text(LocalizedStringKey("affected_area"))
                        .foregroundColor(.blue)
                    TextEditor(text: $updatedaffectedArea)
                    
                    
                }
            }
            .navigationBarTitle(NSLocalizedString("edit_issues", comment: ""))
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }, label: {
                    Text(LocalizedStringKey("cancel"))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }),
                trailing: Button(action: {
                    viewModel.editIssue(issue, updatedTitle: updatedTitle, updatedIssueDescription: updatedIssueDescription, updatedExpectedSolution: updatedExpectedSolution, updatedaffectedArea : updatedaffectedArea)
                    isPresented = false
                }, label: {
                    Text(LocalizedStringKey("update"))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                })
            )
        }
    }
}

//updatedTitle: String, updatedIssueDescription: String, updatedExpectedSolution: String, updatedaffectedArea : String
//    title,date,district,province,affectedArea,issueDescription,expectedSolution,createdBy


//view Issues
struct IssueDetailView: View {
    var createdUser : String
    let issue: Issue
    @ObservedObject var viewModel: IssuesViewModel
    @State private var showingDeleteAlert = false
    @State private var isShowingEditIssueSheet = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var body: some View {
        Form{
            Section {
                HStack {
                    Text(LocalizedStringKey("title"))
                        .foregroundColor(.blue)
                    Text(issue.title)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("district"))
                        .foregroundColor(.blue)
                    Text(issue.district)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("provice"))
                        .foregroundColor(.blue)
                    Text(issue.province)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("v_affected_area"))
                        .foregroundColor(.blue)
                    Text(issue.affectedArea)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("v_date"))
                        .foregroundColor(.blue)
                    Text(dateFormatter.string(from: issue.date))
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("v_description"))
                        .foregroundColor(.blue)
                    Text(issue.issueDescription)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("v_expected_solution"))
                        .foregroundColor(.blue)
                    Text(issue.expectedSolution)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                HStack {
                    Text(LocalizedStringKey("created_by"))
                        .foregroundColor(.blue)
                    Text(issue.createdBy)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                
            }
        }
        .navigationBarItems(trailing: navigationBarTrailingItems)
        .sheet(isPresented: $isShowingEditIssueSheet, content: {
            EditIssueSheet(createdUser : createdUser, issue: issue, viewModel: viewModel, isPresented: $isShowingEditIssueSheet)
        })
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text(LocalizedStringKey("c_delete")),
                message: Text(LocalizedStringKey("c_delete_msg")),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text(LocalizedStringKey("delete")), action: {
                    viewModel.deleteIssue(issue)
                })
            )
        }
    }
    
    @ViewBuilder
    private var navigationBarTrailingItems: some View {
        if issue.createdBy == createdUser {
            HStack {
                Button(action: {
                    isShowingEditIssueSheet = true
                    // Edit project
                }, label: {
                    Image(systemName: "pencil")
                })
                Button(action: {
                    showingDeleteAlert = true
                }, label: {
                    Image(systemName: "trash")
                })
            }
        }
    }
}



//Registration
struct RegistrationView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var repassword: String
    @Binding var isLoggedIn: Bool
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: UsersEntity.entity(), sortDescriptors: []) var users: FetchedResults<UsersEntity>
    
    var body: some View {
        VStack {
            VStack {
                Image("register")
                    .resizable()
                    .frame(width: 70, height: 70)
                Text(LocalizedStringKey("register"))
                    .font(.largeTitle)
            }
            
            
            TextField(NSLocalizedString("username", comment: ""), text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField(NSLocalizedString("password", comment: ""), text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField(NSLocalizedString("re_password", comment: ""), text: $repassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                registerUser()
            }, label: {
                Text(LocalizedStringKey("register"))
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(LocalizedStringKey("ok")))
            )
        }
    }
    
    private func registerUser() {
        guard !username.isEmpty && !password.isEmpty && password == repassword else {
            alertTitle = NSLocalizedString("invalid_input", comment: "")
            alertMessage = NSLocalizedString("invalid_input_msg", comment: "")
            showAlert = true
            return
        }
        let userExists = users.contains { $0.username == username }
        
        if !userExists {
            let newUser = UsersEntity(context: viewContext)
            newUser.username = username
            newUser.password = password
            saveContext()
            
            isLoggedIn = true
        } else {
            alertTitle = NSLocalizedString("username_no", comment: "")
            alertMessage = NSLocalizedString("username_no_msg", comment: "")
            showAlert = true
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

//Login
struct LoginView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var isLoggedIn: Bool
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var isPasswordVisible = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: UsersEntity.entity(), sortDescriptors: []) var users: FetchedResults<UsersEntity>
    
    var body: some View {
        VStack {
            VStack {
                Image("login")
                    .resizable()
                    .frame(width: 70, height: 70)
                Text(LocalizedStringKey("login"))
                    .font(.largeTitle)
            }
            
            
            TextField(NSLocalizedString("username", comment: ""), text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack{
                if isPasswordVisible {
                    TextField(NSLocalizedString("password", comment: ""), text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                } else {
                    SecureField(NSLocalizedString("password", comment: ""), text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            
            
            
            Button(action: {
                loginUser()
            }, label: {
                Text(LocalizedStringKey("login"))
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(LocalizedStringKey("ok")))
            )
        }
    }
    
    private func loginUser() {
        guard !username.isEmpty && !password.isEmpty else {
            alertTitle = NSLocalizedString("invalid_input", comment: "")
            alertMessage = NSLocalizedString("invalid_input_msg", comment: "")
            showAlert = true
            return
            
        }
        
        let userExists = users.contains { $0.username == username && $0.password == password }
        
        if userExists {
            isLoggedIn = true
        } else {
            alertTitle = NSLocalizedString("login_failed", comment: "")
            alertMessage = NSLocalizedString("login_failed_msg", comment: "")
            showAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

