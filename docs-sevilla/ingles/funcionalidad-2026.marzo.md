# Technical Documentation: Streak System and Activity Module (March 2026)

## Functional Overview
The activity module's main goal is tracking and visualizing user consistency. It is based on a streak of consecutive recording days and a calendar interface summarizing monthly activity per user.

## Streak System Architecture
The streak system works via date validation each time the server receives a new recording.

### Control Logic (Server)
Located in the audios controller, the logic compares the current date with the last recorded date for the user:
* **Increment**: If the difference between today and the last recorded day is exactly one day, the system increments the streak value stored in the user's profile.
* **Maintenance**: If the user records today and has already recorded previously today, the streak remains unchanged.
* **Reset**: If the difference is greater than one day, the streak resets to 1, indicating the consistency cycle was broken.

Data is persisted in the database's user collection, keeping the `racha_actual` and `ultima_grabacion` fields updated.

## Activity Calendar Implementation
The calendar view (`/calendario-rachas`) is a dynamic component organizing user activity on a monthly basis.

### Data Processing
To generate the view, the server performs the following tasks:
1. **Month Generation**: Uses calendar libraries to create a grid of weeks and days corresponding to the requested month and year.
2. **Activity Counting**: Queries the recordings database filtering by user and the month's date range. A map is generated associating each day of the month with the total number of recorded audios.
3. **Temporal Identification**: The current day is marked so the interface can highlight it relative to the rest of the month.

### Interface Visualization (Frontend)
The template uses conditional logic to determine each calendar cell's styling:
* **"Today" State**: A highlighted cell with the system's main color (blue) for quick location.
* **"Activity" State**: Cells with an orange background and a numerical indicator showing the amount of audios recorded that day.

## Daily Routine Integration
The module also centralizes access to the daily exercise routine. This is presented as an informative card below the calendar, allowing the user to view their progress and jump straight to the 5 recommended exercises for the day, thereby unifying activity review with task execution.

## Accessibility and Responsive Design
The module implements a dynamic high-contrast styling system. Using classes applied to the page body, the calendar and routine card adjust their colors, borders, and icon visibility for the three accessibility modes (`contrast-1`, `contrast-2`, `contrast-3`), ensuring all key components are readable in high-visibility monitor configurations.

## Files and their Function in the Module
* **`pialara/blueprints/audios.py`**: The module's brain. Calculates streaks upon saving audios and prepares the calendar data structure (days, months, counts) to send to the view.
* **`pialara/templates/audios/calendario_rachas.html`**: Defines the visual structure. Contains logic to paint cells according to their state and specific CSS styles for accessibility modes and responsive design.
* **`pialara/templates/layout.html`**: Manages calendar access visibility in the main navigation menu for users with the appropriate role.
* **`pialara/models/User.py`**: Defines the user object structure where streak values and recording dates are persistently stored.
