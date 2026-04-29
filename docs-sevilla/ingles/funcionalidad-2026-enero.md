# Technical Documentation: Microphone Check and Warning Modal

## 1. General Description
This functionality implements a client-side pre-validation for audio recording. Its purpose is to ensure the user has a microphone connected and has granted the necessary permissions before attempting to record, improving the user experience and avoiding "empty recording" errors.

## 2. Execution Flow
1. The user clicks the recording button (`.record-button`).
2. The system intercepts the event and initiates an asynchronous validation.
3. **Validation 1 (Hardware):** It queries `navigator.mediaDevices.enumerateDevices()` to verify if any `audioinput` type device exists.
4. **Validation 2 (Software/Permissions):** It verifies if the `currentStream` variable (which stores the initialized audio stream upon page load) is defined.
5. **Result:**
   - **Success:** If both validations pass, the original recording logic proceeds (`mediaRecorder.start()`).
   - **Failure:** If the device or permissions are missing, execution stops and the warning modal is displayed (`#mic-warning-modal`).

## 3. Technical Implementation

### 3.1. JavaScript (`speech-recording.js`)
The recording button's <code>EventListener</code> was modified to be `async` and include the blocking logic.

```javascript
recordButton.addEventListener('click', async () => {
    // 1. Hardware Check
    let hasMicDevice = false;
    try {
        const devices = await navigator.mediaDevices.enumerateDevices();
        hasMicDevice = devices.some(d => d.kind === 'audioinput');
    } catch (e) {
        console.error("Error enumerating devices", e);
    }

    // 2. Block if no hardware or active stream
    if (!currentStream && !hasMicDevice) {
         showMicWarningModal();
         return; // Stops recording
    }
    
    if (!currentStream) {
        showMicWarningModal();
        return; // Stops recording
    }

    // ... Continues original logic ...
});
```

### 3.2. HTML (`client_text.html`)
A modal container was inserted at the end of the file (before the scripts) that remains hidden by default.

- **Main ID:** `mic-warning-modal`
- **Structure:** Dark overlay with a floating center card.
- **Iconography:** Embedded SVG representing a microphone with an alert sign.

### 3.3. CSS (`style_cliente.css`)
"Additive" styles added to the end of the file to avoid breaking the existing design.

- **Key Classes:**
    - `.mic-modal-overlay`: Manages the dark background and centering (Flexbox).
    - `.mic-modal-content`: The white card with a yellow border (`#ffbc42`).
    - `.mic-modal-btn`: Action button to close the modal.

## 4. Modified Files
| File | Relative Path | Change Description |
|---------|---------------|------------------------|
| **Logic** | `pialara/static/js/speech-recording.js` | Injection of asynchronous validation in the click event. |
| **Styles** | `pialara/static/styles/style_cliente.css` | New CSS rules for the modal at the end of the file. |
| **Template** | `pialara/templates/audios/client_text.html` | Insertion of the modal HTML before the script block. |

## 5. Maintenance
- **Preservation:** The code was designed to be minimally intrusive. If you wish to disable the validation, simply comment out the validation lines in the JS; the HTML and CSS can remain without affecting the display (since they are hidden by default).
- **Compatibility:** Uses standard browser APIs (`navigator.mediaDevices`).

---

# Functionality: Audio Recording Tips Modal

This component displays a modal with recommendations for recording audio, using **Bootstrap 5**.

## Structure

- **Modal** (`#modalConsejosAudio`)
  - **Header**
    - Title: "Tips for recording your audio" with SVG icon.
    - Close button (`btn-close`).
  - **Body**
    - Introductory text.
    - Tips list:
      1. Stay in a **quiet** place.
      2. Speak with **calm** and naturally.
      3. Comfortable and clear volume.
      4. Review and **record again** if necessary.
      5. Take the time you need.
  - **Footer**
    - Thank you message.
    - "Got it" button to close the modal.

- **Trigger Button**
  - Circular button with `i` icon.
  - Location: top right corner (`position-fixed top-0 end-0`).
  - Attributes: `data-bs-toggle="modal"` and `data-bs-target="#modalConsejosAudio"`.

## Notes

- Centered, large-sized modal (`modal-dialog-centered modal-lg`).
- Compatible with mobile and desktop devices.
- Custom styles for icon and spacing (`px-4 px-md-5`, `gap-2`).
