-- ============================================================
-- Geosphere — skema Supabase
-- Jalankan sekali di: Supabase → SQL Editor → New query → Run
-- Aman dijalankan ulang (memakai "if not exists" / "drop policy if exists").
-- ============================================================

-- 1) TABEL ---------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  nama       text not null default '',
  paket      text not null default 'basic' check (paket in ('basic','pro','ai')),
  st         text not null default 'Menunggu aktivasi',   -- Menunggu aktivasi | Aktif | Nonaktif
  kelas      text not null default '-',
  role       text not null default 'siswa' check (role in ('siswa','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.user_data (          -- progres belajar tiap siswa
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_state (          -- isi & pengaturan yang dikelola admin
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.public_scores (      -- untuk papan peringkat
  user_id    uuid primary key references auth.users(id) on delete cascade,
  nama       text,
  kelas      text,
  earned     integer not null default 0,
  pts        integer not null default 0,
  updated_at timestamptz not null default now()
);

-- 2) FUNGSI PENGECEK ADMIN ------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- 3) PROFIL OTOMATIS SAAT DAFTAR --------------------------------
-- Peran (role) dan status TIDAK diambil dari data pendaftar, jadi tidak bisa dipalsukan.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, nama, paket)
  values (
    new.id,
    new.email,
    coalesce(left(new.raw_user_meta_data->>'nama', 80), ''),
    case when new.raw_user_meta_data->>'paket' in ('basic','pro','ai')
         then new.raw_user_meta_data->>'paket' else 'basic' end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) KEAMANAN BARIS (RLS) ---------------------------------------
alter table public.profiles      enable row level security;
alter table public.user_data     enable row level security;
alter table public.app_state     enable row level security;
alter table public.public_scores enable row level security;

-- profiles: siswa hanya melihat profilnya sendiri; hanya admin yang boleh mengubah
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());
drop policy if exists profiles_update_admin on public.profiles;
create policy profiles_update_admin on public.profiles for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
drop policy if exists profiles_delete_admin on public.profiles;
create policy profiles_delete_admin on public.profiles for delete to authenticated
  using (public.is_admin());

-- user_data: siswa membaca/menulis data sendiri; admin semua
drop policy if exists user_data_select on public.user_data;
create policy user_data_select on public.user_data for select to authenticated
  using (user_id = auth.uid() or public.is_admin());
drop policy if exists user_data_insert on public.user_data;
create policy user_data_insert on public.user_data for insert to authenticated
  with check (user_id = auth.uid() or public.is_admin());
drop policy if exists user_data_update on public.user_data;
create policy user_data_update on public.user_data for update to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());
drop policy if exists user_data_delete on public.user_data;
create policy user_data_delete on public.user_data for delete to authenticated
  using (public.is_admin());

-- app_state: semua yang sudah masuk boleh membaca; hanya admin yang menulis
drop policy if exists app_state_select on public.app_state;
create policy app_state_select on public.app_state for select to authenticated using (true);
drop policy if exists app_state_write_admin on public.app_state;
create policy app_state_write_admin on public.app_state for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- public_scores: semua yang sudah masuk boleh membaca; siswa hanya menulis skornya sendiri
drop policy if exists scores_select on public.public_scores;
create policy scores_select on public.public_scores for select to authenticated using (true);
drop policy if exists scores_insert on public.public_scores;
create policy scores_insert on public.public_scores for insert to authenticated
  with check (user_id = auth.uid());
drop policy if exists scores_update on public.public_scores;
create policy scores_update on public.public_scores for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists scores_delete_admin on public.public_scores;
create policy scores_delete_admin on public.public_scores for delete to authenticated
  using (public.is_admin());

-- 5) JADIKAN DIRI ANDA ADMIN -------------------------------------
-- Langkah: (a) daftar dulu di web Geosphere dengan email admin Anda,
-- (b) ganti email di bawah, (c) jalankan baris ini saja.
--
-- update public.profiles set role = 'admin', st = 'Aktif' where email = 'EMAIL-ADMIN-ANDA@contoh.com';
