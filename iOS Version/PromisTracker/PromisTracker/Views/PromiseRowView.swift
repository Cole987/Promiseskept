import SwiftUI

struct PromiseRowView: View {
    let promise: Promise
    @ObservedObject var viewModel: PromiseViewModel

    @State private var showStatusIcon = false

    var progressColor: Color {
        if promise.failed {
            return .red
        } else if promise.completed {
            return .green
        } else {
            return .orange
        }
    }

    var statusIconName: String {
        if promise.failed {
            return "xmark.octagon.fill"
        } else if promise.completed {
            return "checkmark.circle.fill"
        } else {
            return "clock.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIconName)
                .foregroundColor(progressColor)
                .font(.title2)
                .scaleEffect(showStatusIcon ? 1.2 : 1)
                .animation(.easeInOut(duration: 0.3), value: showStatusIcon)
                .onAppear { showStatusIcon = true }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(promise.title)
                        .font(.headline)
                        .lineLimit(1)
                    if promise.pinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Text(priorityText)
                        .font(.caption)
                        .foregroundColor(priorityColor)
                        .padding(6)
                        .background(priorityColor.opacity(0.2))
                        .cornerRadius(8)
                }

                AnimatedProgressBar(progress: promise.progress, color: progressColor)
                    .frame(height: 10)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Text(progressPercentage)
                        .font(.caption2)
                    Spacer()
                    Text(timeRemaining)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button {
                togglePinned()
            } label: {
                Label(
                    NSLocalizedString(promise.pinned ? "unpin" : "pin", comment: "Toggle pin status"),
                    systemImage: promise.pinned ? "pin.slash" : "pin"
                )
            }
            Button {
                toggleComplete()
            } label: {
                Label(
                    NSLocalizedString(promise.completed ? "mark_incomplete" : "mark_complete", comment: "Toggle completion status"),
                    systemImage: promise.completed ? "xmark.circle" : "checkmark.circle"
                )
            }
            Button {
                toggleFailed()
            } label: {
                Label(
                    NSLocalizedString(promise.failed ? "mark_active" : "mark_failed", comment: "Toggle failed status"),
                    systemImage: promise.failed ? "clock" : "xmark.octagon"
                )
            }
            Button(role: .destructive) {
                if let index = viewModel.promises.firstIndex(where: { $0.id == promise.id }) {
                    viewModel.promises.remove(at: index)
                }
            } label: {
                Label(NSLocalizedString("delete", comment: "Delete action"), systemImage: "trash")
            }
        }
    }

    func toggleComplete() {
        var updated = promise
        updated.completed.toggle()
        if updated.completed {
            updated.failed = false
            updated.progress = 1.0
        } else {
            updated.progress = 0
        }
        viewModel.updatePromise(updated)
    }

    func toggleFailed() {
        var updated = promise
        updated.failed.toggle()
        if updated.failed {
            updated.completed = false
            updated.progress = 0
        }
        viewModel.updatePromise(updated)
    }
    
    func togglePinned() {
        var updated = promise
        updated.pinned.toggle()
        viewModel.updatePromise(updated)
    }

    var progressPercentage: String {
        "\(Int(promise.progress * 100))%"
    }

    var timeRemaining: String {
        let remaining = promise.endDate.timeIntervalSinceNow
        if remaining <= 0 {
            return NSLocalizedString("completed", comment: "Already ended")
        }
        let days = Int(remaining / 86400)
        let hours = Int((remaining.truncatingRemainder(dividingBy: 86400)) / 3600)
        return String(format: NSLocalizedString("time_remaining_format", comment: "Remaining time"), days, hours)
    }

    var priorityText: String {
        switch promise.priority {
        case 2: return NSLocalizedString("priority_high", comment: "High")
        case 1: return NSLocalizedString("priority_medium", comment: "Medium")
        default: return NSLocalizedString("priority_low", comment: "Low")
        }
    }

    var priorityColor: Color {
        switch promise.priority {
        case 2: return .red
        case 1: return .orange
        default: return .green
        }
    }
}
