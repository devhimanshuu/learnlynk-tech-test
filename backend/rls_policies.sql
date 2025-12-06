-- LearnLynk Tech Test - Task 2: RLS Policies on leads

alter table public.leads enable row level security;

-- Example helper: assume JWT has tenant_id, user_id, role.
-- You can use: current_setting('request.jwt.claims', true)::jsonb

-- SELECT Policy
create policy "leads_select_policy"
on public.leads
for select
using (
  -- Admin sees all leads for their tenant
  (
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') = 'admin'
    and
    tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
  )
  or
  -- Counselors see leads they own OR leads assigned to their teams
  (
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') = 'counselor'
    and
    tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
    and
    (
      -- Lead is owned by the user
      owner_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'user_id')::uuid
      or
      -- Lead is owned by a member of one of the user's teams (Interpretation of 'assigned to any team')
      -- Assuming schema: user_teams(user_id, team_id)
      exists (
        select 1
        from user_teams ut_viewer
        join user_teams ut_owner on ut_viewer.team_id = ut_owner.team_id
        where ut_viewer.user_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'user_id')::uuid
          and ut_owner.user_id = leads.owner_id
      )
    )
  )
);

-- INSERT Policy
create policy "leads_insert_policy"
on public.leads
for insert
with check (
  -- Counselors and Admins can insert
  (
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') in ('admin', 'counselor')
  )
  and
  -- Tenant ID must match
  tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
  and
  -- Optionally verify owner_id matches user_id for counselors, but requirements didn't strictly specify this restriction, likely flexible.
  -- Ensuring the inserted record belongs to the tenant.
  true
);
