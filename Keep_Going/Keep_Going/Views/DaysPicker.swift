//
//  DaysPicker.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 16/05/2025.
//

import SwiftUI

struct DaysPicker: View {
    @Binding var schedule: [WeekDay]
    var onInteraction: (() -> Void)? = nil
    
    var body: some View {
        ForEach(WeekDay.allCases) { day in
            HStack {
                Text(day.name)
                Spacer()
                CustomeCheckField(value: (schedule.first {$0 == day}) != nil ? true : false )
            }
            .padding(4)
            .frame(height: 30)
//            .background(Color.gray.opacity(0.1))
//            .background(in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .compositingGroup()
            .shadow(radius: 2)
            .onTapGesture {
                onInteraction?()
                if let i = schedule.firstIndex(where: {$0 == day}){
                    schedule.remove(at: i)
                } else {
                    schedule.append(day)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var schedule: [WeekDay] = [.monday]
    DaysPicker(schedule: $schedule)
}

