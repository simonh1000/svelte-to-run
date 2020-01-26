<script>
    import TopAppBar, { Row, Section, Title } from "@smui/top-app-bar";
    import Run from "svelte-material-icons/Run.svelte";
</script>

<TopAppBar variant="static" color="primary">
    <Row>
        <Section>
            <Title class="flex-row flex-center">
                <span class="icon-container">
                    <Run />
                </span>
                Start to Run
            </Title>
        </Section>
    </Row>
</TopAppBar>
