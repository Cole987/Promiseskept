let PROMISES = [
  {
    id: 1,
    title: "Apprendre JavaScript",
    notes: "Faire des tutos et pratiquer chaque jour",
    priority: "high",
    status: "active",
    progress: 0.5,
    pinned: true,
  },
  {
    id: 2,
    title: "Terminer le projet ESCE",
    notes: "",
    priority: "medium",
    status: "completed",
    progress: 1,
    pinned: false,
  },
  {
    id: 3,
    title: "Faire du sport",
    notes: "3 séances par semaine",
    priority: "low",
    status: "failed",
    progress: 0.2,
    pinned: false,
  },
  {
    id: 4,
    title: "Lire un livre sur la guerre froide",
    notes: "Commencer ce week-end",
    priority: "medium",
    status: "active",
    progress: 0.1,
    pinned: false,
  },
];

const statusIcons = {
  active: "⏳",
  completed: "✅",
  failed: "❌",
};

function priorityClass(priority) {
  if (priority === "low") return "low";
  if (priority === "medium") return "medium";
  return "high";
}

let editingId = null;

function renderPromises(filter = "") {
  const list = document.getElementById("promiseList");
  list.innerHTML = "";

  const filteredPromises = PROMISES
    .filter(
      (p) =>
        p.title.toLowerCase().includes(filter.toLowerCase()) ||
        p.notes.toLowerCase().includes(filter.toLowerCase())
    )
    .sort((a, b) => {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return 0;
    });

  filteredPromises.forEach((p) => {
    const li = document.createElement("li");
    li.className = "promise-item";

    if (editingId === p.id) {
      li.innerHTML = `
        <form id="editForm-${p.id}">
          <div class="promise-header">
            <input type="text" name="title" value="${escapeHtml(p.title)}" required style="flex-grow:1; font-weight:600; font-size:1.125rem; padding:4px;" />
            <select name="priority" style="margin-left:12px;">
              <option value="low" ${p.priority === "low" ? "selected" : ""}>Basse</option>
              <option value="medium" ${p.priority === "medium" ? "selected" : ""}>Moyenne</option>
              <option value="high" ${p.priority === "high" ? "selected" : ""}>Haute</option>
            </select>
          </div>
          <textarea name="notes" rows="3" placeholder="Notes..." style="width:100%; margin-top:8px;">${escapeHtml(p.notes)}</textarea>
          <div style="margin-top:8px; text-align:right;">
            <button type="submit">Enregistrer</button>
            <button type="button" id="cancelBtn-${p.id}">Annuler</button>
          </div>
        </form>
      `;

      li.querySelector(`#editForm-${p.id}`).addEventListener("submit", (e) => {
        e.preventDefault();
        const form = e.target;
        const updatedTitle = form.title.value.trim();
        const updatedPriority = form.priority.value;
        const updatedNotes = form.notes.value.trim();

        if (!updatedTitle) {
          alert("Le titre est obligatoire.");
          return;
        }

        const idx = PROMISES.findIndex((pr) => pr.id === p.id);
        if (idx !== -1) {
          PROMISES[idx].title = updatedTitle;
          PROMISES[idx].priority = updatedPriority;
          PROMISES[idx].notes = updatedNotes;
        }
        editingId = null;
        renderPromises(document.getElementById("searchInput").value);
      });

      li.querySelector(`#cancelBtn-${p.id}`).addEventListener("click", () => {
        editingId = null;
        renderPromises(document.getElementById("searchInput").value);
      });
    } else {
      li.innerHTML = `
        <div class="promise-header">
          <div class="promise-title">
            <span class="status-icon">${statusIcons[p.status]}</span>
            ${escapeHtml(p.title)}
            ${p.pinned ? '<span class="pinned" title="Épinglé">📌</span>' : ""}
          </div>
          <div class="priority ${priorityClass(p.priority)}">${p.priority}</div>
        </div>
        ${p.notes ? `<p class="promise-notes">${escapeHtml(p.notes)}</p>` : ""}
        <div class="progress-bar">
          <div class="progress-fill" style="width: ${p.progress * 100}%"></div>
        </div>
        <div style="margin-top:10px; text-align:right;">
          <button class="editBtn">Éditer</button>
          <button class="deleteBtn" style="margin-left:8px; color:#bf360c;">Supprimer</button>
        </div>
      `;

      li.querySelector(".editBtn").addEventListener("click", () => {
        editingId = p.id;
        renderPromises(document.getElementById("searchInput").value);
      });

      li.querySelector(".deleteBtn").addEventListener("click", () => {
        if (confirm(`Supprimer la promesse "${p.title}" ?`)) {
          PROMISES = PROMISES.filter((pr) => pr.id !== p.id);
          renderPromises(document.getElementById("searchInput").value);
        }
      });
    }

    list.appendChild(li);
  });
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

document
  .getElementById("searchInput")
  .addEventListener("input", (e) => {
    renderPromises(e.target.value);
  });

renderPromises();
