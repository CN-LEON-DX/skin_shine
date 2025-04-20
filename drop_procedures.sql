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