//
//  TimePickerView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var isImmediateSheetOpened: Bool
    
    @State private var tempSelectedHours: Int
    @State private var tempSelectedMinutes: Int
    
    @Environment (\.colorScheme) private var colorScheme
    
    init(selectedHours: Binding<Int>, selectedMinutes: Binding<Int>, isImmediateSheetOpened: Binding<Bool>) {
            self._selectedHours = selectedHours
            self._selectedMinutes = selectedMinutes
            self._isImmediateSheetOpened = isImmediateSheetOpened
            self._tempSelectedHours = State(initialValue: selectedHours.wrappedValue)
            self._tempSelectedMinutes = State(initialValue: selectedMinutes.wrappedValue)
        }

    var body: some View {
        VStack {
            Text("Durée")
                .font(.title)
                .bold()
                .padding()
            Text("Sélectionner la durée du temps d'écran.")
                .foregroundStyle(.secondary)
            HStack {
                Picker("hours", selection: $tempSelectedHours) {
                    ForEach(0..<24, id: \.self) { i in
                        Text("\(i)").tag(i)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .onChange(of: tempSelectedHours) { newValue in
                    if (newValue == 0 && tempSelectedMinutes == 0) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            tempSelectedMinutes = 1
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                Text("hrs")
                    .bold()
                Picker("minutes", selection: $tempSelectedMinutes) {
                    ForEach(stride(from: 0, to: 60, by: 1).map({$0}), id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .onChange(of: tempSelectedMinutes) { newValue in
                    if (tempSelectedHours == 0 && newValue == 0) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            tempSelectedMinutes = 1
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                Text("mns")
                    .bold()
            }
            .padding()
            
            HStack {
                
                Button(action: {
                    isImmediateSheetOpened = false
                }, label: {
                    Text("Annuler")
                })
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .white : .black))
                Button(action: {
                    isImmediateSheetOpened = false
                    selectedHours = tempSelectedHours
                    selectedMinutes = tempSelectedMinutes
                }, label: {
                    Text("Confirmer")
                })
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .white : .black))
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    VStack {
        @State var hour = 12
        @State var minute = 5
        @State var isPresented = true
        TimePickerView(selectedHours: $hour, selectedMinutes: $minute, isImmediateSheetOpened: $isPresented)
    }
    .background(.gray.opacity(0.5))
//    ContentView()
}
