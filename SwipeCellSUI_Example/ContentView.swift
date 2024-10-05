//
//  ContentView.swift
//  SwipeCellSUI_Example
//
//  Created by Dominik Butz on 19/10/2020.
//

import SwiftUI
import SwipeCellSUI

struct ContentView: View {
    
    @State var data = (1...10).map { "Item \($0)" }
    @State var currentUserInteractionCellID: String?
    
    @State private var selection:Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Picker("", selection:  Binding<Int>(
                    get: { self.selection },
                    set: { tag in
                        withAnimation { // needed explicit for transitions
                            self.selection = tag
                        }
                    })) {
                    Text("Scroll View").tag(0)
                    Text("List").tag(1)
                }
                .pickerStyle(.segmented)
                
                switch selection {
                    
                case 0:
                    scrollView(data: data, proxy: proxy).transition(.move(edge: .leading))
                default:
                    listView(data: data, proxy: proxy).transition(.move(edge: .trailing))
                }
                
            }
        }
    }
    
    func scrollView(data:[String], proxy:GeometryProxy)->some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 10) {
                listContent(data: data, proxy: proxy)
            }.animation(.default, value: data)
        }
    }
    
    func listView(data:[String], proxy:GeometryProxy)->some View {
        return List {
            listContent(data: data, proxy: proxy)
        }.animation(.default, value: data)
    }
    
    func listContent(data:[String], proxy:GeometryProxy) -> some View {
        ForEach(data, id:\.self) { item in
            RowView(availableWidth: proxy.size.width - 20, item: item, fillColor: selection == 0 ? .green :  .orange, deletionCallback: { item in
                    self.data = self.data.filter({ (anyItem) -> Bool in
                        anyItem != item
                    })
            }, currentUserInteractionCellID: $currentUserInteractionCellID)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}


struct RowView: View {
    var availableWidth: CGFloat
    var item: String
    var fillColor: Color
    @State private var isPinned: Bool = false
    var deletionCallback: (String)->()
    @Binding var currentUserInteractionCellID: String?
    
    var body: some View {
        Text(item).frame(width: availableWidth, height:100)
            .background(RoundedRectangle(cornerRadius: 5).fill(fillColor))
            .swipeCell(id: self.item, cellWidth: availableWidth, leadingSideGroup: leftGroup(), trailingSideGroup: rightGroup(), currentUserInteractionCellID: $currentUserInteractionCellID, settings: SwipeCellSettings())
            .onTapGesture {
                self.currentUserInteractionCellID = item
            }
     
    }
    
    func leftGroup()->[SwipeCellActionItem] {
        return [ SwipeCellActionItem(buttonView: {
            
            self.pinView(swipeOut: false)
            
        }, swipeOutButtonView: {
            self.pinView(swipeOut: true)
        }, buttonWidth: 80, backgroundColor: .yellow, swipeOutAction: true, swipeOutHapticFeedbackType: .success, swipeOutIsDestructive: false)
        {
            print("pin action!")
            self.isPinned.toggle()
        }]
    }
    
    func pinView(swipeOut: Bool)->AnyView {

            Group {
                Spacer()
                VStack(spacing: 2) {
                    Image(systemName: self.isPinned ? "pin.slash": "pin").font(.system(size: 24)).foregroundColor(.white)
                    Text(self.isPinned ? "Unpin": "Pin").fixedSize().font(.system(size: 14)).foregroundColor(.white)
                }.frame(maxHeight: 80).padding(.horizontal, swipeOut ? 20 : 5)
                if swipeOut == false {
                    Spacer()
                }
            }.animation(.default).castToAnyView()

    }
    
    
    func rightGroup()->[SwipeCellActionItem] {

        let items =  [
            SwipeCellActionItem(buttonView: {
    
                    VStack(spacing: 2)  {
                    Image(systemName: "person.crop.circle.badge.plus").font(.system(size: 22)).foregroundColor(.white)
                        Text("Share").fixedSize().font(.system(size: 12)).foregroundColor(.white)
                    }.frame(maxHeight: 80).castToAnyView()

            }, backgroundColor: .blue)
            {
                print("share action!")
            },
            SwipeCellActionItem(buttonView: {
                    VStack(spacing: 2)  {
                    Image(systemName: "folder.fill").font(.system(size: 22)).foregroundColor(.white)
                        Text("Move").fixedSize().font(.system(size: 12)).foregroundColor(.white)
                    }.frame(maxHeight: 80).castToAnyView()
          
            }, backgroundColor: .purple, actionCallback: {
                print("folder action")
            }),
            
            SwipeCellActionItem(buttonView: {
                self.trashView(swipeOut: false)
            }, swipeOutButtonView: {
                self.trashView(swipeOut: true)
            }, backgroundColor: .red, swipeOutAction: true, swipeOutHapticFeedbackType: .warning, swipeOutIsDestructive: true) {
                print("delete action")
               self.deletionCallback(item)
            }
          ]
        
        return items
    }
    
    func trashView(swipeOut: Bool)->AnyView {
            VStack(spacing: 3)  {
                Image(systemName: "trash").font(.system(size: swipeOut ? 28 : 22)).foregroundColor(.white)
                Text("Delete").fixedSize().font(.system(size: swipeOut ? 16 : 12)).foregroundColor(.white)
            }.frame(maxHeight: 80).animation(.default).castToAnyView()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
