# SkillBox AI — credit monetization v1

## Product rules (proposed, not activated)

- New registered user: **3 welcome credits** (once per verified account).
- One successfully completed AI generation: **1 credit**.
- Insufficient balance: no generation, prompt to purchase credits.
- Failed provider generation: refund/reserve-release exactly once.
- Trial abuse mitigation: verified accounts, per-user and IP limits, CAPTCHA when appropriate, spending cap and monitoring.
- Credits must be stored in the database, **never** localStorage or frontend counters.

## Suggested packages (NOT for sale yet)

- 10 credits — 99 UAH
- 30 credits — 249 UAH
- 100 credits — 699 UAH

Prices are placeholders to test unit economics. Recalculate based on provider model, token use, payment processing, taxes, support and refunds. Avoid unlimited generations.

## Infrastructure

GitHub Pages hosts the public frontend. A **separate** Supabase project should host authentication, ledger and Edge Functions. Do not reuse the existing FlipRadar project.

SQL blueprint: `supabase/migrations/20261016_ai_credits.sql`.

The SQL establishes private ledger tables with read-only user access. It does not automatically grant credits, charge credits, connect an AI provider or process payments.

Server implementation must:
1. Verify authenticated user and ownership of the request.
2. Enforce request size, per-user rate limits, quotas, concurrent request limits, and model budget.
3. Atomically reserve 1 credit with an idempotency key; do not allow negative balance.
4. Call the model with an API key stored in a server-side secret.
5. On success, store result and mark completed. On failure, restore reserved credit exactly once.
6. Verify payment provider webhook signature and event idempotency before granting purchased credits.
7. Record ledger references for all grants/deductions/refunds and provide account deletion/data retention policy.
8. Never trust the browser for credit balance, payment status or generation completion.

## Deployment blockers

- Dedicated Supabase project has not yet been created.
- AI provider billing and server-side key are not configured.
- Payment provider merchant account and signed webhooks are not configured.
- Authentication, atomic charging, abuse prevention and public backend deployment remain to be completed.

**Do not mark AI generation or payments as live until all checks pass.**
