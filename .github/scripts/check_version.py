#!/usr/bin/env python3
"""
Check for new Docker image versions and compare with current chart version.
"""

import requests
import os
import re
import sys
from packaging import version as pkg_version


def extract_current_version(chart_folder):
    """Extract current appVersion from Chart.yaml using regex (preserves comments)."""
    chart_path = f'charts/{chart_folder}/Chart.yaml'
    with open(chart_path, 'r') as f:
        content = f.read()

    current_version_match = re.search(r'^appVersion:\s*["\']?([^\s"\']+)["\']?\s*$', content, re.MULTILINE)
    return current_version_match.group(1) if current_version_match else "unknown"


def fetch_latest_version(docker_tags_url, version_pattern):
    """Fetch Docker tags and find the latest matching version."""
    response = requests.get(docker_tags_url)
    response.raise_for_status()
    data = response.json()

    # Extract version strings based on the response format
    versions = []
    if 'tags' in data:
        # Format: {"tags": ["1.0.0", "2.0.0"]} (e.g., OCI registry)
        versions = [tag for tag in data.get('tags', []) if re.match(version_pattern, tag)]
    elif 'results' in data:
        # Format: {"results": [{"name": "1.0.0"}, ...]} (e.g., Docker Hub)
        versions = [tag['name'] for tag in data['results'] if re.match(version_pattern, tag['name'])]

    versions.sort(key=lambda v: pkg_version.parse(v), reverse=True)
    return versions[0] if versions else None


def main():
    chart_folder = os.environ.get('CHART_FOLDER')
    docker_tags_url = os.environ.get('DOCKER_TAGS_URL')
    version_pattern = os.environ.get('VERSION_PATTERN', r'^\d+\.\d+\.\d+$')

    if not chart_folder or not docker_tags_url:
        print("Error: CHART_FOLDER and DOCKER_TAGS_URL environment variables are required")
        sys.exit(1)

    # Get current version
    current_version = extract_current_version(chart_folder)
    print(f"Current version: {current_version}")

    # Get latest version
    latest_version = fetch_latest_version(docker_tags_url, version_pattern)

    if latest_version is None:
        print(f"No matching versions found. Using current version: {current_version}")
        latest_version = current_version

    print(f"Latest version: {latest_version}")

    # Write outputs to GITHUB_OUTPUT
    github_output = os.environ.get('GITHUB_OUTPUT')
    if github_output:
        with open(github_output, 'a') as f:
            f.write(f"current_version={current_version}\n")
            f.write(f"latest_version={latest_version}\n")
            f.write(f"update_needed={'true' if latest_version != current_version else 'false'}\n")

    update_needed = latest_version != current_version
    print(f"Update needed: {update_needed}")


if __name__ == '__main__':
    main()
