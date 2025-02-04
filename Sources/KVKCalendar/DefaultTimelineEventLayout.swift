//
//  DefaultTimelineEventLayout.swift
//  KVKCalendar
//
//  Created by Tom Knapen on 12/07/2021.
//

#if os(iOS)

import UIKit

public struct DefaultTimelineEventLayout: TimelineEventLayout {
    public func getEventRects(forEvents events: [Event],
                              date: Date?,
                              context: TimelineEventLayoutContext) -> [CGRect] {
        var rects: [CGRect] = []
        let viewMode: TimelineStyle.ViewMode
        switch context.type {
        case .week:
            viewMode = context.style.week.viewMode
        default:
            viewMode = .default
        }
        
        switch viewMode {
        case .default:
            let crossEvents = context.calculateCrossEvents(forEvents: events)
            events.forEach { (event) in
                var frame = context.getEventRect(start: event.start,
                                                 end: event.end,
                                                 date: date,
                                                 style: event.style)

                // calculate 'width' and position 'x' event
                // check events are not empty to avoid crash https://github.com/kvyatkovskys/KVKCalendar/issues/237
                if let crossEvent = crossEvents[event.start.timeIntervalSince1970], !crossEvent.events.isEmpty {
                    var newX = frame.origin.x
                    var newWidth = frame.width
                    newWidth /= CGFloat(crossEvent.events.count == 0 ? 1 : crossEvent.events.count)
                    newWidth -= context.style.timeline.offsetEvent
                    frame.size.width = newWidth

                    if crossEvent.events.count > 1 {
                        rects.forEach { (rect) in
                            while rect.intersects(CGRect(x: newX,
                                                         y: frame.origin.y,
                                                         width: frame.width,
                                                         height: frame.height)) {
                                newX += (rect.width + context.style.timeline.offsetEvent).rounded()
                            }
                        }
                    }

                    frame.origin.x = newX
                }

                rects.append(frame)
            }
        case .list:
            events.forEach { (event) in
                var frame = context.pageFrame
                frame.size.height = event.style?.defaultHeight ?? context.style.event.defaultHeight ?? 50
                frame.origin.y = (rects.last?.origin.y ?? 0) + ((rects.last?.height ?? 0) + context.style.timeline.offsetEvent)
                
                if let defaultWidth = event.style?.defaultWidth ?? context.style.event.defaultWidth {
                    frame.size.width = defaultWidth - context.style.timeline.offsetEvent
                } else {
                    frame.size.width -= context.style.timeline.offsetEvent
                }
                
                rects.append(frame)
            }
        }

        return rects
    }
}

#endif
