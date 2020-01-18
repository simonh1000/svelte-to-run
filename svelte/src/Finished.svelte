<script>
    import { onMount } from "svelte";
    import { releaseWakeLock } from "../../elm/src/lib.js";
    export let state;
    onMount(() => {
        releaseWakeLock();
    });
</script>

<h2>Finished</h2>
{JSON.stringify(state)}
