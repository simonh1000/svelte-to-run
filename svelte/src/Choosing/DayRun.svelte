<script>
    import { createEventDispatcher } from "svelte";

    export let dayRun;
    let width;

    const dispatch = createEventDispatcher();
    function selectRun() {
        dispatch("selectRun", { dayRun });
    }
</script>

<style>
    .activity {
        display: flex;
        flex-direction: column;
    }
    .schema-items {
        display: flex;
    }
    .red {
        background-color: red;
    }
    .white {
        background-color: white;
    }
</style>

<div class="activity" bind:clientWidth={width}>
    <h3>{dayRun.title}</h3>

    <div class="schema-items" on:click={selectRun}>
        {#each dayRun.list as item}
            <div
                class={item.type == 'run' ? 'red' : 'white'}
                style="width: {item.time * 15}px">
                {item.time}
            </div>
        {/each}
    </div>
</div>
