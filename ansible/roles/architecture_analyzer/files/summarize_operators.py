#!/usr/bin/env python3
"""
Resumo da análise de operators no host remoto.
Lê operators.json localmente e grava operator_analysis_summary.json (pequeno).
Evita trazer o JSON gigante para o controlador Ansible.
"""
import json
import sys

def get_items(data, key, default=None):
    if not data or not isinstance(data, dict):
        return default or []
    val = data.get(key)
    if isinstance(val, dict) and "items" in val:
        return val["items"]
    if isinstance(val, list):
        return val
    return default or []

def main():
    if len(sys.argv) < 3:
        print("Usage: summarize_operators.py <operators.json> <output_summary.json>", file=sys.stderr)
        sys.exit(1)
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    try:
        with open(input_path, "r") as f:
            ops = json.load(f)
    except Exception as e:
        summary = {
            "operator_health": {"total_csvs": 0, "total_subscriptions": 0, "total_install_plans": 0, "total_operator_groups": 0},
            "operator_versions": {"csv_versions": [], "subscription_versions": [], "operator_names": []},
            "operator_issues": ["Falha ao ler operators.json: " + str(e)]
        }
        with open(output_path, "w") as f:
            json.dump(summary, f, indent=2)
        sys.exit(0)
    # operators.json from merge: keys clusterserviceversions_json, subscriptions_json, etc.; value is { "items": [...] }
    def as_list(val):
        if isinstance(val, list):
            return val
        if isinstance(val, dict) and "items" in val:
            return val["items"]
        return []
    csv_items = as_list(ops.get("clusterserviceversions_json") or ops.get("clusterserviceversions"))
    sub_items = as_list(ops.get("subscriptions_json") or ops.get("subscriptions"))
    ip_items = as_list(ops.get("installplans_json") or ops.get("installplans"))
    og_items = as_list(ops.get("operatorgroups_json") or ops.get("operatorgroups"))

    issues = []
    for ip in ip_items:
        if isinstance(ip, dict) and ip.get("status", {}).get("phase") == "Failed":
            issues.append("Some install plans may have failed")
            break
    for s in sub_items:
        if not isinstance(s, dict):
            continue
        conds = s.get("status", {}).get("conditions") or []
        for c in conds:
            if c.get("status") == "False":
                issues.append("Some subscriptions may have issues")
                break
        if issues and "subscriptions" in issues[-1]:
            break
    for csv in csv_items:
        if not isinstance(csv, dict):
            continue
        phase = csv.get("status", {}).get("phase")
        if phase and phase != "Succeeded":
            issues.append("Some cluster service versions may have issues")
            break

    def safe_get(lst, attr, limit=50):
        out = []
        seen = set()
        for x in lst:
            if not isinstance(x, dict):
                continue
            val = x.get("spec", {}).get(attr) or x.get("metadata", {}).get(attr)
            if val is not None and val not in seen:
                seen.add(val)
                out.append(val)
            if len(out) >= limit:
                break
        return out

    csv_versions = safe_get(csv_items, "version")
    sub_channels = safe_get(sub_items, "channel")
    operator_names = safe_get(csv_items, "displayName")

    summary = {
        "operator_health": {
            "total_csvs": len(csv_items),
            "total_subscriptions": len(sub_items),
            "total_install_plans": len(ip_items),
            "total_operator_groups": len(og_items)
        },
        "operator_versions": {
            "csv_versions": csv_versions,
            "subscription_versions": sub_channels,
            "operator_names": operator_names
        },
        "operator_issues": issues
    }
    with open(output_path, "w") as f:
        json.dump(summary, f, indent=2)

if __name__ == "__main__":
    main()
