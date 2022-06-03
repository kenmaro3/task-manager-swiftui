//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Kentaro Mihara on 2022/05/03.
//

import SwiftUI
import CoreData

class TaskViewModel: ObservableObject{
    @Published var currentTab: String = "Today"
    
    // MARK: New Task Properties
    @Published var openEditTask: Bool = false
    @Published var taskTitle: String = ""
    @Published var taskColor: String = "Yellow"
    @Published var taskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
    @Published var showDatePicker: Bool = false
    
    
    // MARK: Editing Existing Task Data
    @Published var editTask: Task?
    
    
    // MARK: Adding Task to Core Data
    
    func addTask(context: NSManagedObjectContext)-> Bool{
        // MARK: Updating Existing Data in Core Data
        var task: Task!
        if let editTask = editTask{
            task = editTask
        }
        else{
            task = Task(context: context)
        }
        task.title = taskTitle
        task.color = taskColor
        task.deadline = taskDeadline
        task.type = taskType
        task.isCompleted = false
        
        if let _ = try? context.save(){
            return true
        }
        return false
        
    }
    
    
    // MARK: Resetting Task Data
    func resetTaskData(){
        taskType = "Basic"
        taskTitle = ""
        taskColor = "Yellow"
        taskDeadline = Date()
    }
    
    
    // MARK: If Edit task Is Available then Setting Existing Data
    func setupTask(){
        if let editTask = editTask{
            taskType = editTask.type  ?? "Basic"
            taskColor = editTask.color ?? "Yellow"
            taskTitle = editTask.title ?? ""
            taskDeadline = editTask.deadline ?? Date()
        }
    }
    
}

