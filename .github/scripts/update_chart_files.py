#!/usr/bin/env python3
"""
Update chart files with new version information.
Preserves all comments and formatting in YAML files.
"""

import os
import re
import sys
from datetime import datetime


def determine_version_bump_type(old_version, new_version):
    """Determine if this is a patch, minor, or major version bump.

    Returns 'major', 'minor', or 'patch' based on comparing version numbers.
    """
    try:
        old_parts = old_version.split(".")
        new_parts = new_version.split(".")

        # Ensure we have at least 3 parts
        while len(old_parts) < 3:
            old_parts.append("0")
        while len(new_parts) < 3:
            new_parts.append("0")

        old_major, old_minor, old_patch = (
            int(old_parts[0]),
            int(old_parts[1]),
            int(old_parts[2]),
        )
        new_major, new_minor, new_patch = (
            int(new_parts[0]),
            int(new_parts[1]),
            int(new_parts[2]),
        )

        # Compare version parts
        if new_major != old_major:
            return "major"
        elif new_minor != old_minor:
            return "minor"
        else:
            return "patch"
    except (ValueError, IndexError):
        # If version parsing fails, default to patch
        return "patch"


def bump_chart_version(chart_version, bump_type):
    """Bump the chart version by the specified type.

    Args:
        chart_version: Current chart version (e.g., '1.3.1')
        bump_type: 'major', 'minor', or 'patch'

    Returns:
        New chart version
    """
    parts = chart_version.split(".")
    major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])

    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
    elif bump_type == "minor":
        minor += 1
        patch = 0
    else:  # patch
        patch += 1

    return f"{major}.{minor}.{patch}"


def update_chart_yaml(chart_folder, new_version, old_version):
    """Update Chart.yaml with new version and update artifacthub.io/changes."""
    chart_path = f"charts/{chart_folder}/Chart.yaml"

    with open(chart_path, "r") as f:
        chart_content = f.read()

    # Update appVersion line
    chart_content = re.sub(
        r'^appVersion:\s*["\']?([^\s"\']+)["\']?\s*$',
        f"appVersion: {new_version}",
        chart_content,
        flags=re.MULTILINE,
    )

    # Update version line (chart version - bump based on docker version change)
    old_version_match = re.search(
        r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\s*$", chart_content, re.MULTILINE
    )
    new_chart_version = None

    if old_version_match:
        old_chart_version = old_version_match.group(1)

        # Determine bump type based on docker version change
        bump_type = determine_version_bump_type(old_version, new_version)
        new_chart_version = bump_chart_version(old_chart_version, bump_type)

        chart_content = re.sub(
            r"^version:\s*[0-9]+\.[0-9]+\.[0-9]+\s*$",
            f"version: {new_chart_version}",
            chart_content,
            flags=re.MULTILINE,
        )
        print(
            f"Updated Chart.yaml: chart version {old_chart_version} → {new_chart_version} ({bump_type}), appVersion {new_version}"
        )
    else:
        print(
            f"Warning: Could not find version in Chart.yaml, keeping appVersion update only"
        )
        new_chart_version = old_version

    # Update artifacthub.io/changes annotation
    changes_entry = (
        f"- Updated {chart_folder.capitalize()} from {old_version} to {new_version}"
    )

    if "artifacthub.io/changes:" in chart_content:
        # Append to existing changes - add after the annotation line
        chart_content = re.sub(
            r"(artifacthub\.io/changes:\s*\|)",
            rf"\1\n    {changes_entry}",
            chart_content,
        )
    else:
        # Add new annotation if it doesn't exist
        annotations_match = re.search(r"^annotations:", chart_content, re.MULTILINE)
        if annotations_match:
            # Insert after annotations: line
            chart_content = re.sub(
                r"^(annotations:)",
                f"\\1\n  artifacthub.io/changes: |\n    {changes_entry}",
                chart_content,
                flags=re.MULTILINE,
            )

    with open(chart_path, "w") as f:
        f.write(chart_content)

    return new_chart_version


