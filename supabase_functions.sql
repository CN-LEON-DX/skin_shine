-- 1. Function xử lý đăng ký
CREATE OR REPLACE FUNCTION register_user(
    p_auth_id UUID,
    p_email TEXT,
    p_provider TEXT DEFAULT 'email',
    p_full_name TEXT DEFAULT NULL,
    p_username TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL,
    p_provider_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_account_id UUID;
    v_username TEXT;
    v_user_id UUID;
    v_otp_code TEXT;
    v_result JSONB;
    v_auth_exists BOOLEAN;
BEGIN
    -- Kiểm tra xem auth_id đã tồn tại trong auth.users chưa
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = p_auth_id) INTO v_auth_exists;
    
    IF NOT v_auth_exists THEN
        RAISE EXCEPTION 'Auth user does not exist. Please try again.';
    END IF;

    -- Kiểm tra email đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM public.accounts WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email already exists';
    END IF;
    
    -- Nếu không có username thì tạo username từ email
    IF p_username IS NULL THEN
        v_username := split_part(p_email, '@', 1);
        -- Đảm bảo username là duy nhất
        WHILE EXISTS (SELECT 1 FROM public.users WHERE username = v_username) LOOP
            v_username := v_username || floor(random() * 1000)::text;
        END LOOP;
    ELSE
        v_username := p_username;
    END IF;
    
    -- Thêm vào bảng accounts
    INSERT INTO public.accounts (auth_id, email, provider, provider_id, created_at, last_sign_in)
    VALUES (p_auth_id, p_email, p_provider, p_provider_id, NOW(), NOW())
    RETURNING id INTO v_account_id;
    
    -- Thêm vào bảng users
    INSERT INTO public.users (account_id, username, full_name, avatar_url, created_at, updated_at)
    VALUES (v_account_id, v_username, p_full_name, p_avatar_url, NOW(), NOW())
    RETURNING id INTO v_user_id;
    
    -- Tạo mã OTP (6 chữ số ngẫu nhiên)
    v_otp_code := floor(random() * 900000 + 100000)::text;
    
    -- Thêm vào bảng otp_verifications
    INSERT INTO public.otp_verifications (
        user_id,
        email,
        otp_code,
        expires_at,
        created_at,
        updated_at
    )
    VALUES (
        v_user_id,
        p_email,
        v_otp_code,
        NOW() + INTERVAL '3 minutes',
        NOW(),
        NOW()
    );
    
    -- Tạo kết quả trả về
    v_result := jsonb_build_object(
        'success', true,
        'account_id', v_account_id,
        'user_id', v_user_id,
        'username', v_username,
        'otp_code', v_otp_code,
        'requires_verification', true
    );
    
    RETURN v_result;
END;
$$;

