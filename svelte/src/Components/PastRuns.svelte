<script>
    import RunSummary from "./PastRun";
    export let state;

    const dayRuns = state.dayRuns.reduce((acc, dayRun) => {
        acc[dayRun.title] = dayRun.list;
        return acc;
    }, {});
</script>

<h2>Past Runs</h2>

{#each state.history as run}
    <RunSummary {run} dayRun={dayRuns[run.title]} />
{/each}
