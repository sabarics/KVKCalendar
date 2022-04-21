//
//  ListViewData.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 26.12.2020.
//

#if os(iOS)

import Foundation

public struct SectionListView {
    
    public let date: Date
    public var events: [Event]
    public var isShowHeader:Bool = false
    public init(date: Date, events: [Event]) {
        self.date = date
        self.events = events
    }
}

public final class ListViewData {
    
    var sections: [SectionListView]
    var date: Date
    var isSkeletonVisible = false
    
    init(data: CalendarData) {
        self.date = data.date
        self.sections = []
    }
    
    public init(date: Date, sections: [SectionListView]) {
        self.date = date
        self.sections = sections
    }
    
    func titleOfHeader(section: Int, formatter: DateFormatter, locale: Locale) -> String {
        let dateSection = sections[section].date
        formatter.locale = locale
        return formatter.string(from: dateSection)
    }
    
    func reloadEvents(_ events: [Event]) {
        sections = events.reduce([], { (acc, event) -> [SectionListView] in
            var accTemp = acc
            
            guard let idx = accTemp.firstIndex(where: { $0.date.year == event.start.year && $0.date.month == event.start.month && $0.date.day == event.start.day }) else {
                accTemp += [SectionListView(date: event.start, events: [event])]
                accTemp = accTemp.sorted(by: { $0.date < $1.date })
                return accTemp
            }
            
            accTemp[idx].events.append(event)
            accTemp[idx].events = accTemp[idx].events.sorted(by: { $0.start < $1.start })
            return accTemp
        })
        
        var tempSectionList : [SectionListView] = []
        for (index,obj) in sections.enumerated(){
            guard let idx = tempSectionList.firstIndex(where: { $0.date.year == obj.date.year && $0.date.month == obj.date.month }) else {
                tempSectionList.append(sections[index])
                continue
            }
        }
        for (_,obj) in tempSectionList.enumerated(){
            let firstIndex = sections.firstIndex{$0.date == obj.date}
            if let firstIndex = firstIndex{
                sections[firstIndex].isShowHeader = true
            }
        }
    }
    
    func event(indexPath: IndexPath) -> Event {
        sections[indexPath.section].events[indexPath.row]
    }
    
    func numberOfSection() -> Int {
        isSkeletonVisible ? 2 : sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        isSkeletonVisible ? 5 : sections[section].events.count
    }
    
}

#endif
