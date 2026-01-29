#!/usr/bin/env python3
"""Merge security config JSON files into a single security_configs.json. Deletes each
file after reading to minimize peak disk usage on bastions with limited space."""
import json
import os

FILES = [
    ("securitycontextconstraints", "_scc.json"),
    ("networkpolicies_json", "_np.json"),
    ("podsecuritypolicies_json", "_psp.json"),
    ("secrets_json", "_secrets.json"),
    ("configmaps_json", "_cm.json"),
    ("collection_metadata", ".security_metadata.json"),
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
    with open("security_configs.json", "w") as fp:
        json.dump(d, fp, indent=2)
    try:
        os.unlink("merge_security_configs_json.py")
    except OSError:
        pass

if __name__ == "__main__":
    main()
