-- SkillBox AI credit ledger schema (run ONLY in a dedicated SkillBox AI Supabase project).
-- 3 free credits on signup. One successful generation costs 1 credit.
create table if not exists public.ai_wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.ai_credit_ledger (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null check (delta <> 0),
  reason text not null check (reason in ('welcome','generation','purchase','refund','admin_adjustment')),
  reference text not null,
  created_at timestamptz not null default now(),
  unique (user_id, reference)
);
create index if not exists ai_credit_ledger_user_created_idx on public.ai_credit_ledger(user_id, created_at desc);
create table if not exists public.ai_generations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  idempotency_key uuid not null,
  service text not null,
  status text not null default 'pending' check (status in ('pending','completed','failed')),
  result_text text,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (user_id, idempotency_key)
);
create index if not exists ai_generations_user_created_idx on public.ai_generations(user_id, created_at desc);
alter table public.ai_wallets enable row level security;
alter table public.ai_credit_ledger enable row level security;
alter table public.ai_generations enable row level security;
revoke all on public.ai_wallets, public.ai_credit_ledger, public.ai_generations from anon, authenticated;
grant select on public.ai_wallets, public.ai_credit_ledger, public.ai_generations to authenticated;
create policy "wallet owner read" on public.ai_wallets for select to authenticated using (user_id = (select auth.uid()));
create policy "ledger owner read" on public.ai_credit_ledger for select to authenticated using (user_id = (select auth.uid()));
create policy "generation owner read" on public.ai_generations for select to authenticated using (user_id = (select auth.uid()));
-- Only a trusted server with service-role permissions can change balances or generation records.
-- Never expose service-role keys in GitHub Pages or browser JavaScript.
create or replace function public.ai_wallet_balance(p_user_id uuid)
returns integer language sql stable security invoker set search_path = '' as $$
  select coalesce(sum(delta),0)::integer from public.ai_credit_ledger where user_id = p_user_id;
$$;
revoke all on function public.ai_wallet_balance(uuid) from public, anon, authenticated;
-- Service role or a trusted server should grant welcome credits after verifying the user.
-- Atomic deduction, provider failure refunds, idempotency and per-user rate limiting
-- must be implemented server-side before allowing public AI generation.
