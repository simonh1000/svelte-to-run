<script>
    export let list;
    export let section;

    let mkClass = function(selected, type, idx) {
        return idx == selected ? type + " selected" : type;
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
    .run {
        color: var(--mdc-theme-primary, #475da3);
    }
    .walk {
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