-- 2. Function xử lý đăng nhập
CREATE OR REPLACE FUNCTION handle_login(
    p_auth_id UUID,
    p_email TEXT,
    p_provider TEXT,
    p_provider_id TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_account_id UUID;
    v_account_exists BOOLEAN;
    v_email_exists BOOLEAN;
    v_username TEXT;
    v_user_id UUID;
    v_result JSONB;
BEGIN
    -- Kiểm tra tài khoản đã tồn tại chưa
    SELECT EXISTS(SELECT 1 FROM public.accounts WHERE auth_id = p_auth_id) INTO v_account_exists;
    
    -- Kiểm tra email đã tồn tại chưa (nhưng với provider khác)
    SELECT EXISTS(
        SELECT 1 FROM public.accounts 
        WHERE email = p_email AND provider != p_provider
    ) INTO v_email_exists;
    
    -- Trường hợp 1: Tài khoản đã tồn tại - cập nhật thời gian đăng nhập
    IF v_account_exists THEN
        UPDATE public.accounts
        SET last_sign_in = NOW()
        WHERE auth_id = p_auth_id
        RETURNING id INTO v_account_id;
        
        -- Lấy user_id
        SELECT id INTO v_user_id FROM public.users WHERE account_id = v_account_id;
        
        v_result := jsonb_build_object(
            'success', true,
            'action', 'updated',
            'account_id', v_account_id,
            'user_id', v_user_id
        );
        
    -- Trường hợp 2: Email đã tồn tại với provider khác - xử lý liên kết
    ELSIF v_email_exists THEN
        -- Phương án: Liên kết provider mới với tài khoản hiện có
        -- Hoặc có thể ném exception yêu cầu người dùng đăng nhập bằng provider ban đầu
        RAISE EXCEPTION 'Email already registered with a different provider. Please sign in using your original provider.';
        
    -- Trường hợp 3: Tài khoản chưa tồn tại - tạo mới
    ELSE
        -- Tạo username từ email nếu không có
        IF p_full_name IS NULL THEN
            v_username := split_part(p_email, '@', 1);
        ELSE
            v_username := regexp_replace(lower(p_full_name), '[^a-z0-9]', '', 'g');
        END IF;
        
        -- Đảm bảo username là duy nhất
        WHILE EXISTS (SELECT 1 FROM public.users WHERE username = v_username) LOOP
            v_username := v_username || floor(random() * 1000)::text;
        END LOOP;
        
        -- Thêm vào bảng accounts
        INSERT INTO public.accounts (auth_id, email, provider, provider_id, created_at, last_sign_in)
        VALUES (p_auth_id, p_email, p_provider, p_provider_id, NOW(), NOW())
        RETURNING id INTO v_account_id;
        
        -- Thêm vào bảng users
        INSERT INTO public.users (account_id, username, full_name, avatar_url, created_at, updated_at)
        VALUES (v_account_id, v_username, p_full_name, p_avatar_url, NOW(), NOW())
        RETURNING id INTO v_user_id;
        
        v_result := jsonb_build_object(
            'success', true,
            'action', 'created',
            'account_id', v_account_id,
            'user_id', v_user_id,
            'username', v_username
        );
    END IF;
    
    RETURN v_result;
END;
$$;

-- 3. Function lấy thông tin người dùng đầy đủ (giữ nguyên vì đã là function)
DROP FUNCTION IF EXISTS get_user_details;

CREATE OR REPLACE FUNCTION get_user_details(p_auth_id UUID)
RETURNS TABLE (
    user_id UUID,
    account_id UUID,
    email TEXT,
    username TEXT,
    full_name TEXT,
    avatar_url TEXT,
    is_verified BOOLEAN,
    is_expert BOOLEAN,
    role TEXT,
    skin_type TEXT,
    expert_id UUID,
    expert_title TEXT,
    expert_specialty TEXT,
    cart_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        u.account_id,
        a.email,
        u.username,
        u.full_name,
        u.avatar_url,
        u.is_verified,
        u.is_expert,
        u.role,
        u.skin_type,
        e.id AS expert_id,
        e.title AS expert_title,
        e.specialty AS expert_specialty,
        COALESCE((SELECT COUNT(*) FROM public.cart_items WHERE cart_items.user_id = u.id), 0) AS cart_count
    FROM 
        public.accounts a
    JOIN 
        public.users u ON a.id = u.account_id
    LEFT JOIN 
        public.experts e ON u.id = e.user_id
    WHERE 
        a.auth_id = p_auth_id;
END;
$$;

-- 4. Function cập nhật thông tin profile
CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id UUID,
    p_username TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_skin_type TEXT DEFAULT NULL,
    p_date_of_birth DATE DEFAULT NULL,
    p_skin_concerns TEXT[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE public.users
    SET
        username = COALESCE(p_username, username),
        full_name = COALESCE(p_full_name, full_name),
        avatar_url = COALESCE(p_avatar_url, avatar_url),
        bio = COALESCE(p_bio, bio),
        skin_type = COALESCE(p_skin_type, skin_type),
        date_of_birth = COALESCE(p_date_of_birth, date_of_birth),
        skin_concerns = COALESCE(p_skin_concerns, skin_concerns),
        updated_at = NOW()
    WHERE
        id = p_user_id;
    
    v_result := jsonb_build_object(
        'success', true,
        'user_id', p_user_id,
        'updated_at', NOW()
    );
    
    RETURN v_result;
END;
$$;

-- 5. Function để thêm bài đăng (chuyển từ procedure thành function)
CREATE OR REPLACE FUNCTION add_post(
    p_user_id UUID,
    p_title TEXT DEFAULT NULL,
    p_content TEXT DEFAULT '',
    p_type TEXT DEFAULT 'user_question',
    p_images TEXT[] DEFAULT NULL,
    p_hashtags TEXT[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_expert_id UUID;
    v_is_expert BOOLEAN;
    v_post_id UUID;
    v_result JSONB;
BEGIN
    -- Check if the user is an expert
    SELECT is_expert INTO v_is_expert FROM public.users WHERE id = p_user_id;
    
    -- Get expert_id if the user is an expert
    IF v_is_expert THEN
        SELECT id INTO v_expert_id FROM public.experts WHERE user_id = p_user_id;
    END IF;
    
    -- Insert the new post
    INSERT INTO public.posts (
        user_id,
        expert_id,
        title,
        content,
        type,
        images,
        hashtags,
        created_at,
        updated_at
    )
    VALUES (
        p_user_id,
        v_expert_id,
        p_title,
        p_content,
        p_type,
        p_images,
        p_hashtags,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_post_id;
    
    -- Update expert's post count if applicable
    IF v_is_expert AND v_expert_id IS NOT NULL THEN
        UPDATE public.experts
        SET posts = posts + 1
        WHERE id = v_expert_id;
    END IF;
    
    v_result := jsonb_build_object(
        'success', true,
        'post_id', v_post_id,
        'is_expert_post', v_is_expert,
        'created_at', NOW()
    );
    
    RETURN v_result;
END;
$$;

-- 6. Function đánh giá sản phẩm
CREATE OR REPLACE FUNCTION add_product_review(
    p_user_id UUID,
    p_product_id UUID,
    p_rating INT,
    p_review TEXT DEFAULT NULL,
    p_images TEXT[] DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_review_exists BOOLEAN;
    v_review_id UUID;
    v_result JSONB;
    v_action TEXT;
BEGIN
    -- Kiểm tra người dùng đã đánh giá sản phẩm này chưa
    SELECT EXISTS(
        SELECT 1 FROM public.product_reviews
        WHERE user_id = p_user_id AND product_id = p_product_id
    ) INTO v_review_exists;
    
    IF v_review_exists THEN
        -- Cập nhật đánh giá hiện có
        UPDATE public.product_reviews
        SET
            rating = p_rating,
            review = COALESCE(p_review, review),
            images = COALESCE(p_images, images),
            updated_at = NOW()
        WHERE
            user_id = p_user_id AND product_id = p_product_id
        RETURNING id INTO v_review_id;
        
        v_action := 'updated';
    ELSE
        -- Thêm đánh giá mới
        INSERT INTO public.product_reviews (
            user_id,
            product_id,
            rating,
            review,
            images,
            created_at,
            updated_at
        )
        VALUES (
            p_user_id,
            p_product_id,
            p_rating,
            p_review,
            p_images,
            NOW(),
            NOW()
        )
        RETURNING id INTO v_review_id;
        
        -- Cập nhật số lượng đánh giá
        UPDATE public.products
        SET reviews_count = reviews_count + 1
        WHERE id = p_product_id;
        
        v_action := 'created';
    END IF;
    
    -- Cập nhật điểm đánh giá trung bình
    UPDATE public.products
    SET rating = (
        SELECT AVG(rating)::DECIMAL(3,1)
        FROM public.product_reviews
        WHERE product_id = p_product_id
    )
    WHERE id = p_product_id;
    
    v_result := jsonb_build_object(
        'success', true,
        'action', v_action,
        'review_id', v_review_id,
        'product_id', p_product_id,
        'rating', p_rating
    );
    
    RETURN v_result;
END;
$$;

-- 7. Function tạo đơn hàng
CREATE OR REPLACE FUNCTION create_order(
    p_user_id UUID,
    p_shipping_fee DECIMAL DEFAULT 0,
    p_shipping_method TEXT DEFAULT 'standard',
    p_payment_method TEXT DEFAULT 'cod',
    p_shipping_address JSONB DEFAULT '{}'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_price DECIMAL(10,2) := 0;
    v_cart_item RECORD;
    v_order_id UUID;
    v_result JSONB;
    v_items_count INT := 0;
BEGIN
    -- Check for empty cart
    IF NOT EXISTS (SELECT 1 FROM public.cart_items WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'Cart is empty';
    END IF;
    
    -- Calculate total price
    SELECT COALESCE(SUM(p.price * ci.quantity), 0) INTO v_total_price
    FROM public.cart_items ci
    JOIN public.products p ON ci.product_id = p.id
    WHERE ci.user_id = p_user_id;
    
    -- Create the order
    INSERT INTO public.orders (
        user_id,
        status,
        total_price,
        shipping_fee,
        shipping_method,
        payment_method,
        shipping_address,
        created_at,
        updated_at
    )
    VALUES (
        p_user_id,
        'pending',
        v_total_price,
        p_shipping_fee,
        p_shipping_method,
        p_payment_method,
        p_shipping_address,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_order_id;
    
    -- Add order items from cart
    FOR v_cart_item IN 
        SELECT 
            ci.product_id, 
            p.name AS product_name, 
            COALESCE(p.discount_price, p.price) AS product_price, 
            ci.quantity
        FROM public.cart_items ci
        JOIN public.products p ON ci.product_id = p.id
        WHERE ci.user_id = p_user_id
    LOOP
        INSERT INTO public.order_items (
            order_id,
            product_id,
            product_name,
            product_price,
            quantity,
            created_at
        )
        VALUES (
            v_order_id,
            v_cart_item.product_id,
            v_cart_item.product_name,
            v_cart_item.product_price,
            v_cart_item.quantity,
            NOW()
        );
        
        -- Update product stock
        UPDATE public.products
        SET stock_quantity = stock_quantity - v_cart_item.quantity
        WHERE id = v_cart_item.product_id;
        
        v_items_count := v_items_count + 1;
    END LOOP;
    
    -- Clear the user's cart
    DELETE FROM public.cart_items WHERE user_id = p_user_id;
    
    v_result := jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'total_price', v_total_price,
        'shipping_fee', p_shipping_fee,
        'items_count', v_items_count,
        'created_at', NOW()
    );
    
    RETURN v_result;
END;
$$;

-- Cập nhật bảng OTP Verification (xác thực OTP) với một constraint duy nhất
DROP TABLE IF EXISTS public.otp_verifications;

CREATE TABLE public.otp_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id) -- Đảm bảo mỗi user chỉ có một mã OTP đang hoạt động
);

-- Indexes cho bảng otp_verifications
CREATE INDEX idx_otp_verifications_user_id ON public.otp_verifications(user_id);
CREATE INDEX idx_otp_verifications_email ON public.otp_verifications(email);
CREATE INDEX idx_otp_verifications_otp_code ON public.otp_verifications(otp_code);
CREATE INDEX idx_otp_verifications_expires_at ON public.otp_verifications(expires_at);

-- Function để xác thực OTP
CREATE OR REPLACE FUNCTION verify_otp(
    p_user_id UUID,
    p_otp_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_valid BOOLEAN := FALSE;
    v_result JSONB;
BEGIN
    -- Kiểm tra xem OTP có hợp lệ không
    SELECT EXISTS(
        SELECT 1 FROM public.otp_verifications
        WHERE user_id = p_user_id
        AND otp_code = p_otp_code
        AND is_verified = FALSE
        AND expires_at > NOW()
    ) INTO v_is_valid;
    
    IF v_is_valid THEN
        -- Cập nhật trạng thái xác thực
        UPDATE public.otp_verifications
        SET is_verified = TRUE, updated_at = NOW()
        WHERE user_id = p_user_id AND otp_code = p_otp_code;
        
        -- Cập nhật trạng thái người dùng đã xác thực
        UPDATE public.users
        SET is_verified = TRUE, verification_date = NOW()
        WHERE id = p_user_id;
        
        v_result := jsonb_build_object(
            'success', true,
            'message', 'OTP verification successful'
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Invalid or expired OTP code'
        );
    END IF;
    
    RETURN v_result;
END;
$$;

-- Function để gửi lại OTP
CREATE OR REPLACE FUNCTION resend_otp(
    p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_email TEXT;
    v_otp_code TEXT;
    v_result JSONB;
BEGIN
    -- Lấy email người dùng
    SELECT a.email INTO v_email
    FROM public.users u
    JOIN public.accounts a ON u.account_id = a.id
    WHERE u.id = p_user_id;
    
    IF v_email IS NULL THEN
        v_result := jsonb_build_object(
            'success', false,
            'message', 'User not found'
        );
        RETURN v_result;
    END IF;
    
    -- Tạo mã OTP mới (6 chữ số ngẫu nhiên)
    v_otp_code := floor(random() * 900000 + 100000)::text;
    
    -- Cập nhật bản ghi OTP hiện tại hoặc tạo mới nếu không tồn tại
    UPDATE public.otp_verifications
    SET 
        otp_code = v_otp_code,
        is_verified = FALSE,
        expires_at = NOW() + INTERVAL '3 minutes',
        updated_at = NOW()
    WHERE user_id = p_user_id;
    
    -- Kiểm tra xem bản ghi có được cập nhật không
    IF NOT FOUND THEN
        -- Nếu không tìm thấy bản ghi để cập nhật, thêm mới
        INSERT INTO public.otp_verifications (
            user_id,
            email,
            otp_code,
            expires_at,
            created_at,
            updated_at
        )
        VALUES (
            p_user_id,
            v_email,
            v_otp_code,
            NOW() + INTERVAL '3 minutes',
            NOW(),
            NOW()
        );
    END IF;
    
    v_result := jsonb_build_object(
        'success', true,
        'otp_code', v_otp_code,
        'message', 'OTP resent successfully'
    );
    
    RETURN v_result;
END;
$$;

-- Cấp quyền cho các function để có thể gọi từ client
GRANT EXECUTE ON FUNCTION register_user TO anon, authenticated;
GRANT EXECUTE ON FUNCTION handle_login TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_details TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_user_profile TO authenticated;
GRANT EXECUTE ON FUNCTION add_post TO authenticated;
GRANT EXECUTE ON FUNCTION add_product_review TO authenticated;
GRANT EXECUTE ON FUNCTION create_order TO authenticated;
GRANT EXECUTE ON FUNCTION verify_otp TO anon, authenticated;
GRANT EXECUTE ON FUNCTION resend_otp TO anon, authenticated; 