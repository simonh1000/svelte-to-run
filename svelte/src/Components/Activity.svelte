<script>
    export let list;
    export let section;

    let mkClass = function(selected, type, idx) {
        let col = type == "run" ? "running" : "walking";
        return idx == selected ? col + " selected" : col;
    };
</script>

<style>
    .activity {
        display: flex;
        flex-direction: column;
    }
    .schema-items {
        display: flex;
        flex-direction: column;
        /* height: 60px; */
    }
    .schema-items div {
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .selected {
        font-weight: bold;
    }
    .running {
        color: blue;
    }
    .walking {
        color: deepskyblue;
    }
</style>

<div class="schema-items">
    {#each list as item, idx}
        <div class={mkClass(section, item.type, idx)}>
            {item.type} for {item.time} minute(s)
        </div>
    {/each}
</div>
