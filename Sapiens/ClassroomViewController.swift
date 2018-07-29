//
//  ClassroomViewController.swift
//  Sapiens
//
//  Created by Daniel Araújo on 25/07/2018.
//  Copyright © 2018 Daniel Araújo Silva. All rights reserved.
//
import UIKit
import SwiftDataTables

class ClassroomViewController: UIViewController {

    var user = User(user: COREDATA.loginUserCore().user!, pass: COREDATA.loginUserCore().pass!)
    
    var dataTable: SwiftDataTable! = nil
    var dataSource: DataTableContent = []
    
    var arraySchedules : [SchedulesInfo] = []
    
    let headerTitles = [
        "Código",
        "Nome",
        "Créditos",
        "Prática",
        "Teorica"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataTable = SwiftDataTable(dataSource: self)
        self.dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dataTable.frame = self.view.frame
        self.view.addSubview(self.dataTable);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("------------------MATERIAS--------------------")
        REST.schedulesResponse(user: self.user, onComplete: { (arrayResponse) in
            for i in arrayResponse.disciplinas {
                self.dataSource.append([
                    DataTableValueType.string(i.codigo),
                    DataTableValueType.string(i.nome),
                    DataTableValueType.string(i.creditos),
                    DataTableValueType.string(i.turma.pratica),
                    DataTableValueType.string(i.turma.teorica)
                    ])
            }
            self.dataTable.reload()
        }) { (error) in
            switch error {
            case .noResponse:
                self.showAlert(title: "Erro!", message: MESSAGE.MESSAGE_NORESPONSE)
            case .noJson:
                self.showAlert(title: "Erro!", message: MESSAGE.MESSAGE_NOJSON)
            case .nullResponse:
                self.showAlert(title: "Erro!", message: MESSAGE.MESSAGE_NULLJSON)
            case .responseStatusCode(code: let codigo):
                self.showAlert(title: "Erro!", message: MESSAGE.returnStatus(valueStatus:codigo))
            case .noConectionInternet:
                self.showAlert(title: "OPS!", message: MESSAGE.MESSAGE_NO_INTERNET)
            default:
                self.showAlert(title: "OPS!", message: MESSAGE.MESSAGE_DEFAULT)
            }
        }
        self.dataSource.removeAll()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
}

extension ClassroomViewController: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return self.headerTitles.count
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}