//
//  Home.swift
//  TaskManager
//
//  Created by Kentaro Mihara on 2022/05/03.
//

import SwiftUI

struct Home: View {
    @StateObject var taskModel: TaskViewModel = .init()
    // MARK: Matched Geometory Namespace
    @Namespace var animation
    
    
    // MARK: Fetching Tasks
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.deadline, ascending: false)], predicate: nil, animation: .easeInOut) var tasks: FetchedResults<Task>
    
    // MARK: Environment Values
    @Environment(\.self) var env
    
    
    var body: some View {
        let _ = print("\nhere=============")
        let _ = print("\(tasks.count)")
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                VStack(alignment: .leading, spacing: 8){
                    Text("Welcome back")
                        .font(.callout)
                    Text("Here's Update Today.")
                        .font(.title2.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                
                CustomSegmentedBar()
                    .padding(.top, 5)
                
                // MARK: Task View
                // Later will come
                TaskView()
            }
            .padding()
        }
        .overlay(alignment: .bottom){
            // MARK: Add Button
            Button{
                taskModel.openEditTask.toggle()
                
            } label: {
                Label{
                    Text("Add Task")
                        .font(.callout)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "plus.app.fill")
                }
                .foregroundColor(Color("segmented_character_selected"))
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color("segmented_character_not_selected"), in: Capsule())
            }
            
            // MARK: Linear Gradient BG
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
            .background{
                LinearGradient(colors: [
                    Color("segmented_character_selected").opacity(0.05),
                    Color("segmented_character_selected").opacity(0.4),
                    Color("segmented_character_selected").opacity(0.7),
                    Color("segmented_character_selected")
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
            }
            
        }
        
        .fullScreenCover(isPresented: $taskModel.openEditTask){
            taskModel.resetTaskData()
        } content: {
            AddNewTask()
                .environmentObject(taskModel)
        }
    }
    
    // MARK: TaskView
    @ViewBuilder
    func TaskView() -> some View{
        LazyVStack(spacing: 20){
            // MARK: Custom Filtered Request View
            
            DynamicFilteredView(currentTab: taskModel.currentTab){ (task: Task) in
                TaskRowView(task: task)
            }
//            ForEach(tasks){ task in
//                TaskRowView(task: task)
//            }
        }
        .padding(.top, 20)
    }
    
    // MARK: TaskRowView
    @ViewBuilder
    func TaskRowView(task: Task) -> some View{
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.3))
                    }
                Spacer()
                
                // MARK: Edit Button only for InCompleted Task
                //if !task.isCompleted && taskModel.currentTab != "Failed"{
                if taskModel.currentTab != "Failed"{
                    Button{
                        taskModel.editTask = task
                        taskModel.openEditTask = true
                        taskModel.setupTask()
                        
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.black)
                        
                    }
                }
            }
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundColor(.black)
                .padding(.vertical, 10)
            
            HStack(alignment: .bottom, spacing: 0){
                VStack(alignment: .leading, spacing: 10){
                    Label{
                        Text((task.deadline ?? Date()).formatted(date: .long, time: .omitted))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    
                    Label{
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.isCompleted && taskModel.currentTab != "Failed"{
                //if taskModel.currentTab != "Failed"{
                    Button{
                        // MARK: Update Core Data
                        task.isCompleted.toggle()
                        try? env.managedObjectContext.save()
                        
                    } label: {
                        Circle()
                            .strokeBorder(.black, lineWidth: 1.5)
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                }
            }
            
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(task.color ?? "Yellow"))
        }
    }
    
    // MARK: Custom Segmented Bar
    @ViewBuilder
    func CustomSegmentedBar() -> some View{
        // In Case if we Missed the Task
        let tabs = ["Today", "Upcoming", "Task Done", "Failed"]
        HStack(spacing: 10){
            ForEach(tabs, id: \.self){ tab in
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(taskModel.currentTab == tab ? Color("segmented_character_selected"): Color("segmented_character_not_selected"))
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background{
                        if taskModel.currentTab == tab {
                            Capsule()
                                .fill(Color("segmented_background_selected"))
                                .matchedGeometryEffect(id: "TAB", in: animation)
                            
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture{
                        withAnimation{taskModel.currentTab = tab}
                        
                    }
            }
        }
        
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
