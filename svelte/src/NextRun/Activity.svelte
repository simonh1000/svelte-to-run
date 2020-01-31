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
        padding-top: 20px;
        padding-bottom: 20px;
    }
    .schema-items {
        display: flex;
        flex-direction: column;
        width: 150px;
    }
    .item {
        margin-bottom: 5px;
    }
    .selected {
        font-weight: bold;
    }
    .running {
        color: var(--mdc-theme-primary, #475da3);
    }
    .walking {
        color: rgb(177, 178, 243);
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
