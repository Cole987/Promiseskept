//
//  PromiseWidget.swift
//  PromisTracker
//
//  Created by Yanis Racouët on 7/12/25.
//

import WidgetKit
import SwiftUI

struct PromiseEntry: TimelineEntry {
    let date: Date
    let promises: [Promise]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PromiseEntry {
        PromiseEntry(date: Date(), promises: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (PromiseEntry) -> ()) {
        completion(PromiseEntry(date: Date(), promises: loadPromises()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PromiseEntry>) -> ()) {
        let entry = PromiseEntry(date: Date(), promises: loadPromises())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }

    func loadPromises() -> [Promise] {
        if let data = UserDefaults.standard.data(forKey: "promises"),
           let decoded = try? JSONDecoder().decode([Promise].self, from: data) {
            return decoded
        }
        return []
    }
}

struct PromiseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Promesses actives")
                .font(.headline)
            ForEach(entry.promises.prefix(3)) { promise in
                Text(promise.title)
                    .font(.subheadline)
            }
            if entry.promises.isEmpty {
                Text("Aucune promesse")
                    .font(.subheadline)
            }
        }
        .padding()
    }
}

@main
struct PromiseWidget: Widget {
    let kind: String = "PromiseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PromiseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Suivi Promesses")
        .description("Affiche vos promesses actives.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
