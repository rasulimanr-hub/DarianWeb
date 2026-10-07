create table if not exists public.knowledge_data (
    id integer primary key,
    data jsonb not null default '{}'::jsonb,
    updated_at timestamptz not null default now()
);

create table if not exists public.admin_users (
    id uuid primary key references auth.users(id) on delete cascade,
    created_at timestamptz not null default now()
);

alter table public.knowledge_data enable row level security;
alter table public.admin_users enable row level security;

insert into public.admin_users (id)
select id from auth.users where email = 'dsat422@gmail.com'
on conflict (id) do nothing;

drop policy if exists "Public can read knowledge data" on public.knowledge_data;
create policy "Public can read knowledge data"
    on public.knowledge_data for select
    to anon, authenticated
    using (true);

drop policy if exists "Admins can insert knowledge data" on public.knowledge_data;
create policy "Admins can insert knowledge data"
    on public.knowledge_data for insert
    to authenticated
    with check (
        id = 1
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );

drop policy if exists "Admins can update knowledge data" on public.knowledge_data;
create policy "Admins can update knowledge data"
    on public.knowledge_data for update
    to authenticated
    using (
        id = 1
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    )
    with check (
        id = 1
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );

drop policy if exists "Admins can delete knowledge data" on public.knowledge_data;
create policy "Admins can delete knowledge data"
    on public.knowledge_data for delete
    to authenticated
    using (
        id = 1
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );

insert into public.knowledge_data (id, data)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('topic-images', 'topic-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Anon can read topic images" on storage.objects;
drop policy if exists "Authenticated can upload topic images" on storage.objects;
drop policy if exists "Authenticated can read topic images" on storage.objects;
drop policy if exists "Authenticated can update topic images" on storage.objects;
drop policy if exists "Authenticated can delete topic images" on storage.objects;

create policy "Anon can read topic images"
    on storage.objects for select
    to anon, authenticated
    using (bucket_id = 'topic-images');

create policy "Admins can upload topic images"
    on storage.objects for insert
    to authenticated
    with check (
        bucket_id = 'topic-images'
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );

create policy "Admins can update topic images"
    on storage.objects for update
    to authenticated
    using (
        bucket_id = 'topic-images'
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    )
    with check (
        bucket_id = 'topic-images'
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );

create policy "Admins can delete topic images"
    on storage.objects for delete
    to authenticated
    using (
        bucket_id = 'topic-images'
        and exists (
            select 1 from public.admin_users au
            where au.id = auth.uid()
        )
    );