# Start to Run

A PWA Start-to-Run app written in Svelte - try it at https://svelte-to-run.netlify.com/

Uses the following browser apis:

    - Geolocation
    - SpeechSynthesis
    - WakeLock

## Get started

Install the dependencies...

```bash
npm install
```

...then start webpack:

```bash
npm run dev
```

Navigate to [localhost:5000](http://localhost:5000). You should see your app running. Edit a component file in `src`, save it, and the page should reload with your changes.

## Production Builds

```bash
npm run build
```

## Privacy

The app records location, but all the data is saved to your brower's local storage and nowhere else!
To export your data go to https://svelte-to-run.netlify.com/debug, switch to Past Runs and click on the link in the footer.

## Changelog

-   1.3.1 - Convert day runs to js data structure
-   1.3.0 - Block back button while running (to prevent loss of data)
-   1.2.0 - add abilty to abandon a run but record data
-   1.1.2 - Fix typos in running data
-   1.1.1 - use enableHighAccuracy for geolocation
-   1.1.0 - add warning about not turning off phone
-   1.0.0 - initial release
