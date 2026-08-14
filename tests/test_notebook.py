import json

from jira_analytics.pipeline import project_root


def test_notebook_is_executed_and_reader_facing():
    path = project_root() / "notebooks" / "customer_lifecycle_analysis.ipynb"
    notebook = json.loads(path.read_text(encoding="utf-8"))
    markdown = [c for c in notebook["cells"] if c["cell_type"] == "markdown"]
    code = [c for c in notebook["cells"] if c["cell_type"] == "code"]
    headings = "\n".join("".join(c["source"]) for c in markdown)
    assert len(markdown) >= 8
    assert all(title in headings for title in ["## TL;DR", "## Context and methods", "## Data", "## Results", "## Takeaways"])
    assert all(c["execution_count"] is not None for c in code)
    assert not [o for c in code for o in c.get("outputs", []) if o.get("output_type") == "error"]

