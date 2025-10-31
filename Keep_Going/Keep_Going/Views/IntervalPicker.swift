//
//  IntervalPicker.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import SwiftUI

struct IntervalPicker: View {
    @Binding var interval: Int
    @State private var showWheel: Bool = false
    var onInteraction: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            HStack{
                Text("Repeat every")
                Spacer()
                Text("\(interval) \(interval == 1 ? "day" : "days")")
                    .foregroundStyle(showWheel ? .red : .blue)
                    
            }
            .onTapGesture {
                onInteraction?()
                withAnimation {
                    showWheel.toggle()
                }
            }
            if showWheel {
                Picker("Interval", selection: $interval) {
                    ForEach(1..<100) { i in
                        Text("\(i)")
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: interval) { _, _ in
                    onInteraction?()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var interval: Int = 2
    IntervalPicker(interval: $interval)
}

