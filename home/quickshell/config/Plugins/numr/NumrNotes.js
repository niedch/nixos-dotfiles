const normalizeNote = (n) => {
  if (!n || typeof n !== "object" || Array.isArray(n)) return null;
  const id = String(n.id ?? "");
  if (!id) return null;
  return {
    id,
    text: String(n.text ?? ""),
    updatedAt: String(n.updatedAt ?? "")
  };
};

const tutorialNoteText = `# Welcome to Numr
# This is a live-evaluating scratchpad. Try editing!

# --- Basic Arithmetic & Percentages ---
20% of 150
100 + 15%

# --- Variables ---
tax = 15%
100 + tax

# --- Unit Conversions ---
5 km in miles
22 C in F

# --- Currency Conversion ---
$100 in eur
1 BTC in USD

# --- Continuation (Use '_' or start with operator) ---
_ * 2
+ 10

# Comments can be documented using '#' at the beginning of a line.
`;

const newNote = (text = "") => ({
  id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
  text: String(text),
  updatedAt: new Date().toISOString()
});

const tutorialNote = () => newNote(tutorialNoteText);

const noteTitle = (note) => {
  if (!note) return "";

  const lines = String(note.text ?? "").split(/\r?\n/);
  for (const rawLine of lines) {
    let line = rawLine.trim();
    if (line === "") continue;
    if (line.startsWith("#")) {
      line = line.slice(1).trim();
    }
    return line;
  }
  return "";
};

const lineCount = (note) => {
  if (!note) return 0;

  const text = String(note.text ?? "");
  if (text === "") return 0;

  return text.split(/\r?\n/).length;
};

const findIndex = (notes, id) => {
  const values = Array.isArray(notes) ? notes : [];
  const target = String(id ?? "");
  if (!target) return -1;
  return values.findIndex(note => note && String(note.id ?? "") === target);
};

const addNote = (notes, note) => {
  const normalized = normalizeNote(note);
  const values = Array.isArray(notes) ? notes : [];
  if (!normalized) return [...values];
  return [...values, normalized];
};

const removeNoteAt = (notes, index) => {
  const values = Array.isArray(notes) ? notes : [];
  const target = Number(index);
  if (Number.isNaN(target) || target < 0 || target >= values.length) {
    return [...values];
  }
  return values.filter((_, i) => i !== target);
};

const parseNotes = (raw) => {
  try {
    const parsed = JSON.parse(String(raw ?? "{}"));
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      return { schemaVersion: 1, activeNoteId: "", notes: [] };
    }

    const values = Array.isArray(parsed.notes) ? parsed.notes : [];
    const notes = values.map(normalizeNote).filter(note => note !== null);

    let activeNoteId = String(parsed.activeNoteId ?? "");
    if (findIndex(notes, activeNoteId) < 0) activeNoteId = "";
    return { schemaVersion: 1, activeNoteId, notes };
  } catch (err) {
    return { schemaVersion: 1, activeNoteId: "", notes: [] };
  }
};

const displayRows = (notes) => {
  const values = Array.isArray(notes) ? notes : [];
  return values
    .map(normalizeNote)
    .filter(note => note !== null)
    .map(note => {
      let title = noteTitle(note);
      if (title.length > 40) {
        title = `${title.slice(0, 40)}…`;
      }
      return {
        id: note.id,
        title,
        lineCount: lineCount(note)
      };
    });
};

if (typeof module !== "undefined") {
  module.exports = {
    parseNotes,
    normalizeNote,
    newNote,
    tutorialNote,
    noteTitle,
    lineCount,
    findIndex,
    addNote,
    removeNoteAt,
    displayRows
  };
}
