# CLAUDE.md

This file provides guidance to Claude Code when working in this project.

---

## Project: memo_app_v2 (Flutter)

### Central Documentation Files (MANDATORY)

Three files MUST always be respected and kept in sync:

1. **docs/project_tree.md** - Complete file/folder structure
2. **docs/functions.md** - All function signatures
3. **docs/variables_file.md** - All important variables (state, model fields, provider fields, etc.)

---

## GLOBAL RULES (ALWAYS)

### Before Writing ANY Code

Before proposing or writing ANY new code (file, class, function, variable):

1. **READ and ANALYZE:**
   - docs/project_tree.md
   - docs/functions.md
   - docs/variables_file.md

2. **CHECK if the requested element:**
   - Already exists under the same name
   - Already exists under a different but equivalent name

3. **If it ALREADY exists:**
   - REUSE or MODIFY the existing element instead of creating a duplicate
   - Mention clearly which existing file/function/variable you are using

4. **If it does NOT exist:**
   - You are allowed to create it
   - You MUST then update the corresponding documentation file(s) to keep them consistent

---

### Mandatory Documentation Updates

**EVERY TIME you make changes:**

- Create a new file → update `docs/project_tree.md`
- Rename / move a file → update `docs/project_tree.md`
- Create a new function → add its full signature in `docs/functions.md`
- Modify / rename a function → update its entry in `docs/functions.md`
- Create a new important variable / field → add it in `docs/variables_file.md`
- Rename / delete a variable / field → update `docs/variables_file.md`

---

### Prohibited Actions

- ❌ NEVER invent files or functions without checking these docs first
- ❌ NEVER leave these docs out-of-date
- ❌ NEVER create duplicates of existing elements

---

## Response Format (MANDATORY)

When answering user requests, structure your response as follows:

1. **Documentation Analysis** - Explain what you found in the 3 docs (reused elements, conflicts, duplicates)
2. **Proposed Changes** - Describe what you will ADD or MODIFY
3. **Documentation Updates** - Show the updated parts of:
   - docs/project_tree.md (if file structure changed)
   - docs/functions.md (if functions changed)
   - docs/variables_file.md (if variables changed)

**⚠️ CRITICAL:** If you propose code but do NOT update the docs accordingly, consider your answer INCOMPLETE.

---

## Auto-Accept Mode

This project is configured for autonomous operation:
- Proceed directly with all standard operations (create, edit, delete files)
- No confirmation needed for routine development tasks
- Only ask for clarification on major architectural decisions
