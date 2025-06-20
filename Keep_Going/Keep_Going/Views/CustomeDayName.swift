//
//  CustomeDayName.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 05/06/2025.
//

import SwiftUI

struct CustomeDayName: View {
    var day: WeekDay
    var value: Bool
    var body: some View {
        HStack{
            Spacer()
            Text(day.name)
                .font(.footnote)
            Spacer()
        }
//        .padding(4)
        .frame(height: 30)
        .background(value ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
        .background(in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        .compositingGroup()
        .shadow(radius: 2)
    }
}

#Preview {
    CustomeDayName(day: .monday, value: true)
}
#Preview {
    CustomeDayName(day: .monday, value: false)
}
