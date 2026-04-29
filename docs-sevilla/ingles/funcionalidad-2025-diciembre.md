# Audio Rating Functionality

This functionality allows users to rate the pronunciation difficulty of a phrase immediately after recording and submitting an audio. The goal is to collect feedback on the complexity of the exercises.

## Interaction Flow

1.  **Recording and Submission**:
    *   The user records an audio and clicks the "Send" button.
    *   The system displays a loading indicator ("wait...") while the file is uploaded to the server.

2.  **Modal Appearance**:
    *   Once the server confirms the audio was successfully saved, a modal (pop-up window) appears.
    *   This modal uses the `SweetAlert` library.

3.  **Rating Interface**:
    *   The modal displays the question: **"How easy was it to pronounce this phrase?"**.
    *   It shows an interactive 5-star scale.
    *   It has explanatory labels at the ends: "Very hard" (1 star) and "Very easy" (5 stars).

4.  **Interaction with Stars**:
    *   **Hover**: When hovering over the stars, they light up to indicate the potential selection.
    *   **Click**: Clicking a star locks the rating.

5.  **Saving the Rating**:
    *   Selecting a star automatically sends a request to the server (`POST /audios/save-rating`) with the audio ID and the score (from 1 to 5).
    *   If the save is successful, a green message appears: **"Rating saved!"**.

6.  **Completion**:
    *   The modal includes a **"Record another audio"** button.
    *   Clicking it reloads the page to allow the user to perform a new exercise.

## Technical Details

### Relevant Files

*   **Frontend (Logic)**: `pialara/static/js/speech-recording.js`
    *   Handles the modal display after the audio upload AJAX response.
    *   Manages mouse events (mouseenter, mouseleave, click) over the stars.
    *   Performs the AJAX request to save the rating.
*   **Frontend (Template)**: `pialara/templates/audios/client_record.html`
    *   Contains the modal HTML structure within a hidden `div` with id `rating-template`.
    *   Defines the classes and icons (Bootstrap Icons) for the stars.

### Modal Implementation

The modal is built by cloning a hidden DOM element (`#rating-template`) and injecting it into a SweetAlert alert. This allows reusing the HTML structure and keeping the event logic separate.
