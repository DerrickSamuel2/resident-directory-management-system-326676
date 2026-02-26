# Resident Directory Database — Schema & Seed (PostgreSQL)

This database schema and seed data were applied **directly** to PostgreSQL using the connection command in `db_connection.txt`, executing **one SQL statement at a time** via:

```bash
$(cat db_connection.txt) -c "SQL_STATEMENT"
```

> Connection (from `db_connection.txt`):
>
> `psql postgresql://appuser:dbuser123@localhost:5000/myapp`

---

## Extensions

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

`pgcrypto` is used for:
- `gen_random_uuid()` default IDs
- `crypt(..., gen_salt('bf'))` password hashing for seed users

---

## Tables

### roles

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS roles (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL UNIQUE, description TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
```

### users

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS users (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE, last_login_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
```

### user_roles

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS user_roles (user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE, assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), PRIMARY KEY (user_id, role_id));"
```

### residents

Resident directory profile; optionally linked to a `users` account.

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS residents (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL, unit_number TEXT, building TEXT, phone TEXT, email TEXT, first_name TEXT NOT NULL, last_name TEXT NOT NULL, bio TEXT, profile_image_url TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
```

### resident_privacy_settings

Privacy settings for directory visibility and contact fields.

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS resident_privacy_settings (resident_id UUID PRIMARY KEY REFERENCES residents(id) ON DELETE CASCADE, show_email BOOLEAN NOT NULL DEFAULT FALSE, show_phone BOOLEAN NOT NULL DEFAULT FALSE, show_unit BOOLEAN NOT NULL DEFAULT TRUE, allow_messages BOOLEAN NOT NULL DEFAULT TRUE, directory_visible BOOLEAN NOT NULL DEFAULT TRUE, updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
```

### messages

In-app messaging (simple 1:1).

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS messages (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), sender_user_id UUID REFERENCES users(id) ON DELETE SET NULL, recipient_user_id UUID REFERENCES users(id) ON DELETE SET NULL, subject TEXT, body TEXT NOT NULL, sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), read_at TIMESTAMPTZ, is_deleted_by_sender BOOLEAN NOT NULL DEFAULT FALSE, is_deleted_by_recipient BOOLEAN NOT NULL DEFAULT FALSE);"
```

### notifications

Basic notifications for app events.

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS notifications (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID REFERENCES users(id) ON DELETE CASCADE, type TEXT NOT NULL, title TEXT, body TEXT, data JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), read_at TIMESTAMPTZ);"
```

### audit_logs

Audit trail of important actions.

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TABLE IF NOT EXISTS audit_logs (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL, action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id UUID, details JSONB NOT NULL DEFAULT '{}'::jsonb, ip_address INET, user_agent TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
```

---

## Indexes

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE INDEX IF NOT EXISTS idx_residents_name ON residents (last_name, first_name);"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE INDEX IF NOT EXISTS idx_messages_recipient_sent_at ON messages (recipient_user_id, sent_at DESC);"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE INDEX IF NOT EXISTS idx_notifications_user_created_at ON notifications (user_id, created_at DESC);"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs (entity_type, entity_id);"
```

---

## updated_at triggers (users, residents)

Trigger function (note the escaping for `$$` when run via shell):

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS \$\$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; \$\$ LANGUAGE plpgsql;"
```

Triggers:

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "DROP TRIGGER IF EXISTS trg_users_updated_at ON users;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();"

psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "DROP TRIGGER IF EXISTS trg_residents_updated_at ON residents;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE TRIGGER trg_residents_updated_at BEFORE UPDATE ON residents FOR EACH ROW EXECUTE FUNCTION set_updated_at();"
```

---

## Seed data

### Roles

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO roles (name, description) VALUES ('admin', 'Administrator with full access') ON CONFLICT (name) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO roles (name, description) VALUES ('resident', 'Standard resident user') ON CONFLICT (name) DO NOTHING;"
```

### Admin user

