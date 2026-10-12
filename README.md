# Geosphere (terhubung Supabase)

Satu halaman statis (`index.html`) + database Supabase. Di-host di Netlify, kode di GitHub.

## Pengaturan Supabase (sekali saja)
1. **SQL Editor → New query**: tempel isi `supabase.sql` → **Run**.
2. **Authentication → Providers → Email**: matikan **Confirm email** (aktivasi dilakukan admin, jadi tidak perlu konfirmasi email).
3. **Authentication → URL Configuration**: isi **Site URL** dengan alamat Netlify Anda (untuk tautan "lupa kata sandi").
4. Buka web Geosphere → **Daftar** dengan email admin Anda (pilih paket apa saja).
5. Kembali ke **SQL Editor**, jalankan (ganti emailnya):
   `update public.profiles set role='admin', st='Aktif' where email='EMAIL-ADMIN-ANDA';`
6. Masuk dengan email itu → Anda masuk sebagai admin.

## Alur siswa
Daftar → pilih paket → bayar (masih simulasi) → admin menekan **Aktifkan** di tab Akun → siswa masuk dengan email & kata sandi.

## Catatan keamanan
- `index.html` memuat **anon key** (publik, memang dirancang begitu). Keamanan data dijaga oleh aturan RLS di `supabase.sql`. **Jangan pernah menaruh service_role key di file ini.**
- Skor dan koin disimpan dari browser siswa, jadi cocok untuk kelas, bukan untuk kompetisi berhadiah.
- Email bawaan Supabase dibatasi jumlahnya per jam. Untuk banyak pengguna, pasang SMTP sendiri (Authentication → SMTP).
