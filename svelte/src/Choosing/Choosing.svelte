<script>
    import DayRun from "./DayRun.svelte";
    export let dayRuns;
</script>

<style>
    .runs {
        display: flex;
        flex-direction: column;
    }
    h2 {
        font-size: 16px;
    }
</style>

<h2>Choose your run</h2>

<div class="runs">
    {#each dayRuns as dayRun}
        <DayRun {dayRun} on:selectRun />
    {/each}
</div>
