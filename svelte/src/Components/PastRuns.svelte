<script>
    import { onMount } from "svelte";

    export let state;
</script>

<h2>Past Runs</h2>
{JSON.stringify(state)}
