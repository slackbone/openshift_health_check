#!/usr/bin/env python3
"""Merge operator JSON files into a single operators.json. Deletes each file after
reading to minimize peak disk usage on bastions with limited space (e.g. /tmp)."""
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
            try:
                with open(path) as fp:
                    d[key] = json.load(fp)
            finally:
                try:
                    os.unlink(path)
                except OSError:
                    pass
    with open("operators.json", "w") as fp:
        json.dump(d, fp, indent=2)
    # Remove merge script to free space
    try:
        os.unlink("merge_operators_json.py")
    except OSError:
        pass

if __name__ == "__main__":
    main()
