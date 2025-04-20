# skin_shine

A new Flutter project.
-- Bảng Accounts (quản lý đăng nhập)
CREATE TABLE public.accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    provider TEXT NOT NULL DEFAULT 'email' CHECK (provider IN ('email', 'google', 'facebook', 'apple')),
    provider_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_sign_in TIMESTAMPTZ,
    UNIQUE (provider, provider_id),
    UNIQUE (email, provider)
);

-- Indexes cho bảng accounts
CREATE INDEX idx_accounts_auth_id ON public.accounts(auth_id);
CREATE INDEX idx_accounts_email ON public.accounts(email);
CREATE INDEX idx_accounts_provider ON public.accounts(provider);

-- Bảng Users (thông tin người dùng)
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMPTZ,
    skin_type TEXT,
    date_of_birth DATE,
    skin_concerns TEXT[],
    notification_preferences JSONB DEFAULT '{}'::JSONB,
    is_expert BOOLEAN DEFAULT FALSE,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng users
CREATE INDEX idx_users_account_id ON public.users(account_id);
CREATE INDEX idx_users_username ON public.users(username);
CREATE INDEX idx_users_is_verified ON public.users(is_verified);
CREATE INDEX idx_users_is_expert ON public.users(is_expert);
CREATE INDEX idx_users_skin_type ON public.users(skin_type);

-- Bảng Experts (chuyên gia da liễu)
CREATE TABLE public.experts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    education TEXT,
    specialty TEXT,
    certifications TEXT[],
    is_online BOOLEAN DEFAULT FALSE,
    followers INT DEFAULT 0,
    posts INT DEFAULT 0,
    reviews INT DEFAULT 0,
    rating DECIMAL(3,1) DEFAULT 5.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng experts
CREATE INDEX idx_experts_user_id ON public.experts(user_id);
CREATE INDEX idx_experts_rating ON public.experts(rating);
CREATE INDEX idx_experts_specialty ON public.experts(specialty);

-- Bảng theo dõi chuyên gia
CREATE TABLE public.expert_followers (
    expert_id UUID REFERENCES public.experts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (expert_id, user_id)
);

-- Bảng Posts (bài đăng)
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    expert_id UUID REFERENCES public.experts(id) ON DELETE SET NULL,
    title TEXT,
    content TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('user_question', 'expert_advice', 'before_after')),
    images TEXT[], -- Mảng URL hình ảnh từ Storage
    likes INT DEFAULT 0,
    comments INT DEFAULT 0,
    shares INT DEFAULT 0,
    hashtags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng posts
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_posts_expert_id ON public.posts(expert_id);
CREATE INDEX idx_posts_type ON public.posts(type);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX idx_posts_hashtags ON public.posts USING GIN (hashtags);

-- Bảng Comments (bình luận)
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    expert_id UUID REFERENCES public.experts(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    likes INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng comments
CREATE INDEX idx_comments_post_id ON public.comments(post_id);
CREATE INDEX idx_comments_user_id ON public.comments(user_id);
CREATE INDEX idx_comments_created_at ON public.comments(created_at DESC);

-- Bảng Likes (lượt thích)
CREATE TABLE public.likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    -- Đảm bảo một trong post_id hoặc comment_id phải có giá trị
    CONSTRAINT either_post_or_comment CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL) OR
        (post_id IS NULL AND comment_id IS NOT NULL)
    ),
    -- Đảm bảo mỗi người dùng chỉ có thể thích mỗi bài đăng/bình luận một lần
    CONSTRAINT unique_post_like UNIQUE (user_id, post_id),
    CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id)
);

-- Indexes cho bảng likes
CREATE INDEX idx_likes_user_id ON public.likes(user_id);
CREATE INDEX idx_likes_post_id ON public.likes(post_id);
CREATE INDEX idx_likes_comment_id ON public.likes(comment_id);

-- Bảng Products (sản phẩm)
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    discount_price DECIMAL(10,2),
    category TEXT,
    brand TEXT,
    image_url TEXT,
    image_urls TEXT[],
    rating DECIMAL(3,1) DEFAULT 0.0,
    reviews_count INT DEFAULT 0,
    stock_quantity INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    skin_types TEXT[],
    ingredients TEXT[],
    benefits TEXT[],
    how_to_use TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng products
CREATE INDEX idx_products_category ON public.products(category);
CREATE INDEX idx_products_brand ON public.products(brand);
CREATE INDEX idx_products_rating ON public.products(rating DESC);
CREATE INDEX idx_products_price ON public.products(price);
CREATE INDEX idx_products_is_featured ON public.products(is_featured);
CREATE INDEX idx_products_skin_types ON public.products USING GIN (skin_types);

-- Bảng Product Reviews (đánh giá sản phẩm)
CREATE TABLE public.product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    images TEXT[],
    likes INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng product_reviews
CREATE INDEX idx_product_reviews_product_id ON public.product_reviews(product_id);
CREATE INDEX idx_product_reviews_user_id ON public.product_reviews(user_id);
CREATE INDEX idx_product_reviews_rating ON public.product_reviews(rating);