- Email: `admin@residentdir.local`
- Password: `admin123`

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO users (email, password_hash, full_name) VALUES ('admin@residentdir.local', crypt('admin123', gen_salt('bf')), 'System Admin') ON CONFLICT (email) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO user_roles (user_id, role_id) SELECT u.id, r.id FROM users u JOIN roles r ON r.name='admin' WHERE u.email='admin@residentdir.local' ON CONFLICT DO NOTHING;"
```

### Sample residents

All sample residents use password: `password123`

#### Alex Johnson

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO users (email, password_hash, full_name) VALUES ('alex.johnson@example.com', crypt('password123', gen_salt('bf')), 'Alex Johnson') ON CONFLICT (email) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO user_roles (user_id, role_id) SELECT u.id, r.id FROM users u JOIN roles r ON r.name='resident' WHERE u.email='alex.johnson@example.com' ON CONFLICT DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO residents (user_id, unit_number, building, phone, email, first_name, last_name, bio) SELECT u.id, '12B', 'North', '+1-555-0101', u.email, 'Alex', 'Johnson', 'Enjoys community gardening and board games.' FROM users u WHERE u.email='alex.johnson@example.com' ON CONFLICT (user_id) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO resident_privacy_settings (resident_id, show_email, show_phone, show_unit, allow_messages, directory_visible) SELECT r.id, TRUE, FALSE, TRUE, TRUE, TRUE FROM residents r JOIN users u ON r.user_id=u.id WHERE u.email='alex.johnson@example.com' ON CONFLICT (resident_id) DO NOTHING;"
```

#### Taylor Lee

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO users (email, password_hash, full_name) VALUES ('taylor.lee@example.com', crypt('password123', gen_salt('bf')), 'Taylor Lee') ON CONFLICT (email) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO user_roles (user_id, role_id) SELECT u.id, r.id FROM users u JOIN roles r ON r.name='resident' WHERE u.email='taylor.lee@example.com' ON CONFLICT DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO residents (user_id, unit_number, building, phone, email, first_name, last_name, bio) SELECT u.id, '7A', 'South', '+1-555-0102', u.email, 'Taylor', 'Lee', 'Remote worker; happy to help with tech questions.' FROM users u WHERE u.email='taylor.lee@example.com' ON CONFLICT (user_id) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO resident_privacy_settings (resident_id, show_email, show_phone, show_unit, allow_messages, directory_visible) SELECT r.id, FALSE, TRUE, TRUE, TRUE, TRUE FROM residents r JOIN users u ON r.user_id=u.id WHERE u.email='taylor.lee@example.com' ON CONFLICT (resident_id) DO NOTHING;"
```

#### Jamie Patel (messages disabled)

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO users (email, password_hash, full_name) VALUES ('jamie.patel@example.com', crypt('password123', gen_salt('bf')), 'Jamie Patel') ON CONFLICT (email) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO user_roles (user_id, role_id) SELECT u.id, r.id FROM users u JOIN roles r ON r.name='resident' WHERE u.email='jamie.patel@example.com' ON CONFLICT DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO residents (user_id, unit_number, building, phone, email, first_name, last_name, bio) SELECT u.id, '3C', 'East', '+1-555-0103', u.email, 'Jamie', 'Patel', 'Dog owner; loves morning walks.' FROM users u WHERE u.email='jamie.patel@example.com' ON CONFLICT (user_id) DO NOTHING;"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO resident_privacy_settings (resident_id, show_email, show_phone, show_unit, allow_messages, directory_visible) SELECT r.id, FALSE, FALSE, TRUE, FALSE, TRUE FROM residents r JOIN users u ON r.user_id=u.id WHERE u.email='jamie.patel@example.com' ON CONFLICT (resident_id) DO NOTHING;"
```

### Sample message + notification

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO messages (sender_user_id, recipient_user_id, subject, body) SELECT s.id, r.id, 'Welcome', 'Hi Taylor — welcome to the building! Let me know if you need anything.' FROM users s, users r WHERE s.email='alex.johnson@example.com' AND r.email='taylor.lee@example.com';"
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO notifications (user_id, type, title, body, data) SELECT u.id, 'message', 'New message', 'You have a new message from Alex Johnson.', jsonb_build_object('from', 'alex.johnson@example.com') FROM users u WHERE u.email='taylor.lee@example.com';"
```

### Seed audit log entry

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "INSERT INTO audit_logs (actor_user_id, action, entity_type, entity_id, details) SELECT u.id, 'SEED', 'users', u.id, jsonb_build_object('note','Initial admin seeded') FROM users u WHERE u.email='admin@residentdir.local';"
```

---

## Quick verification

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "SELECT 'roles' as table, count(*) as count FROM roles UNION ALL SELECT 'users', count(*) FROM users UNION ALL SELECT 'residents', count(*) FROM residents;"
```
