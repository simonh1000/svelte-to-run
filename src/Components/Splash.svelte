<script>
    import Button from "@smui/button";

    export let onAccept;
</script>

<style>
    a {
        text-decoration: underline;
    }
</style>

<h1 class="text-center text-4xl mt-4">Welcome</h1>

<ul class="list-disc list-outside ml-4 mt-4 mb-4">
    <li class="mb-2">
        This app is written by a programmer, not a fitness specialist. Seek
        advice about starting to run, on stretching, and on taking breaks
        between runs.
    </li>
    <li class="mb-2">
        It helps track progress whether you run outside on in a gym.
    </li>
    <li class="mb-2">
        It uses cutting-edge browser features, and
        <span class="font-bold">works best with Chrome on Android</span>
        . If you experience a technical issue or have a feature request, please
        use
        <a href="https://github.com/simonh1000/svelte-to-run">Github</a>
        .
    </li>
    <li class="mb-2">
        The app collects no personal data. Your running data is stored on your
        phone. It does use Google Analytics - see their
        <a href="https://policies.google.com/technologies/partner-sites">
            privacy policy
        </a>
        .
    </li>
</ul>

<div class="flex flex-row justify-center">
    <Button
        variant="raised"
        on:click={onAccept}
        style="padding: 20px; min-width: 36px; height: auto">
        <span>I understand</span>
    </Button>

</div>
