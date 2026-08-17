---
name: ship
description: Take the working tree to an open pull request by running the branch, commit, and pr skills in order.
disable-model-invocation: true
---

# Ship

Run `/branch`, `/commit`, and `/pr` in order, carrying the current working tree from uncommitted changes to an open pull request. Each keeps its own review gate; ship doesn't add another one, only sequences them.

## 1. Branch

Run `/branch`.

## 2. Commit

Run `/commit`.

If it finds nothing to commit (the branch from step 1 already held committed work), don't stop ship for that alone: continue to step 3 if the branch has commits ahead of its base. If it has neither uncommitted changes nor commits ahead of base, there's nothing to ship: say so and stop.

## 3. PR

Run `/pr`.
