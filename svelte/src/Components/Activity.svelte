<script>
    export let list;
    export let section;

    let mkClass = function(selected, type, idx) {
        let col = type == "run" ? "running" : "walking";
        return idx == selected ? col + " selected" : col;
    };
</script>

<style>
    .schema-container {
        display: flex;
        justify-content: center;
    }
    .schema-items {
        padding-top: 30px;
        padding-bottom: 30px;
        display: flex;
        flex-direction: column;
        /* height: 60px; */
    }
    .item {
        margin: 5px 0;
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

<div class="schema-container">
    <div class="schema-items">
        {#each list as item, idx}
            <div class={'item ' + mkClass(section, item.type, idx)}>
                {item.type} for {item.time} minute(s)
            </div>
        {/each}
    </div>
</div>