-- Bảng Cart Items (giỏ hàng)
CREATE TABLE public.cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_cart_item UNIQUE (user_id, product_id)
);

-- Indexes cho bảng cart_items
CREATE INDEX idx_cart_items_user_id ON public.cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON public.cart_items(product_id);

-- Bảng Orders (đơn hàng)
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total_price DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_method TEXT,
    payment_method TEXT,
    shipping_address JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng orders
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);

-- Bảng Order Items (chi tiết đơn hàng)
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng order_items
CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON public.order_items(product_id);

-- Bảng Skin Analysis (phân tích da)
CREATE TABLE public.skin_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    score DECIMAL(3,1),
    concerns JSONB,
    recommendations JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng skin_analyses
CREATE INDEX idx_skin_analyses_user_id ON public.skin_analyses(user_id);
CREATE INDEX idx_skin_analyses_created_at ON public.skin_analyses(created_at DESC);

-- Bảng Skin Progress (tiến trình da)
CREATE TABLE public.skin_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    score DECIMAL(3,1),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng skin_progress
CREATE INDEX idx_skin_progress_user_id ON public.skin_progress(user_id);
CREATE INDEX idx_skin_progress_created_at ON public.skin_progress(created_at DESC);

-- Bảng Consultations (cuộc tư vấn)
CREATE TABLE public.consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    expert_id UUID NOT NULL REFERENCES public.experts(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    scheduled_time TIMESTAMPTZ,
    duration INT, -- Thời lượng tính bằng phút
    concerns TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng consultations
CREATE INDEX idx_consultations_user_id ON public.consultations(user_id);
CREATE INDEX idx_consultations_expert_id ON public.consultations(expert_id);
CREATE INDEX idx_consultations_status ON public.consultations(status);
CREATE INDEX idx_consultations_scheduled_time ON public.consultations(scheduled_time);

-- Bảng Messages (tin nhắn)
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'video', 'document')),
    media_url TEXT,
    media_thumb TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes cho bảng messages
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON public.messages(receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_conversation ON public.messages((
    LEAST(sender_id, receiver_id),
    GREATEST(sender_id, receiver_id)
));


--------------------------------------------------


-- 1. Procedure xử lý đăng ký
CREATE OR REPLACE PROCEDURE register_user(
    p_auth_id UUID,
    p_email TEXT,
    p_provider TEXT DEFAULT 'email',
    p_provider_id TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_username TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id UUID;
    v_username TEXT;
BEGIN
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
    VALUES (v_account_id, v_username, p_full_name, p_avatar_url, NOW(), NOW());
    
    COMMIT;
END;
$$;

-- 2. Procedure xử lý đăng nhập
CREATE OR REPLACE PROCEDURE handle_login(
    p_auth_id UUID,
    p_email TEXT,
    p_provider TEXT,
    p_provider_id TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id UUID;
    v_account_exists BOOLEAN;
    v_email_exists BOOLEAN;
    v_username TEXT;
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
        WHERE auth_id = p_auth_id;
        
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
        VALUES (v_account_id, v_username, p_full_name, p_avatar_url, NOW(), NOW());
    END IF;
    
    COMMIT;
END;
$$;

-- 3. Procedure lấy thông tin người dùng đầy đủ
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
        COALESCE((SELECT COUNT(*) FROM public.cart_items WHERE user_id = u.id), 0) AS cart_count
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

-- 4. Procedure cập nhật thông tin profile
CREATE OR REPLACE PROCEDURE update_user_profile(
    p_user_id UUID,
    p_username TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_skin_type TEXT DEFAULT NULL,
    p_date_of_birth DATE DEFAULT NULL,
    p_skin_concerns TEXT[] DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
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
END;
$$;

-- 5. Procedure lấy feed bài đăng kèm thông tin liên quan
CREATE OR REPLACE FUNCTION get_posts_feed(
    p_user_id UUID,
    p_limit INT DEFAULT 10,
    p_offset INT DEFAULT 0,
    p_post_type TEXT DEFAULT NULL
)
RETURNS TABLE (
    post_id UUID,
    post_title TEXT,
    post_content TEXT,
    post_type TEXT,
    post_images TEXT[],
    post_likes INT,
    post_comments INT,
    post_created_at TIMESTAMPTZ,
    author_id UUID,
    author_username TEXT,
    author_full_name TEXT,
    author_avatar_url TEXT,
    author_is_verified BOOLEAN,
    is_expert BOOLEAN,
    expert_id UUID,
    expert_title TEXT,
    user_has_liked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS post_id,
        p.title AS post_title,
        p.content AS post_content,
        p.type AS post_type,
        p.images AS post_images,
        p.likes AS post_likes,
        p.comments AS post_comments,
        p.created_at AS post_created_at,
        u.id AS author_id,
        u.username AS author_username,
        u.full_name AS author_full_name,
        u.avatar_url AS author_avatar_url,
        u.is_verified AS author_is_verified,
        u.is_expert AS is_expert,
        e.id AS expert_id,
        e.title AS expert_title,
        EXISTS(SELECT 1 FROM public.likes WHERE user_id = p_user_id AND post_id = p.id) AS user_has_liked
    FROM 
        public.posts p
    JOIN 
        public.users u ON p.user_id = u.id
    LEFT JOIN 
        public.experts e ON p.expert_id = e.id
    WHERE
        (p_post_type IS NULL OR p.type = p_post_type)
    ORDER BY 
        p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;
-- 6. Procedure thêm bài đăng mới - đã sửa
CREATE OR REPLACE PROCEDURE add_post(
    p_user_id UUID,
    OUT post_id UUID,
    p_title TEXT DEFAULT NULL,
    p_content TEXT DEFAULT '',
    p_type TEXT DEFAULT 'user_question',
    p_images TEXT[] DEFAULT NULL,
    p_hashtags TEXT[] DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_expert_id UUID;
    v_is_expert BOOLEAN;
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
    RETURNING id INTO post_id;
    
    -- Update expert's post count if applicable
    IF v_is_expert AND v_expert_id IS NOT NULL THEN
        UPDATE public.experts
        SET posts = posts + 1
        WHERE id = v_expert_id;
    END IF;
END;
$$;

-- 7. Procedure xử lý đánh giá sản phẩm
CREATE OR REPLACE PROCEDURE add_product_review(
    p_user_id UUID,
    p_product_id UUID,
    p_rating INT,
    p_review TEXT DEFAULT NULL,
    p_images TEXT[] DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_review_exists BOOLEAN;
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
            user_id = p_user_id AND product_id = p_product_id;
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
        );
        
        -- Cập nhật số lượng đánh giá
        UPDATE public.products
        SET reviews_count = reviews_count + 1
        WHERE id = p_product_id;
    END IF;
    
    -- Cập nhật điểm đánh giá trung bình
    UPDATE public.products
    SET rating = (
        SELECT AVG(rating)::DECIMAL(3,1)
        FROM public.product_reviews
        WHERE product_id = p_product_id
    )
    WHERE id = p_product_id;
END;
$$;

-- 8. Procedure tạo đơn hàng mới - đã sửa
CREATE OR REPLACE PROCEDURE create_order(
    p_user_id UUID,
    OUT order_id UUID,
    p_shipping_fee DECIMAL DEFAULT 0,
    p_shipping_method TEXT DEFAULT 'standard',
    p_payment_method TEXT DEFAULT 'cod',
    p_shipping_address JSONB DEFAULT '{}'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_price DECIMAL(10,2) := 0;
    v_cart_item RECORD;
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
    RETURNING id INTO order_id;
    
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
            order_id,
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
    END LOOP;
    
    -- Clear the user's cart
    DELETE FROM public.cart_items WHERE user_id = p_user_id;
END;
$$;


-----------------------------------------------

-- 1. Trigger cập nhật số lượng likes cho post
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.post_id IS NOT NULL THEN
        UPDATE public.posts SET likes = likes + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' AND OLD.post_id IS NOT NULL THEN
        UPDATE public.posts SET likes = GREATEST(0, likes - 1) WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_post_likes_count
AFTER INSERT OR DELETE ON public.likes
FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- 2. Trigger cập nhật số lượng comments cho post
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.posts SET comments = comments + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.posts SET comments = GREATEST(0, comments - 1) WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_post_comments_count
AFTER INSERT OR DELETE ON public.comments
FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- 3. Trigger cập nhật số lượng likes cho comment
CREATE OR REPLACE FUNCTION update_comment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.comment_id IS NOT NULL THEN
        UPDATE public.comments SET likes = likes + 1 WHERE id = NEW.comment_id;
    ELSIF TG_OP = 'DELETE' AND OLD.comment_id IS NOT NULL THEN
        UPDATE public.comments SET likes = GREATEST(0, likes - 1) WHERE id = OLD.comment_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_comment_likes_count
AFTER INSERT OR DELETE ON public.likes
FOR EACH ROW EXECUTE FUNCTION update_comment_likes_count();

-- 4. Trigger cập nhật số lượng followers cho expert
CREATE OR REPLACE FUNCTION update_expert_followers_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.experts SET followers = followers + 1 WHERE id = NEW.expert_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.experts SET followers = GREATEST(0, followers - 1) WHERE id = OLD.expert_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_expert_followers_count
AFTER INSERT OR DELETE ON public.expert_followers
FOR EACH ROW EXECUTE FUNCTION update_expert_followers_count();

-- 5. Trigger tự động cập nhật trường updated_at
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Áp dụng cho tất cả bảng có trường updated_at
CREATE TRIGGER trigger_update_users_timestamp
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_posts_timestamp
BEFORE UPDATE ON public.posts
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_comments_timestamp
BEFORE UPDATE ON public.comments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_products_timestamp
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_product_reviews_timestamp
BEFORE UPDATE ON public.product_reviews
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_orders_timestamp
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_experts_timestamp
BEFORE UPDATE ON public.experts
FOR EACH ROW EXECUTE FUNCTION update_timestamp();