//
//  DatePickerSection.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct DatePickerSection: View {
    @ObservedObject var viewModel: CalorieViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset - 3, to: Date())!
                    let day = Calendar.current.component(.day, from: date)
                    let weekday = Calendar.current.component(.weekday, from: date)
                    let weekdaySymbol = String(Calendar.current.shortWeekdaySymbols[weekday - 1].prefix(3))
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                    let isFutureDate = date > Date()
                    let hasRecord = viewModel.hasRecord(for: date) // Check if there is a record for this date
                    
                    VStack(spacing: 4) {
                        Text(weekdaySymbol)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        ZStack {
                            Text("\(day)")
                                .font(.headline)
                                .foregroundColor(isSelected && !isFutureDate ? .white : isFutureDate ? .gray : .green)
                                .padding()
                                // Only show background circle for selected dates
                                .background(isSelected && !isFutureDate ? Color.green : Color.clear)
                                .clipShape(Circle())
                            
                            // Green dot above the day number if there is a record
                            if hasRecord && !isFutureDate {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                    .offset(y: -20) // Position the dot above the day number
                            }
                        }
                    }
                    .onTapGesture {
                        if !isFutureDate {
                            viewModel.selectedDate = date
                        }
                    }
                    .disabled(isFutureDate)
                }
            }
        }
    }
}
