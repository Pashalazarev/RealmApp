//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {

    var taskLists: Results<TaskList>! // сделали список который соответсвует стандартам realm ( массив)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        createTempData()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)// обращаемся к нашей базе через точку входа в нашу базу и вызываем метод objects который находит и формирует список на основе данных task list
    }
    
    override func viewWillAppear(_ animated: Bool) { // метод который перезапускает табличное представление
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count // кол-во элементов элементов нашего массива
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.name
        content.secondaryText = "\(taskList.tasks.count)"
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // trailingSwipeActionsConfigurationForRowAt метод который определяет 3 кнопочки при свайпе слева направо!
        let taskList = taskLists[indexPath.row] // вытачкиваем 1 элемент из массива
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in // в методе delete  мы
            StorageManager.shared.delete(taskList) // обращаемся к storage manager и вызываем метод delete куда передаем список наших задач
            tableView.deleteRows(at: [indexPath], with: .automatic) // удаляем 1 какуе-то ячейку по индексу автоматически
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic) // кнопка edit
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in // is done нужен когда мы внесли изменения в alertController и кнопка возвращалась в стандартное состояние
            StorageManager.shared.done(taskList) // кнопка done
            tableView.reloadRows(at: [indexPath], with: .automatic) // перезагружаем табличное представление
            isDone(true)
        }
        
        editAction.backgroundColor = .orange // настраиваем цвет для кнопки
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // метод prepare for segue
        guard let indexPath = tableView.indexPathForSelectedRow else { return }// находим индекс нашей ячейки  по той по которой тапаем
        guard let tasksVC = segue.destination as? TasksViewController else { return } // создаем экземпляр вьюконтроллера на который будет переход, кастим до нужного вьюконтроллера
        let taskList = taskLists[indexPath.row] // извлекаем один элемент по индексу который определен выше из нашего массива
        tasksVC.taskList = taskList // списов передаем на сл экран
    }

    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func createTempData() { // создаем метод специальный чтобы реализовать метод из DataManager
        DataManager.shared.createTempData { [unowned self] in
            tableView.reloadData() // перезапускаем методы протокола табличного
        }
    }
}

extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
        
        alert.action(with: taskList) { [weak self] newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList, newValue: newValue)
                completion()
            } else {
                self?.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        StorageManager.shared.save(taskList) { taskList in
            let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0) // находим индекс по которому будем добавлять
            tableView.insertRows(at: [rowIndex], with: .automatic) // перезагружаем одну ячейку( обновляем)
        }
    }
}
