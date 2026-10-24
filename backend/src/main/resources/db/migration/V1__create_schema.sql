-- ═══════════════════════════════════════════════════════════════════════════
-- V1: Schema completo (16 tabelas)
--
-- O Flyway é a ÚNICA fonte de verdade do schema. O Hibernate roda com
-- ddl-auto=validate e apenas valida que o schema existe e bate com as
-- entidades — ele não cria nem altera nada.
--
-- Fonte de verdade: gerado a partir das entidades JPA (Hibernate ORM 7.4)
-- via pg_dump --schema-only, e portanto bate exatamente com o que o
-- Hibernate espera validar.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Usuários e perfis ────────────────────────────────────────────────────────

CREATE TABLE users (
    id uuid NOT NULL,
    active boolean NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email character varying(255) NOT NULL,
    must_change_password boolean DEFAULT false NOT NULL,
    name character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(255) NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT uk6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email),
    CONSTRAINT users_role_check CHECK (
        (role)::text = ANY ((ARRAY['CUSTOMER','MANAGER','PROFESSIONAL'])::text[])
    )
);

CREATE TABLE profiles (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    owner_id uuid NOT NULL,
    role character varying(30) NOT NULL,
    establishment_id uuid NOT NULL,
    CONSTRAINT profiles_pkey PRIMARY KEY (id),
    CONSTRAINT profiles_role_check CHECK (
        (role)::text = ANY ((ARRAY['GESTOR','PROFESSIONAL','RECEPTIONIST'])::text[])
    )
);

-- ── Estabelecimento ──────────────────────────────────────────────────────────

CREATE TABLE establishments (
    id uuid NOT NULL,
    active boolean NOT NULL,
    cep character varying(255),
    city character varying(255),
    complement character varying(255),
    neighborhood character varying(255),
    number character varying(255),
    state character varying(255),
    street character varying(255),
    business_type character varying(255),
    cnpj character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email character varying(255) NOT NULL,
    legal_name character varying(255) NOT NULL,
    logo_url character varying(255),
    name character varying(255) NOT NULL,
    owner_id uuid NOT NULL,
    phone character varying(255) NOT NULL,
    terms_accepted boolean NOT NULL,
    terms_accepted_at timestamp(6) without time zone,
    trial_end_date timestamp(6) without time zone NOT NULL,
    trial_start_date timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    whatsapp character varying(255),
    CONSTRAINT establishments_pkey PRIMARY KEY (id),
    CONSTRAINT uk67xxsiri6bja96p1owo1x9fjx UNIQUE (cnpj),
    CONSTRAINT ukdr6k8vj9mhkf3k3a5q1j5h9fk UNIQUE (email)
);

-- ── Profissionais e clientes ────────────────────────────────────────────────

CREATE TABLE professionals (
    id uuid NOT NULL,
    active boolean,
    commission numeric(5,2),
    cpf character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email character varying(255) NOT NULL,
    gender character varying(255),
    name character varying(255) NOT NULL,
    nickname character varying(255),
    password character varying(255),
    phone character varying(255),
    photo_url character varying(255),
    specialty character varying(100),
    updated_at timestamp(6) without time zone NOT NULL,
    establishment_id uuid NOT NULL,
    user_id uuid,
    CONSTRAINT professionals_pkey PRIMARY KEY (id),
    CONSTRAINT ukon2obvk23lp36dm7loa9bg8jb UNIQUE (cpf),
    CONSTRAINT ukr9p60nf406aly6o2o701fh7wa UNIQUE (user_id),
    CONSTRAINT fkso9fo2c212wlu3qnnbfgurb5u FOREIGN KEY (establishment_id)
        REFERENCES establishments (id),
    CONSTRAINT fkgkfsdbkwd8shxk9isiddv2n43 FOREIGN KEY (user_id)
        REFERENCES users (id)
);

CREATE TABLE clients (
    id uuid NOT NULL,
    active boolean,
    created_at timestamp(6) without time zone NOT NULL,
    date_of_birth date,
    email character varying(255),
    name character varying(255),
    notes character varying(255),
    phone character varying(255) NOT NULL,
    photo_url character varying(255),
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid,
    CONSTRAINT clients_pkey PRIMARY KEY (id),
    CONSTRAINT uksmrp6gi0tckq1w5rnd7boyowu UNIQUE (user_id),
    CONSTRAINT fktiuqdledq2lybrds2k3rfqrv4 FOREIGN KEY (user_id)
        REFERENCES users (id)
);

-- ── Catálogo: serviços e produtos ───────────────────────────────────────────