def update_changelog(
    chart_folder, new_chart_version, new_version, old_version, include_changelog
):
    """Update CHANGELOG.md if it exists and is requested."""
    if not include_changelog:
        return

    current_date = datetime.utcnow().strftime("%Y-%m-%d")
    changelog_entry = f"## [{new_chart_version}] - {current_date}\n\n### Updated\n- Updated application from {old_version} to {new_version}\n\n"

    changelog_path = f"charts/{chart_folder}/CHANGELOG.md"
    if os.path.exists(changelog_path):
        with open(changelog_path, "r") as f:
            changelog_content = f.read()

        # Insert new entry after the main heading
        changelog_content = re.sub(
            r"(# Changelog\n\n.*?\n\n)",
            rf"\1{changelog_entry}",
            changelog_content,
            count=1,
            flags=re.DOTALL,
        )

        with open(changelog_path, "w") as f:
            f.write(changelog_content)

        print("Updated CHANGELOG.md with new version entry")


def update_readme(chart_folder, new_version):
    """Update README.md in chart folder if it exists."""
    readme_path = f"charts/{chart_folder}/README.md"
    if not os.path.exists(readme_path):
        return

    with open(readme_path, "r") as f:
        readme_content = f.read()

    current_date = datetime.utcnow().strftime("%Y-%m-%d")
    version_section = f"## Version Information\n\n- **Current Version**: `{new_version}`\n- **Last Updated**: {current_date}\n\n---\n"

    if "## Version Information" in readme_content:
        readme_content = re.sub(
            r"## Version Information\n\n.*?\n\n---\n",
            version_section,
            readme_content,
            flags=re.DOTALL,
        )
    else:
        # Try to insert after the first heading
        readme_content = re.sub(
            r"(^# .*?\n)",
            rf"\1\n{version_section}",
            readme_content,
            count=1,
            flags=re.MULTILINE,
        )

    with open(readme_path, "w") as f:
        f.write(readme_content)

    print("Updated README.md with version information")


def update_root_readme(chart_folder, new_chart_version, new_version):
    """Update the chart entry in the root README.md."""
    with open("README.md", "r") as f:
        root_readme = f.read()

    # Update the table row for this chart
    # Match pattern: | [chart-name](charts/chart-name) | VERSION | APPVERSION | Description |
    chart_pattern = rf"(\| \[{chart_folder}\]\(charts/{chart_folder}\) \| )([0-9]+\.[0-9]+\.[0-9]+)( \| )([0-9]+\.[0-9]+\.[0-9]+)( \| )"
    root_readme = re.sub(
        chart_pattern, rf"\g<1>{new_chart_version}\g<3>{new_version}\g<5>", root_readme
    )

    with open("README.md", "w") as f:
        f.write(root_readme)

    print(
        f"Updated root README.md: chart version {new_chart_version}, appVersion {new_version}"
    )


def main():
    chart_folder = os.environ.get("CHART_FOLDER")
    new_version = os.environ.get("NEW_VERSION")
    old_version = os.environ.get("OLD_VERSION")
    include_changelog = os.environ.get("INCLUDE_CHANGELOG", "false").lower() == "true"

    if not chart_folder or not new_version or not old_version:
        print(
            "Error: CHART_FOLDER, NEW_VERSION, and OLD_VERSION environment variables are required"
        )
        sys.exit(1)

    # Update Chart.yaml and get new chart version
    new_chart_version = update_chart_yaml(chart_folder, new_version, old_version)

    # Update CHANGELOG.md if requested
    update_changelog(
        chart_folder, new_chart_version, new_version, old_version, include_changelog
    )

    # Update chart README.md
    update_readme(chart_folder, new_version)

    # Update root README.md
    update_root_readme(chart_folder, new_chart_version, new_version)


if __name__ == "__main__":
    main()
