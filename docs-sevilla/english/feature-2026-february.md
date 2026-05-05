# Documentation: Daily Routine Functionality

## General Description
The **Daily Routine** functionality was designed to improve user retention on the platform and structure their voice recording sessions. Instead of requiring the patient to manually search for tags or the term "Syllabus" in a search engine, the routine provides a continuous "Guided Training Mode".

When the user starts a routine, they are presented with an uninterrupted train of 5 phrases proposed by the backend. After recording each one, the system evaluates in session what the next one is and automatically redirects them until finished.

## User Flow
1. The user (client) logs into the Lara system.
2. On the main screen (`/cliente-tag`), a highlighted card informs them they have a daily routine ready.
3. Upon clicking the "Start Training" button, the backend generates a queue of 5 files (Syllabus `ObjectId`) in session memory.
4. The system automatically redirects to the recording screen (`/client-record`) for the first tag.
5. During recording, a progress bar shows the current stage (e.g., `Phrase 1 of 5`).
6. Instead of the "Send" button, an intelligent adaptive "Save & Next" or "Finish Routine" button appears as appropriate.
7. Upon saving the last phrase successfully, SweetAlert notifies and cleanly redirects back to the tags homepage.

## Modified Files

### 1. `pialara/blueprints/audios.py` (Controller)
* **New Endpoint (`@bp.route('/client-routine')`)**: Logic that builds the routine. Applies an `aggregate` with `$sample: { size: 5 }` on the syllabus collection, extracts the identifiers, and registers the state in `session['routine_items']` and an index `session['routine_index']`.
* **Recording Route (`@bp.route('/client-record/')`)**: Added conditional logic `if 'routine_items' in session`. If the session exists, it no longer randomly selects phrases skipping tags, but advances by injecting `routine_data = {"current": index+1, "total": 5}` into the HTML template.
* **Audio Saving (`@bp.route('/save-record')`)**: After successfully recording an item (`audio.insert_one()`), the controller advances `session['routine_index'] += 1`. If phrases remain, it outputs the `next_routine_url` variable via JSON. If the array is finished, it outputs the boolean `"is_routine_completed": True` and destroys the variable in session with `session.pop()`.

### 2. `pialara/templates/audios/client_tag.html` (Client Home View)
* Added a UI element `<div class="card text-center border-primary shadow-sm w-100">` at the beginning of the `<section>` with an inviting Call-To-Action (CTA) to use the automated generator.

### 3. `pialara/templates/audios/client_record.html` (Recording View)
* **Progress Bar**: Integration of Jinja variables `{% if routine_data %}`. Dynamic progress is calculated generating a `<div class="progress-bar">` that fills from 20% to 100%.
* **Submit button label**: Simple block `{% if routine_data.current < routine_data.total %}` to visually switch from "Send" to the naturally expected "Save & Next" behavior.

### 4. `pialara/static/js/speech-recording.js` (Frontend AJAX Script)
* Rewritten and injected the `swal()` Modal control logic. In the AJAX `.done(...)` event:
  * In a normal flow, clicking "Record another audio" causes the browser to trigger a basic `window.location.reload()`.
  * In routine mode flow, the script rescues the dynamically returned URL (`window.location.href = data.next_routine_url`). This dynamic routing is imperceptible to the user so that stepping between phrases feels fast rather than like manually loading new pages.

## Future Work
The current codebase uses `%sample: {size: 5}` generalizing routines as a functional and stable proof of concept. The architecture is open so that, by editing a simple MongoDB pipeline in the `/client-routine` endpoint (line `~230` of `audios.py`), an advanced student can implement logic based on the "Clicks" collection or the "Low ratings" matrix of the Lara app.
