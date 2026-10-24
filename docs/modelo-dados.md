# 🗄️ Modelo de Dados — NextCalendar

Diagrama Entidade-Relacionamento (DER) gerado a partir das entidades JPA do backend.

> **Dica:** O GitHub renderiza este diagrama automaticamente. Para exportar como imagem PNG, abra no [Mermaid Live Editor](https://mermaid.live) e faça o download.

```mermaid
erDiagram
    users {
        UUID id PK
        string name
        string email UK
        string password_hash
        string role
        boolean active
        boolean must_change_password
        datetime created_at
        datetime updated_at
    }

    establishments {
        UUID id PK
        UUID owner_id FK
        string legal_name
        string name
        string cnpj UK
        string phone
        string whatsapp
        string email UK
        string business_type
        string logo_url
        string address_street
        string address_number
        string address_city
        string address_state
        string address_zip
        datetime trial_start_date
        datetime trial_end_date
        boolean terms_accepted
        datetime terms_accepted_at
        boolean active
        datetime created_at
        datetime updated_at
    }

    professionals {
        UUID id PK
        UUID user_id FK
        UUID establishment_id FK
        string name
        string nickname
        string specialty
        string cpf UK
        string email
        string phone
        string gender
        string photo_url
        decimal commission
        boolean active
        datetime created_at
        datetime updated_at
    }

    clients {
        UUID id PK
        UUID user_id FK
        string name
        string phone
        string email
        date date_of_birth
        string photo_url
        text notes
        boolean active
        datetime created_at
        datetime updated_at
    }

    services {
        UUID id PK
        UUID establishment_id FK
        string name
        decimal price
        int duration
        string category
        boolean active
        datetime created_at
        datetime updated_at
    }

    products {
        UUID id PK
        UUID establishment_id FK
        string name
        string category
        decimal price
        int stock_quantity
        boolean active
        datetime created_at
        datetime updated_at
    }

    professional_services {
        UUID professional_id PK_FK
        UUID service_id PK_FK
    }

    appointments {
        UUID id PK
        UUID establishment_id FK
        UUID professional_id FK
        UUID client_id FK
        UUID service_id FK
        datetime start_date_time
        datetime end_date_time
        string status
        string client_name_fallback
        string client_phone_fallback
        boolean is_fit_in
        text notes
        string google_event_id
        bigint version
        datetime created_at
        datetime updated_at
    }

    orders {
        UUID id PK
        UUID establishment_id FK
        UUID appointment_id FK
        string status
        string payment_method
        decimal discount_amount
        decimal closed_total_amount
        datetime created_at
        datetime updated_at
        datetime closed_at
    }

    orders_items {
        UUID id PK
        UUID order_id FK
        UUID service_id FK
        UUID product_id FK
        string item_type
        string name
        decimal unit_price
        int quantity
        datetime created_at
    }

    technical_sheets {
        UUID id PK
        UUID client_id FK
        text observations
        datetime created_at
        datetime updated_at
    }

    technical_sheet_entries {
        UUID id PK
        UUID technical_sheet_id FK
        UUID appointment_id FK
        UUID professional_id FK
        text notes
        datetime created_at
    }

    technical_sheet_photos {
        UUID id PK
        UUID entry_id FK
        string url
        string caption
        datetime created_at
    }

    photos {
        UUID id PK
        UUID appointment_id FK
        UUID client_id FK
        UUID taken_by FK
        string photo_type
        string caption
        bytes data
        string content_type
        datetime created_at
    }

    working_hours {
        UUID id PK
        UUID professional_id FK
        string day_of_week
        time start_time
        time end_time
        time break_start
        time break_end
        boolean active
    }

    blocked_times {
        UUID id PK
        UUID professional_id FK
        datetime start_date_time
        datetime end_date_time
        string reason
        datetime created_date
    }

    %% Relacionamentos
    users ||--o{ establishments : "e dono de"
    users ||--o| professionals  : "possui perfil"
    users ||--o| clients        : "possui perfil"

    establishments ||--o{ professionals        : "possui"
    establishments ||--o{ services             : "oferece"
    establishments ||--o{ products             : "estoca"
    establishments ||--o{ appointments         : "recebe"
    establishments ||--o{ orders               : "gera"

    professionals ||--o{ professional_services  : "realiza"
    services      ||--o{ professional_services  : "e feito por"

    professionals ||--o{ appointments   : "atende"
    clients       ||--o{ appointments   : "agenda"
    services      ||--o{ appointments   : "e agendado em"

    appointments ||--|| orders                   : "gera comanda"
    orders       ||--o{ orders_items             : "contem"
    services     ||--o{ orders_items             : "referenciado em"
    products     ||--o{ orders_items             : "referenciado em"

    clients      ||--|| technical_sheets         : "possui ficha"
    technical_sheets ||--o{ technical_sheet_entries : "tem registros"
    technical_sheet_entries ||--o{ technical_sheet_photos : "tem fotos"
    appointments ||--o{ technical_sheet_entries  : "origina entrada"
    professionals ||--o{ technical_sheet_entries : "registra"

    appointments ||--o{ photos    : "tem fotos"
    clients      ||--o{ photos    : "tem fotos"
    users        ||--o{ photos    : "fotografa"

    professionals ||--o{ working_hours  : "tem horarios"
    professionals ||--o{ blocked_times  : "tem bloqueios"
```
