#!/usr/bin/env python3
"""Merge operator JSON files into a single operators.json (used when jq is not available)."""
import json
import os

FILES = [
    ("clusterserviceversions_json", "_csv.json"),
    ("subscriptions_json", "_sub.json"),
    ("installplans_json", "_ip.json"),
    ("operatorgroups_json", "_og.json"),
    ("catalogs_json", "_cat.json"),
    ("collection_metadata", ".operators_metadata.json"),
]

def main():
    d = {}
    for key, path in FILES:
        if os.path.isfile(path):
            with open(path) as fp:
                d[key] = json.load(fp)
    with open("operators.json", "w") as fp:
        json.dump(d, fp, indent=2)

if __name__ == "__main__":
    main()
