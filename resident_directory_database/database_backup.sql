--
-- PostgreSQL database dump
--

\restrict Lh7txhljfPhmkH9dU8dXyPigjJAMoMu3f4jiSLEoCcqYgosEjECPquQe3fRGkbb

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO postgres;

\unrestrict Lh7txhljfPhmkH9dU8dXyPigjJAMoMu3f4jiSLEoCcqYgosEjECPquQe3fRGkbb
\connect myapp
\restrict Lh7txhljfPhmkH9dU8dXyPigjJAMoMu3f4jiSLEoCcqYgosEjECPquQe3fRGkbb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: appuser
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;


ALTER FUNCTION public.set_updated_at() OWNER TO appuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    actor_user_id uuid,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO appuser;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sender_user_id uuid,
    recipient_user_id uuid,
    subject text,
    body text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone,
    is_deleted_by_sender boolean DEFAULT false NOT NULL,
    is_deleted_by_recipient boolean DEFAULT false NOT NULL
);


ALTER TABLE public.messages OWNER TO appuser;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    type text NOT NULL,
    title text,
    body text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);


ALTER TABLE public.notifications OWNER TO appuser;

--
-- Name: resident_privacy_settings; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.resident_privacy_settings (
    resident_id uuid NOT NULL,
    show_email boolean DEFAULT false NOT NULL,
    show_phone boolean DEFAULT false NOT NULL,
    show_unit boolean DEFAULT true NOT NULL,
    allow_messages boolean DEFAULT true NOT NULL,
    directory_visible boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.resident_privacy_settings OWNER TO appuser;

--
-- Name: residents; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.residents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    unit_number text,
    building text,
    phone text,
    email text,
    first_name text NOT NULL,
    last_name text NOT NULL,
    bio text,
    profile_image_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.residents OWNER TO appuser;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.roles OWNER TO appuser;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_roles OWNER TO appuser;

--
-- Name: users; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    full_name text,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO appuser;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.audit_logs (id, actor_user_id, action, entity_type, entity_id, details, ip_address, user_agent, created_at) FROM stdin;
fd930aed-3807-44c8-9277-1144949a5149	fa3250b7-e728-4af7-90a0-e0a5aa9f9443	SEED	users	fa3250b7-e728-4af7-90a0-e0a5aa9f9443	{"note": "Initial admin seeded"}	\N	\N	2026-02-26 10:15:48.459431+00
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.messages (id, sender_user_id, recipient_user_id, subject, body, sent_at, read_at, is_deleted_by_sender, is_deleted_by_recipient) FROM stdin;
c825acce-965e-4fc0-9238-1b0130d8a524	b9193e70-b843-448f-bb6b-81f4db50d0c2	99ea492b-1a69-4d6a-8831-c1dd3ca736c5	Welcome	Hi Taylor — welcome to the building! Let me know if you need anything.	2026-02-26 10:15:42.793258+00	\N	f	f
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.notifications (id, user_id, type, title, body, data, created_at, read_at) FROM stdin;
62bb0384-3386-4440-aea3-1081648dfd43	99ea492b-1a69-4d6a-8831-c1dd3ca736c5	message	New message	You have a new message from Alex Johnson.	{"from": "alex.johnson@example.com"}	2026-02-26 10:15:45.538565+00	\N
\.


--
-- Data for Name: resident_privacy_settings; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.resident_privacy_settings (resident_id, show_email, show_phone, show_unit, allow_messages, directory_visible, updated_at) FROM stdin;
2dde01cf-26cd-408f-88f1-385bf005da22	t	f	t	t	t	2026-02-26 10:15:16.973629+00
4911e2f1-11b5-4442-a2a4-67aaac7bf7a1	f	t	t	t	t	2026-02-26 10:15:27.863738+00
70330e33-458d-455e-b0ac-0534b706493c	f	f	t	f	t	2026-02-26 10:15:40.215319+00
\.


--
-- Data for Name: residents; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.residents (id, user_id, unit_number, building, phone, email, first_name, last_name, bio, profile_image_url, is_active, created_at, updated_at) FROM stdin;
2dde01cf-26cd-408f-88f1-385bf005da22	b9193e70-b843-448f-bb6b-81f4db50d0c2	12B	North	+1-555-0101	alex.johnson@example.com	Alex	Johnson	Enjoys community gardening and board games.	\N	t	2026-02-26 10:15:14.25219+00	2026-02-26 10:15:14.25219+00
4911e2f1-11b5-4442-a2a4-67aaac7bf7a1	99ea492b-1a69-4d6a-8831-c1dd3ca736c5	7A	South	+1-555-0102	taylor.lee@example.com	Taylor	Lee	Remote worker; happy to help with tech questions.	\N	t	2026-02-26 10:15:25.265521+00	2026-02-26 10:15:25.265521+00
70330e33-458d-455e-b0ac-0534b706493c	3c4356c4-610e-4cd9-a93d-49b9b46b64de	3C	East	+1-555-0103	jamie.patel@example.com	Jamie	Patel	Dog owner; loves morning walks.	\N	t	2026-02-26 10:15:37.434925+00	2026-02-26 10:15:37.434925+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.roles (id, name, description, created_at) FROM stdin;
9058f149-5df3-49ac-b378-530b410f9d1f	admin	Administrator with full access	2026-02-26 10:14:58.415435+00
7167d77f-a759-4d93-b38d-cc6763218017	resident	Standard resident user	2026-02-26 10:15:00.718847+00
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.user_roles (user_id, role_id, assigned_at) FROM stdin;
fa3250b7-e728-4af7-90a0-e0a5aa9f9443	9058f149-5df3-49ac-b378-530b410f9d1f	2026-02-26 10:15:06.611085+00
b9193e70-b843-448f-bb6b-81f4db50d0c2	7167d77f-a759-4d93-b38d-cc6763218017	2026-02-26 10:15:11.442394+00
99ea492b-1a69-4d6a-8831-c1dd3ca736c5	7167d77f-a759-4d93-b38d-cc6763218017	2026-02-26 10:15:22.279982+00
3c4356c4-610e-4cd9-a93d-49b9b46b64de	7167d77f-a759-4d93-b38d-cc6763218017	2026-02-26 10:15:34.685279+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.users (id, email, password_hash, full_name, is_active, last_login_at, created_at, updated_at) FROM stdin;
fa3250b7-e728-4af7-90a0-e0a5aa9f9443	admin@residentdir.local	$2a$06$V18/AbyBU9ycBkk/Htpnse0S/YX9iDFTXBP2BGKOybEs66zGItzeG	System Admin	t	\N	2026-02-26 10:15:04.145317+00	2026-02-26 10:15:04.145317+00
b9193e70-b843-448f-bb6b-81f4db50d0c2	alex.johnson@example.com	$2a$06$SwvkebbzPtnd7lN7R/HHJOdDeluNBKDOVGh0L/IyDx0EehoMvtx52	Alex Johnson	t	\N	2026-02-26 10:15:08.961039+00	2026-02-26 10:15:08.961039+00
99ea492b-1a69-4d6a-8831-c1dd3ca736c5	taylor.lee@example.com	$2a$06$yj2m0N3oEgb1CTHlpFc5OebGu/0AqFN0jr/KkwDK4NsCkq1L/LlxS	Taylor Lee	t	\N	2026-02-26 10:15:20.157756+00	2026-02-26 10:15:20.157756+00
3c4356c4-610e-4cd9-a93d-49b9b46b64de	jamie.patel@example.com	$2a$06$mv5yAA9IiDB/T3MMIIQaNO96.94U/obchQ4PQiOeHpW9Tajwm2ilS	Jamie Patel	t	\N	2026-02-26 10:15:30.829203+00	2026-02-26 10:15:30.829203+00
\.


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: resident_privacy_settings resident_privacy_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.resident_privacy_settings
    ADD CONSTRAINT resident_privacy_settings_pkey PRIMARY KEY (resident_id);


--
-- Name: residents residents_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_pkey PRIMARY KEY (id);


--
-- Name: residents residents_user_id_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_user_id_key UNIQUE (user_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_logs_entity; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity_type, entity_id);


--
-- Name: idx_messages_recipient_sent_at; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_messages_recipient_sent_at ON public.messages USING btree (recipient_user_id, sent_at DESC);


--
-- Name: idx_notifications_user_created_at; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_notifications_user_created_at ON public.notifications USING btree (user_id, created_at DESC);


--
-- Name: idx_residents_name; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_residents_name ON public.residents USING btree (last_name, first_name);


--
-- Name: residents trg_residents_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_residents_updated_at BEFORE UPDATE ON public.residents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: audit_logs audit_logs_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: messages messages_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: messages messages_sender_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: resident_privacy_settings resident_privacy_settings_resident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.resident_privacy_settings
    ADD CONSTRAINT resident_privacy_settings_resident_id_fkey FOREIGN KEY (resident_id) REFERENCES public.residents(id) ON DELETE CASCADE;


--
-- Name: residents residents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.residents
    ADD CONSTRAINT residents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: DATABASE myapp; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE myapp TO appuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO appuser;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO appuser;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO appuser;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO appuser;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO appuser;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO appuser;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO appuser;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO appuser;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO appuser;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO appuser;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO appuser;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict Lh7txhljfPhmkH9dU8dXyPigjJAMoMu3f4jiSLEoCcqYgosEjECPquQe3fRGkbb

