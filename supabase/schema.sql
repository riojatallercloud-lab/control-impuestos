-- Control de impuestos SII: tablas aisladas con prefijo sii_
create table if not exists public.sii_miembros (
  email text primary key,
  nombre text,
  creado timestamptz not null default now()
);
create table if not exists public.sii_meses (
  periodo text primary key check (periodo ~ '^\d{4}-\d{2}$'),
  docs jsonb not null default '[]'::jsonb,
  rem numeric,
  updated_at timestamptz not null default now(),
  updated_by uuid
);
create table if not exists public.sii_config (
  id int primary key check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace function public.sii_es_miembro() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.sii_miembros m where lower(m.email) = lower(auth.jwt()->>'email'));
$$;
revoke all on function public.sii_es_miembro() from public, anon;
grant execute on function public.sii_es_miembro() to authenticated;

alter table public.sii_miembros enable row level security;
alter table public.sii_meses enable row level security;
alter table public.sii_config enable row level security;

drop policy if exists sii_meses_rw on public.sii_meses;
create policy sii_meses_rw on public.sii_meses for all to authenticated
  using ((select public.sii_es_miembro())) with check ((select public.sii_es_miembro()));
drop policy if exists sii_config_rw on public.sii_config;
create policy sii_config_rw on public.sii_config for all to authenticated
  using ((select public.sii_es_miembro())) with check ((select public.sii_es_miembro()));
drop policy if exists sii_miembros_ver on public.sii_miembros;
create policy sii_miembros_ver on public.sii_miembros for select to authenticated
  using ((select public.sii_es_miembro()));

revoke all on public.sii_meses, public.sii_config, public.sii_miembros from anon;
grant select, insert, update, delete on public.sii_meses, public.sii_config to authenticated;
grant select on public.sii_miembros to authenticated;

-- Gestión de usuarios desde la app (solo miembros; nadie puede quitarse a sí mismo)
drop policy if exists sii_miembros_agregar on public.sii_miembros;
create policy sii_miembros_agregar on public.sii_miembros for insert to authenticated
  with check ((select public.sii_es_miembro()));
drop policy if exists sii_miembros_quitar on public.sii_miembros;
create policy sii_miembros_quitar on public.sii_miembros for delete to authenticated
  using ((select public.sii_es_miembro()) and lower(email) <> lower(auth.jwt()->>'email'));
grant insert, delete on public.sii_miembros to authenticated;
