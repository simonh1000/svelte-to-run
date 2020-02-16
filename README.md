# Start to Run

A PWA running app writeen in Svelte - try it at https://svelte-to-run.netlify.com/

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

## Changelog

1.1 - add warning about not turning off phone
1.1.1 - use enableHighAccuracy for geolocation
1.1.2 - Fix typos in running data
