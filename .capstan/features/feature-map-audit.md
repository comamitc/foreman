# Feature-map audit

## Sub-features
- Map resolution as [contract](../../references/contract.md) ("`features` is the optional feature-map field") specifies.
- Drift checks across the index, feature files, links, headings, reach paths, commands, observable results, and gotchas.
- Repairs limited to verified stale or missing documentation; product defects are reported.

## How to get to it (user POV)
Install Capstan as [README](../../README.md) ("Install and invoke") describes, and state in an issue or in a text invocation that the outcome is an audit of the configured feature map.
[feature-map audit](../../references/modes/feature-map-audit.md) ("This file owns the feature-map audit") owns the procedure.

## Driving it
Invocation: invoke Capstan with the URL or number of an issue that states the audit outcome, or with text that states it.
End state: with verified drift, the repairs go through the normal plan, implementation, review, and ready gate, and the final summary lists the checked features, proven repairs, product-defect handoffs, and gaps.
With no drift, the issue is reconciled as a no-op; no diff is manufactured.
With an absent or disabled map, the audit gives a no-map result and seeds no map.

## Gotchas
- A normal feature delivery, init, or resume does not enter the audit.
- A failed drive command is classified first; a product defect is reported, not documented away.
- The audit does not delete a still-true claim or weaken a proof to pass.
