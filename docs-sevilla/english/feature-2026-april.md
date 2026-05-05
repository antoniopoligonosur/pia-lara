# Functionality: Internationalization and English Translation (April 2026)

## General Description
The April functionality introduces multi-language support to the Lara platform, allowing users to toggle between Spanish (default language) and English. This feature improves the system's accessibility for international users.

## Interaction Flow
1. **Language Selection**: In the main navigation menu (layout), the user has a dedicated button to switch the language ('EN' and 'ES' icons).
2. **Session Change**: Clicking the button makes a request to the corresponding route (e.g., `/set_language/en`). Flask updates the `session['lang']` variable and reloads the current page.
3. **Dynamic Rendering**: All static HTML texts are automatically replaced with their corresponding English version before being sent to the user's browser.

## Technical Details and Architecture

### 1. Base System: Flask-Babel
The main engine used for internationalization is `Flask-Babel`. This library provides the necessary functions to mark, extract, and compile the text strings to be translated.

### 2. Frontend Modifications (Jinja2)
In all templates (such as `client_record.html`, `calendario_rachas.html`, or `users/update.html`), static literal strings have been wrapped in the `_()` translation function.
*Example:* `<h1>{{ _('Streak Calendar') }}</h1>`

For texts defined in static `.js` files (like the *SweetAlert* alert modals in `speech-recording.js`), global variables are injected in the template header (`window.translations`) so that JavaScript can read the string previously translated by Jinja.

### 3. Backend Modifications
* Routes and Controllers: Some return messages in AJAX requests (`jsonify` in `audios.py`) have been natively wrapped using `from flask_babel import _`.
* Dynamic selectors and HTML option menus are also iteratively translated by passing the variables through Babel's translation function.

### 4. Translation Dictionaries
The core files containing the text mapping are hosted in the `pialara/translations/en/LC_MESSAGES/` path:
* `messages.po`: Readable text file specifying the original Spanish identifiers and their English `msgstr` values.
* `messages.mo`: The compiled binary used by the server for fast assignment at runtime.
