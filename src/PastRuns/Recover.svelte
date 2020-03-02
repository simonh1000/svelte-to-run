<script>
    import RunSummary from "./PastRun.svelte";

    export let state;
</script>

<h1>recover</h1>
<RunSummary run={state} />
{JSON.stringify(state)}
