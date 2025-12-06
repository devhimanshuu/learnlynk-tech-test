-- LearnLynk Tech Test - Task 1: Schema
-- Fill in the definitions for leads, applications, tasks as per README.

create extension if not exists "pgcrypto";

-- Leads table
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  owner_id uuid not null,
  email text,
  phone text,
  full_name text,
  stage text not null default 'new',
  source text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for leads
create index if not exists leads_tenant_owner_stage_idx on public.leads (tenant_id, owner_id, stage);

-- Applications table
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  lead_id uuid not null references public.leads(id) on delete cascade,
  program_id uuid,
  intake_id uuid,
  stage text not null default 'inquiry',
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for applications
create index if not exists applications_tenant_lead_idx on public.applications (tenant_id, lead_id);

-- Tasks table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  application_id uuid not null references public.applications(id) on delete cascade,
  title text,
  type text not null check (type in ('call', 'email', 'review')),
  status text not null default 'open',
  due_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tasks_due_at_check check (due_at >= created_at)
);

-- Indexes for tasks
create index if not exists tasks_tenant_due_status_idx on public.tasks (tenant_id, due_at, status);
