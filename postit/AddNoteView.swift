//
//  AddNoteView.swift
//  postit
//
//  Created by Carlos Petit on 04-12-22.
//

import SwiftUI

struct AddNoteView: View {
    @State var text = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        HStack {
            TextField("write a note", text: $text)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .clipped()
            Button(action: postNote) {
                Text("add note")
            }
            .padding(8)
            
        }
    }
    func postNote() {
        let paraameter = ["title": text, "body":text] as [String: Any]
        
        let url = URL(string: "http://localhost:3021/notes")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do{
            try request.httpBody = JSONSerialization.data(withJSONObject: paraameter, options: .prettyPrinted)
        }catch{
            print(error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { data, res, err in
            guard err == nil else {return}
            guard let data = data else {return}
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                }
                    
            }catch let error{
                print(error)
            }
        
    }
        task.resume()
        self.text = ""
        presentationMode.wrappedValue.dismiss()
        
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView()
    }
}

