# Hướng dẫn cập nhật từ Procedure sang Function trong Supabase

## Bước 1: Xóa các Procedure cũ

Để xóa các procedure cũ, hãy thực hiện các bước sau:

1. Đăng nhập vào [Supabase Dashboard](https://supabase.com/).
2. Chọn dự án của bạn.
3. Vào phần SQL Editor.
4. Tạo một query mới và dán nội dung từ file `drop_procedures.sql`.
5. Chạy script để xóa tất cả procedure cũ.

```sql
-- Xóa tất cả các procedure cũ
DROP PROCEDURE IF EXISTS public.register_user CASCADE;
DROP PROCEDURE IF EXISTS public.handle_login CASCADE;
DROP PROCEDURE IF EXISTS public.update_user_profile CASCADE;
DROP PROCEDURE IF EXISTS public.add_post CASCADE;
DROP PROCEDURE IF EXISTS public.add_product_review CASCADE;
DROP PROCEDURE IF EXISTS public.create_order CASCADE;

-- Kiểm tra lại để xác nhận không còn procedure nào tồn tại
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_type = 'PROCEDURE'
ORDER BY routine_name;
```

## Bước 2: Tạo các Function mới

1. Tạo một query mới và dán nội dung từ file `supabase_functions.sql`.
2. Chạy script để tạo tất cả các function mới.

## Bước 3: Cấp quyền cho Function

Đảm bảo rằng tất cả các function đã được cấp quyền cho các role tương ứng:

```sql
-- Cấp quyền cho các function để có thể gọi từ client
GRANT EXECUTE ON FUNCTION register_user TO anon, authenticated;
GRANT EXECUTE ON FUNCTION handle_login TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_details TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_user_profile TO authenticated;
GRANT EXECUTE ON FUNCTION add_post TO authenticated;
GRANT EXECUTE ON FUNCTION add_product_review TO authenticated;
GRANT EXECUTE ON FUNCTION create_order TO authenticated;
```

## Bước 4: Cập nhật mã nguồn Flutter

Cập nhật các hàm trong `SupabaseService` để sử dụng function thay vì procedure:

1. `signUpWithEmail` - đã cập nhật
2. `signInWithGoogle` - đã cập nhật
3. `uploadAvatar` - đã cập nhật

## Bước 5: Kiểm tra

1. Chạy ứng dụng và đảm bảo rằng các chức năng sau hoạt động đúng:
   - Đăng ký người dùng mới
   - Đăng nhập bằng email
   - Đăng nhập bằng Google
   - Cập nhật thông tin cá nhân

2. Thực hiện truy vấn để kiểm tra các function đã tồn tại:

```sql
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY routine_name;
```

## Phụ lục: Sửa lỗi không tìm thấy function

Nếu gặp lỗi "Could not find the function", hãy kiểm tra:

1. Function đã được tạo đúng cách với đúng tên
2. Số lượng và thứ tự tham số phù hợp
3. Role của người dùng đã được cấp quyền EXECUTE
4. Function đã được đặt trong schema "public"

Để làm mới cache schema, bạn có thể thử:

```sql
ALTER FUNCTION register_user(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) RENAME TO register_user_temp;
ALTER FUNCTION register_user_temp RENAME TO register_user;
``` 