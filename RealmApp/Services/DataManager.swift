//
//  DataManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {// если мы не можем извлечь данные из юзер дефолтс то мы должны эти данные загрузить и 
            let shoppingList = TaskList() // создаем первый список задач ( экземпляр модели)
            shoppingList.name = "Shopping List" // добавляем конкретный список
            
            let moviesList = TaskList( // еще один список
                value: [
                    "Movies List",
                    Date(),
                    [
                        ["Best film ever"],
                        ["The best of the best", "Must have", Date(), true]
                    ]
                ]
            )
            
            let milk = Task() // создаем задачу! Это экземпляр нашей задачи
            milk.name = "Milk" // называем
            milk.note = "2L" //  отмечаем note
            
            let bread = Task(value: ["Bread", "", Date(), true])//  свойство хлеб где экземпляр таскс со всем заполненными полями
            let apples = Task(value: ["name": "Apples", "note": "2Kg"])// передаем словарь!Ключ - название нашего параметра а значение-название! Весь список из модели не обязательно прописывать
            
            
            shoppingList.tasks.append(milk)// первый способ добавления в задачу
            shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1) // второй способ добавления в Tasks через insert milk уже под индексом 0
            
            DispatchQueue.main.async { // сохраняем данные в базу данных асинхронно основному потоку
                StorageManager.shared.save([shoppingList, moviesList]) // добавляем 2 списка shoppingList и  moviesList
                UserDefaults.standard.set(true, forKey: "done")// сохраняем данные в userDefaults
                completion()
            }
        }
    }
}
