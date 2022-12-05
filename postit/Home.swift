//
//  ContentView.swift
//  postit
//
//  Created by Carlos Petit on 30-11-22.
//

import SwiftUI

struct Home: View {
    @State var notes = [Note]()
    @State var showAdd = false
    @State var showAlert = false
    @State var deleteItem: Note?
    @State var isEditMode: EditMode = .inactive
    @State var updateNote = ""
    @State var updateID = ""
    
    var alert: Alert{
        Alert(title: Text("Delete"),
              message: Text("are you sure man?"),primaryButton: .destructive(Text("Delete"),  action: deleteNotes),
              secondaryButton: .cancel())
    }
    
    var body: some View {
        NavigationView{
            List(self.notes) { note in
                HStack{
                    if self.isEditMode == .active {
                        HStack{
                            Image(systemName: "pencil.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.yellow)
                            VStack{
                                Text("\(note.title)")
                                    
                                    .onLongPressGesture {
                                        self.showAlert.toggle()
                                        self.deleteItem = note
                                    }
                                Text(note.body)
                                    .font(.subheadline)
                            }
                            .padding()
                            
                                
                        }
                        .onTapGesture {
                            self.updateNote = note.body
                            self.updateID = note.id
                            self.showAdd.toggle()
                        }
                        
                    }else{
                        HStack{
                            Image(systemName: "bookmark")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                            VStack (alignment: .leading){
                                Text("\(note.title)")
                                    .onLongPressGesture {
                                        self.showAlert.toggle()
                                        self.deleteItem = note
                                    }
                                Text(note.body)
                                    .font(.subheadline)
                            }
                            .padding()
                           
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            .alert(isPresented: $showAlert, content: {
                alert
            })
            .sheet(isPresented: $showAdd, onDismiss: {
                fetchNotes()
                if self.isEditMode == .active {
                    self.isEditMode = .inactive
                }
            }, content: {
                if self.isEditMode == .inactive {
                    AddNoteView()
                }else{
                    UpdateNoteView(text: $updateNote, noteID: $updateID)
                }
                
            })
            .onAppear(perform: {
                fetchNotes()
            })
            .navigationTitle("Home")
            .navigationBarItems(leading:Button(action: {
                if self.isEditMode == .inactive {
                    self.isEditMode = .active
                }else{
                    self.isEditMode = .inactive
                }
            }, label: {
                if self.isEditMode == .inactive {
                    Text("Edit")
                }else{
                    Text("Done")
                }
            }), trailing: Button(action: {
                self.showAdd.toggle()
            }, label: {
                Text("Add")
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }) )
        }
    }
    
    func fetchNotes(){
        let url = URL(string: "http://localhost:3021/notes")!
        let task = URLSession.shared.dataTask(with: url) { data, res, err in
            guard let data = data else {return}
            do {
                let notes = try JSONDecoder().decode([Note].self, from: data)
                self.notes = notes
            }catch{
                print("Error Decode data \(error)")
            }
            
        }
        task.resume()
    }
    
    func deleteNotes() {
        guard let id =  self.deleteItem?._id else { return }
        let url = URL(string: "http://localhost:3021/notes/\(id)")!
        print(url)
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
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
        fetchNotes()
    }
}


struct Note: Identifiable, Codable {
    var id: String { _id }
    var _id: String
    var title: String
    var body: String
    var createdAt: String
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
