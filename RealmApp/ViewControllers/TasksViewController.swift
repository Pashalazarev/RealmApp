//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList! // основной список который мы передаем с помощью prepare for segue
    
    private var currentTasks: Results<Task>! // массив с текущими задачами создаем из общего списка задач
    private var completedTasks: Results<Task>!//  массив с выполненными задачами создаем из общего списка задач

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        currentTasks = taskList.tasks.filter("isComplete = false")//  наполняем массив с текущими задачами по параметру "isComplete = false". т.е будут все значения которые не выполнены. оно есть в модели!
        completedTasks = taskList.tasks.filter("isComplete = true") // наполняем массив с выполненными задачами по параметру по  "isComplete = false". будут все значения которые выполнены
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { // определяем 2 секции
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row] // в зависимости от того какая секция мы берем задачу из текущей, либо выполненной задачи
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }

//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // метод с помощью которого появляются 3 кнопочки слева направа
//       
//        
//    }
    
}

extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { [weak self] taskTitle, note in
            if let _ = task, let _ = completion {
                // TODO - edit task
            } else {
                self?.save(task: taskTitle, withNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        StorageManager.shared.save(task, withNote: note, to: taskList) { task in // сохраняем в storageManager
            let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0) // отображаем визуально
            tableView.insertRows(at: [rowIndex], with: .automatic) // перезагружаем нашу tableView по индексу автоматически
        }
    }
}