CREATE TABLE services (
    id uuid NOT NULL,
    active boolean NOT NULL,
    category character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    duration integer NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    establishment_id uuid NOT NULL,
    CONSTRAINT services_pkey PRIMARY KEY (id),
    CONSTRAINT fkss2obdlksrbsmc28pe4q7kq24 FOREIGN KEY (establishment_id)
        REFERENCES establishments (id)
);

CREATE TABLE products (
    id uuid NOT NULL,
    active boolean NOT NULL,
    category character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL,
    stock_quantity integer NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    establishment_id uuid NOT NULL,
    CONSTRAINT products_pkey PRIMARY KEY (id),
    CONSTRAINT fk99gib6u0rm71m4vr6qdfj33is FOREIGN KEY (establishment_id)
        REFERENCES establishments (id)
);

-- ── Agenda ──────────────────────────────────────────────────────────────────

CREATE TABLE working_hours (
    id uuid NOT NULL,
    active boolean NOT NULL,
    break_end time(0) without time zone,
    break_start time(0) without time zone,
    day_of_week character varying(15) NOT NULL,
    end_time time(0) without time zone NOT NULL,
    start_time time(0) without time zone NOT NULL,
    professional_id uuid NOT NULL,
    CONSTRAINT working_hours_pkey PRIMARY KEY (id),
    CONSTRAINT uk64g5k33ogecp1ka72822pyaoi UNIQUE (professional_id, day_of_week),
    CONSTRAINT working_hours_day_of_week_check CHECK (
        (day_of_week)::text = ANY (
            (ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'])::text[]
        )
    ),
    CONSTRAINT fknnvu8rfmv0pkj07bh1n484euo FOREIGN KEY (professional_id)
        REFERENCES professionals (id)
);

CREATE TABLE blocked_times (
    id uuid NOT NULL,
    created_date timestamp(6) without time zone NOT NULL,
    end_date_time timestamp(6) without time zone NOT NULL,
    reason character varying(255),
    start_date_time timestamp(6) without time zone NOT NULL,
    professional_id uuid NOT NULL,
    CONSTRAINT blocked_times_pkey PRIMARY KEY (id),
    CONSTRAINT fkgbkisf057gcww45sgr1c2kc4d FOREIGN KEY (professional_id)
        REFERENCES professionals (id)
);

CREATE TABLE appointments (
    id uuid NOT NULL,
    client_name_fallback character varying(255),
    client_phone_fallback character varying(255),
    created_at timestamp(6) without time zone NOT NULL,
    end_date_time timestamp(6) without time zone NOT NULL,
    google_eventid character varying(255),
    is_fit_in boolean NOT NULL,
    notes text,
    start_date_time timestamp(6) without time zone NOT NULL,
    status character varying(255),
    updated_at timestamp(6) without time zone NOT NULL,
    version bigint NOT NULL,
    client_id uuid,
    establishment_id uuid NOT NULL,
    professional_id uuid NOT NULL,
    service_id uuid NOT NULL,
    CONSTRAINT appointments_pkey PRIMARY KEY (id),
    CONSTRAINT appointments_status_check CHECK (
        (status)::text = ANY (
            (ARRAY['SCHEDULED','CONFIRMED','IN_PROGRESS','DONE','NO_SHOW','CANCELLED'])::text[]
        )
    ),
    CONSTRAINT fkfbl6cciquyyvv5s1e31qmflkb FOREIGN KEY (client_id)
        REFERENCES clients (id),
    CONSTRAINT fkp67um2dte8j9fqpqql9w2ln6l FOREIGN KEY (establishment_id)
        REFERENCES establishments (id),
    CONSTRAINT fk70r651dhvcob4dm4icn54of0y FOREIGN KEY (professional_id)
        REFERENCES professionals (id),
    CONSTRAINT fk5iltr7k9pows18hk8nc101vc1 FOREIGN KEY (service_id)
        REFERENCES services (id)
);

CREATE INDEX idx_appointment_professional_date
    ON appointments (professional_id, start_date_time);

-- ── Comandas (orders) ───────────────────────────────────────────────────────

CREATE TABLE orders (
    id uuid NOT NULL,
    closed_at timestamp(6) without time zone,
    closed_total_amount numeric(10,2),
    created_at timestamp(6) without time zone NOT NULL,
    discount_amount numeric(10,2) NOT NULL,
    payment_method character varying(255),
    status character varying(255) NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    appointment_id uuid NOT NULL,
    establishment_id uuid NOT NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (id),
    CONSTRAINT uk84femdlmmmf9gue90on3nd4fv UNIQUE (appointment_id),
    CONSTRAINT orders_payment_method_check CHECK (
        (payment_method)::text = ANY ((ARRAY['CASH','CREDIT_CARD','DEBIT_CARD','PIX'])::text[])
    ),
    CONSTRAINT orders_status_check CHECK (
        (status)::text = ANY ((ARRAY['OPEN','CLOSED','CANCELLED'])::text[])
    ),
    CONSTRAINT fkq1rj3q22xnpng1mg1ypawgjkp FOREIGN KEY (appointment_id)
        REFERENCES appointments (id),
    CONSTRAINT fk9w7m3yp1dtyu3j59ktgdut28t FOREIGN KEY (establishment_id)
        REFERENCES establishments (id)
);

CREATE TABLE orders_items (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    item_type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid,
    service_id uuid,
    CONSTRAINT orders_items_pkey PRIMARY KEY (id),
    CONSTRAINT orders_items_item_type_check CHECK (
        (item_type)::text = ANY ((ARRAY['SERVICE','PRODUCT'])::text[])
    ),
    CONSTRAINT fkij1wwgx6o198ubsx1oulpopem FOREIGN KEY (order_id)
        REFERENCES orders (id),
    CONSTRAINT fki7bwk7vkrcl9jeyqpso3fpnjk FOREIGN KEY (product_id)
        REFERENCES products (id),
    CONSTRAINT fk3krrqyhk2kspnj206qw7jkppv FOREIGN KEY (service_id)
        REFERENCES services (id)
);

-- ── Fichas técnicas ─────────────────────────────────────────────────────────

CREATE TABLE technical_sheets (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    observations text,
    updated_at timestamp(6) without time zone NOT NULL,
    client_id uuid NOT NULL,
    CONSTRAINT technical_sheets_pkey PRIMARY KEY (id),
    CONSTRAINT ukq87v4pu8urf4efjgy16kxpmj4 UNIQUE (client_id),
    CONSTRAINT fkq214qihyfaitoxlxydyfm8dq3 FOREIGN KEY (client_id)
        REFERENCES clients (id)
);

CREATE TABLE technical_sheet_entries (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    notes text,
    appointment_id uuid NOT NULL,
    professional_id uuid NOT NULL,
    technical_sheet_id uuid NOT NULL,
    CONSTRAINT technical_sheet_entries_pkey PRIMARY KEY (id),
    CONSTRAINT fkancn4xc42mvmextf41s20xgcq FOREIGN KEY (technical_sheet_id)
        REFERENCES technical_sheets (id),
    CONSTRAINT fkq6tpnekn4mrfvmlwvccouh9ft FOREIGN KEY (professional_id)
        REFERENCES professionals (id),
    CONSTRAINT fktru9fq61s053ueho07nw1xpcb FOREIGN KEY (appointment_id)
        REFERENCES appointments (id)
);

CREATE TABLE technical_sheet_photos (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    photo_url character varying(255) NOT NULL,
    entry_id uuid NOT NULL,
    CONSTRAINT technical_sheet_photos_pkey PRIMARY KEY (id),
    CONSTRAINT fkf0o199n4cngihu9llpqg3aywo FOREIGN KEY (entry_id)
        REFERENCES technical_sheet_entries (id)
);

-- ── Fotos (bytea — binário nativo do PostgreSQL) ────────────────────────────

CREATE TABLE photos (
    id uuid NOT NULL,
    caption character varying(500),
    content_type character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    data bytea NOT NULL,
    photo_type character varying(50),
    appointment_id uuid,
    client_id uuid,
    taken_by uuid,
    CONSTRAINT photos_pkey PRIMARY KEY (id),
    CONSTRAINT photos_photo_type_check CHECK (
        (photo_type)::text = ANY ((ARRAY['BEFORE','AFTER','OTHER'])::text[])
    ),
    CONSTRAINT fk62h6mw0g39u869u6kpp80mcg9 FOREIGN KEY (appointment_id)
        REFERENCES appointments (id),
    CONSTRAINT fkj0q52km5u6h8qsxfdwgam2pjf FOREIGN KEY (client_id)
        REFERENCES clients (id),
    CONSTRAINT fkfrfs8oyb8mvqvqfcdrjjbvbf0 FOREIGN KEY (taken_by)
        REFERENCES users (id)
);

CREATE INDEX idx_photos_appointment ON photos (appointment_id);
CREATE INDEX idx_photos_client ON photos (client_id);
