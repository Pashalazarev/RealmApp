//
//  AlertController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

extension UIAlertController { // создаем расширение для alert controller
    
    static func createAlert(withTitle title: String, andMessage message: String) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: .alert) // создаем метод который будем вызывать на других вьюконтроллерах
    }
        
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) { // есть метод action в подклассе UIAlertController. Создаем для списка задач
        
        let doneButton = taskList == nil ? "Save" : "Update" // создаем title
                
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in // делаем кнопку save и передаем title
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) // делаем кнопку cancel и передаем titlr
        
        addAction(saveAction) // добавляем экшины
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) { // создаем экшн для тасков
                        
        let title = task == nil ? "Save" : "Update"
        
        let saveAction = UIAlertAction(title: title, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "New task"
            textField.text = task?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = task?.note
        }
    }
}
