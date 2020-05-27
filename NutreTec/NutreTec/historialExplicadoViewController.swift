//
//  historialExplicadoViewController.swift
//  NutreTec
//
//  Created by Oscar Francisco Lopez Escobar on 18/05/20.
//  Copyright © 2020 disp_moviles. All rights reserved.
//

import UIKit
import Charts

class historialExplicadoViewController: UIViewController {

    @IBOutlet weak var lblTitulo: UILabel!
    // La vista de la gráfica de puntos.
    @IBOutlet weak var chartView: LineChartView!
    
    var titulo = ""
    var tamano = 40
    var date = Date()
    var tipo = ""
    var diaString = ""
    var misRegistros = [RegistroProgreso]()
    // Los valores para la gráfica.
    var valores = [ChartDataEntry]()
    // valores2 y valores3 se usan si se deben graficar todas las métricas.
    // (tipo == "general")
    var valores2 = [ChartDataEntry]()
    var valores3 = [ChartDataEntry]()
    
    @IBOutlet weak var btnIzquierda: UIButton!
    @IBOutlet weak var btnDerecha: UIButton!
    
    override func viewDidLoad() {
        lblTitulo.text = titulo
        lblTitulo.font = lblTitulo.font.withSize(CGFloat(tamano))
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Encontrar la cantidad de datos disponibles.
        misRegistros = []
        
        // Cargar los registros del archivo y guardarlos en misRegistros.
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("registrosProgreso.plist")

        misRegistros.removeAll()
        do {
            let data = try Data.init(contentsOf: pathArchivo)
            misRegistros = try PropertyListDecoder().decode([RegistroProgreso].self, from: data)
        } catch {
            print("Error al cargar los datos")
        }

        // Obtener la fecha de hoy.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        diaString = dateFormatter.string(from: date)
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "dd"

        // Generar máximo 5 puntos y empezar a buscar desde
        // el último elemento del arreglo misRegistros.
        var (jIzq, jDer) = generarSetsYGrafica(i: 5, j: misRegistros.count - 1)
    }
    
    // Generar los arreglos (valores, valores2, valores3) con los
    // puntos que se graficarán.
    // Generar la gráfica.
    // Parámetros:
    //  i: la cantidad máxima de puntos que se generarán
    //  j: el índice inicial para buscar en el arreglos misRegistros
    //     de manera descendente (por defecto este valor es
    //     misRegistros.count - 1).
    // Regresa los últimos índices a la izquierda y derecha.
    func generarSetsYGrafica(i : Int, j : Int) -> (Int, Int) {
        
        let jInicial = j
        
        var i = i
        var j = j
        
        // Habilitar/deshabilitar botones
        // cuando no hay más datos en
        // alguna dirección.
        if j - i <= 0 {
            btnIzquierda.isEnabled = false
        } else {
            btnIzquierda.isEnabled = true
        }
        
        if jInicial == misRegistros.count - 1 {
            btnDerecha.isEnabled = false
        } else {
            btnDerecha.isEnabled = true
        }
        
        while i > 0 {
            
            var entry = ChartDataEntry()
            
            // Ya no hay más registros.
            if j < 0 {
                break
            }
            
//            let tempDate = dateFormatter.date(from: misRegistros[j].dia)
            // let tempDay = Double(dayDateFormatter.string(from: tempDate!))!
            
            if tipo == "peso" {
                entry = ChartDataEntry(x: Double(i), y: misRegistros[j].peso)
            } else if tipo == "masa" {
                entry = ChartDataEntry(x: Double(i), y: misRegistros[j].masaMuscular)
            } else if tipo == "grasa" {
                entry = ChartDataEntry(x: Double(i), y: misRegistros[j].porcentajeGrasa)
            }
            
            if tipo == "general" {
                let entryPeso = ChartDataEntry(x: Double(i), y: misRegistros[j].peso)
                let entryMasa = ChartDataEntry(x: Double(i), y: misRegistros[j].masaMuscular)
                let entryGrasa = ChartDataEntry(x: Double(i), y: misRegistros[j].porcentajeGrasa)
                
                valores.append(entryPeso)
                valores2.append(entryMasa)
                valores3.append(entryGrasa)
                
            } else {
                valores.append(entry)
            }
            
            j -= 1
            i -= 1
            
        }
        
        // Voltear el arreglo para que esté en orden cronológico.
        valores.reverse()
        valores2.reverse()
        valores3.reverse()
        
        // Crear la gráfica.
        setChartValues(tipo: tipo)
        
        return (j + 1, jInicial)
    }
    
    func setChartValues(tipo : String) {
        
        /*
        
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(count)) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set1 = LineChartDataSet(entries: values, label: titulo)
        let data = LineChartData(dataSet: set1)
 
         */
        
        let data = LineChartData()
        self.chartView.xAxis.granularity = 1.0
        
        if tipo != "general" {
            
            let label = tipo == "peso" ? "Peso (kg)" : (tipo == "masa") ? "Masa muscular (kg)" : (tipo == "grasa") ? "Porcentaje de grasa (%)" : ""
            
            let set1 = LineChartDataSet(entries: valores, label: label)

            // self.chartView.data = data
            data.addDataSet(set1)
        }
        
        self.chartView.rightAxis.enabled = false

        if tipo == "peso" {
            self.chartView.leftAxis.axisMinimum = 0
            self.chartView.leftAxis.axisMaximum = data.getDataSetByIndex(0).yMax * 2
        } else if tipo == "masa" {
            self.chartView.leftAxis.axisMinimum = 0
            self.chartView.leftAxis.axisMaximum = data.getDataSetByIndex(0).yMax * 2
        } else if tipo == "grasa" {
            self.chartView.leftAxis.axisMinimum = 0
            self.chartView.leftAxis.axisMaximum = 100
        } else if tipo == "general" {
            let set1 = LineChartDataSet(entries: valores, label: "Peso (kg)")
            let set2 = LineChartDataSet(entries: valores2, label: "Masa muscular (kg)")
            let set3 = LineChartDataSet(entries: valores3, label: "Porcentaje de grasa (%)")

            // Poner las líneas de colores diferentes.
            var colors1 = [NSUIColor]()
            var colors2 = [NSUIColor]()
            for _ in 0..<set1.count {
                colors1.append(UIColor.red as NSUIColor)
                colors2.append(UIColor.green as NSUIColor)
            }
            
            set1.colors = [colors1[0]]
            set1.circleColors = colors1
            
            set2.colors = [colors2[0]]
            set2.circleColors = colors2
            
            data.addDataSet(set1)
            data.addDataSet(set2)
            data.addDataSet(set3)
        }
        
        self.chartView.data = data

    }

    // Busca en misRegistros el día de hoy.
    // Empieza a buscar desde el final.
    // Si existe, regresarlo.
    // Si no, regresar nil.
    func buscarDia(dia: String) -> RegistroProgreso? {
        
        for reg in misRegistros.reversed() {
            if reg.dia == diaString {
                return reg
            }
        }
        
        return nil
    }
    
    @IBAction func tapIzquierda(_ sender: UIButton) {
    }
    
    
    @IBAction func tapDerecha(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
