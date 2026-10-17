# Geosphere (terhubung Supabase)

Satu halaman statis (`index.html`) + database Supabase. Di-host di Netlify, kode di GitHub.

## Pengaturan Supabase (sekali saja)
> Sudah pernah menjalankan `supabase.sql` versi lama? Jalankan ulang file yang baru ini; aman diulang dan hanya menambah yang kurang.

1. **SQL Editor → New query**: tempel isi `supabase.sql` → **Run**.
2. **Authentication → Providers → Email**: matikan **Confirm email** (aktivasi dilakukan admin, jadi tidak perlu konfirmasi email).
3. **Authentication → URL Configuration**: isi **Site URL** dengan alamat Netlify Anda (untuk tautan "lupa kata sandi").
4. Buka web Geosphere → **Daftar** dengan email admin Anda (pilih paket apa saja; di kolom nomor pesanan Shopee isi sembarang 6+ karakter, mis. ADMIN1).
5. Kembali ke **SQL Editor**, jalankan (ganti emailnya):
   `update public.profiles set role='admin', st='Aktif' where email='EMAIL-ADMIN-ANDA';`
6. Masuk dengan email itu → Anda masuk sebagai admin.

## Pembayaran lewat Shopee
1. Masuk sebagai admin → tab **Pembayaran Shopee** → isi link produk/toko Shopee untuk tiap paket.
2. Alur siswa: Daftar → pilih paket → **Buka toko Shopee** (bayar) → tempel **Nomor Pesanan** → akun dibuat.
3. Admin melihat nomor pesanan di tab **Akun**, mencocokkannya di Shopee Seller Centre, lalu menekan **Aktifkan**. Satu nomor pesanan hanya bisa dipakai satu akun.

## Acak soal
Tab admin **Acak Soal**: acak urutan soal dan pilihan jawaban per akun, ganti acakan (tetap/harian/mingguan), dan jumlah soal per siswa dari bank soal (0 = semua).

## Catatan keamanan
- `index.html` memuat **anon key** (publik, memang dirancang begitu). Keamanan data dijaga oleh aturan RLS di `supabase.sql`. **Jangan pernah menaruh service_role key di file ini.**
- Skor dan koin disimpan dari browser siswa, jadi cocok untuk kelas, bukan untuk kompetisi berhadiah.
- Email bawaan Supabase dibatasi jumlahnya per jam. Untuk banyak pengguna, pasang SMTP sendiri (Authentication → SMTP).
