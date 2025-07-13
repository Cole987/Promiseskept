//
//  PromiseViewModel.swift
//  PromisTracker
//
//  Created by Yanis Racouët on 7/12/25.
//

import Foundation

class PromiseViewModel: ObservableObject {
    @Published var promises: [Promise] = [] {
        didSet { save() }
    }

    init() { load() }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "promises"),
           let decoded = try? JSONDecoder().decode([Promise].self, from: data) {
            promises = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(promises) {
            UserDefaults.standard.set(encoded, forKey: "promises")
        }
    }

    func addPromise(_ promise: Promise) {
        promises.append(promise)
    }

    func updatePromise(_ promise: Promise) {
        if let index = promises.firstIndex(where: { $0.id == promise.id }) {
            promises[index] = promise
        }
    }

    func deletePromise(at offsets: IndexSet) {
        promises.remove(atOffsets: offsets)
    }

    var completed: [Promise] { promises.filter { $0.completed && !$0.failed } }
    var failed: [Promise] { promises.filter { $0.failed } }
    var active: [Promise] { promises.filter { !$0.completed && !$0.failed } }
}
