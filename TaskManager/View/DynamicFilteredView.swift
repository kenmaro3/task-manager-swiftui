//
//  DynamicFilteredView.swift
//  TaskManager
//
//  Created by Kentaro Mihara on 2022/05/03.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject{
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    // MARK: Building Custom ForEach which will give Coredata object to build View
    //init(dateToFilter: Date, @ViewBuilder content: @escaping (T)->Content){
    init(currentTab: String, @ViewBuilder content: @escaping (T)->Content){
        // MARK: Predicate to Filter current date Tasks
        let calendar = Calendar.current
        var predicate: NSPredicate!
        
        if currentTab == "Today"{
            let today = calendar.startOfDay(for: Date())
            let tommorow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 hours
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tommorow, 0])
        }
        else if currentTab == "Upcoming"{
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tommorow = Date.distantFuture
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 hours
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tommorow, 0])
            
        }
        else if currentTab == "Task Done"{
            // This will fetch task between today and tommorow which is 24 hours
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
            
        }
        else if currentTab == "Failed"{
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 hours
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past, today, 0])
            
        }
        else{
            
        }
        
        
        
        
        // Initializing Request with NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: predicate)
        self.content = content
    }
    
    var body: some View{
        Group{
            if request.isEmpty{
                Text("No tasks  found!!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            }
            else{
                ForEach(request, id: \.objectID){ object in
                    self.content(object)
                    
                }
            }
        }
    }
}

