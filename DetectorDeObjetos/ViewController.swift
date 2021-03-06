//
//  ViewController.swift
//  DetectorDeObjetos
//
//  Created by Jhoney Lopes on 10/06/17.
/*
 Copyright 2017 Jhoney Lopes
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var imagemDoObjeto: UIImageView!
    @IBOutlet var resposta: UILabel!
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        resposta.text = "esperando objeto..."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - Functions
extension ViewController {
    
    func detectandoObjeto(imagem: CIImage) {
        
        // Carregar o modelo
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Não foi possível carregar o modelo.")
        }
        
        // Criando "vision request"
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let resultados = request.results as? [VNClassificationObservation], let primeiroResultado = resultados.first else {
                fatalError("Resultado inesperado! Erro fatal!")
            }
            // Atualizar a label de resposta
            DispatchQueue.main.async {
                self.resposta.text = "Com a taxa de \(Int(primeiroResultado.confidence * 100))% acredito que seja: \(primeiroResultado.identifier)"
            }
        }
        
        // Rodar o Core ML para classificação
        let handler = VNImageRequestHandler(ciImage: imagem)
        do {
            try handler.perform([request])
        } catch {
            print("Este foi o erro gerado: \(error)")
        }
        
    }
    
}

// MARK: - IBActions
extension ViewController {
    
    @IBAction func selecionarImagem(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let imagem = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Não foi possível carregar uma imagem!")
        }
        imagemDoObjeto.image = imagem
        resposta.text = "identificando objeto..."
        
        guard let ciIbagens = CIImage(image: imagem) else {
            fatalError("Não consegui converter as ibagenssss")
        }
        detectandoObjeto(imagem: ciIbagens)
    }
    
}

// MARK: - UINavigationViewControllerDelegate
extension ViewController: UINavigationControllerDelegate {
    
}


