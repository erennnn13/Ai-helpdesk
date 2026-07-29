--
-- PostgreSQL database dump
--

\restrict rIs2beObgjOPsVLz8esfvC7hiitKkrIby7DV0KxYjjA2tnTrIjMXLdGAei5bans

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public.ticket DROP CONSTRAINT "ticket_assignedToId_fkey";
ALTER TABLE ONLY public.session DROP CONSTRAINT "session_userId_fkey";
ALTER TABLE ONLY public.message DROP CONSTRAINT "message_ticketId_fkey";
ALTER TABLE ONLY public.account DROP CONSTRAINT "account_userId_fkey";
ALTER TABLE ONLY pgboss.subscription DROP CONSTRAINT subscription_name_fkey;
ALTER TABLE ONLY pgboss.schedule DROP CONSTRAINT schedule_name_fkey;
ALTER TABLE ONLY pgboss.queue DROP CONSTRAINT queue_dead_letter_fkey;
ALTER TABLE ONLY pgboss.job_common DROP CONSTRAINT q_fkey;
ALTER TABLE ONLY pgboss.job_common DROP CONSTRAINT dlq_fkey;
DROP INDEX public.verification_identifier_idx;
DROP INDEX public.user_email_key;
DROP INDEX public.ticket_status_idx;
DROP INDEX public."ticket_status_createdAt_idx";
DROP INDEX public."ticket_createdAt_idx";
DROP INDEX public."session_userId_idx";
DROP INDEX public.session_token_key;
DROP INDEX public."email_log_messageId_key";
DROP INDEX public."account_userId_idx";
DROP INDEX pgboss.warning_i1;
DROP INDEX pgboss.queue_stats_i1;
DROP INDEX pgboss.job_dep_parent_idx;
DROP INDEX pgboss.job_common_i9;
DROP INDEX pgboss.job_common_i8;
DROP INDEX pgboss.job_common_i7;
DROP INDEX pgboss.job_common_i6;
DROP INDEX pgboss.job_common_i5;
DROP INDEX pgboss.job_common_i4;
DROP INDEX pgboss.job_common_i3;
DROP INDEX pgboss.job_common_i2;
DROP INDEX pgboss.job_common_i1;
ALTER TABLE ONLY public.verification DROP CONSTRAINT verification_pkey;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
ALTER TABLE ONLY public.ticket DROP CONSTRAINT ticket_pkey;
ALTER TABLE ONLY public.session DROP CONSTRAINT session_pkey;
ALTER TABLE ONLY public.message DROP CONSTRAINT message_pkey;
ALTER TABLE ONLY public.knowledge_base DROP CONSTRAINT knowledge_base_pkey;
ALTER TABLE ONLY public.email_log DROP CONSTRAINT email_log_pkey;
ALTER TABLE ONLY public.account DROP CONSTRAINT account_pkey;
ALTER TABLE ONLY public._prisma_migrations DROP CONSTRAINT _prisma_migrations_pkey;
ALTER TABLE ONLY pgboss.warning DROP CONSTRAINT warning_pkey;
ALTER TABLE ONLY pgboss.version DROP CONSTRAINT version_pkey;
ALTER TABLE ONLY pgboss.subscription DROP CONSTRAINT subscription_pkey;
ALTER TABLE ONLY pgboss.schedule DROP CONSTRAINT schedule_pkey;
ALTER TABLE ONLY pgboss.queue_stats_20260728 DROP CONSTRAINT queue_stats_20260728_pkey;
ALTER TABLE ONLY pgboss.queue_stats_20260727 DROP CONSTRAINT queue_stats_20260727_pkey;
ALTER TABLE ONLY pgboss.queue_stats DROP CONSTRAINT queue_stats_pkey;
ALTER TABLE ONLY pgboss.queue DROP CONSTRAINT queue_pkey;
ALTER TABLE ONLY pgboss.job_dependency DROP CONSTRAINT job_dependency_pkey;
ALTER TABLE ONLY pgboss.job_common DROP CONSTRAINT job_common_pkey;
ALTER TABLE ONLY pgboss.job DROP CONSTRAINT job_pkey;
ALTER TABLE ONLY pgboss.bam DROP CONSTRAINT bam_pkey;
ALTER TABLE public.ticket ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.verification;
DROP TABLE public."user";
DROP SEQUENCE public.ticket_id_seq;
DROP TABLE public.ticket;
DROP TABLE public.session;
DROP TABLE public.message;
DROP TABLE public.knowledge_base;
DROP TABLE public.email_log;
DROP TABLE public.account;
DROP TABLE public._prisma_migrations;
DROP TABLE pgboss.warning;
DROP TABLE pgboss.version;
DROP TABLE pgboss.subscription;
DROP TABLE pgboss.schedule;
DROP TABLE pgboss.queue_stats_20260728;
DROP TABLE pgboss.queue_stats_20260727;
DROP TABLE pgboss.queue_stats;
DROP TABLE pgboss.queue;
DROP TABLE pgboss.job_dependency;
DROP TABLE pgboss.job_common;
DROP TABLE pgboss.job;
DROP TABLE pgboss.bam;
DROP FUNCTION public.get_ticket_stats();
DROP FUNCTION pgboss.job_table_run_async(command_name text, version integer, command text, tbl_name text, queue_name text);
DROP FUNCTION pgboss.job_table_run(command text, tbl_name text, queue_name text);
DROP FUNCTION pgboss.job_table_format(command text, table_name text);
DROP FUNCTION pgboss.delete_queue(queue_name text);
DROP FUNCTION pgboss.create_queue(queue_name text, options jsonb);
DROP TYPE public."TicketStatus";
DROP TYPE public."TicketSource";
DROP TYPE public."TicketCategory";
DROP TYPE public."Role";
DROP TYPE pgboss.job_state;
-- *not* dropping schema, since initdb creates it
DROP SCHEMA pgboss;
--
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'AGENT',
    'ADMIN'
);


ALTER TYPE public."Role" OWNER TO postgres;

--
-- Name: TicketCategory; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."TicketCategory" AS ENUM (
    'GENERAL',
    'TECHNICAL',
    'REFUND'
);


ALTER TYPE public."TicketCategory" OWNER TO postgres;

--
-- Name: TicketSource; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."TicketSource" AS ENUM (
    'WEB',
    'EMAIL'
);


ALTER TYPE public."TicketSource" OWNER TO postgres;

--
-- Name: TicketStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."TicketStatus" AS ENUM (
    'OPEN',
    'RESOLVED',
    'CLOSED',
    'NEW',
    'PROCESSING'
);


ALTER TYPE public."TicketStatus" OWNER TO postgres;

--
-- Name: create_queue(text, jsonb); Type: FUNCTION; Schema: pgboss; Owner: postgres
--

CREATE FUNCTION pgboss.create_queue(queue_name text, options jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      tablename varchar := CASE WHEN options->>'partition' = 'true'
                            THEN 'j' || encode(sha224(queue_name::bytea), 'hex')
                            ELSE 'job_common'
                            END;
      queue_created_on timestamptz;
    BEGIN

      WITH q as (
        INSERT INTO pgboss.queue (
          name,
          policy,
          retry_limit,
          retry_delay,
          retry_backoff,
          retry_delay_max,
          expire_seconds,
          retention_seconds,
          deletion_seconds,
          warning_queued,
          dead_letter,
          partition,
          table_name,
          heartbeat_seconds,
          notify
        )
        VALUES (
          queue_name,
          options->>'policy',
          COALESCE((options->>'retryLimit')::int, 2),
          COALESCE((options->>'retryDelay')::int, 0),
          COALESCE((options->>'retryBackoff')::bool, false),
          (options->>'retryDelayMax')::int,
          COALESCE((options->>'expireInSeconds')::int, 900),
          COALESCE((options->>'retentionSeconds')::int, 1209600),
          COALESCE((options->>'deleteAfterSeconds')::int, 604800),
          COALESCE((options->>'warningQueueSize')::int, 0),
          options->>'deadLetter',
          COALESCE((options->>'partition')::bool, false),
          tablename,
          (options->>'heartbeatSeconds')::int,
          COALESCE((options->>'notify')::bool, false)
        )
        ON CONFLICT DO NOTHING
        RETURNING created_on
      )
      SELECT created_on into queue_created_on from q;

      IF queue_created_on IS NULL OR options->>'partition' IS DISTINCT FROM 'true' THEN
        RETURN;
      END IF;

      EXECUTE format('CREATE TABLE pgboss.%I (LIKE pgboss.job INCLUDING DEFAULTS)', tablename);

      EXECUTE pgboss.job_table_format($cmd$ALTER TABLE pgboss.job ADD PRIMARY KEY (name, id)$cmd$, tablename);
      EXECUTE pgboss.job_table_format($cmd$ALTER TABLE pgboss.job ADD CONSTRAINT q_fkey FOREIGN KEY (name) REFERENCES pgboss.queue (name) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED$cmd$, tablename);
      EXECUTE pgboss.job_table_format($cmd$ALTER TABLE pgboss.job ADD CONSTRAINT dlq_fkey FOREIGN KEY (dead_letter) REFERENCES pgboss.queue (name) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED$cmd$, tablename);

      EXECUTE pgboss.job_table_format($cmd$CREATE INDEX job_i5 ON pgboss.job (name, start_after) WHERE state < 'active' AND NOT blocked$cmd$, tablename);
      EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i4 ON pgboss.job (name, singleton_on, COALESCE(singleton_key, '')) WHERE state <> 'cancelled' AND singleton_on IS NOT NULL$cmd$, tablename);
      EXECUTE pgboss.job_table_format($cmd$CREATE INDEX job_i7 ON pgboss.job (name, group_id) WHERE state = 'active' AND group_id IS NOT NULL$cmd$, tablename);
      EXECUTE pgboss.job_table_format($cmd$CREATE INDEX job_i9 ON pgboss.job (name, id) WHERE blocking AND state = 'completed'$cmd$, tablename);

      IF options->>'policy' = 'short' THEN
        EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i1 ON pgboss.job (name, COALESCE(singleton_key, '')) WHERE state = 'created' AND policy = 'short'$cmd$, tablename);
      ELSIF options->>'policy' = 'singleton' THEN
        EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i2 ON pgboss.job (name, COALESCE(singleton_key, '')) WHERE state = 'active' AND policy = 'singleton'$cmd$, tablename);
      ELSIF options->>'policy' = 'stately' THEN
        EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i3 ON pgboss.job (name, state, COALESCE(singleton_key, '')) WHERE state <= 'active' AND policy = 'stately'$cmd$, tablename);
      ELSIF options->>'policy' = 'exclusive' THEN
        EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i6 ON pgboss.job (name, COALESCE(singleton_key, '')) WHERE state <= 'active' AND policy = 'exclusive'$cmd$, tablename);
      ELSIF options->>'policy' = 'key_strict_fifo' THEN
        EXECUTE pgboss.job_table_format($cmd$CREATE UNIQUE INDEX job_i8 ON pgboss.job (name, singleton_key) WHERE state IN ('active', 'retry', 'failed') AND policy = 'key_strict_fifo'$cmd$, tablename);
        EXECUTE pgboss.job_table_format($cmd$ALTER TABLE pgboss.job ADD CONSTRAINT job_key_strict_fifo_singleton_key_check CHECK (NOT (policy = 'key_strict_fifo' AND singleton_key IS NULL))$cmd$, tablename);
      END IF;

      EXECUTE format('ALTER TABLE pgboss.%I ADD CONSTRAINT cjc CHECK (name=%L)', tablename, queue_name);
      EXECUTE format('ALTER TABLE pgboss.job ATTACH PARTITION pgboss.%I FOR VALUES IN (%L)', tablename, queue_name);
    END;
    $_$;


ALTER FUNCTION pgboss.create_queue(queue_name text, options jsonb) OWNER TO postgres;

--
-- Name: delete_queue(text); Type: FUNCTION; Schema: pgboss; Owner: postgres
--

CREATE FUNCTION pgboss.delete_queue(queue_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      v_table varchar;
      v_partition bool;
    BEGIN
      
      SELECT table_name, partition
      FROM pgboss.queue
      WHERE name = queue_name
      INTO v_table, v_partition;

      IF v_partition THEN
        EXECUTE format('DROP TABLE IF EXISTS pgboss.%I', v_table);
      ELSE
        EXECUTE format('DELETE FROM pgboss.%I WHERE name = %L', v_table, queue_name);
      END IF;
    
      DELETE FROM pgboss.queue WHERE name = queue_name;
    END;
    $$;


ALTER FUNCTION pgboss.delete_queue(queue_name text) OWNER TO postgres;

--
-- Name: job_table_format(text, text); Type: FUNCTION; Schema: pgboss; Owner: postgres
--

CREATE FUNCTION pgboss.job_table_format(command text, table_name text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT format(
        regexp_replace(
          regexp_replace(command, '\.job\y', '.%1$I', 'g'),
          '\yjob_i(\d+)', '%1$s_i\1', 'g'
        ),
        table_name
      );
    $_$;


ALTER FUNCTION pgboss.job_table_format(command text, table_name text) OWNER TO postgres;

--
-- Name: job_table_run(text, text, text); Type: FUNCTION; Schema: pgboss; Owner: postgres
--

CREATE FUNCTION pgboss.job_table_run(command text, tbl_name text DEFAULT NULL::text, queue_name text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      tbl RECORD;
    BEGIN
      IF queue_name IS NOT NULL THEN
        SELECT table_name INTO tbl_name FROM pgboss.queue WHERE name = queue_name;
      END IF;

      IF tbl_name IS NOT NULL THEN
        EXECUTE pgboss.job_table_format(command, tbl_name);
        RETURN;
      END IF;

      EXECUTE pgboss.job_table_format(command, 'job_common');

      FOR tbl IN SELECT table_name FROM pgboss.queue WHERE partition = true
      LOOP
        EXECUTE pgboss.job_table_format(command, tbl.table_name);
      END LOOP;
    END;
    $$;


ALTER FUNCTION pgboss.job_table_run(command text, tbl_name text, queue_name text) OWNER TO postgres;

--
-- Name: job_table_run_async(text, integer, text, text, text); Type: FUNCTION; Schema: pgboss; Owner: postgres
--

CREATE FUNCTION pgboss.job_table_run_async(command_name text, version integer, command text, tbl_name text DEFAULT NULL::text, queue_name text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF queue_name IS NOT NULL THEN
        SELECT table_name INTO tbl_name FROM pgboss.queue WHERE name = queue_name;
      END IF;

      IF tbl_name IS NOT NULL THEN
        INSERT INTO pgboss.bam (name, version, status, queue, table_name, command)
        VALUES (
          command_name,
          version,
          'pending',
          queue_name,
          tbl_name,
          pgboss.job_table_format(command, tbl_name)
        );
        RETURN;
      END IF;

      INSERT INTO pgboss.bam (name, version, status, queue, table_name, command)
      SELECT
        command_name,
        version,
        'pending',
        NULL,
        'job_common',
        pgboss.job_table_format(command, 'job_common')
      UNION ALL
      SELECT
        command_name,
        version,
        'pending',
        queue.name,
        queue.table_name,
        pgboss.job_table_format(command, queue.table_name)
      FROM pgboss.queue
      WHERE partition = true;
    END;
    $$;


ALTER FUNCTION pgboss.job_table_run_async(command_name text, version integer, command text, tbl_name text, queue_name text) OWNER TO postgres;

--
-- Name: get_ticket_stats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_ticket_stats() RETURNS TABLE(open_count bigint, resolved_count bigint, closed_count bigint, total_count bigint, ai_resolved_count bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
      RETURN QUERY
      SELECT
        COUNT(*) FILTER (WHERE status = 'OPEN') AS open_count,
        COUNT(*) FILTER (WHERE status = 'RESOLVED') AS resolved_count,
        COUNT(*) FILTER (WHERE status = 'CLOSED') AS closed_count,
        COUNT(*) AS total_count,
        (
          SELECT COUNT(DISTINCT t.id)
          FROM "ticket" t
          JOIN "message" m ON m."ticketId" = t.id
          WHERE t.status = 'RESOLVED' AND m.sender = 'AI'
        ) AS ai_resolved_count
      FROM "ticket";
    END;
    $$;


ALTER FUNCTION public.get_ticket_stats() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bam; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.bam (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    version integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    queue text,
    table_name text NOT NULL,
    command text NOT NULL,
    error text,
    created_on timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    started_on timestamp with time zone,
    completed_on timestamp with time zone
);


ALTER TABLE pgboss.bam OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retry_limit integer DEFAULT 2 NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    retry_delay integer DEFAULT 0 NOT NULL,
    retry_backoff boolean DEFAULT false NOT NULL,
    retry_delay_max integer,
    expire_seconds integer DEFAULT 900 NOT NULL,
    deletion_seconds integer DEFAULT 604800 NOT NULL,
    singleton_key text,
    singleton_on timestamp without time zone,
    group_id text,
    group_tier text,
    start_after timestamp with time zone DEFAULT now() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    started_on timestamp with time zone,
    completed_on timestamp with time zone,
    keep_until timestamp with time zone DEFAULT (now() + '336:00:00'::interval) NOT NULL,
    output jsonb,
    dead_letter text,
    policy text,
    heartbeat_on timestamp with time zone,
    heartbeat_seconds integer,
    blocked boolean DEFAULT false NOT NULL,
    blocking boolean DEFAULT false NOT NULL,
    pending_dependencies integer DEFAULT 0 NOT NULL,
    source_name text,
    source_id uuid,
    source_created_on timestamp with time zone,
    source_retry_count integer
)
PARTITION BY LIST (name);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: job_common; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job_common (
    id uuid DEFAULT gen_random_uuid() CONSTRAINT job_id_not_null NOT NULL,
    name text CONSTRAINT job_name_not_null NOT NULL,
    priority integer DEFAULT 0 CONSTRAINT job_priority_not_null NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state CONSTRAINT job_state_not_null NOT NULL,
    retry_limit integer DEFAULT 2 CONSTRAINT job_retry_limit_not_null NOT NULL,
    retry_count integer DEFAULT 0 CONSTRAINT job_retry_count_not_null NOT NULL,
    retry_delay integer DEFAULT 0 CONSTRAINT job_retry_delay_not_null NOT NULL,
    retry_backoff boolean DEFAULT false CONSTRAINT job_retry_backoff_not_null NOT NULL,
    retry_delay_max integer,
    expire_seconds integer DEFAULT 900 CONSTRAINT job_expire_seconds_not_null NOT NULL,
    deletion_seconds integer DEFAULT 604800 CONSTRAINT job_deletion_seconds_not_null NOT NULL,
    singleton_key text,
    singleton_on timestamp without time zone,
    group_id text,
    group_tier text,
    start_after timestamp with time zone DEFAULT now() CONSTRAINT job_start_after_not_null NOT NULL,
    created_on timestamp with time zone DEFAULT now() CONSTRAINT job_created_on_not_null NOT NULL,
    started_on timestamp with time zone,
    completed_on timestamp with time zone,
    keep_until timestamp with time zone DEFAULT (now() + '336:00:00'::interval) CONSTRAINT job_keep_until_not_null NOT NULL,
    output jsonb,
    dead_letter text,
    policy text,
    heartbeat_on timestamp with time zone,
    heartbeat_seconds integer,
    blocked boolean DEFAULT false CONSTRAINT job_blocked_not_null NOT NULL,
    blocking boolean DEFAULT false CONSTRAINT job_blocking_not_null NOT NULL,
    pending_dependencies integer DEFAULT 0 CONSTRAINT job_pending_dependencies_not_null NOT NULL,
    source_name text,
    source_id uuid,
    source_created_on timestamp with time zone,
    source_retry_count integer,
    CONSTRAINT job_key_strict_fifo_singleton_key_check CHECK ((NOT ((policy = 'key_strict_fifo'::text) AND (singleton_key IS NULL))))
);


ALTER TABLE pgboss.job_common OWNER TO postgres;

--
-- Name: job_dependency; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job_dependency (
    child_name text NOT NULL,
    child_id uuid NOT NULL,
    parent_name text NOT NULL,
    parent_id uuid NOT NULL
);


ALTER TABLE pgboss.job_dependency OWNER TO postgres;

--
-- Name: queue; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.queue (
    name text NOT NULL,
    policy text NOT NULL,
    retry_limit integer NOT NULL,
    retry_delay integer NOT NULL,
    retry_backoff boolean NOT NULL,
    retry_delay_max integer,
    expire_seconds integer NOT NULL,
    retention_seconds integer NOT NULL,
    deletion_seconds integer NOT NULL,
    dead_letter text,
    partition boolean NOT NULL,
    table_name text NOT NULL,
    deferred_count integer DEFAULT 0 NOT NULL,
    queued_count integer DEFAULT 0 NOT NULL,
    ready_count integer DEFAULT 0 NOT NULL,
    warning_queued integer DEFAULT 0 NOT NULL,
    active_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    total_count integer DEFAULT 0 NOT NULL,
    ready_history integer[] DEFAULT '{}'::integer[] NOT NULL,
    heartbeat_seconds integer,
    notify boolean DEFAULT false NOT NULL,
    singletons_active text[],
    monitor_on timestamp with time zone,
    maintain_on timestamp with time zone,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT queue_check CHECK ((dead_letter IS DISTINCT FROM name))
);


ALTER TABLE pgboss.queue OWNER TO postgres;

--
-- Name: queue_stats; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.queue_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    deferred_count integer DEFAULT 0 NOT NULL,
    queued_count integer DEFAULT 0 NOT NULL,
    ready_count integer DEFAULT 0 NOT NULL,
    active_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    total_count integer DEFAULT 0 NOT NULL,
    captured_on timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (captured_on);


ALTER TABLE pgboss.queue_stats OWNER TO postgres;

--
-- Name: queue_stats_20260727; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.queue_stats_20260727 (
    id uuid DEFAULT gen_random_uuid() CONSTRAINT queue_stats_id_not_null NOT NULL,
    name text CONSTRAINT queue_stats_name_not_null NOT NULL,
    deferred_count integer DEFAULT 0 CONSTRAINT queue_stats_deferred_count_not_null NOT NULL,
    queued_count integer DEFAULT 0 CONSTRAINT queue_stats_queued_count_not_null NOT NULL,
    ready_count integer DEFAULT 0 CONSTRAINT queue_stats_ready_count_not_null NOT NULL,
    active_count integer DEFAULT 0 CONSTRAINT queue_stats_active_count_not_null NOT NULL,
    failed_count integer DEFAULT 0 CONSTRAINT queue_stats_failed_count_not_null NOT NULL,
    total_count integer DEFAULT 0 CONSTRAINT queue_stats_total_count_not_null NOT NULL,
    captured_on timestamp with time zone DEFAULT now() CONSTRAINT queue_stats_captured_on_not_null NOT NULL
);


ALTER TABLE pgboss.queue_stats_20260727 OWNER TO postgres;

--
-- Name: queue_stats_20260728; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.queue_stats_20260728 (
    id uuid DEFAULT gen_random_uuid() CONSTRAINT queue_stats_id_not_null NOT NULL,
    name text CONSTRAINT queue_stats_name_not_null NOT NULL,
    deferred_count integer DEFAULT 0 CONSTRAINT queue_stats_deferred_count_not_null NOT NULL,
    queued_count integer DEFAULT 0 CONSTRAINT queue_stats_queued_count_not_null NOT NULL,
    ready_count integer DEFAULT 0 CONSTRAINT queue_stats_ready_count_not_null NOT NULL,
    active_count integer DEFAULT 0 CONSTRAINT queue_stats_active_count_not_null NOT NULL,
    failed_count integer DEFAULT 0 CONSTRAINT queue_stats_failed_count_not_null NOT NULL,
    total_count integer DEFAULT 0 CONSTRAINT queue_stats_total_count_not_null NOT NULL,
    captured_on timestamp with time zone DEFAULT now() CONSTRAINT queue_stats_captured_on_not_null NOT NULL
);


ALTER TABLE pgboss.queue_stats_20260728 OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    key text DEFAULT ''::text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    cron_on timestamp with time zone,
    bam_on timestamp with time zone,
    flow_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: warning; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.warning (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    message text NOT NULL,
    data jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.warning OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    id text NOT NULL,
    "accountId" text NOT NULL,
    "providerId" text NOT NULL,
    "userId" text NOT NULL,
    "accessToken" text,
    "refreshToken" text,
    "idToken" text,
    "accessTokenExpiresAt" timestamp(3) without time zone,
    "refreshTokenExpiresAt" timestamp(3) without time zone,
    scope text,
    password text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: email_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_log (
    id text NOT NULL,
    "messageId" text NOT NULL,
    "ticketId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.email_log OWNER TO postgres;

--
-- Name: knowledge_base; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.knowledge_base (
    id text NOT NULL,
    question text NOT NULL,
    answer text NOT NULL,
    category public."TicketCategory" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.knowledge_base OWNER TO postgres;

--
-- Name: message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message (
    id text NOT NULL,
    body text NOT NULL,
    sender text NOT NULL,
    "senderEmail" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "ticketId" integer NOT NULL,
    "bodyHtml" text
);


ALTER TABLE public.message OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    id text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    token text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "ipAddress" text,
    "userAgent" text,
    "userId" text NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket (
    subject text NOT NULL,
    status public."TicketStatus" DEFAULT 'NEW'::public."TicketStatus" NOT NULL,
    category public."TicketCategory",
    "customerEmail" text NOT NULL,
    "customerName" text NOT NULL,
    "assignedToId" text,
    "aiSummary" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    source public."TicketSource" DEFAULT 'WEB'::public."TicketSource" NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.ticket OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_id_seq OWNER TO postgres;

--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_id_seq OWNED BY public.ticket.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    "emailVerified" boolean DEFAULT false NOT NULL,
    image text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    role public."Role" DEFAULT 'AGENT'::public."Role" NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: verification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.verification (
    id text NOT NULL,
    identifier text NOT NULL,
    value text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.verification OWNER TO postgres;

--
-- Name: job_common; Type: TABLE ATTACH; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job ATTACH PARTITION pgboss.job_common DEFAULT;


--
-- Name: queue_stats_20260727; Type: TABLE ATTACH; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue_stats ATTACH PARTITION pgboss.queue_stats_20260727 FOR VALUES FROM ('2026-07-27 05:30:00+05:30') TO ('2026-07-28 05:30:00+05:30');


--
-- Name: queue_stats_20260728; Type: TABLE ATTACH; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue_stats ATTACH PARTITION pgboss.queue_stats_20260728 FOR VALUES FROM ('2026-07-28 05:30:00+05:30') TO ('2026-07-29 05:30:00+05:30');


--
-- Name: ticket id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket ALTER COLUMN id SET DEFAULT nextval('public.ticket_id_seq'::regclass);


--
-- Data for Name: bam; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.bam (id, name, version, status, queue, table_name, command, error, created_on, started_on, completed_on) FROM stdin;
\.


--
-- Data for Name: job_common; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job_common (id, name, priority, data, state, retry_limit, retry_count, retry_delay, retry_backoff, retry_delay_max, expire_seconds, deletion_seconds, singleton_key, singleton_on, group_id, group_tier, start_after, created_on, started_on, completed_on, keep_until, output, dead_letter, policy, heartbeat_on, heartbeat_seconds, blocked, blocking, pending_dependencies, source_name, source_id, source_created_on, source_retry_count) FROM stdin;
c919d439-de52-4b84-95b0-6d25eefe1b0b	ticket-autoresolve	0	{"ticketId": 111}	completed	2	0	30	f	\N	300	604800	autoresolve-ticket-111	\N	\N	\N	2026-07-28 15:40:38.564469+05:30	2026-07-28 15:40:38.564469+05:30	2026-07-28 15:40:40.749963+05:30	2026-07-28 15:40:51.371726+05:30	2026-08-11 15:40:38.564469+05:30	\N	\N	standard	2026-07-28 15:40:40.749963+05:30	\N	f	f	0	\N	\N	\N	\N
c0f454e1-9d54-48b8-a0f9-4efd42dc228f	ticket-autoresolve	0	{"ticketId": 112}	completed	2	0	30	f	\N	300	604800	autoresolve-ticket-112	\N	\N	\N	2026-07-28 19:26:30.489198+05:30	2026-07-28 19:26:30.489198+05:30	2026-07-28 19:26:31.359208+05:30	2026-07-28 19:26:39.024098+05:30	2026-08-11 19:26:30.489198+05:30	\N	\N	standard	2026-07-28 19:26:31.359208+05:30	\N	f	f	0	\N	\N	\N	\N
9338ac3f-b320-4bc1-a1a5-595131eccc1d	ticket-autoresolve	0	{"ticketId": 113}	completed	2	0	30	f	\N	300	604800	autoresolve-ticket-113	\N	\N	\N	2026-07-28 19:27:56.202742+05:30	2026-07-28 19:27:56.202742+05:30	2026-07-28 19:27:56.557625+05:30	2026-07-28 19:28:03.027313+05:30	2026-08-11 19:27:56.202742+05:30	\N	\N	standard	2026-07-28 19:27:56.557625+05:30	\N	f	f	0	\N	\N	\N	\N
\.


--
-- Data for Name: job_dependency; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job_dependency (child_name, child_id, parent_name, parent_id) FROM stdin;
\.


--
-- Data for Name: queue; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.queue (name, policy, retry_limit, retry_delay, retry_backoff, retry_delay_max, expire_seconds, retention_seconds, deletion_seconds, dead_letter, partition, table_name, deferred_count, queued_count, ready_count, warning_queued, active_count, failed_count, total_count, ready_history, heartbeat_seconds, notify, singletons_active, monitor_on, maintain_on, created_on, updated_on) FROM stdin;
__pgboss__send-it	standard	2	0	f	\N	900	1209600	604800	\N	f	job_common	0	0	0	0	0	0	0	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	\N	f	\N	2026-07-29 20:02:17.818559+05:30	2026-07-29 20:02:17.824282+05:30	2026-07-27 11:50:02.367402+05:30	2026-07-27 11:50:02.367402+05:30
ticket-autoresolve	standard	2	0	f	\N	900	1209600	604800	\N	f	job_common	0	0	0	0	0	0	3	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	\N	f	\N	2026-07-29 20:02:17.818559+05:30	2026-07-29 20:02:17.824282+05:30	2026-07-27 23:56:34.431187+05:30	2026-07-27 23:56:34.431187+05:30
ticket-classify	standard	2	0	f	\N	900	1209600	604800	\N	f	job_common	0	0	0	0	0	0	0	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	\N	f	\N	2026-07-29 20:02:17.818559+05:30	2026-07-29 20:02:17.824282+05:30	2026-07-27 23:56:34.414839+05:30	2026-07-27 23:56:34.414839+05:30
\.


--
-- Data for Name: queue_stats_20260727; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.queue_stats_20260727 (id, name, deferred_count, queued_count, ready_count, active_count, failed_count, total_count, captured_on) FROM stdin;
\.


--
-- Data for Name: queue_stats_20260728; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.queue_stats_20260728 (id, name, deferred_count, queued_count, ready_count, active_count, failed_count, total_count, captured_on) FROM stdin;
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, key, cron, timezone, data, options, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, cron_on, bam_on, flow_on) FROM stdin;
37	2026-07-29 20:02:17.87854+05:30	2026-07-29 20:02:17.947022+05:30	2026-07-29 20:02:13.639008+05:30
\.


--
-- Data for Name: warning; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.warning (id, type, message, data, created_on) FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
235662a8-8fe8-40a2-872e-d4b7f5c9d5e6	8b97e083812d253e730b15089ba6eab2dd09a9428b573efea3e3ff73a4ae4c94	2026-07-21 11:44:56.41797+05:30	20260718090520_init	\N	\N	2026-07-21 11:44:56.389741+05:30	1
dbddd177-9cf8-4cce-9e44-d0d02a74cd69	f04723d917bb47435d3f8271be0b65885cffcf20f3779ccea79bf55bcf806a14	2026-07-21 11:44:56.420191+05:30	20260718093720_add_role_and_passwordhash_to_user	\N	\N	2026-07-21 11:44:56.418337+05:30	1
baa3cad2-5b70-4b2d-a4dd-6afe19d3ee61	a632837d9a23e9e8438aed6061b142c7cb469ba8e199be7b2f61726cc80cd256	2026-07-21 11:44:56.433151+05:30	20260718093822_add_tickets_messages_knowledgebase	\N	\N	2026-07-21 11:44:56.420715+05:30	1
b0b3a234-0c81-4239-9fd9-8d05200644dd	3261f8706783231ca3bf3c45c998ae5f20b7b969ebdfbfb5f78a48a72bdf2050	2026-07-21 11:44:56.435089+05:30	20260719122747_sync_schema	\N	\N	2026-07-21 11:44:56.433513+05:30	1
f9271be5-910d-480f-879a-1856e5aecc54	7896918b4e275e8eac3a44ada4ecc95569d333f5d0b01ba1968d14b2eb0b808b	2026-07-21 11:44:56.436372+05:30	20260720090741_add_user_soft_delete	\N	\N	2026-07-21 11:44:56.43538+05:30	1
15464785-9a72-44eb-ac7d-a7ef95327054	00fae916ed4187052bb04de9ddc37003f74a6919c950cef782f8b578d71391dc	2026-07-21 11:45:03.326244+05:30	20260721061503_email_to_ticket_schema	\N	\N	2026-07-21 11:45:03.29821+05:30	1
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account (id, "accountId", "providerId", "userId", "accessToken", "refreshToken", "idToken", "accessTokenExpiresAt", "refreshTokenExpiresAt", scope, password, "createdAt", "updatedAt") FROM stdin;
70a94d9d-3e09-4a9b-acb6-457dc4658721	admin@example.com	credential	b032b8c4-fa17-4741-a2ea-34994bfa955b	\N	\N	\N	\N	\N	\N	$2b$12$cJx7dud0eA0DN5STd8iEA.Rt8BBR6jPWstsMCK.10hG5G9YKYsYIe	2026-07-21 06:17:47.862	2026-07-21 06:17:47.862
b3b69f1d-1365-4d19-b84c-d93a4ec71f49	agent@example.com	credential	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	\N	\N	\N	\N	\N	$2b$12$5paZJMB/1jDHUMON8Xx0/uFRjmlOeGlFH59XuztcDwsIg6HeEWzJa	2026-07-21 06:17:48.114	2026-07-21 06:17:48.114
\.


--
-- Data for Name: email_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_log (id, "messageId", "ticketId", "createdAt") FROM stdin;
6328a4ce-3223-421b-9c11-6dd2b189d3a9	3346b0d2-f00c-4b88-92de-9d298e76e212	111	2026-07-28 10:10:38.556
5373ecf5-1354-4c3c-b36b-18287268399b	6fa4ef2e-a4b0-4605-8765-09b584088842	112	2026-07-28 13:56:30.486
402db6a0-3530-4aa2-b19c-2ef9171f1eff	ac1bfb0a-bf2a-47c7-a5b7-88fce9e54adc	113	2026-07-28 13:57:56.203
\.


--
-- Data for Name: knowledge_base; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.knowledge_base (id, question, answer, category, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message (id, body, sender, "senderEmail", "createdAt", "ticketId", "bodyHtml") FROM stdin;
92a1e5c8-89c7-40ba-a84e-61fd935c7d97	E2E automated test reply	AGENT	agent@example.com	2026-07-21 06:44:07.048	1	\N
cc8397e6-6d01-437f-a550-40c5b574695f	E2E reply 1784616617984	AGENT	agent@example.com	2026-07-21 06:50:18.062	1	\N
f89ba81f-3188-4825-95d5-6336f4465e50	E2E reply 1784616665663	AGENT	agent@example.com	2026-07-21 06:51:05.859	1	\N
0e190728-4b37-4a47-bcdd-b49c0b3b68ef	E2E reply 1784625585100	AGENT	agent@example.com	2026-07-21 09:19:46.079	1	\N
2c341f14-ca75-40d6-a965-118c866c5686	E2E reply 1784625626307	AGENT	agent@example.com	2026-07-21 09:20:26.6	1	\N
0c02a24a-1cdc-419d-a77c-c1862127a33b	E2E reply 1784625692125	AGENT	agent@example.com	2026-07-21 09:21:32.529	1	\N
1c0aa80e-3037-42f2-ba6c-847002790cc1	Hello, I am writing regarding this issue: Need help setting up integration. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-22 14:59:32.222	2	\N
e19d5424-5a50-4a62-affb-596044d44382	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-30 08:11:32.243	3	\N
43e80821-6d71-4694-b2a4-94bd4f4e0760	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-03 20:11:32.256	5	\N
5fec979c-1f39-46a1-8edd-5b472c0fc4ec	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-01 05:17:32.258	6	\N
ed79bf00-7d3f-4de3-b462-d80c894cf102	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 07:32:32.26	7	\N
6dea0661-fc34-4409-b714-407e94a8a883	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-07 07:43:32.271	9	\N
c2b9d49a-075a-425e-8aed-91b0c4c25f08	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-28 08:29:32.274	10	\N
519f75ba-70a2-4ed0-9337-1febcb939d46	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-16 04:17:32.276	11	\N
c2476e67-1934-40b7-944b-5a14cf963b0d	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-02 20:38:32.279	12	\N
0f0964b4-9532-44dd-b610-632eb6a34e18	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 11:14:32.282	13	\N
d695865d-131d-434d-8269-cdb5250040a1	Hello, I am writing regarding this issue: Need help setting up integration. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-08 13:39:32.288	14	\N
cb9a5c46-6003-4381-aca2-667d5062bf52	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-01 14:00:32.29	15	\N
cfedd5a6-cbc7-46d7-bc45-0da73ec33140	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-07 09:25:32.292	16	\N
0819d1ef-a3c7-4ae3-b528-f604fbd798a1	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-06 08:39:32.293	17	\N
3739bab4-1484-434f-9ee1-0721819b0a78	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-19 19:45:32.296	18	\N
5dbc168a-f4c9-4b7e-94d9-76c940fe76a7	Hello, I am writing regarding this issue: How do I upgrade my plan?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-26 20:22:32.3	19	\N
55e02440-0e95-4b41-ae9b-2eabc0b8626c	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-13 05:06:32.303	20	\N
956da50a-19a7-44d8-9d07-b938ebf48271	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-12 05:59:32.305	21	\N
ab5b1ded-b423-4ced-aa7b-e0cf5d10f0c4	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-16 16:03:32.306	22	\N
5495d195-bf5e-47bd-80d2-fb0c7e454e8d	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-27 03:37:32.309	23	\N
eea74488-72b4-425f-8c53-946bf2a0ab7f	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-03 05:40:32.31	24	\N
fa88c677-ed92-4160-8d7f-44b86016a0e3	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-12 01:18:32.312	25	\N
217871c3-cf77-4435-9803-814aae994cc9	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 20:28:32.314	26	\N
d5eb5eda-ca33-4184-8824-66b6010cc83a	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-05 17:08:32.316	27	\N
39fa6865-e71b-4838-9b26-25d696fc0e7f	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-03 07:51:32.32	28	\N
516093ee-f32a-44b1-a765-feb16d63d7ac	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-19 03:35:32.321	29	\N
3c34183a-73c7-46b0-861b-2e0b60dcaf66	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 04:33:32.323	30	\N
ec7b9d97-149c-4b3d-82f0-74f5477eeed3	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-12 08:22:32.324	31	\N
23109328-19e3-4226-8530-b13f32872940	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-09 14:11:32.326	32	\N
c4c4d8d8-3986-498c-bd1f-231f47f28fa2	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-28 17:01:32.328	33	\N
724134a1-cad6-43d3-8586-b64fff80ec15	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-17 22:15:32.329	34	\N
848aa6ea-a704-4d01-af16-4853b3eabe1c	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 12:18:32.331	35	\N
e88205f5-81ae-409a-9e90-de2711183ce6	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-22 21:16:32.335	36	\N
17e0eb08-7c1c-48ac-b4ba-dcedb7f02339	aoikdmnfkamskgmaskdpigfnsogdpoasmmpdogmpksdmgfklpmaspkmgpnpng 	CUSTOMER	\N	2026-07-06 06:01:32.264	8	\N
73ecf36b-6d24-4f3a-8f00-2d0d35d5b57f	ktdskghgxgxgjlhc	CUSTOMER	e2e@example.com	2026-07-21 06:18:09.42	1	\N
a9ab5c5d-ce34-438f-a041-5f1ab400e08a	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-08 13:18:32.337	37	\N
1d216852-7913-4ef6-ad5a-447118e93b14	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-08 08:07:32.339	38	\N
f89daa3f-4e67-4266-887c-6a9ff0dfa86d	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-07 11:08:32.34	39	\N
f0c49ccb-975b-4770-8fdc-d71cf824e43f	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-07 17:28:32.342	40	\N
f5057f99-78e1-4925-9037-71ae53d0e1b9	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-13 21:41:32.343	41	\N
1e467838-ba7e-4779-ba56-72009b322589	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-22 12:48:32.344	42	\N
22dfbc74-62cd-4361-a700-1e619566035b	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 11:10:32.345	43	\N
59f1b728-8b98-495f-9d50-3cafcc69608e	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 19:20:32.346	44	\N
62bf00a6-e89d-46b4-8086-59edb31d31a2	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-08 04:38:32.347	45	\N
c9f0f0a3-7164-4681-aed8-c4dcf4c9d965	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-06 10:03:32.348	46	\N
9d08d79c-df78-4f15-a606-8e762ba88251	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-02 16:47:32.351	47	\N
edd2e6ce-48a4-4a28-85c9-33ba91e4e65a	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-06 09:35:32.353	48	\N
9a468990-2784-43d9-9dad-e726902f93d8	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-01 16:39:32.355	49	\N
4bcd6c57-1d88-4be6-a658-76eaa6ae3c94	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 03:56:32.356	50	\N
016209cb-ce1b-4c71-975d-8553a124ae0e	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-11 12:43:32.359	51	\N
51043ce5-f784-46fe-b547-11d7b30056b1	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-10 07:47:32.36	52	\N
ba606631-4f46-4bcb-a44e-f63caf252a56	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-29 14:56:32.362	53	\N
5e295b11-d1f0-448c-92f8-ea401ed18665	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-22 19:17:32.363	54	\N
4ea14809-7f52-4dac-945b-bd1300738a51	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-18 16:52:32.364	55	\N
bc8bf3f0-ebaf-455e-a59c-cb401077f5ef	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-16 11:58:32.367	56	\N
ba26337a-f106-4a14-9c8e-cfd618cabf81	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 17:22:32.369	57	\N
44ad243b-76b5-4690-bea5-7ff91ddbf9e6	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-30 18:29:32.372	58	\N
825d5ba3-43ed-4622-a564-5a34e4f5f4cb	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 06:31:32.375	59	\N
90e65709-8a8d-4acb-a69b-6fcbd0e6d7b8	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-30 18:42:32.377	60	\N
89096a07-8801-4c4c-be75-39a120379925	Hello, I am writing regarding this issue: How do I upgrade my plan?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-06 19:49:32.38	61	\N
9625e861-bd84-4255-92d0-e645ee5cc4b6	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-03 19:20:32.386	62	\N
dea3517b-3441-40e8-afc8-08053b1d0487	Hello, I am writing regarding this issue: Need help setting up integration. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-11 19:16:32.388	63	\N
019f23f9-f600-492b-b13f-1f8cfb7b7410	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 23:29:32.391	64	\N
6ffcd062-f59c-4331-afdd-fe640f987012	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 15:35:32.393	65	\N
1a4397ce-2195-4b81-a8e6-1e68c044f6bd	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-09 01:56:32.395	66	\N
66cec315-dbd5-43ac-8b9e-05aaf063d624	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-26 15:15:32.4	67	\N
6e3b81d3-9f7d-45ba-8d4a-bb9acbbba993	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-30 15:44:32.405	68	\N
d44e1a6d-f4fa-4271-a1bc-57cc11771412	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-07 16:58:32.407	69	\N
9312be76-3e02-4f4c-bff5-9e12c7874e6f	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-19 21:50:32.41	70	\N
c95bf1be-e305-4f44-9ba7-eac9d52d21dc	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 15:01:32.413	71	\N
efcc1fdf-3d11-4770-ac84-8b088c5abd52	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-03 06:35:32.42	72	\N
95ff4396-824b-44d5-8bae-ea920d027705	Hello, I am writing regarding this issue: Need help setting up integration. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-13 14:45:32.424	73	\N
6d6baf2d-9502-4d45-a920-158bd910e679	Hello, I am writing regarding this issue: My account is locked. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 18:40:32.429	74	\N
d15b611b-6ce5-470d-8cb1-6123238e73c8	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-18 16:15:32.435	75	\N
01f087e5-3d2e-4638-816b-73fa6ab23ec2	Hello, I am writing regarding this issue: Subscription cancelled but still charged. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-25 07:56:32.44	76	\N
a14a55ad-1ece-4049-9652-6940dbc09f0b	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-09 07:46:32.443	77	\N
d062bf2f-a2ef-4e81-8a35-6f79f015853f	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-02 23:51:32.449	78	\N
2880aa06-6692-4b41-bb3a-4d8b964a2054	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-30 16:08:32.453	79	\N
3501134a-af36-413f-a8f8-c6c8a4d7fab2	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 12:09:32.457	80	\N
987bfc55-6526-45d3-b10e-f6e393e40029	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-12 11:50:32.464	81	\N
e4f7e97a-3073-4300-b8a2-e1d883a872fa	Hello, I am writing regarding this issue: How do I upgrade my plan?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-13 15:43:32.466	82	\N
f9bccd99-09e5-489f-86e7-444dd2812d11	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 10:05:32.467	83	\N
213afd5a-05b1-4619-aad3-05793361f3a3	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-11 10:41:32.47	84	\N
ce2164b4-5f59-49d8-b9e8-0df4c49c406e	Hello, I am writing regarding this issue: Cannot reset password. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-24 16:32:32.474	85	\N
3a45f4a9-d64c-45e8-9ce8-5e98928737b1	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-26 07:02:32.48	86	\N
5eed2f69-3a58-4cd5-85ec-3420b55a600a	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-18 03:28:32.482	87	\N
35f1f769-e6ee-4a14-9cbf-823d024ac0a5	Hello, I am writing regarding this issue: How do I upgrade my plan?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-29 02:43:32.485	88	\N
f97e62ca-ea41-462c-a56f-fd07c9f2abd0	Hello, I am writing regarding this issue: Where is my invoice?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-15 16:03:32.49	89	\N
9dd27648-d6bd-4f60-b67c-dc71a1c2b1f5	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 09:19:32.496	90	\N
6c250afa-6933-4784-a459-90482f36e1f1	Hello, I am writing regarding this issue: How do I upgrade my plan?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-22 09:29:32.498	91	\N
2e6d23dd-3d0a-4fbe-a9fe-68db93c4e76b	Hello, I am writing regarding this issue: Double charged on my credit card. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-24 08:35:32.501	92	\N
d136d920-62c4-4b11-9adf-984c786a5e3f	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-04 21:27:32.504	93	\N
589042fc-6f57-4567-a548-4fc6e50decb9	Hello, I am writing regarding this issue: Feature request: Dark mode. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-27 04:54:32.508	94	\N
0d217a68-250a-414c-a87c-1fc66e35754f	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-06-29 02:53:32.51	95	\N
a8ab0a7c-5cb0-4bfa-b513-6aac2cf0a7b0	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-19 15:49:32.512	96	\N
7ebd504f-58a6-454e-ad48-44eb18351806	Hello, I am writing regarding this issue: Refund requested for order. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 02:46:32.513	97	\N
b425dbe8-7336-4d4c-9fae-fe3cb4c5af5a	Hello, I am writing regarding this issue: Unhappy with the service. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-20 22:17:32.514	98	\N
ba32bd45-a86c-4825-a746-15a855533141	Hello, I am writing regarding this issue: API rate limit exceeded. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-19 23:52:32.515	99	\N
b40ff380-c185-4a8e-8e06-12b52a45d57e	Hello, I am writing regarding this issue: Is there a student discount?. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-21 17:23:32.516	100	\N
2fd67bde-901b-4dd6-8a45-7b2298d889a9	Hello, I am writing regarding this issue: App crashes on startup. Please get back to me as soon as possible.	CUSTOMER	\N	2026-07-21 00:50:32.517	101	\N
eccf5026-7d8b-4472-a790-90d0b60529f9	yghjvhhkvn	ADMIN	admin@example.com	2026-07-21 18:28:29.482	98	\N
03038b79-fe70-4eda-af13-be2ac1562a65	yes we will be right back to you shortly!!!!	ADMIN	admin@example.com	2026-07-21 18:33:23.52	98	\N
d422498f-9a30-42fb-af21-0898809b5023	hey	ADMIN	admin@example.com	2026-07-21 19:28:59.264	13	\N
fac45b43-61a3-4b9f-995f-82a0d62bbaf4	This is a test ticket for E2E testing.	CUSTOMER	e2e@example.com	2026-07-22 09:48:27.063	102	\N
260ffbf7-b5fd-4d4a-b062-b9f82e5d826c	E2E Reply 1784726958001	AGENT	agent@example.com	2026-07-22 13:29:18.108	102	\N
95312853-3717-465d-8474-d731b46f2eb9	E2E Multi-turn Msg 1 - 1784726966507	AGENT	agent@example.com	2026-07-22 13:29:26.651	102	\N
e984842a-9caa-4323-b9a9-087a635c9b53	E2E Multi-turn Msg 2 - 1784726966729	AGENT	agent@example.com	2026-07-22 13:29:26.857	102	\N
303dfb10-eb15-4cf7-b409-6432f5a61a9a	Hello,\nThank you for reaching out to us regarding Ticket #8478.We are very sorry for the inconvenience caused by the app crashing on startup. Our team is currently reviewing this issue, and we will get back to you with an update shortly. We truly appreciate your patience.\n\nBest regards,\nCustomer Support Team	ADMIN	admin@example.com	2026-07-26 09:11:23.011	101	\N
497237b8-3d17-4ea0-97c7-3fe27e11d9d1	aijbndfoandfaon oinaeoinfknkapk	CUSTOMER	\N	2026-07-02 07:09:32.251	4	\N
98d047a3-968c-4117-98ce-048f62ff4f1c	Hi, I have been charged incorrectly on my September billing statement. I only have the Basic plan but I was charged $149.99 twice instead of $29.99 once. I would like to dispute these charges and get a full refund of the difference. Please look into this as a matter of urgency. Thank you.	CUSTOMER	jordan.mitchell@example.com	2026-07-25 04:25:43.219	5237	<p>Hi, I have been charged incorrectly on my September billing statement.</p><p>I only have the Basic plan but I was charged $149.99 twice instead of $29.99 once.</p><p>I would like to dispute these charges and get a full refund of the difference.</p><p>Please look into this as a matter of urgency. Thank you.</p>
51bb49ea-98b2-4df3-a5d8-54c6da12bb64	Hi Tirth,\nWe have resolved the issue regarding your Kubernetes cluster on our end. Could you please check on your side to confirm if everything is now working as expected? If you continue to experience any issues or need further assistance, please let us know.\nBest regards,\nAdmin	ADMIN	admin@example.com	2026-07-28 13:58:41.614	112	\N
d653df38-7868-4de4-ac92-3c9773eacabf	Hi Jordan, thank you for reaching out to our support team.\nI've reviewed your ticket and I can see you're experiencing issues with your billing statement.\nI completely understand how frustrating unexpected charges can be, and I want to assure you that we take this very seriously.\nTo get started, I'd like to gather a few more details so we can resolve this as quickly as possible.\nCould you please confirm the invoice number shown on your billing statement?\nAdditionally, it would help to know the date range during which these unexpected charges appeared.\nIf you have any screenshots or PDF copies of the invoice, feel free to attach them to this ticket.\nOur billing team reviews all disputed charges thoroughly and typically resolves cases within 2–3 business days.\nI've flagged your case as high priority so it gets the attention it deserves.\nPlease don't hesitate to ask if you have any other questions in the meantime — I'm here to help.	AGENT	agent@example.com	2026-07-25 05:25:48.191	5237	<p>Hi Jordan, thank you for reaching out to our support team.</p><p>I've reviewed your ticket and I can see you're experiencing issues with your billing statement.</p><p>I completely understand how frustrating unexpected charges can be, and I want to assure you that we take this very seriously.</p><p>To get started, I'd like to gather a few more details so we can resolve this as quickly as possible.</p><p>Could you please confirm the invoice number shown on your billing statement?</p><p>Additionally, it would help to know the date range during which these unexpected charges appeared.</p><p>If you have any screenshots or PDF copies of the invoice, feel free to attach them to this ticket.</p><p>Our billing team reviews all disputed charges thoroughly and typically resolves cases within 2–3 business days.</p><p>I've flagged your case as high priority so it gets the attention it deserves.</p><p>Please don't hesitate to ask if you have any other questions in the meantime — I'm here to help.</p>
505680e1-7aac-4e41-b8bd-b33a9a934d05	Hello, thanks for getting back to me so promptly.\nThe invoice number is INV-2024-09341, and the charges I'm disputing appeared on my September statement.\nI was charged $149.99 on the 14th and again on the 28th, but I only subscribe to the Basic plan at $29.99 per month.\nI've been a customer for over three years without any billing issues until now.\nI've already checked my account settings and my plan clearly shows "Basic — $29.99/month".\nI did not upgrade or authorise any additional services during September.\nAttached to this reply you'll find a screenshot of my account plan page and a copy of the PDF invoice.\nI'd like a full refund of the overcharged amount as soon as possible, please.\nCould you also let me know what caused this so I can make sure it doesn't happen again?\nI really appreciate your help and hope this can be sorted out quickly.	CUSTOMER	jordan.mitchell@example.com	2026-07-25 07:49:48.216	5237	<p>Hello, thanks for getting back to me so promptly.</p><p>The invoice number is INV-2024-09341, and the charges I'm disputing appeared on my September statement.</p><p>I was charged $149.99 on the 14th and again on the 28th, but I only subscribe to the Basic plan at $29.99 per month.</p><p>I've been a customer for over three years without any billing issues until now.</p><p>I've already checked my account settings and my plan clearly shows "Basic — $29.99/month".</p><p>I did not upgrade or authorise any additional services during September.</p><p>Attached to this reply you'll find a screenshot of my account plan page and a copy of the PDF invoice.</p><p>I'd like a full refund of the overcharged amount as soon as possible, please.</p><p>Could you also let me know what caused this so I can make sure it doesn't happen again?</p><p>I really appreciate your help and hope this can be sorted out quickly.</p>
46a29005-3c3f-4647-abc8-8b28b3ca676b	Thank you for providing those details, Jordan — that's very helpful.\nI've located invoice INV-2024-09341 in our system and I can confirm I can see the discrepancy you're describing.\nIt looks like your account was inadvertently enrolled in our "Professional Add-On" bundle on September 12th.\nThis appears to have been triggered by an automated promotion that was incorrectly applied to a subset of long-term Basic accounts.\nI sincerely apologise for this error — it should never have happened to your account.\nI've now escalated your case directly to our billing department with a note requesting an immediate refund of $120.00 (the difference between what you paid and what you should have been charged).\nYour account has also been corrected so that the Professional Add-On has been removed and you are back on the Basic plan at $29.99/month.\nYou should receive a confirmation email about the refund within the next 24 hours.\nThe refund itself typically takes 5–7 business days to appear on your original payment method depending on your bank.\nAgain, I'm truly sorry for the inconvenience this has caused and I appreciate your patience.	AGENT	agent@example.com	2026-07-25 10:13:48.218	5237	<p>Thank you for providing those details, Jordan — that's very helpful.</p><p>I've located invoice INV-2024-09341 in our system and I can confirm I can see the discrepancy you're describing.</p><p>It looks like your account was inadvertently enrolled in our "Professional Add-On" bundle on September 12th.</p><p>This appears to have been triggered by an automated promotion that was incorrectly applied to a subset of long-term Basic accounts.</p><p>I sincerely apologise for this error — it should never have happened to your account.</p><p>I've now escalated your case directly to our billing department with a note requesting an immediate refund of $120.00 (the difference between what you paid and what you should have been charged).</p><p>Your account has also been corrected so that the Professional Add-On has been removed and you are back on the Basic plan at $29.99/month.</p><p>You should receive a confirmation email about the refund within the next 24 hours.</p><p>The refund itself typically takes 5–7 business days to appear on your original payment method depending on your bank.</p><p>Again, I'm truly sorry for the inconvenience this has caused and I appreciate your patience.</p>
5b4ea609-ee5b-4e87-90dd-c1cd548d1399	Thank you for looking into this so quickly — I really appreciate it.\nI'm glad to hear the issue has been identified and that my account has been corrected.\nHowever, I noticed you mentioned a refund of $120.00, but the total overcharge is actually $240.00 across both months.\nCould you please double-check? The September statement shows two charges of $149.99 each, totalling $299.98.\nAt $29.99 per month, I should have only been charged $59.98 for September, making the overcharge $240.00.\nI want to make sure the full amount is refunded, not just a partial amount.\nAlso, I'm a bit concerned — does this mean October will also be incorrect?\nI haven't received my October invoice yet, so I'd like to confirm my plan is definitely back to Basic.\nWould it be possible for you to send me written confirmation of the corrected plan and the refund amount?\nI want to keep a record in case there are any further discrepancies.	CUSTOMER	jordan.mitchell@example.com	2026-07-25 12:37:48.219	5237	<p>Thank you for looking into this so quickly — I really appreciate it.</p><p>I'm glad to hear the issue has been identified and that my account has been corrected.</p><p>However, I noticed you mentioned a refund of $120.00, but the total overcharge is actually $240.00 across both months.</p><p>Could you please double-check? The September statement shows two charges of $149.99 each, totalling $299.98.</p><p>At $29.99 per month, I should have only been charged $59.98 for September, making the overcharge $240.00.</p><p>I want to make sure the full amount is refunded, not just a partial amount.</p><p>Also, I'm a bit concerned — does this mean October will also be incorrect?</p><p>I haven't received my October invoice yet, so I'd like to confirm my plan is definitely back to Basic.</p><p>Would it be possible for you to send me written confirmation of the corrected plan and the refund amount?</p><p>I want to keep a record in case there are any further discrepancies.</p>
eae08c00-b1b3-466d-b69e-a5bdafffccc1	You are absolutely right, Jordan, and I apologise for my error in the previous message.\nI recalculated and confirmed that the total overcharge is indeed $240.00, not $120.00.\nI've corrected the refund request in our billing system to reflect the full $240.00 owed to you.\nI've also added an internal note to ensure the billing team processes the complete amount in one transaction.\nRegarding October — I've audited your account and I can confirm the Professional Add-On has been fully removed.\nYour October billing cycle will charge only $29.99, and I've set a manual review flag to verify this once the invoice is generated.\nI'll also send you a written summary email from our support address confirming: (1) the plan correction, (2) the refund amount of $240.00, and (3) the expected timeline.\nThat email should arrive within the hour.\nIf you don't see it within two hours, please check your spam folder and let me know so I can resend it.\nI truly appreciate your patience and diligence in catching my mistake — it helps us serve you better.	AGENT	agent@example.com	2026-07-25 15:01:48.22	5237	<p>You are absolutely right, Jordan, and I apologise for my error in the previous message.</p><p>I recalculated and confirmed that the total overcharge is indeed $240.00, not $120.00.</p><p>I've corrected the refund request in our billing system to reflect the full $240.00 owed to you.</p><p>I've also added an internal note to ensure the billing team processes the complete amount in one transaction.</p><p>Regarding October — I've audited your account and I can confirm the Professional Add-On has been fully removed.</p><p>Your October billing cycle will charge only $29.99, and I've set a manual review flag to verify this once the invoice is generated.</p><p>I'll also send you a written summary email from our support address confirming: (1) the plan correction, (2) the refund amount of $240.00, and (3) the expected timeline.</p><p>That email should arrive within the hour.</p><p>If you don't see it within two hours, please check your spam folder and let me know so I can resend it.</p><p>I truly appreciate your patience and diligence in catching my mistake — it helps us serve you better.</p>
d107ea64-b20d-4bf2-8879-97005c96b87e	test	ADMIN	admin@example.com	2026-07-28 14:04:27.212	112	\N
80d407bb-6a39-4c88-8e25-a46325936833	Thank you for correcting that so promptly, I do appreciate the transparency.\nI received the confirmation email a few minutes ago and the details look correct.\nI can see the refund of $240.00 has been initiated and the plan shows Basic at $29.99/month.\nI do have one more question though — the email mentions the refund will go to "the original payment method".\nI actually updated my credit card last month because my old one expired.\nWill the refund go to the new card or the old expired one?\nI wouldn't want the money to get lost or cause any complications with my bank.\nCould you also confirm the last four digits of the card the refund is being sent to?\nI just want to make sure everything is directed correctly before we proceed further.\nThanks again for all your help so far.	CUSTOMER	jordan.mitchell@example.com	2026-07-25 17:25:48.222	5237	<p>Thank you for correcting that so promptly, I do appreciate the transparency.</p><p>I received the confirmation email a few minutes ago and the details look correct.</p><p>I can see the refund of $240.00 has been initiated and the plan shows Basic at $29.99/month.</p><p>I do have one more question though — the email mentions the refund will go to "the original payment method".</p><p>I actually updated my credit card last month because my old one expired.</p><p>Will the refund go to the new card or the old expired one?</p><p>I wouldn't want the money to get lost or cause any complications with my bank.</p><p>Could you also confirm the last four digits of the card the refund is being sent to?</p><p>I just want to make sure everything is directed correctly before we proceed further.</p><p>Thanks again for all your help so far.</p>
d829e98c-587a-4f3e-bc6d-5f2302e45ae7	That's a great question, Jordan, and I'm glad you raised it before we processed the refund.\nI've checked your payment method on file and I can see the card was updated on August 22nd.\nThe refund will go to the new card ending in 4821, which is the card currently associated with your account.\nOur payment processor uses the most recently saved payment method for all refunds, so you don't need to worry about the expired card.\nI've also double-checked with our billing team to confirm the refund instruction specifies the new card explicitly.\nYou should see the $240.00 credit appear within 5–7 business days from today.\nIf the money hasn't appeared after 10 business days, please contact your bank first as processing times can vary.\nIf your bank has no record of the refund after 10 days, reach back out to us and we'll investigate immediately.\nIs there anything else I can clarify or help you with regarding this billing issue?\nWe want to make sure you feel fully confident that everything has been resolved correctly.	AGENT	agent@example.com	2026-07-25 19:49:48.223	5237	<p>That's a great question, Jordan, and I'm glad you raised it before we processed the refund.</p><p>I've checked your payment method on file and I can see the card was updated on August 22nd.</p><p>The refund will go to the new card ending in 4821, which is the card currently associated with your account.</p><p>Our payment processor uses the most recently saved payment method for all refunds, so you don't need to worry about the expired card.</p><p>I've also double-checked with our billing team to confirm the refund instruction specifies the new card explicitly.</p><p>You should see the $240.00 credit appear within 5–7 business days from today.</p><p>If the money hasn't appeared after 10 business days, please contact your bank first as processing times can vary.</p><p>If your bank has no record of the refund after 10 days, reach back out to us and we'll investigate immediately.</p><p>Is there anything else I can clarify or help you with regarding this billing issue?</p><p>We want to make sure you feel fully confident that everything has been resolved correctly.</p>
d4ea2de1-e4d9-4d24-8191-dc70ac8c2ffb	Perfect, the card ending in 4821 is my current card, so that's all correct — thank you for checking.\nI'm feeling much more confident now that the refund is on its way and my plan is fixed.\nI did want to ask about one more thing while we're here.\nI noticed that when I log into my account, there's still a banner showing "Professional Plan — Trial Active".\nEven though you mentioned the add-on has been removed, this banner seems to suggest otherwise.\nCould you check whether there's a caching issue, or if the plan change hasn't fully propagated yet?\nI've tried logging out and back in, and clearing my browser cache, but the banner persists.\nI'd hate for there to be a behind-the-scenes charge associated with a trial I never signed up for.\nPlease let me know what's happening with this banner and whether I need to take any action on my end.\nI appreciate your continued help — you've been very thorough throughout this process.	CUSTOMER	jordan.mitchell@example.com	2026-07-25 22:13:48.223	5237	<p>Perfect, the card ending in 4821 is my current card, so that's all correct — thank you for checking.</p><p>I'm feeling much more confident now that the refund is on its way and my plan is fixed.</p><p>I did want to ask about one more thing while we're here.</p><p>I noticed that when I log into my account, there's still a banner showing "Professional Plan — Trial Active".</p><p>Even though you mentioned the add-on has been removed, this banner seems to suggest otherwise.</p><p>Could you check whether there's a caching issue, or if the plan change hasn't fully propagated yet?</p><p>I've tried logging out and back in, and clearing my browser cache, but the banner persists.</p><p>I'd hate for there to be a behind-the-scenes charge associated with a trial I never signed up for.</p><p>Please let me know what's happening with this banner and whether I need to take any action on my end.</p><p>I appreciate your continued help — you've been very thorough throughout this process.</p>
68dbbc8b-0aad-4f55-92bf-c29db5c015d6	Thank you for flagging that banner, Jordan — that's definitely something we need to address.\nI've just checked your account on the backend and I can confirm your subscription is correctly set to Basic at $29.99/month with no active trials.\nWhat you're seeing is a UI display bug that affects some accounts when an add-on trial is removed mid-cycle.\nThe banner is cosmetic and does not reflect your actual billing status, so no charges will be incurred because of it.\nHowever, I completely understand that seeing it is confusing and concerning, and we should get it cleared.\nI've submitted a ticket to our front-end engineering team to clear the stale trial flag from your account's UI state.\nThis should resolve within 24–48 hours; after that, the banner will no longer appear when you log in.\nI've also marked this UI bug internally so the team can patch it for other affected customers as well.\nIn the meantime, if you want written confirmation that your plan is Basic with no trials, I can send another summary email right now.\nJust say the word and I'll have it out to you immediately.	AGENT	agent@example.com	2026-07-26 00:37:48.224	5237	<p>Thank you for flagging that banner, Jordan — that's definitely something we need to address.</p><p>I've just checked your account on the backend and I can confirm your subscription is correctly set to Basic at $29.99/month with no active trials.</p><p>What you're seeing is a UI display bug that affects some accounts when an add-on trial is removed mid-cycle.</p><p>The banner is cosmetic and does not reflect your actual billing status, so no charges will be incurred because of it.</p><p>However, I completely understand that seeing it is confusing and concerning, and we should get it cleared.</p><p>I've submitted a ticket to our front-end engineering team to clear the stale trial flag from your account's UI state.</p><p>This should resolve within 24–48 hours; after that, the banner will no longer appear when you log in.</p><p>I've also marked this UI bug internally so the team can patch it for other affected customers as well.</p><p>In the meantime, if you want written confirmation that your plan is Basic with no trials, I can send another summary email right now.</p><p>Just say the word and I'll have it out to you immediately.</p>
72a83948-0229-47d5-b9d6-635a50d4ccd0	Thank you for checking that and for reporting the bug to the engineering team.\nA written confirmation would be great actually — please do send that summary email.\nI want to have documentation in case there are any billing issues next month.\nI also wanted to mention that throughout this conversation, you have been incredibly patient and thorough.\nThis is exactly the kind of support that keeps me as a loyal customer — I genuinely appreciate it.\nI do have one small additional concern: I noticed the account page shows a "Referral Credit" of $15.00 that I don't remember earning.\nIs this credit legitimate, or could it be related to the erroneous Professional Add-On enrollment?\nI want to make sure everything on my account is accurate, not just the billing plan.\nCould you investigate where that $15.00 credit came from and confirm it's correct?\nAgain, thank you so much for sticking with me through all of these questions.	CUSTOMER	jordan.mitchell@example.com	2026-07-26 03:01:48.225	5237	<p>Thank you for checking that and for reporting the bug to the engineering team.</p><p>A written confirmation would be great actually — please do send that summary email.</p><p>I want to have documentation in case there are any billing issues next month.</p><p>I also wanted to mention that throughout this conversation, you have been incredibly patient and thorough.</p><p>This is exactly the kind of support that keeps me as a loyal customer — I genuinely appreciate it.</p><p>I do have one small additional concern: I noticed the account page shows a "Referral Credit" of $15.00 that I don't remember earning.</p><p>Is this credit legitimate, or could it be related to the erroneous Professional Add-On enrollment?</p><p>I want to make sure everything on my account is accurate, not just the billing plan.</p><p>Could you investigate where that $15.00 credit came from and confirm it's correct?</p><p>Again, thank you so much for sticking with me through all of these questions.</p>
378bb735-96eb-4f28-8d28-80adfae59c59	Thank you for your kind words, Jordan — it's genuinely my pleasure to help you get this sorted out.\nI've just sent the written summary email; please check your inbox in the next few minutes.\nRegarding the $15.00 Referral Credit — I looked into this right away.\nThe credit was applied on September 10th and is associated with a referral code redeemed by a new account: sam.p@webdesigns.io.\nThis is entirely separate from the billing issue and appears to be a legitimate referral reward.\nOur referral program gives both the referrer and the new user $15.00 in account credit when the new user completes their first paid month.\nIf you did refer someone with that email address, the credit is genuinely yours to use.\nIf you didn't refer that person, it's possible someone used your referral link without your knowledge — which is permitted under our terms.\nEither way, the credit is valid, has no expiration date, and will be applied automatically to your next invoice.\nPlease let me know if you have any further questions about the referral credit or anything else on your account.	AGENT	agent@example.com	2026-07-26 05:25:48.226	5237	<p>Thank you for your kind words, Jordan — it's genuinely my pleasure to help you get this sorted out.</p><p>I've just sent the written summary email; please check your inbox in the next few minutes.</p><p>Regarding the $15.00 Referral Credit — I looked into this right away.</p><p>The credit was applied on September 10th and is associated with a referral code redeemed by a new account: sam.p@webdesigns.io.</p><p>This is entirely separate from the billing issue and appears to be a legitimate referral reward.</p><p>Our referral program gives both the referrer and the new user $15.00 in account credit when the new user completes their first paid month.</p><p>If you did refer someone with that email address, the credit is genuinely yours to use.</p><p>If you didn't refer that person, it's possible someone used your referral link without your knowledge — which is permitted under our terms.</p><p>Either way, the credit is valid, has no expiration date, and will be applied automatically to your next invoice.</p><p>Please let me know if you have any further questions about the referral credit or anything else on your account.</p>
78fc666f-dea4-4f1e-bde5-4a918fd3b2ea	E2E Reply 1785333331563	AGENT	agent@example.com	2026-07-29 13:55:31.676	113	\N
af691805-4bb4-4622-b822-e6f3c04edcf0	Oh, that's interesting! Sam does ring a bell — I believe I shared my referral link on a community forum a couple of months ago.\nSo the $15.00 credit is legitimate and I actually get to keep it — that's a pleasant surprise!\nI received the confirmation email you sent and all the details look correct.\nIt clearly states Basic plan at $29.99/month, no active trials, and a pending refund of $240.00.\nI'm much more reassured now and I think we're almost done here.\nOne final thing: will the refund show on my credit card statement as a single $240.00 transaction?\nOr might it appear as two separate $120.00 credits?\nI just want to know what to look out for when reviewing my statement.\nThis has been a lengthy ticket but I feel like everything has been handled with great care.\nYou've been outstanding — please pass on my thanks to your team and your billing department as well.	CUSTOMER	jordan.mitchell@example.com	2026-07-26 07:49:48.227	5237	<p>Oh, that's interesting! Sam does ring a bell — I believe I shared my referral link on a community forum a couple of months ago.</p><p>So the $15.00 credit is legitimate and I actually get to keep it — that's a pleasant surprise!</p><p>I received the confirmation email you sent and all the details look correct.</p><p>It clearly states Basic plan at $29.99/month, no active trials, and a pending refund of $240.00.</p><p>I'm much more reassured now and I think we're almost done here.</p><p>One final thing: will the refund show on my credit card statement as a single $240.00 transaction?</p><p>Or might it appear as two separate $120.00 credits?</p><p>I just want to know what to look out for when reviewing my statement.</p><p>This has been a lengthy ticket but I feel like everything has been handled with great care.</p><p>You've been outstanding — please pass on my thanks to your team and your billing department as well.</p>
bc383bee-feec-4770-8a5f-4dd9d72a3f26	Great to hear the referral credit is one you remember — it belongs to you, enjoy it on your next invoice!\nTo answer your question about the refund format: it will appear as a single $240.00 credit transaction on your card statement.\nOur payment processor batches the refund as one reversal rather than splitting it, so look out for a single line item.\nThe description on your statement will likely read something like "Refund – Support Billing Adjustment", depending on your bank's formatting.\nI've passed your kind words along to the billing team and my supervisor — feedback like yours means a great deal to us.\nI'll keep this ticket open for another 48 hours to confirm the UI banner disappears as expected.\nIf the banner is still showing after 48 hours, please reply here and I'll escalate it immediately.\nSimilarly, if the refund hasn't arrived within 10 business days, don't hesitate to reach out and I'll investigate personally.\nIt has genuinely been a pleasure working through this with you, Jordan.\nYou've been patient, clear, and thorough — exactly the kind of interaction that makes this job rewarding.	AGENT	agent@example.com	2026-07-26 10:13:48.228	5237	<p>Great to hear the referral credit is one you remember — it belongs to you, enjoy it on your next invoice!</p><p>To answer your question about the refund format: it will appear as a single $240.00 credit transaction on your card statement.</p><p>Our payment processor batches the refund as one reversal rather than splitting it, so look out for a single line item.</p><p>The description on your statement will likely read something like "Refund – Support Billing Adjustment", depending on your bank's formatting.</p><p>I've passed your kind words along to the billing team and my supervisor — feedback like yours means a great deal to us.</p><p>I'll keep this ticket open for another 48 hours to confirm the UI banner disappears as expected.</p><p>If the banner is still showing after 48 hours, please reply here and I'll escalate it immediately.</p><p>Similarly, if the refund hasn't arrived within 10 business days, don't hesitate to reach out and I'll investigate personally.</p><p>It has genuinely been a pleasure working through this with you, Jordan.</p><p>You've been patient, clear, and thorough — exactly the kind of interaction that makes this job rewarding.</p>
c6759959-fcea-4d76-85e9-de7a82c3bc49	Thank you so much — I'll watch out for the single $240.00 transaction on my statement.\nI logged back in today and I'm happy to report that the "Professional Plan — Trial Active" banner is gone.\nIt must have cleared faster than the 48-hour estimate, which is a great sign.\nMy account now shows Basic plan at $29.99/month with no trials and the $15.00 referral credit listed.\nEverything looks clean and correct from my end.\nI still haven't received the refund on my credit card yet, but I understand it can take up to 10 business days.\nI'll keep an eye on my statement and come back if I don't see it by next week.\nIs there anything I need to do on my end to help process the refund, or is it fully automated?\nI also wanted to confirm — once the refund is received and I'm satisfied, should I mark this ticket as resolved?\nOr will the system automatically close it after a period of inactivity?	CUSTOMER	jordan.mitchell@example.com	2026-07-26 12:37:48.229	5237	<p>Thank you so much — I'll watch out for the single $240.00 transaction on my statement.</p><p>I logged back in today and I'm happy to report that the "Professional Plan — Trial Active" banner is gone.</p><p>It must have cleared faster than the 48-hour estimate, which is a great sign.</p><p>My account now shows Basic plan at $29.99/month with no trials and the $15.00 referral credit listed.</p><p>Everything looks clean and correct from my end.</p><p>I still haven't received the refund on my credit card yet, but I understand it can take up to 10 business days.</p><p>I'll keep an eye on my statement and come back if I don't see it by next week.</p><p>Is there anything I need to do on my end to help process the refund, or is it fully automated?</p><p>I also wanted to confirm — once the refund is received and I'm satisfied, should I mark this ticket as resolved?</p><p>Or will the system automatically close it after a period of inactivity?</p>
f2e2f95d-9094-4823-a55d-f587a6745269	Excellent news about the banner — I'm really pleased that resolved so quickly!\nTo answer your questions: the refund is entirely automated from our end, so there's nothing you need to do.\nOur payment processor handles it end-to-end once the billing team approves the instruction, which they already have.\nRegarding closing the ticket — you're welcome to mark it as resolved at any time once you're satisfied.\nAlternatively, our system will automatically move the ticket to "Resolved" status after 7 days of no new activity.\nI'd suggest waiting until the refund arrives on your statement before marking it resolved, just so you have the option to ask follow-up questions easily.\nOnce it's marked resolved, you can still reopen it within 30 days if any issues arise.\nI'll also set a reminder on my end to follow up with you in 8 business days to confirm the refund has landed.\nThat way, even if you forget to check back, we'll make sure nothing slips through the cracks.\nPlease enjoy the rest of your week, Jordan — it's been a genuine pleasure assisting you!	AGENT	agent@example.com	2026-07-26 15:01:48.23	5237	<p>Excellent news about the banner — I'm really pleased that resolved so quickly!</p><p>To answer your questions: the refund is entirely automated from our end, so there's nothing you need to do.</p><p>Our payment processor handles it end-to-end once the billing team approves the instruction, which they already have.</p><p>Regarding closing the ticket — you're welcome to mark it as resolved at any time once you're satisfied.</p><p>Alternatively, our system will automatically move the ticket to "Resolved" status after 7 days of no new activity.</p><p>I'd suggest waiting until the refund arrives on your statement before marking it resolved, just so you have the option to ask follow-up questions easily.</p><p>Once it's marked resolved, you can still reopen it within 30 days if any issues arise.</p><p>I'll also set a reminder on my end to follow up with you in 8 business days to confirm the refund has landed.</p><p>That way, even if you forget to check back, we'll make sure nothing slips through the cracks.</p><p>Please enjoy the rest of your week, Jordan — it's been a genuine pleasure assisting you!</p>
9d590986-4e86-484a-89b4-dd095c4be772	Hi Support Team,\n\nWe are running PostgreSQL 16 in production for our ticketing platform, and under peak load (~5,000 active concurrent requests), we are noticing elevated connection latency and occasional "connection limit exceeded" errors.\n\nWe are currently using standard pg.Pool settings with max: 20 instances across 10 API pods.\nCould you help us with best practices on:\n1. Configuring connection pooling (e.g. PgBouncer vs application-level pg.Pool settings).\n2. Recommended index types (B-Tree vs GIN/GiST) for multi-column JSONB filters.\n3. Tuning work_mem and max_connections parameters safely.\n\nAny guidance or documentation would be greatly appreciated!\n\nBest regards,\nAlex Rivera	CUSTOMER	alex.rivera@techcorp.io	2026-07-27 05:43:50.526	103	<p>Hi Support Team,<br/><br/>We are running PostgreSQL 16 in production for our ticketing platform, and under peak load (~5,000 active concurrent requests), we are noticing elevated connection latency and occasional "connection limit exceeded" errors.<br/><br/>We are currently using standard pg.Pool settings with max: 20 instances across 10 API pods.<br/>Could you help us with best practices on:<br/>1. Configuring connection pooling (e.g. PgBouncer vs application-level pg.Pool settings).<br/>2. Recommended index types (B-Tree vs GIN/GiST) for multi-column JSONB filters.<br/>3. Tuning work_mem and max_connections parameters safely.<br/><br/>Any guidance or documentation would be greatly appreciated!<br/><br/>Best regards,<br/>Alex Rivera</p>
98f702da-db06-42a4-bcbc-b788525da286	E2E Reply 1785333365167	AGENT	agent@example.com	2026-07-29 13:56:05.276	113	\N
3618015b-1e9c-49c3-b9b6-816621fda935	That's a really thoughtful approach — thank you for setting that follow-up reminder.\nI feel very well looked after and I'm impressed with how thoroughly you've handled this case.\nI'll wait for the refund before marking the ticket resolved, as you suggested.\nQuick update: I checked my October invoice that just generated, and it shows $29.99 exactly — perfect!\nSo the billing correction has definitely taken full effect, which is a huge relief.\nThe $15.00 referral credit is shown as a deduction, so October's total is actually only $14.99.\nThat's a nice way to soften what has been a stressful month of billing issues!\nI'm going to set a reminder to check my credit card statement in a week.\nIf the refund shows up before your follow-up, I'll come back here and let you know so you don't need to worry.\nThanks once again for everything — this has been the best support experience I've had in years.	CUSTOMER	jordan.mitchell@example.com	2026-07-26 17:25:48.231	5237	<p>That's a really thoughtful approach — thank you for setting that follow-up reminder.</p><p>I feel very well looked after and I'm impressed with how thoroughly you've handled this case.</p><p>I'll wait for the refund before marking the ticket resolved, as you suggested.</p><p>Quick update: I checked my October invoice that just generated, and it shows $29.99 exactly — perfect!</p><p>So the billing correction has definitely taken full effect, which is a huge relief.</p><p>The $15.00 referral credit is shown as a deduction, so October's total is actually only $14.99.</p><p>That's a nice way to soften what has been a stressful month of billing issues!</p><p>I'm going to set a reminder to check my credit card statement in a week.</p><p>If the refund shows up before your follow-up, I'll come back here and let you know so you don't need to worry.</p><p>Thanks once again for everything — this has been the best support experience I've had in years.</p>
05f6b2fa-a0b6-415c-90e6-14e9f97c3f6a	What fantastic news about the October invoice — $14.99 after the referral credit is a great outcome!\nI'm so glad the correction came through in time for the new billing cycle.\nI'll note in your case file that October has been verified as correct, so we have a full paper trail.\nThank you for being so proactive in checking and reporting back — it really helps us close the loop thoroughly.\nAt this point, the only outstanding item is the $240.00 refund hitting your credit card, which should come through within the next few business days.\nThe follow-up reminder on my side is set for 8 business days from today, so you'll hear from me either way.\nI also want to mention: if you'd be willing to leave a short review of your support experience, we'd truly appreciate it.\nYou can find the feedback link in the confirmation email I sent earlier — it only takes a minute.\nOf course, there's absolutely no pressure and your account experience is our priority regardless.\nWishing you a smooth and billing-issue-free rest of the month, Jordan!	AGENT	agent@example.com	2026-07-26 19:49:48.231	5237	<p>What fantastic news about the October invoice — $14.99 after the referral credit is a great outcome!</p><p>I'm so glad the correction came through in time for the new billing cycle.</p><p>I'll note in your case file that October has been verified as correct, so we have a full paper trail.</p><p>Thank you for being so proactive in checking and reporting back — it really helps us close the loop thoroughly.</p><p>At this point, the only outstanding item is the $240.00 refund hitting your credit card, which should come through within the next few business days.</p><p>The follow-up reminder on my side is set for 8 business days from today, so you'll hear from me either way.</p><p>I also want to mention: if you'd be willing to leave a short review of your support experience, we'd truly appreciate it.</p><p>You can find the feedback link in the confirmation email I sent earlier — it only takes a minute.</p><p>Of course, there's absolutely no pressure and your account experience is our priority regardless.</p><p>Wishing you a smooth and billing-issue-free rest of the month, Jordan!</p>
8e4bb5dd-78d3-4e60-a630-eb3a469c99a9	Great update — I'll keep an eye on the card and let you know as soon as the refund appears.\nJust to close the loop on a few things: I left a 5-star review on the feedback link from your email.\nI mentioned how patient and thorough you were throughout the whole process.\nI also noted that the issue stemmed from an automated system error, which I thought was worth flagging for your team's benefit.\nOne thing I wanted to raise — since this billing error affected "a subset of long-term Basic accounts" as you mentioned earlier, are other customers aware?\nI'd hate to think that other long-term customers are being overcharged and don't know it yet.\nIs there a plan to notify affected accounts proactively, or do customers have to report it themselves?\nI'm not trying to create more work for you, I just feel it's the right thing to ask.\nEither way, I'm satisfied with how my case has been handled and I'm grateful for your help.\nLooking forward to your follow-up in a few days!	CUSTOMER	jordan.mitchell@example.com	2026-07-26 22:13:48.232	5237	<p>Great update — I'll keep an eye on the card and let you know as soon as the refund appears.</p><p>Just to close the loop on a few things: I left a 5-star review on the feedback link from your email.</p><p>I mentioned how patient and thorough you were throughout the whole process.</p><p>I also noted that the issue stemmed from an automated system error, which I thought was worth flagging for your team's benefit.</p><p>One thing I wanted to raise — since this billing error affected "a subset of long-term Basic accounts" as you mentioned earlier, are other customers aware?</p><p>I'd hate to think that other long-term customers are being overcharged and don't know it yet.</p><p>Is there a plan to notify affected accounts proactively, or do customers have to report it themselves?</p><p>I'm not trying to create more work for you, I just feel it's the right thing to ask.</p><p>Either way, I'm satisfied with how my case has been handled and I'm grateful for your help.</p><p>Looking forward to your follow-up in a few days!</p>
7d1dea09-cbc1-49b2-91bf-ecf0e0c712b8	Thank you so much for the 5-star review, Jordan — that genuinely means a lot to me and the team.\nYour question about other affected customers is an excellent one and shows real community-mindedness.\nI can confirm that our engineering and billing teams have already identified all accounts impacted by the same automation error.\nA proactive notification email is being prepared and will be sent to all affected customers within the next 24 hours.\nEach customer will receive a notification explaining the error, the corrected plan, and the refund that will be applied automatically.\nNo affected customer will need to contact support themselves — refunds are being processed in bulk.\nYour ticket actually helped us identify and document the issue more thoroughly, so in a way, you've helped other customers too.\nI've added a note to your file recognising your contribution to the investigation.\nI'm truly grateful for your patience, your attention to detail, and your willingness to stick with us through a frustrating situation.\nYour follow-up check-in is on my calendar — speak soon, Jordan, and take care!	AGENT	agent@example.com	2026-07-27 00:37:48.234	5237	<p>Thank you so much for the 5-star review, Jordan — that genuinely means a lot to me and the team.</p><p>Your question about other affected customers is an excellent one and shows real community-mindedness.</p><p>I can confirm that our engineering and billing teams have already identified all accounts impacted by the same automation error.</p><p>A proactive notification email is being prepared and will be sent to all affected customers within the next 24 hours.</p><p>Each customer will receive a notification explaining the error, the corrected plan, and the refund that will be applied automatically.</p><p>No affected customer will need to contact support themselves — refunds are being processed in bulk.</p><p>Your ticket actually helped us identify and document the issue more thoroughly, so in a way, you've helped other customers too.</p><p>I've added a note to your file recognising your contribution to the investigation.</p><p>I'm truly grateful for your patience, your attention to detail, and your willingness to stick with us through a frustrating situation.</p><p>Your follow-up check-in is on my calendar — speak soon, Jordan, and take care!</p>
c5979c7e-09cf-4105-b8e8-daf05ffe184c	That is really great to hear — I'm glad other customers are being notified proactively rather than finding out themselves.\nAnd it's kind of you to mention that my ticket contributed to identifying the issue more thoroughly.\nI just checked my credit card account online and the $240.00 refund has just appeared — it landed faster than expected!\nThe transaction description reads "Refund – Support Billing Adjustment" exactly as you described it would.\nSo as of right now, everything is fully resolved: my plan is correct, the October invoice is correct, and the refund has arrived.\nI'm going to mark this ticket as resolved.\nYou've been absolutely exceptional throughout this entire process — patient, knowledgeable, accurate, and genuinely caring.\nThis is the gold standard of customer support and I will not hesitate to recommend your service to others because of this experience.\nThank you from the bottom of my heart for turning a really stressful situation into a positive one.\nTake care, and I hope you have a wonderful rest of your day!	CUSTOMER	jordan.mitchell@example.com	2026-07-27 03:01:48.236	5237	<p>That is really great to hear — I'm glad other customers are being notified proactively rather than finding out themselves.</p><p>And it's kind of you to mention that my ticket contributed to identifying the issue more thoroughly.</p><p>I just checked my credit card account online and the $240.00 refund has just appeared — it landed faster than expected!</p><p>The transaction description reads "Refund – Support Billing Adjustment" exactly as you described it would.</p><p>So as of right now, everything is fully resolved: my plan is correct, the October invoice is correct, and the refund has arrived.</p><p>I'm going to mark this ticket as resolved.</p><p>You've been absolutely exceptional throughout this entire process — patient, knowledgeable, accurate, and genuinely caring.</p><p>This is the gold standard of customer support and I will not hesitate to recommend your service to others because of this experience.</p><p>Thank you from the bottom of my heart for turning a really stressful situation into a positive one.</p><p>Take care, and I hope you have a wonderful rest of your day!</p>
08b9beaf-4410-40b1-bf1d-04ec74786673	Hi Support,\n\nMy annual subscription renewed automatically yesterday, but I meant to cancel before the renewal date as our company has migrated to a different workspace.\n\nCould you please process a full refund for this charge ($299.00) back to my original payment method? I haven't used any services on the account since the renewal.\n\nPlease let me know how to proceed or if you need any additional billing confirmation from my side.\n\nThank you,\nEmily Watson	CUSTOMER	emily.watson@example.com	2026-07-27 05:46:01.614	104	<p>Hi Support,<br/><br/>My annual subscription renewed automatically yesterday, but I meant to cancel before the renewal date as our company has migrated to a different workspace.<br/><br/>Could you please process a full refund for this charge ($299.00) back to my original payment method? I haven't used any services on the account since the renewal.<br/><br/>Please let me know how to proceed or if you need any additional billing confirmation from my side.<br/><br/>Thank you,<br/>Emily Watson</p>
d1ac6b47-9f23-42a2-8369-03616b832148	Hello Support,\n\nWe are observing repeating PostgreSQL deadlock errors on our production database cluster during peak hours.\nThe error log shows:\n"ERROR: deadlock detected; Process 48102 waits for ShareLock on transaction 920194; blocked by process 48108."\n\nOur queries use INSERT ... ON CONFLICT (id) DO UPDATE.\nCould you help us analyze why these deadlocks occur when updating related foreign key rows simultaneously?\nAlso, do you recommend switching to explicit row-level locking (SELECT ... FOR UPDATE) or ordering locks by primary key?\n\nThanks,\nMarcus	CUSTOMER	marcus.vance@databasedesigns.io	2026-07-27 05:56:06.007	105	<p>Hello Support,<br/><br/>We are observing repeating PostgreSQL deadlock errors on our production database cluster during peak hours.<br/>The error log shows:<br/>"ERROR: deadlock detected; Process 48102 waits for ShareLock on transaction 920194; blocked by process 48108."<br/><br/>Our queries use INSERT ... ON CONFLICT (id) DO UPDATE.<br/>Could you help us analyze why these deadlocks occur when updating related foreign key rows simultaneously?<br/>Also, do you recommend switching to explicit row-level locking (SELECT ... FOR UPDATE) or ordering locks by primary key?<br/><br/>Thanks,<br/>Marcus</p>
897c3f21-3c38-4e36-a3f0-7eba72b8a548	Hello,\nI forgot my account password. How can I reset my password to regain access to my account?\nThank you!	CUSTOMER	elena.rostova@example.com	2026-07-27 07:14:48.731	106	\N
07db26f9-189b-4767-a1ba-0676df384f6b	Hi Team,\nOur Apache Kafka consumer group is failing with CommitFailedException during rebalances.\nCan an engineer help inspect our session.timeout.ms and max.poll.interval.ms settings?	CUSTOMER	devon.miles@techstack.io	2026-07-27 07:14:54.158	107	\N
63df0b4e-6d4b-44bf-987a-0c00fc0853ea	Hi Support,\n\nI am a new user and would like to know how to create an account on your platform.\nCould you please guide me through the registration steps?\n\nThanks,\nSophia	CUSTOMER	sophia.sterling@example.com	2026-07-27 07:24:07.554	108	\N
8894318b-0ba4-4dca-bf10-102d25909e41	Hi Support,\n\nI am a new user and would like to know how to create an account on your platform.\nCould you please guide me through the registration steps?\n\nThanks,\nSophia	CUSTOMER	sophia.sterling@example.com	2026-07-27 08:50:57.868	109	\N
f5750600-5919-4bc8-a3d9-1469e13bad69	Hello, to reset your password and regain access to your account, please follow these steps:\n1. Go to the login page.\n2. Click 'Forgot Password'.\n3. Enter your registered email address.\n4. Follow the instructions sent in the reset email. If you do not receive the email, please check your spam folder.	AI	ai-assistant@support.local	2026-07-27 07:14:54.131	106	<p style="margin-bottom: 8px;">Hello, to reset your password and regain access to your account, please follow these steps:</p><ol style="list-style-type: decimal; padding-left: 20px; margin-bottom: 8px;"><li style="margin-bottom: 4px;">Go to the login page.</li><li style="margin-bottom: 4px;">Click 'Forgot Password'.</li><li style="margin-bottom: 4px;">Enter your registered email address.</li><li style="margin-bottom: 4px;">Follow the instructions sent in the reset email. If you do not receive the email, please check your spam folder.</li></ol>
05c8543b-275c-43ea-8481-cc7baa42e104	Hi Sophia, To create an account on our platform, please follow these steps:\n1. Click the Sign Up button.\n2. Enter your name, email, and password.\n3. Verify your email address.\n4. Log in to access your account. Please let us know if you have any questions!	AI	ai-assistant@support.local	2026-07-27 07:24:12.826	108	<p style="margin-bottom: 8px;">Hi Sophia, To create an account on our platform, please follow these steps:</p><ol style="list-style-type: decimal; padding-left: 20px; margin-bottom: 8px;"><li style="margin-bottom: 4px;">Click the Sign Up button.</li><li style="margin-bottom: 4px;">Enter your name, email, and password.</li><li style="margin-bottom: 4px;">Verify your email address.</li><li style="margin-bottom: 4px;">Log in to access your account. Please let us know if you have any questions!</li></ol>
69565587-ec48-4223-82a3-e4ba28a4d9ed	Hi Sophia,\n\nThank you for reaching out! You can easily create an account by following these steps:\n1. Click the Sign Up button.\n2. Enter your name, email, and password.\n3. Verify your email address.\n4. Log in to access your account.\n\nPlease let us know if you have any questions or need further assistance!	AI	ai-assistant@support.local	2026-07-27 08:51:04.582	109	<p style="margin-bottom: 8px;">Hi Sophia,</p><ol style="list-style-type: decimal; padding-left: 20px; margin-bottom: 8px;"><li style="margin-bottom: 4px;">Click the Sign Up button.</li><li style="margin-bottom: 4px;">Enter your name, email, and password.</li><li style="margin-bottom: 4px;">Verify your email address.</li><li style="margin-bottom: 4px;">Log in to access your account.</li></ol>
90c2be93-7750-48da-90bc-8c994a82f128	Hi Support Team,\n\nOur production deployment is failing in Kubernetes node pool 'us-east-1a'.\nThe pod status shows CrashLoopBackOff and container status is OOMKilled with exit code 137.\n\nMemory request is set to 512Mi and limit is set to 1Gi. Could an engineer help inspect if our Java heap configuration (-Xmx) is exceeding cgroup v2 memory limits?\n\nThanks,\nLiam	CUSTOMER	liam.oconnor@cloudscale.io	2026-07-27 08:59:03.457	110	\N
275301fa-e988-4cbd-ac07-074979928515	test password	CUSTOMER	tirth1357@gmail.com	2026-07-28 10:10:38.529	111	<div dir="ltr">test password </div>
0afa5e6a-cf81-45f1-89fc-c02cb05d4163	Hello,\n\nIf you are experiencing issues with your password or need to reset it, please follow these steps:\n\n1. Go to the login page.\n2. Click Forgot Password.\n3. Enter your registered email address.\n4. Follow the instructions in the reset email.\n\nIf you do not receive the email, please check your spam folder.	AI	ai-assistant@support.local	2026-07-28 10:10:51.347	111	<p style="margin-bottom: 8px;">Hello,</p><ol style="list-style-type: decimal; padding-left: 20px; margin-bottom: 8px;"><li style="margin-bottom: 4px;">Go to the login page.</li><li style="margin-bottom: 4px;">Click Forgot Password.</li><li style="margin-bottom: 4px;">Enter your registered email address.</li><li style="margin-bottom: 4px;">Follow the instructions in the reset email.</li></ol>
0644d529-be79-4f5d-ac9b-c87412bc9f93	Hi Tirth,\nThank you for reaching out to us. We have resolved the issue regarding your password, and your account should now be working properly. Please try logging in again, and let us know if you need any further assistance.\nBest regards,\nAdmin	ADMIN	admin@example.com	2026-07-28 10:34:38.567	111	\N
6159568f-097d-4bd6-8962-c0f19de3d316	the issue is fixed thanks	ADMIN	admin@example.com	2026-07-28 10:37:02.447	111	\N
0d721340-13b0-4f55-8670-eee9073f711a	issue is fixed	ADMIN	admin@example.com	2026-07-28 10:55:52.411	111	\N
f41b2df3-c084-4de4-bb15-ae84a602f962	My kubernetes cluster is not respsoding.IT rams intp crashloopback off\nevery time.Please fix the issue as soon as possible.	CUSTOMER	tirth1357@gmail.com	2026-07-28 13:56:30.461	112	<div dir="ltr">My kubernetes cluster is not respsoding.IT rams intp crashloopback off every time.Please fix the issue as soon as possible.</div>
f528f00c-65d2-42dc-9b42-7d1043710087	My kubernetes cluster is not respsoding.IT rams intp crashloopback off\nevery time.Please fix the issue as soon as possible.	CUSTOMER	tirth1357@gmail.com	2026-07-28 13:57:56.201	113	<div dir="ltr">My kubernetes cluster is not respsoding.IT rams intp crashloopback off every time.Please fix the issue as soon as possible.</div>
3eafedfd-4422-4e0e-a093-b8d7ad145152	its working now please check	ADMIN	admin@example.com	2026-07-28 14:00:52.799	112	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (id, "expiresAt", token, "createdAt", "updatedAt", "ipAddress", "userAgent", "userId") FROM stdin;
nMvDbBkO1m4pnpbY4Yjq6kghfN0ogfLT	2026-07-28 06:43:44.401	n5SdhLFSL79XvSugAj8Gij9W7Hmxo23M	2026-07-21 06:43:44.401	2026-07-21 06:43:44.401	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
zsM6momwm74B61kDcgX23lJzEYEhIO4e	2026-07-28 06:43:45.519	0JeCgo75TzqfBvsTQCFwVtgSF6VTG2yO	2026-07-21 06:43:45.519	2026-07-21 06:43:45.519	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
xzyxea58PYK88Bkl21o8A2HcZFmQu4lW	2026-07-28 06:43:45.524	ChSJvHNgaT1E4TF1U39E0Yeqe2alTv6D	2026-07-21 06:43:45.524	2026-07-21 06:43:45.524	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
uRheRG5w7Yz4HwjZXLlQ5VXc7tcmjO9o	2026-07-28 06:43:45.941	TXi02WBAGvZ1dmNGfQHrRXgRdnSYq8em	2026-07-21 06:43:45.942	2026-07-21 06:43:45.942	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
o5hyDkBb0Nr0I8xXLWDHS10D1SjtG3F3	2026-07-28 06:43:47.56	k3k0RmnGtxtib46mkfawGCNw6ng266L1	2026-07-21 06:43:47.56	2026-07-21 06:43:47.56	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
QbvyrE2m54v7Rp0ixEZKxjHPfd4P6MpE	2026-07-28 06:43:47.561	WBl4ysmnZhWqfqwB1jKnMDS2puIC6EOO	2026-07-21 06:43:47.562	2026-07-21 06:43:47.562	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
FuM3J4gM7qpHlSi7raWBAxjHIjj2cb1O	2026-07-28 06:43:48.591	lrq9P66dJOP3574sYLQG7cgi71vXIKSM	2026-07-21 06:43:48.591	2026-07-21 06:43:48.591	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7l6cIdmwQfIke4Rof7197eSRxzouJ0BW	2026-07-28 06:43:48.592	6edkJ5VPH440bzck5EKFPVDNU0YCIJm2	2026-07-21 06:43:48.592	2026-07-21 06:43:48.592	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KdU5S2pOyPuSbpwMG3hHJEURXLIQQEQp	2026-07-28 06:43:48.633	a0dFeRFQMOXv7wsMKXnSb8uAnENwLhjz	2026-07-21 06:43:48.633	2026-07-21 06:43:48.633	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DbdqQ6PArwrxO7zaOkq2o1oO2KjdYPZu	2026-07-28 06:43:49.682	rj1GtOTMZ8RQ6UC9mgjGQt0QcNPRDQYn	2026-07-21 06:43:49.682	2026-07-21 06:43:49.682	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jXFCyyEHKSIzkwjyiymYI4EYXG6hAC6m	2026-07-28 06:43:50.593	g6hVeFCeEdsy6sq6w1zIUPjFtzfq3HTp	2026-07-21 06:43:50.593	2026-07-21 06:43:50.593	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
HEL4gQcuysNnDrXRRdzyuUjhYcfmMBGM	2026-07-28 06:43:51.657	WHCBszO76mKvMfD0NzN3cYOm6Z3T0hpN	2026-07-21 06:43:51.657	2026-07-21 06:43:51.657	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
h9jpChqDuWkTLsJgL4agCp8CVQFej1ut	2026-07-28 06:43:52.036	LiDgbGrs4kDjx7UG42Y03cwqZ8Y4D99f	2026-07-21 06:43:52.036	2026-07-21 06:43:52.036	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
aMSJuvdvZsC8fdkWqOSDHKgYXraSjwo0	2026-07-28 06:43:52.689	ZCcTwf7gjNw6pTpVzHgMtrLLl0EexedD	2026-07-21 06:43:52.694	2026-07-21 06:43:52.694	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eGF3qJaxAW6yTjSokwsoyyw6EScG2PXn	2026-07-28 06:43:53.64	DNYSlBeLvetU14cU556OvLPDjKUcDVhN	2026-07-21 06:43:53.64	2026-07-21 06:43:53.64	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
PgfPVRZHZIpaYt8JZoM1s2MJhnmKHjUx	2026-07-28 06:43:53.641	GdjoC3qRNTm9oByJAkgI3Y3dPrYjir0c	2026-07-21 06:43:53.641	2026-07-21 06:43:53.641	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
trtkaknJB6if06cB6C1edfLEfpcxxJf1	2026-07-28 06:43:53.649	1lw0mDSdkAXeb6F3abtbsP3DTxSaJCaU	2026-07-21 06:43:53.649	2026-07-21 06:43:53.649	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
n43N3fHBBRD32Khb5cppmDZnoGELGEJ0	2026-07-28 06:43:56.046	0LWE1mXJT4F1pBHAhTyC396uHOXSTCuv	2026-07-21 06:43:56.046	2026-07-21 06:43:56.046	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
QbjitUIsm40tl0toTWLdRDPTTbR8iFiQ	2026-07-28 06:43:57.183	jdifnx1kMdUaxZscgbyBlinxQKxtXXQQ	2026-07-21 06:43:57.183	2026-07-21 06:43:57.183	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
sGr6qEPcn9scoRaRbuB0Kl2QfFU6KxIU	2026-07-28 06:43:58.042	MBNzqkXJlBumM9WMnMKoAHQVWTCv1gf4	2026-07-21 06:43:58.042	2026-07-21 06:43:58.042	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eHuaNBnkxNdnHzktRaeh4NIfmmyM00QH	2026-07-28 06:43:58.33	tPbn7pDZuC3hzHaM3ipAuiQgm54petXR	2026-07-21 06:43:58.33	2026-07-21 06:43:58.33	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
FX2YDZPYNzLbeAhYHrd1lRuX5REjp6kY	2026-07-28 06:43:59.094	k2PT1XH4kzjRPppMLylPZrhaC6sVovp2	2026-07-21 06:43:59.094	2026-07-21 06:43:59.094	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eLtA3zKFMu7g45dPsN7tJwZ0kExkxE36	2026-07-28 06:43:59.096	b2aO9TKxCCZLseWKgIngdm4Z84fJdwsl	2026-07-21 06:43:59.096	2026-07-21 06:43:59.096	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
5mYyklXR9gYn220UUyaOdj9az1uSUVyY	2026-07-28 06:44:00.213	zXoYObAXkt9LqAbr3tfWzWB8oCPwZTTg	2026-07-21 06:44:00.213	2026-07-21 06:44:00.213	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
oL740wZG1KABoZgL65SSXJK64UelRYXc	2026-07-28 06:44:00.756	hxTd1YpU4zv8J4UQBa8DDsO4efWIkDS3	2026-07-21 06:44:00.756	2026-07-21 06:44:00.756	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
4kW3nEqI0x6PlxqWqtrWAlWhrxHtmVKn	2026-07-28 06:44:02.094	ExZBJdAfyFFZIz0zgdpfkok7Jx0Dhffl	2026-07-21 06:44:02.094	2026-07-21 06:44:02.094	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Rh1yNvXGLz0MRykwxucIXNWEg5Qdi33Y	2026-07-28 06:44:02.726	ssZyyg8xFRHMLj5mEvx1gC7mjzciqJ6X	2026-07-21 06:44:02.726	2026-07-21 06:44:02.726	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jndOKzyInsnoibxcaKp2JhrJrns0N9ax	2026-07-28 06:44:03.373	nuZSRDMezH3gn9dvEh7A1LfvI4cqMN8q	2026-07-21 06:44:03.373	2026-07-21 06:44:03.373	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
2Q48807lLJ2T3wl9hPW6DZafUlMvxrke	2026-07-28 06:44:08.15	0RAhYIVlnFfbQVTO7yvBvBwPqhlYpuV4	2026-07-21 06:44:08.15	2026-07-21 06:44:08.15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
uIprqQ2Xv2D6y4ybjnqbbdCsR0S1JdRW	2026-07-28 06:44:03.994	U5EXN5INdSxQlCjwGypcF5ZnfVcT6two	2026-07-21 06:44:03.994	2026-07-21 06:44:03.994	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
vHIUnaRRXjamntJMQtUmQfdApTnHSxVe	2026-07-28 06:44:04.99	IdWCzZW3tjdj3dRO8IeE0RBUKUUxXSO8	2026-07-21 06:44:04.99	2026-07-21 06:44:04.99	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
kvY2odmZVDKzy3BsewN6JtkNYTHpqbMZ	2026-07-28 06:44:04.989	F1UA6w9no9bDpHZK1Ce0Cv1WM97jTE7i	2026-07-21 06:44:04.989	2026-07-21 06:44:04.989	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
t2clGBdNMhDyayCMCNJOzupBrrVZgBUj	2026-07-28 06:44:04.99	zk4y14GlwHidSHXltB5uw3lbEJacDUDU	2026-07-21 06:44:04.99	2026-07-21 06:44:04.99	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Tj1APao5wraMelORJK9kqDbQ8tBeb9ER	2026-07-28 06:44:05.312	11CyMfbOl2b2fvLMwwK1iKTNgrrGk5fT	2026-07-21 06:44:05.313	2026-07-21 06:44:05.313	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
GnmOAYmkaXno5pfISnQpY8fgErLyeYMj	2026-07-28 06:44:07.813	6bcVTjVB0quGExqpDPkbnrB1fe4RWgMY	2026-07-21 06:44:07.813	2026-07-21 06:44:07.813	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
U1YughSjmw2jCHgmAI7vCZlFabFzR0fS	2026-07-28 06:44:11.904	LM7ZFa9FRheT06fes7gTfpUVoL6ewUln	2026-07-21 06:44:11.904	2026-07-21 06:44:11.904	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
bHK3vtilNSgdhXpY4JIzJfuQmBiZn8xX	2026-07-28 06:44:08.621	6uZGSfSPuwCc1YmaRuqsawFhuINcC854	2026-07-21 06:44:08.621	2026-07-21 06:44:08.621	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
lOi4aFWMoKcXMjnAZhoC0OvTqcKLpVFC	2026-07-28 06:44:11.904	8UIFnz0zNE5W3oUwHrrPvjpd8b70D7Ek	2026-07-21 06:44:11.904	2026-07-21 06:44:11.904	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
egIsATieucrRwvJlx0YOTGmoG3dO7eml	2026-07-28 06:44:09.562	nxMllspuh4FPnkmATnMc5AIaUGFS581R	2026-07-21 06:44:09.563	2026-07-21 06:44:09.563	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
bDscGJ7QtIWjDxDNBBK73KAs766TVuDu	2026-07-28 06:44:11.28	ozEtabZYCw2yAaM5iHFWmnW266bqe7TE	2026-07-21 06:44:11.28	2026-07-21 06:44:11.28	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
qBKuP7RuhbFMmgqVlcIZC1AxgSFvR0EI	2026-07-28 06:47:50.231	sWyKdEcb9WUgwo89xF8gRShUqTErT24b	2026-07-21 06:47:50.231	2026-07-21 06:47:50.231	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
lbzTC2TpHahA2kAeJJBpR7AUr0lzfGBM	2026-07-28 06:47:51.806	jmTkyBZMUZWcKyo24DUgcNuekVisohtt	2026-07-21 06:47:51.806	2026-07-21 06:47:51.806	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fearZQGmqsiCfztIOfmJ4nIJiF5U8Yce	2026-07-28 06:47:52.54	dsoq4ysTLk0k6k0oTRvK1vpve0ScFrn0	2026-07-21 06:47:52.54	2026-07-21 06:47:52.54	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
acaTpTRjksB378zehimrlgTTYhBcwdvV	2026-07-28 06:47:53.95	nqJ0AlvIssQfCwLTOxksRyJW05urrcIv	2026-07-21 06:47:53.95	2026-07-21 06:47:53.95	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fvuUkY8mLnC547dGAzvVqkjX8M5yRVSN	2026-07-28 06:47:53.953	GgZo6MHn4bjLDWcwnglLZ31kVIdUFexZ	2026-07-21 06:47:53.953	2026-07-21 06:47:53.953	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
djcJfSfCtD1ItdbfqWcNb4vQDXtziLXP	2026-07-28 06:47:54.247	XmmLxy9KvDRDh3vmBC09gTchXzK2q4C9	2026-07-21 06:47:54.247	2026-07-21 06:47:54.247	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jWIWwhd0g3vtCRCkUqx0IlCN3THdla7o	2026-07-28 06:47:54.261	EITwLvhpr64r2EY0YHs7djdvNt1Jlm4X	2026-07-21 06:47:54.261	2026-07-21 06:47:54.261	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
mzEPc1D8WTrS3TWxgiro8FopUrj4YrjV	2026-07-28 06:47:54.357	NwHdfH20E46HI01swzcooSAlXCIFR3C9	2026-07-21 06:47:54.357	2026-07-21 06:47:54.357	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
N9f1iVakSt694u9UTAV4NLpx46az0MUP	2026-07-28 06:47:56.953	cQ5vyXp5B26FBjODlZTX0c1nVSM2JI3C	2026-07-21 06:47:56.953	2026-07-21 06:47:56.953	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Cs91Bqz0MQN6iApmjw8OPo580Nth0Mna	2026-07-28 06:47:58.372	7FOnTimhL6alIttFOJWMq6igrv51iLbx	2026-07-21 06:47:58.376	2026-07-21 06:47:58.376	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Qm4POfv6NGWf0OZldRYzkZcno2BXNBvy	2026-07-28 06:47:58.826	hctC3nAOfi5SAkxPhSvZtMAp8ZScQlg3	2026-07-21 06:47:58.826	2026-07-21 06:47:58.826	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
LY5mg45N9mWozK7mothcujfAZpM7tjOz	2026-07-28 06:47:59.397	26DcaxTyzaAq2604dhSiM8v2vmFGQ2bg	2026-07-21 06:47:59.397	2026-07-21 06:47:59.397	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0WgecPVC4ZCmtQZNLW2AeROJhg0FHElI	2026-07-28 06:48:00.313	K16UTEOf51YIuWCqi04hkT6whdSKPLBv	2026-07-21 06:48:00.313	2026-07-21 06:48:00.313	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
e6JaGE6koEgLamTZR5lIt3XLuj3U2iyq	2026-07-28 06:48:01.194	3oMpfXHJzgT1wxPVZ1pxriZysegIawkY	2026-07-21 06:48:01.194	2026-07-21 06:48:01.194	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
C5GhNH6O9GiXfBlmzHgOZ41dfb7KOYp9	2026-07-28 06:48:01.424	0tPoVTsgsKCaGWwRXMN9QTin58gew1mR	2026-07-21 06:48:01.424	2026-07-21 06:48:01.424	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Z3kEaq0yXhMVFxT3OhWz8nfsQSMWitm4	2026-07-28 06:48:01.425	GP6OU7JTUbdxVMKjqSqXXJbzBdLOumR6	2026-07-21 06:48:01.425	2026-07-21 06:48:01.425	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
wcY1rxVFVJ5ixjx4qGdLvRTnhDnWHhxI	2026-07-28 06:48:01.425	88ezdY6f0WGZ0vqLGXI1g9MqjYDC44KB	2026-07-21 06:48:01.425	2026-07-21 06:48:01.425	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
t2ezvnboGtMeFQylrMrZTprXkoMVS7BC	2026-07-28 06:48:02.225	u5KW7l7fZfRWj66DoVvkttcw0b1SjBdw	2026-07-21 06:48:02.225	2026-07-21 06:48:02.225	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Lvbn1vmBtCEyl5ZCXrX80i2Axw4GOmmY	2026-07-28 06:48:07.486	826hd6hj9WVffjjRjWvR2r3a0aVBc5Yt	2026-07-21 06:48:07.508	2026-07-21 06:48:07.508	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
gFhHmtttZ4mEohmVqdvLYSmqjWfG63uE	2026-07-28 06:48:09.41	aPhsUONQnRC7S9yZo7jSD1Yjc8BhbBG7	2026-07-21 06:48:09.421	2026-07-21 06:48:09.421	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
6CpGdnDIdEK40g3g2nbAf39hbK9VYN6Q	2026-07-28 06:48:09.423	E9ILEeBsgfkC8cLJnNTm4gHAvYBN5rOz	2026-07-21 06:48:09.423	2026-07-21 06:48:09.423	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
HPlPZjC05X7ThRva0XuoVX3UwBYoAOpt	2026-07-28 06:48:11.07	IxY2iYI7ZTN5fMfYVjT6JFMN5chM7DWF	2026-07-21 06:48:11.07	2026-07-21 06:48:11.07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
oZyUWdhQrrmDzhqyHSkgSsrFuDjWuP6X	2026-07-28 06:48:11.994	dHPZQdvDYKL4uxtVsDaPtjpv6wwN3IH3	2026-07-21 06:48:11.994	2026-07-21 06:48:11.994	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
C1MNrt8vLZ4uLSjtNwVVDwprzWHfXO5t	2026-07-28 06:48:12.218	4NgYTgnfjkaNpK8Xg1LZHgVbr1yNVmfh	2026-07-21 06:48:12.218	2026-07-21 06:48:12.218	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
a1zwoFQRKSzlnhOfhDUviriDHH9v8c5K	2026-07-28 06:48:13.022	1nZgVpX2QowJOfUGgCPjILTo8EZo8HlA	2026-07-21 06:48:13.022	2026-07-21 06:48:13.022	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
rtyFZbtKCV8YxxMUYsIglHTjKUC3SsO6	2026-07-28 06:48:13.068	02ZkXAu8rYCfBefBg5Lw7Mzs8t8w5McX	2026-07-21 06:48:13.068	2026-07-21 06:48:13.068	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Q93bNe5PvyDQEppGJ6C0UOhIn2hDFjxx	2026-07-28 06:48:21.82	rHqvA8j32DKDPYjxDCSND5LVdaJLm1gr	2026-07-21 06:48:21.82	2026-07-21 06:48:21.82	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
NEPCv35fyxPfHaowXRhznVUSXe85tQoJ	2026-07-28 06:48:13.946	rKwIfElxjlHbunHlBVAxAXTEWhAw4mDh	2026-07-21 06:48:13.946	2026-07-21 06:48:13.946	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
6TWrQRM3Tfl6ZFsCpmSaHsFaMweoeA2F	2026-07-28 06:48:15.747	hMh0X7dh5GUcWJMr20tsrLP2v7cecOfx	2026-07-21 06:48:15.747	2026-07-21 06:48:15.747	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
IOGnJxKcolDGaH70TtaGhcEACZjg7KXT	2026-07-28 06:48:16.533	m7ZOua23kSFXiYteiWthDYIyLZzkAdlx	2026-07-21 06:48:16.533	2026-07-21 06:48:16.533	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
d4VbcjjQXfVn4O6MstbpRSIujjb6K3sT	2026-07-28 06:48:17.103	GHtQO3syVODcAAmipdAKcf2ruh0lu5Up	2026-07-21 06:48:17.112	2026-07-21 06:48:17.112	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
9N5cXeetGKnHtqYvOZIQxUmr7fO3usAZ	2026-07-28 06:48:17.915	oeE0drrfn8m721Gd7gNMbW0Gs9lXHoDU	2026-07-21 06:48:17.915	2026-07-21 06:48:17.915	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ptdBGR0EV1xF1AHwzOBD5TynbhZWwgGO	2026-07-28 06:48:17.916	ycUJQyH4DuefQ6zkWawIPqBS4AhQjVr7	2026-07-21 06:48:17.916	2026-07-21 06:48:17.916	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
PEIxxlEjicQOCqTqXFuDqzpAE8IZX2kh	2026-07-28 06:48:18.748	14u2Qv8OqpLKY5vtpMOOXGdLYTgujX9O	2026-07-21 06:48:18.748	2026-07-21 06:48:18.748	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
NaSli19FUpUFPjvUSO8goMAnna9tgv9I	2026-07-28 06:48:21.181	JrPN09tquREga6Y3DLS3AnOzXhtKBkUR	2026-07-21 06:48:21.181	2026-07-21 06:48:21.181	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
cQSA9dz9gXDizvq8jWpuTi7QANVqWOp0	2026-07-28 06:48:23.685	hyu5wt9PbIBnuzxkewNDTgS6eF5kxXY2	2026-07-21 06:48:23.685	2026-07-21 06:48:23.685	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
2iwhUvNykAMyraxg84xQpY8RYonwC0zw	2026-07-28 06:48:23.985	Jo4RC8jeCUU9KQuo6SSJANBmGWN4Kx5u	2026-07-21 06:48:23.985	2026-07-21 06:48:23.985	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
kTJBHtGLBX1PBKCo6rMSYeaFAbXzR5ZE	2026-07-28 06:48:24.295	LIpr1Ij0i8tViF3NhgEjHc0C2hOy4HAg	2026-07-21 06:48:24.295	2026-07-21 06:48:24.295	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
LVJENKsegITxzgfO9MP3OBnz0PwxnWME	2026-07-28 06:48:18.746	OcwATxyPMAZWGiPixVW3U7kDDUkwUVM7	2026-07-21 06:48:18.746	2026-07-21 06:48:18.746	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1USwzzAWNJak2KVZ2LWuif12lDrq10Lk	2026-07-28 06:48:20.155	vuohT5197to35aUYEe55Gsy2Dmtco9yM	2026-07-21 06:48:20.155	2026-07-21 06:48:20.155	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
hexpKjMVvcnGK6BpQhu5bo6Ov524ecqP	2026-07-28 06:48:22.972	iYOYLQbsMzgDGcKHuWms7mM0kKhz00tp	2026-07-21 06:48:22.972	2026-07-21 06:48:22.972	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
QVCuQcVeRPzW6UTwkrtEVM85VlWMBwpV	2026-07-28 06:50:03.515	0bIyZNMpZAgN2386uX2z2g1k09ScVkYR	2026-07-21 06:50:03.515	2026-07-21 06:50:03.515	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
VdBIgBcHT2MpXEGaS8AnFQZKEtHAA10W	2026-07-28 06:50:03.658	8MXGSsHUC1V6LbDOFs0Qj4Fe5FZOu6Nl	2026-07-21 06:50:03.658	2026-07-21 06:50:03.658	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
4qh7M05ImJGr8Nd8H4WpbH32kyNoNFg3	2026-07-28 06:50:03.659	bxANr3mce1yrL01f1Njvq8bF1LCMHx4A	2026-07-21 06:50:03.659	2026-07-21 06:50:03.659	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KyXnnTrh33u8iiS2cJXuZxzZI2d6iCtc	2026-07-28 06:50:04.086	aFsdyutgrIPhsfaZIpFKDfglWnviSuLX	2026-07-21 06:50:04.086	2026-07-21 06:50:04.086	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KsenwBl3Kaaucqyo0mvtOzJyPzshBpxG	2026-07-28 06:50:02.886	EHFBZrsSeQkyuj3vV1qy4qcr6IJTtKtr	2026-07-21 06:50:02.886	2026-07-21 06:50:02.886	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
RnghLiZfKzBJJp2zn6h8tYTrPvMh0cx8	2026-07-28 06:50:04.533	XJYN4G5lxwdy3w13dvuKZ7MsCuawujNE	2026-07-21 06:50:04.533	2026-07-21 06:50:04.533	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
NIYVk6VZ6tIuXxAZsxGy1OcNzvaZxUum	2026-07-28 06:50:04.533	lVB7svK7pzTE3Wz43QSqXtOOUxPmFCr6	2026-07-21 06:50:04.533	2026-07-21 06:50:04.533	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1yj9oMtZGkpQZK2iiGJnLfelJYk3VO7j	2026-07-28 06:50:04.664	3c8OspQrfwktvB2zoKekPppzrixfcl5B	2026-07-21 06:50:04.669	2026-07-21 06:50:04.669	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0kTvEVBeFlpmJB1kDB9qSFRzZjYLwywc	2026-07-28 06:50:05.033	m50SBwqk16PTXyuYdUdWUQZ6HxmWznR2	2026-07-21 06:50:05.033	2026-07-21 06:50:05.033	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
xM3ELQhLIfJdifJsjWJpk6Ei6ChNhwf1	2026-07-28 06:50:07.399	5RznQfceUMPT2ijtX26u7sOT0V1nAoY4	2026-07-21 06:50:07.399	2026-07-21 06:50:07.399	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
zgPmfvB0A0ghleuSJz2pLtOc9Wplo3bl	2026-07-28 06:50:07.418	w39eLlCcQyBlnMBP86a5rRYuN4QlZfMO	2026-07-21 06:50:07.418	2026-07-21 06:50:07.418	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
F3BXlfI4oY1vQvVaVAFRt5zbQTHzniT5	2026-07-28 06:50:07.882	120Ycty1DyBcOmM5IltyZ5CRcItt8tlP	2026-07-21 06:50:07.882	2026-07-21 06:50:07.882	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eQHYnNBPXNWs9xaJ6n5YRor1VT4RT1Ip	2026-07-28 06:50:07.883	QSJQvExGeLnzrKUN2RS1iZDxgFsYKyXT	2026-07-21 06:50:07.883	2026-07-21 06:50:07.883	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
3cHMZOjVZoOzmIo1y9KQ03jDT0kMX8r0	2026-07-28 06:50:08.559	Nkjmy6ezpB8r7nbLvjOAWpH6mf3HINeP	2026-07-21 06:50:08.559	2026-07-21 06:50:08.559	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
sXalgzla5UDptJai8Q3DenqmV6xrNSj6	2026-07-28 06:50:08.613	mYA9mzTNc8gvl3JCH6152Pe9dLXr0mQy	2026-07-21 06:50:08.613	2026-07-21 06:50:08.613	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
92uzYKehp54R2vSKzvn462GE5SAR8Dz8	2026-07-28 06:50:08.617	jcYe4ZxSPsHFAqBHoaJyxUQMZ6aw4IG0	2026-07-21 06:50:08.617	2026-07-21 06:50:08.617	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
83MzrQqEU08SFRdvLlB5IeABPlt0H6Ku	2026-07-28 06:50:09.361	v53uTCdP1Wfr5Enur0jUggg7b32dqW3T	2026-07-21 06:50:09.361	2026-07-21 06:50:09.361	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ojxwSGv6lPGQwASqqgoNaClVFWPrxh4z	2026-07-28 06:50:09.361	vdH1NFYpPVXsxwTVC3RFOluxnS2WImEB	2026-07-21 06:50:09.361	2026-07-21 06:50:09.361	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
FqWaKtm3RiYuuN5GeZ6QBkgJ76yKn560	2026-07-28 06:50:09.361	qRkzhYIig9UqE7WXei4RfAYgrqqT4si5	2026-07-21 06:50:09.361	2026-07-21 06:50:09.361	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
mIQJzFrhwOmDrwHFPE2PbbURMNX2aXam	2026-07-28 06:50:11.515	HUjkUSNFZv0zDvYtsPntBq2WNWe2Pa2D	2026-07-21 06:50:11.515	2026-07-21 06:50:11.515	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
g8WK1gLZApOXNF5micSBGSeNRqCAE33W	2026-07-28 06:50:11.793	92SI1cdvgdUVQrEg129CM3181Z73dyi3	2026-07-21 06:50:11.793	2026-07-21 06:50:11.793	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
rXsZK4KLineWcYAn7ezzWgBwlB5TfA2W	2026-07-28 06:50:12.1	aL2H0yPYFh6IGq8P5SgSbNQrMqZszVVp	2026-07-21 06:50:12.1	2026-07-21 06:50:12.1	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
HZMmKRXUhz7BpHXi7QT8Nv0JIvDXJwpy	2026-07-28 06:50:12.586	AeQejBV8nhptDTksKHv9LZzzxQlbUYlL	2026-07-21 06:50:12.586	2026-07-21 06:50:12.586	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ywWqT0t845O7cvkpEwOZfuqU1xs5mzm0	2026-07-28 06:50:12.616	d7qZoCMFl6LadTkwS4ovw7uo0R8H76dY	2026-07-21 06:50:12.616	2026-07-21 06:50:12.616	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Ac8m7ZLwSYc5GpKMWfFm8bWTUqBt1Iwv	2026-07-28 06:50:13.392	ERI3TMVbddYmqeQyvN3te5OISFLjX1Qw	2026-07-21 06:50:13.392	2026-07-21 06:50:13.392	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
dRrp22i9WFBEKYirFHudh5BppnFpHM11	2026-07-28 06:50:17.584	wGbbeod2X4STyLtc4pMEgAxY1vH53XnF	2026-07-21 06:50:17.584	2026-07-21 06:50:17.584	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
takR6vH3H350LCstVzVv6ElNSRGEikXJ	2026-07-28 06:50:19.507	HQO2vobJtknrzyJM5YKrB5ocIX9o7tif	2026-07-21 06:50:19.507	2026-07-21 06:50:19.507	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
GsqWelngXdW10Qp7KwB1cNr63pqnKmCD	2026-07-28 06:50:20.893	C1OZYSwnuu3GkoYFjGZItJEJqsuN7JPk	2026-07-21 06:50:20.893	2026-07-21 06:50:20.893	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
I7YmXsDJU73fhlu2ydWC4IGCPpah1RkD	2026-07-28 06:50:13.392	v0SPWANTfHNWWHiYqIRixihD5JjQ8G7Q	2026-07-21 06:50:13.392	2026-07-21 06:50:13.392	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
SXhGM74hpA5u0h2D0tWILa3Kxa69fmD3	2026-07-28 06:50:16.021	7HH6iiK3i3XslGa0QHVaw7NET4THlHfs	2026-07-21 06:50:16.021	2026-07-21 06:50:16.021	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
YKWpQj0Xc8cnqRxtcWeiFayIsX0gpAtn	2026-07-28 06:50:13.393	33yFcnJqaWosygDucHfrObFf40N9tTHC	2026-07-21 06:50:13.393	2026-07-21 06:50:13.393	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
YKSmwMJA9Yyw2GgyzF92GfPHFdo0payY	2026-07-28 06:50:15.704	am6myVV7WjydcpOIo6V6q51rmFQAVG1Y	2026-07-21 06:50:15.704	2026-07-21 06:50:15.704	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
nonosvoX25z7t2nA3NTCadYPRMteP03A	2026-07-28 06:50:16.528	gcXM5NEGnKVXiOgrURKrRoUfKcqHQ1e4	2026-07-21 06:50:16.528	2026-07-21 06:50:16.528	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ImITmNqR6cPnA1F3QZR8rqwNmpFT2hsR	2026-07-28 06:50:16.528	iW0EWIvLUeNJBVEitFmRPXS2A3OEuqu9	2026-07-21 06:50:16.528	2026-07-21 06:50:16.528	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
m1QqKywZjuXr0vXsIFhkYn0vtr3PPVVt	2026-07-28 06:50:17.003	ApSFrQB1uQeQIJkK2bhnLgQV0nK0BvpG	2026-07-21 06:50:17.003	2026-07-21 06:50:17.003	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
XJq8MJnzYt1Vhu3i98H0RNJX24DEc1Qf	2026-07-28 06:50:17.584	2fGIWtBsg8yh3yrU9i4BbF7cWp6v2FSZ	2026-07-21 06:50:17.584	2026-07-21 06:50:17.584	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
k6OkSmSNzuPJUbfLrCFOA964FZzHqMAv	2026-07-28 06:50:19.019	dK8Jf1yKTFkzfWjVZA9ucDOhVIOQ07RH	2026-07-21 06:50:19.019	2026-07-21 06:50:19.019	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
M8D29SvyOypCIj15PcN0FNsCyK8tXbVH	2026-07-28 06:50:19.02	uWKTsTMOTK5jJjhztgPpfNGWRMtYq3MN	2026-07-21 06:50:19.02	2026-07-21 06:50:19.02	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
6SWtLCIOva8L5GvunYITePO5gvpMiS0t	2026-07-28 06:50:20.088	Z6VOhgLa41BMcOE3YH1wTtbcMeDA4PbH	2026-07-21 06:50:20.088	2026-07-21 06:50:20.088	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
yKmww230346LGE9jLslC302XPKLRVRME	2026-07-28 06:50:20.629	3vtYInBXw7MVO3rKDSdl19QQclShB0b3	2026-07-21 06:50:20.629	2026-07-21 06:50:20.629	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
hq21tTHLA6Pekms0wXu43jGAJrz5q0QV	2026-07-28 06:50:20.63	b3tNBRjvqrOixrFranZG0uES54oHMoB2	2026-07-21 06:50:20.63	2026-07-21 06:50:20.63	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
I894K5KjBjesX8pTNk3BM9ZNlH6PLnaV	2026-07-28 06:50:50.868	BzbafSJ9pp3CxAdStoFuVWyFnsme8k3n	2026-07-21 06:50:50.868	2026-07-21 06:50:50.868	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
TJtiGyxMuCgAx0bnK0eCu3sLCAWn2yPK	2026-07-28 06:50:50.869	DeHYXVVvjUmS7fG4K1lgProCjjHK7Ut4	2026-07-21 06:50:50.869	2026-07-21 06:50:50.869	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Th1vOsyoxa81ZPEik7fTEDjxl7w4eScU	2026-07-28 06:50:51.215	KcyZUpdP8lRcvS2Kv3VmyZWRZLXpITKP	2026-07-21 06:50:51.215	2026-07-21 06:50:51.215	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
iJlI7NXyvaykIpplyYOcFQfXduueObe3	2026-07-28 06:50:52.081	J9cUGzlcLVhGfWv3e0LOsQa0Htnsfyem	2026-07-21 06:50:52.081	2026-07-21 06:50:52.081	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
dz9j1LK2gRH2iQkNMq5Xc3Dpu0OH64vy	2026-07-28 06:50:52.165	mFumBNWcsnwjFwzFzVwxumE8dsjCSzYn	2026-07-21 06:50:52.165	2026-07-21 06:50:52.165	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
MFbUwkx8eDBBR7CX8jp6LlnfL6kh39GE	2026-07-28 06:50:52.166	2RtbEt3sybCzXF7Taiww06w1R5xT1xla	2026-07-21 06:50:52.166	2026-07-21 06:50:52.166	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
CtynyQByEHoT3f1gxOLDSq96WS7DKh8u	2026-07-28 06:50:52.167	PW2YRxdcwXyPDh51LU2TVaiRo2bUbQqB	2026-07-21 06:50:52.167	2026-07-21 06:50:52.167	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
CMz30kLi3EMO971cYljIS12VRQR1olWP	2026-07-28 06:50:52.495	9uaD0sP5iXHXVNoPl902WQsaNnfNSEac	2026-07-21 06:50:52.495	2026-07-21 06:50:52.495	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KLAZxgVGrmJQu0ocEIKIfjjzvVZaq5wW	2026-07-28 06:50:54.275	M3icBwWNH4S4xl1XPQjcxtYJ5N34Kiaw	2026-07-21 06:50:54.275	2026-07-21 06:50:54.275	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ZIWPZALiDcPu42i0vnEoiTKdU0LHu50R	2026-07-28 06:50:54.952	dJv1QWWMpbtbTEBoPWLUsB1E9luTKPkm	2026-07-21 06:50:54.952	2026-07-21 06:50:54.952	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
GX8hx2KHJ8o3StUhH5iNR4Z5svRTAPZ0	2026-07-28 06:50:55.217	OhG8lBXPjjiQ4bG5nYhJ6tWN37MA6Yl7	2026-07-21 06:50:55.217	2026-07-21 06:50:55.217	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ex59xYvf2lEY3a90BOOSXblAHienhcD5	2026-07-28 06:50:56.34	eSMZiNC1xTuT8CIoJGQHT57CJYOyzl46	2026-07-21 06:50:56.34	2026-07-21 06:50:56.34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
GazRctLlSEDxApJXHf1Msq3vnmFSB5OP	2026-07-28 06:50:56.341	BGldtqOFuwW3pID6sEOR0j67sPsQC5do	2026-07-21 06:50:56.341	2026-07-21 06:50:56.341	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
o7d6ljLJ5VvEETVyW230rAJ6NB6UxJCZ	2026-07-28 06:50:56.341	pRrDa613caeypwbSEFdtMCQ9MQuK8w6V	2026-07-21 06:50:56.341	2026-07-21 06:50:56.341	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
S6U5l6cjRQMuhLfffSgT0sAzWCr4zK2j	2026-07-28 06:50:56.39	gktsNSY5OyawG3BUyU3K193jMllfvruz	2026-07-21 06:50:56.39	2026-07-21 06:50:56.39	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
dcmdaYtQLG5NiMHwVfURBEYFtjCcYAYR	2026-07-28 06:50:56.931	FTfJKJ9No0KclERYfmMeKB8I0MwHSIgN	2026-07-21 06:50:56.931	2026-07-21 06:50:56.931	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
RU82VBo6j3VgNirtCoH9CLx8sXqi7ysj	2026-07-28 06:50:56.391	wQVre9mo80MhilTy1030hkKOgDh17Kmz	2026-07-21 06:50:56.391	2026-07-21 06:50:56.391	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
58b4RMUd8UexbjFmCFEeEm4FYlpg5Osd	2026-07-28 06:51:01.234	zL23yLDk9d0vcaWj92XXhmJnIbI6UNno	2026-07-21 06:51:01.234	2026-07-21 06:51:01.234	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
de4igZw4m5wLly7YGTotxWaT8ArUKxdA	2026-07-28 06:51:04.097	vkiXAZurSOVbO3T757yw6Uq4MhgRjGZn	2026-07-21 06:51:04.101	2026-07-21 06:51:04.101	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Vc13AVglzlXX7NzQB1xwLWIEOJgVuvqn	2026-07-28 06:51:04.351	MPmg5aVvOwEu3wdRibTSI8oQzGXho34i	2026-07-21 06:51:04.351	2026-07-21 06:51:04.351	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
3XRsFExDYvYmzH8FJKeowRQvtosRXszy	2026-07-28 06:50:56.932	3yHB8y8tGPTvRCDml6FGNci160785Hb2	2026-07-21 06:50:56.932	2026-07-21 06:50:56.932	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
geW6fWQzR4C1xOl9yE8f2gzsrTbgF1sE	2026-07-28 06:50:57.469	o2epIWU1imzvxOPTGVqlLWpm2IGEC3kh	2026-07-21 06:50:57.469	2026-07-21 06:50:57.469	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
xnXXeGASywO5y5j3s5x3SxNsyZB2sSme	2026-07-28 06:50:59.596	93QAbqWcYxM6VoJVuCbXmbqhyqRRSlYJ	2026-07-21 06:50:59.596	2026-07-21 06:50:59.596	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
hvqBe3yIYt8wHgxB7EwzIZGxZOtPApJq	2026-07-28 06:51:00.055	KCcWT9LW4AN0qFYutkRFmoeTVn77GJKz	2026-07-21 06:51:00.055	2026-07-21 06:51:00.055	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7280vpB7THLZ774wneQ4Q8tiUzUe7WDf	2026-07-28 06:51:00.085	bZt0Nb6qGzvbbntpz1EtWwrFZoK3k4Mv	2026-07-21 06:51:00.085	2026-07-21 06:51:00.085	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Yv6TGh20J3SyOgDn1ms6wNboMUH5Kofd	2026-07-28 06:51:01.235	30wKldAh0ejZdurh0Wfp1Nrv2jMmBRP2	2026-07-21 06:51:01.235	2026-07-21 06:51:01.235	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
EFN7TBqyUv57j1aNR7mHOfo2qkyHUeQC	2026-07-28 06:51:01.235	3S3vdopYY0rMyYxKiJOy4cOfIj4vrEup	2026-07-21 06:51:01.235	2026-07-21 06:51:01.235	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
XjFWxQS3EL5br5kouQ4XS1LYHCsdrdjB	2026-07-28 06:51:01.266	nXeIsk8XIQ2g5uB22qkqujMGoHv70xXz	2026-07-21 06:51:01.266	2026-07-21 06:51:01.266	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KQS3OLqHv7vmz4fIVtbOBlz9aFT0yg7w	2026-07-28 06:51:01.235	JiJbRv8hVZLhP0z5NSlQsxJ69MWuB0OY	2026-07-21 06:51:01.235	2026-07-21 06:51:01.235	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
B7LiRO64WmDx5jAJ6DhOofYY5XDqThsK	2026-07-28 06:51:05.239	bK1OTj5Q1OTi0y8LOgkN74leQA1jqH3C	2026-07-21 06:51:05.239	2026-07-21 06:51:05.239	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
8mCRLXzltntM54OaPCOMIZSM9CCROq7H	2026-07-28 06:51:05.294	sOxD8PNxBTjRjQYztFDDpnWz7Fri4tv1	2026-07-21 06:51:05.294	2026-07-21 06:51:05.294	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ZaKjlIIc4ILm4kpRKZjSrx0uqEkeSjEU	2026-07-28 06:51:07.539	pGCoLRYz6NJfB2xyxsNtQGEjR9RBLt6r	2026-07-21 06:51:07.539	2026-07-21 06:51:07.539	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
uyjhlrqTct0FzyKTBkkVr2GqrzZvnYIi	2026-07-28 06:51:07.784	HYuZN8yruDCm4dzQY53ELlhZWBO2VPPb	2026-07-21 06:51:07.784	2026-07-21 06:51:07.784	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
4xfpeMCBijDUp9xMSbVBnXMI8fVn5T9y	2026-07-28 06:51:08.273	6QFyrbI3N00RPKVSnK0sqHQ85sZdbwzc	2026-07-21 06:51:08.273	2026-07-21 06:51:08.273	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
dyPqdY2IbdgOeTeHCjk6XOMf0XIUf6gr	2026-07-28 06:51:08.323	qWTQTmpfDNWu2UwyzkX1QufFdtZQtlxu	2026-07-21 06:51:08.323	2026-07-21 06:51:08.323	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
KjUt5nefAxlr6b6pFh8wpE80ptjj7H4L	2026-07-28 06:51:03.302	vkOKzbYKsks3iQan1Vgc49FM9gwveUdf	2026-07-21 06:51:03.307	2026-07-21 06:51:03.307	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
emucAR8AqjNz6e88B2XQmtaTJWCj2EH2	2026-07-28 06:51:05.238	jFmfIogZbVwwVBfskaqqhjMMlCubaJ2L	2026-07-21 06:51:05.238	2026-07-21 06:51:05.238	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
TTUCy9GLfKgPXyUqyozoVvGM5Sa3QyKK	2026-07-28 06:51:05.294	jLXFIV73K65fg7LMmtfXVjd2VO9MiB6n	2026-07-21 06:51:05.294	2026-07-21 06:51:05.294	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
QogfDngFEFX5GSuPY1amu1kGjORoQdhh	2026-07-28 06:51:05.62	T5GG8T7BjEKOJxV3jOKjtgCE43krzxft	2026-07-21 06:51:05.62	2026-07-21 06:51:05.62	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
WLVCdgmnyGTMAzBPucG5Vr9AM8yM8U0L	2026-07-28 06:51:08.796	leCaxi9beox5ccRJ6BNI6sY0BWRWYwCm	2026-07-21 06:51:08.796	2026-07-21 06:51:08.796	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
OiS4QgZgNMnKgUjgpLMrkZ8kAw1sleB3	2026-07-28 06:51:08.83	Okpldqahgj6mpNfPhYQd8K8mUHvbPvr2	2026-07-21 06:51:08.83	2026-07-21 06:51:08.83	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
M7MCuvlMf3R5Subc9YIHw4xVbzr7Q6U2	2026-07-28 09:19:00.96	NmPfunvLPcmQR0uqAnfXculmccI0Csnh	2026-07-21 09:19:00.96	2026-07-21 09:19:00.96	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1ABjQrSCRusJFAGaQKIuwNryN3Ht5D88	2026-07-28 09:19:01.906	H4dEwKsCyiNodfbR3v3Oig1dDoH1m6lG	2026-07-21 09:19:01.907	2026-07-21 09:19:01.907	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
hjDtM0OsgGtCoXPlIvxu3vUn400CLANn	2026-07-28 09:19:02.605	nD06mlEjXlI4brAm4CIe76G3gdRvngBa	2026-07-21 09:19:02.605	2026-07-21 09:19:02.605	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
dqEvnJ91ITFKgE721SBQNnP2eLkooAjo	2026-07-28 09:19:04.254	c95GDj2fjSpMDJWNhjhmQjdBPquwFPOF	2026-07-21 09:19:04.254	2026-07-21 09:19:04.254	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jagMTydInY2wkfZp6kwfPVH1S4l645XT	2026-07-28 09:19:04.255	poY9YPZGJPjFKkoxB1vDpqOxq53UGet0	2026-07-21 09:19:04.255	2026-07-21 09:19:04.255	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eSPHiHRsKUuuWi5fZgf3TTYRd0gV2UDB	2026-07-28 09:19:04.256	68RIFXmTmGKj5iZuHnSaU8Wa2X1LBJSA	2026-07-21 09:19:04.256	2026-07-21 09:19:04.256	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
nrEgFnsggipKdC4wpN6WFYZijkBF4kCs	2026-07-28 09:19:04.846	O91H8CqR2Tac1q0KoaUttLGb0Xqngn7t	2026-07-21 09:19:04.846	2026-07-21 09:19:04.846	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0mZlN8N3179UeosBCWIVQqAedCfJluuh	2026-07-28 09:19:04.879	k1su5arB79MgkvxZ6KoIHWWmQIH7p9iE	2026-07-21 09:19:04.879	2026-07-21 09:19:04.879	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
pcbsvwsceyReh9aqR2ka1StIbn8WdTsT	2026-07-28 09:19:08.385	JSKi65iJck5snLRSjTTtYYEhjIOQZL5O	2026-07-21 09:19:08.385	2026-07-21 09:19:08.385	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
CBHnEBXWrSuwkwS8JpLVqRnw4cRLuxCk	2026-07-28 09:19:08.894	R9PBuPFxeEYCgtm8Am5O9FNTW61CxfMS	2026-07-21 09:19:08.894	2026-07-21 09:19:08.894	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
WUgrW5datW0phvQL230OyIEJVn9C2OcX	2026-07-28 09:19:09.693	Am5dzOifohYU9VNYLNWU7p6R933rnLHb	2026-07-21 09:19:09.693	2026-07-21 09:19:09.693	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
IpdkGFoO5cgCXLdRcvqjH606HKunIL4D	2026-07-28 09:19:09.708	D0ub5gxRjR1G3lV4iU0UmVkWnyBrcl2e	2026-07-21 09:19:09.708	2026-07-21 09:19:09.708	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
EzIIhTF2ddhxoQt170PH3DQ5YELpyjok	2026-07-28 09:19:11.277	4lOoN1VfPV3M1Tl6S4AbdvvUNEjCqHr1	2026-07-21 09:19:11.277	2026-07-21 09:19:11.277	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
uIA8OqLzQ6yV62clTjfSVmCq6uZY2hrm	2026-07-28 09:19:11.278	z6NdyxLJnBCFLANefkAjZWhGvN0W7tjD	2026-07-21 09:19:11.278	2026-07-21 09:19:11.278	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7x8fQ16nE7Qsl3sCNbsvMpkGWWkIS5vh	2026-07-28 09:19:11.332	0zLyKyJzE6yelppz0HUiQqQyNyKYv0gp	2026-07-21 09:19:11.332	2026-07-21 09:19:11.332	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DwKhk6P12XtJMTMK0u3qWQCaHIuACtv9	2026-07-28 09:19:11.333	xZpNk8bZCmOYm58IP9v82QqvMy3SMEZA	2026-07-21 09:19:11.333	2026-07-21 09:19:11.333	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
TDYFwFvW7oVHhtU7JkdBmCvIrSFdP9YM	2026-07-28 09:19:11.333	cfjLAArGYyuE2OmXanuOHhr7Qr4fFwVX	2026-07-21 09:19:11.333	2026-07-21 09:19:11.333	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
bNEiWn0sxO3x1hq9Z9FoMyGVOKG9cJNg	2026-07-28 09:19:12.231	VpRQz0MQUUZ0ah9gCBlrN51GRXwNnURr	2026-07-21 09:19:12.231	2026-07-21 09:19:12.231	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
mwpsWtN3NVW0JkZIACyh1FTKYFOO6v4Q	2026-07-28 09:19:35.075	NBB37dBAI0OurQa1B4cRI41ojazrjQBE	2026-07-21 09:19:35.075	2026-07-21 09:19:35.075	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
sr5cFbX3OndBOmWymv7lraeI3JXbIIow	2026-07-28 09:19:36.178	AkU9u8v4TYU2ACPpVnszvDr71VYX9iwg	2026-07-21 09:19:36.178	2026-07-21 09:19:36.178	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jWoOu8n3oFkdCM2yAHqHNarE1rMcnsX2	2026-07-28 09:19:37.022	SCHJOHiYA4vKUtqcff8hGR6bb00XbQK8	2026-07-21 09:19:37.022	2026-07-21 09:19:37.022	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eFnMmDEkirSAxDjAbC3D6TYYpZ9fkIhw	2026-07-28 09:19:37.331	6MsdYY7RYwqFawCex4gtefjRUxjo96zI	2026-07-21 09:19:37.331	2026-07-21 09:19:37.331	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
xToqgXMPh87n9sTlgCJhJt0yhw12fUEs	2026-07-28 09:19:38.403	1HvlxKn3K0Kxb5qZtmkwy1J5zICf1Pgq	2026-07-21 09:19:38.403	2026-07-21 09:19:38.403	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DGmt9c3dQykXF4gNerXgyjq8o1NH7tlU	2026-07-28 09:19:38.403	Z6n6w2oPRCGrJ2plFf1mmmAbLQPmFmEi	2026-07-21 09:19:38.403	2026-07-21 09:19:38.403	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
waAJOAblqRVhPQzLHPiGwmkza3369B2m	2026-07-28 09:19:38.404	Ojskv1VuZ5KfJdRpwtKjcKKebwHL25JH	2026-07-21 09:19:38.404	2026-07-21 09:19:38.404	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
zYCehDyuC84rCInkqnVdtIc5r60Ip9Q0	2026-07-28 09:19:40.124	T4XMRovHNMvL7XbyAEyWIfHQhXQAiFkG	2026-07-21 09:19:40.124	2026-07-21 09:19:40.124	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jIDHc7YJJ4pUDYdQcnKVDXxO6FblKzBJ	2026-07-28 09:19:43.108	2RwYp2DyOAZaHXhjyfs6p2jgOONS2JHK	2026-07-21 09:19:43.109	2026-07-21 09:19:43.109	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
MaPKSqTax5kNtGduBMW5YKmjpIEOT8hu	2026-07-28 09:19:43.296	TXkLF0zepMMYQPCizniPB07IJlaqPhER	2026-07-21 09:19:43.296	2026-07-21 09:19:43.296	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7RwYI6Qq8OnSNDQhfW3hU4g6htHGWNaA	2026-07-28 09:19:40.962	Md9qZHXfSV3nChMcOYWGW6KIsxB5xeUw	2026-07-21 09:19:40.962	2026-07-21 09:19:40.962	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ZuBSqOMelgBA6LkwwRGLacc6u441I1RP	2026-07-28 09:19:41.082	8vvrrnhvT8tSmxEkqjOYzgnCe4MCeEdW	2026-07-21 09:19:41.082	2026-07-21 09:19:41.082	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
nTvcIxXvoqLpkzPlxl720sP6BOrCVQxu	2026-07-28 09:19:41.097	LWUY7q0yNVVfn0HZ1FOr2sxTNvMFNIsE	2026-07-21 09:19:41.097	2026-07-21 09:19:41.097	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0Y40qK1TprMAhRAYvTrnze9kEfAA20mS	2026-07-28 09:19:41.482	WQNZxesEhILLQjrq2Xhj3Gz5d84f6oBj	2026-07-21 09:19:41.482	2026-07-21 09:19:41.482	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
XYIH2Lqk9wEXLB72YNLTSIgggsaZZagi	2026-07-28 09:19:42.417	SurVakFRQdidOQ1X154jh94AKOZnUZBO	2026-07-21 09:19:42.417	2026-07-21 09:19:42.417	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
cKHUVcJcJK32xlsFPnwWJd4KqSKisa5E	2026-07-28 09:19:43.302	QFPYsJDA6CRq0rl0r3Lzm6FEZzPx8tRy	2026-07-21 09:19:43.302	2026-07-21 09:19:43.302	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eJ6b3FZOkfVQGVZYzLUlSnDh0LHUIteM	2026-07-28 09:19:44.276	neoNp38XaeTy91BGzT6l5L6khohWUG5t	2026-07-21 09:19:44.276	2026-07-21 09:19:44.276	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
sFIAtSujASwnJbvzR9cobTil0z8yydFD	2026-07-28 09:19:47.34	wWTsnzRdW3QpjYzVvLrGcAyW0HQ1tgJE	2026-07-21 09:19:47.34	2026-07-21 09:19:47.34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
bFSNgfNUm0zF6XkSc8TzKgfwvfK0Fudt	2026-07-28 09:19:47.78	5rzsNpOvjj1LBAXQ2lwizEauPwWhBUbQ	2026-07-21 09:19:47.78	2026-07-21 09:19:47.78	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
hlmSpdRaCIfPAswDpi4XZpws1SR8IGV4	2026-07-28 09:19:48.319	oPUbl14V2zmppVY8DN1fcpUdWQzPAUqP	2026-07-21 09:19:48.319	2026-07-21 09:19:48.319	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
S2ixm80RLCgGtVbYbSD6Pj3hsxgesBwV	2026-07-28 09:19:46.072	a7eFBb7n9bHo1wrLeDCr3MSkrUdqySKQ	2026-07-21 09:19:46.072	2026-07-21 09:19:46.072	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
j2WQamo6L4lw96pvwvuIy6SogED0anzq	2026-07-28 09:19:48.32	Ju2vkIcHbLfMuXgIaz41XNZenFp6MOWu	2026-07-21 09:19:48.32	2026-07-21 09:19:48.32	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
0HnLu5kpCmLi9oudbyrwFGHKZVp1im5u	2026-07-28 09:19:48.604	Y9LcM3EMxS56Dvir4ecRBBeXJ6nfmgjW	2026-07-21 09:19:48.604	2026-07-21 09:19:48.604	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
0GXaRD5Dh9q8YP6KiYC06iE1G0Xr6N9m	2026-07-28 09:20:09.138	u1ViKWS0mQQBmKMp9izMIjGsLAHBlxMa	2026-07-21 09:20:09.138	2026-07-21 09:20:09.138	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
QDj4meeiDuCRqqWUrcdKyyPl0pqSJwjr	2026-07-28 09:20:09.169	irwadU837Xip7JKv3pWtXaowtP7cWxWs	2026-07-21 09:20:09.169	2026-07-21 09:20:09.169	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1o8hk5uvNfO7c7o0fBUjfcBGDM8gQMt9	2026-07-28 09:20:09.169	sa7IW6wpnZfMwYgNrFIS3Da4S5NQjheR	2026-07-21 09:20:09.169	2026-07-21 09:20:09.169	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
3ZQmbw2F2OtL9JtM4o9EljFDQuCcL3ot	2026-07-28 09:20:09.169	MSZdrg4uM3DNnyadeVFBfXHa9LSrnPcP	2026-07-21 09:20:09.169	2026-07-21 09:20:09.169	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
knwqbLzdlTauRembYy5A0RiU0GYbWPZC	2026-07-28 09:20:11.307	jVrqIp6jhimOx6lkvo80pKHd66P7JN09	2026-07-21 09:20:11.307	2026-07-21 09:20:11.307	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
5R5KNEZkyfNc5BN6XbPV3R7r90ntyhvR	2026-07-28 09:20:11.623	1dH61y4gTCHnyUWNvZNB9uMGPfzZfBCU	2026-07-21 09:20:11.623	2026-07-21 09:20:11.623	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
qZmxZ4rWzqUSATzmVxTAj4Z2az9c6A72	2026-07-28 09:20:13.591	FgF62G9FSCJdkCoK1eK7OCq1YLTGI9X2	2026-07-21 09:20:13.591	2026-07-21 09:20:13.591	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
l8ZKT0yizpeGj2y4Fhj46nEoKO6VXbpF	2026-07-28 09:20:13.613	5chCCBpQeaQUBKxkA3lt0cIMvy1XaqD7	2026-07-21 09:20:13.613	2026-07-21 09:20:13.613	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
hclTQcZN7ZLvmdSVx2aOOFb6wN6KdK1C	2026-07-28 09:20:15.632	eI43poo0OJxznuM0o3SHuCtNcaY8j9CS	2026-07-21 09:20:15.632	2026-07-21 09:20:15.632	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fk7nMiyc7ue4PmRQL3TWgncNyzcjsG21	2026-07-28 09:20:15.863	QY6p2DhDrhrnlkISW1NUsUOQfVhpLG6l	2026-07-21 09:20:15.863	2026-07-21 09:20:15.863	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
omjarst3z9im3fWE8c7D9pAM6rDNhj2Y	2026-07-28 09:20:17.779	boQnAorMf9OQ5RB7RPoZUK51FTZYGKuz	2026-07-21 09:20:17.779	2026-07-21 09:20:17.779	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
vjkQ8eHDg3UPzCxCEZy16Cud1Pbe7DcI	2026-07-28 09:20:18.009	dTAquKSwvNQjfVQxZ2NoI0YArgmARxVW	2026-07-21 09:20:18.009	2026-07-21 09:20:18.009	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
4k4WmaNZvVw98FXdAYsS1KoJcZ0pxeh1	2026-07-28 09:20:20.12	1FmCzN6dlkzT3CiAoXHA8w1aWbmB7MSL	2026-07-21 09:20:20.12	2026-07-21 09:20:20.12	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
bfHEKkIRKy4I7xJdjgJ6k7wrpvaOy5O8	2026-07-28 09:20:20.236	GTj412F9xAgqV48cYGVM8bcb69pauAxN	2026-07-21 09:20:20.236	2026-07-21 09:20:20.236	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7yqZuZFc30bUlhC6GaROrjlux7T8vSKd	2026-07-28 09:20:20.464	xELUAWmJyYBP7CXW3MDI0uIK5tkRZpDB	2026-07-21 09:20:20.464	2026-07-21 09:20:20.464	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
P9GbK0oUlt91SspWu5eTZ1Rq245Wrlic	2026-07-28 09:20:20.699	0CaSJpEXx29Qek6JbIIMX1ALJUMTDSag	2026-07-21 09:20:20.699	2026-07-21 09:20:20.699	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
svyYDsteRKaS2lRRHn9AmyA5NbkXOlmv	2026-07-28 09:20:22.473	GGWYfEB4djgjV8ZEF1wiRwgyKh8DrHhq	2026-07-21 09:20:22.473	2026-07-21 09:20:22.473	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ss3hvEO61pR6Zu6DycSLtvFhBthpgGpP	2026-07-28 09:20:22.897	T4eslvmlkFfNfPArBH6msaF6Acv5ivjO	2026-07-21 09:20:22.897	2026-07-21 09:20:22.897	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7HHRedU9ZmTD9KvNIurMVD6tX9zzui2J	2026-07-28 09:20:22.911	yJBA4yYLvflcUptYXabe0acWqKlmZuSS	2026-07-21 09:20:22.911	2026-07-21 09:20:22.911	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
wpwk9CsatiQ3JLW34DNtsNtnMPwwX1tr	2026-07-28 09:20:24.507	WGfLgj02uNmRYS8JWJhIV9cEqllv1Ao3	2026-07-21 09:20:24.507	2026-07-21 09:20:24.507	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
5FobuJpdRk636luFrT4kSgpijShcXCeG	2026-07-28 09:20:24.911	r3ir6Pg9ARYFNSnFH0XOcaStkFccTo23	2026-07-21 09:20:24.911	2026-07-21 09:20:24.911	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
OmJwyrpJyI55OO20HBk5bOAs0oL38oMj	2026-07-28 09:20:25.333	MtP8l8kgnaywX02Zzcj4jisBk174hSfm	2026-07-21 09:20:25.333	2026-07-21 09:20:25.333	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
5YU5Uq6jjCtQRpcxo7fhgO5iuKWUsr4o	2026-07-28 09:20:25.35	rmwtbJ7GuSiJutwEuGCzwdFddIkquW6I	2026-07-21 09:20:25.35	2026-07-21 09:20:25.35	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
aks49U7eIvAD9SYonYEE8ZNo4QMGWgcm	2026-07-28 09:20:26.597	WBECNbvuYZuJ0Oyw87wja9EFeDgsznBc	2026-07-21 09:20:26.597	2026-07-21 09:20:26.597	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
23p8e3RHy7U8l9gL8UKZAFOJTmWxEYfl	2026-07-28 09:20:27.463	AmlQn6ji8AeP3UbhAx6MPz1EvgXM2oxo	2026-07-21 09:20:27.463	2026-07-21 09:20:27.463	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DBEmUCQCX8HSt8wgskd1CVQtNza2nkBu	2026-07-28 09:20:27.932	LOu3AKSvxMfklgX7Q5UUA2qcEhADV581	2026-07-21 09:20:27.932	2026-07-21 09:20:27.932	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
NdKrDTeyEG67VRTqfaTVjb8xzR80VNgh	2026-07-28 09:20:27.708	BYnwJuULGVQkAw2Ueb9VTjJPhkvPlmRN	2026-07-21 09:20:27.708	2026-07-21 09:20:27.708	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
6GVp8zLF0AOYhwhtXqqOlpnhdOWGaQkW	2026-07-28 09:20:29.338	d9PZ2cr0x5b9VVkbDZpQyetPOoWloLJ6	2026-07-21 09:20:29.338	2026-07-21 09:20:29.338	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7sHSM4qzsrTFXVQwvKKYirTsFcWaeCPR	2026-07-28 09:20:29.805	lF8rFKWb8rNbYspQAWIFjZ97t0bwDEuA	2026-07-21 09:20:29.805	2026-07-21 09:20:29.805	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
lnh87qqjh1CKZrV3kDGjdxXRCND6Zfa0	2026-07-28 09:21:15.896	Rx6azb0geoBlKIm4zWu8qvcfas9AukpH	2026-07-21 09:21:15.896	2026-07-21 09:21:15.896	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Uj1cB8XzLefW7vlE2StlfNqCPAeMgKi9	2026-07-28 09:21:15.908	D9Ei0jP748g7i506yxkWozCRZAkJuoPu	2026-07-21 09:21:15.908	2026-07-21 09:21:15.908	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
v45WVRD0s7fR8tKSuSwpEMflzhyqJhWK	2026-07-28 09:21:15.909	t8eNZHFMzqaMRBVyfNokFb2QjXMHTPfF	2026-07-21 09:21:15.909	2026-07-21 09:21:15.909	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KWdwSEcs1HS1HgdmirrkYe2bvMQmIeR7	2026-07-28 09:21:15.909	4gPtfXnMaSYMWloDcDzGwUWIApkthEsh	2026-07-21 09:21:15.909	2026-07-21 09:21:15.909	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Vei7MdiUnFMOmk2lBKuaFwAGV8papM8T	2026-07-28 09:21:18.166	9XeUCTzst29CC0vDNVRGoIEWoHf3iIcG	2026-07-21 09:21:18.166	2026-07-21 09:21:18.166	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
02kgfRHuoqUv5SxowmgteuRsbxvuIw9k	2026-07-28 09:21:18.591	QZvGfA2r954HFzjB3dYIJ04qM1fL0w8E	2026-07-21 09:21:18.591	2026-07-21 09:21:18.591	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Gg3fZrJKgxGqVPxr7ZrvydeWxtNs0XgC	2026-07-28 09:21:18.604	Hd174cxBehotDSNra3cBgaZt3gAOMjzO	2026-07-21 09:21:18.604	2026-07-21 09:21:18.604	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
J7chlR4wfGOtYVYrag0u2VziMK8zyaky	2026-07-28 09:21:18.824	Idgr5YP8V4qcOPPfSabUVLaSzyEvaNRa	2026-07-21 09:21:18.824	2026-07-21 09:21:18.824	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
zqjXE1qk4Axa85ipf2FWOrZpY4QL8N4H	2026-07-28 09:21:20.595	i9EYavgSfG6jyjkaHApP2iYzuGaiyF3i	2026-07-21 09:21:20.595	2026-07-21 09:21:20.595	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
wQEXJtcCzmb7w5OFI7HP4QsmbD5l85l8	2026-07-28 09:21:20.833	h7tNzqGv4zlV9ihbiukZiSuVcCIEyRrD	2026-07-21 09:21:20.833	2026-07-21 09:21:20.833	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ywSHAmzBImwWg8suFkoVQ2Sz6Unymy9J	2026-07-28 09:21:22.611	ZFcLhvFJboAGFXppE82caXGKdAyZ8tWB	2026-07-21 09:21:22.611	2026-07-21 09:21:22.611	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
XocXoXtgsdWdidtx55SHsxdXUfmRRy8A	2026-07-28 09:21:22.846	xrKLfQ1zYomwDu6bZjGSHlKM87E3OQIh	2026-07-21 09:21:22.846	2026-07-21 09:21:22.846	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
39QtZC3sxZcmRvg6IXnkZN8Ug7dF1DVg	2026-07-28 09:21:24.615	7kzTOVwNiV1ke6wzIU99Bm5877x2hXmR	2026-07-21 09:21:24.615	2026-07-21 09:21:24.615	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
f2c8Cd2YX5C72WqCocfCZF59uie9f8NZ	2026-07-28 09:21:24.843	gXFnt6cs92G1LNQUnGXdDBP62rQnvWed	2026-07-21 09:21:24.843	2026-07-21 09:21:24.843	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ZW3ECj8tk8QZU6gug0FqAJLmCEdumt8Y	2026-07-28 09:21:26.862	OrkltphUv2Bso1q2eNsbWh0ji3dXh02a	2026-07-21 09:21:26.862	2026-07-21 09:21:26.862	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0VcDJwh7AB5HeWtDIM7hQ1kGJgHPgi3j	2026-07-28 09:21:27.09	HuYkTZ3xlELY9oCl1kszgFslvWWuIKcs	2026-07-21 09:21:27.09	2026-07-21 09:21:27.09	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
STyO87CR4VmbYjmu5sP3ejoPsjtCQWMD	2026-07-28 09:21:27.321	Ug8mobxoGaOrb7bsb73asapEDczTXi0k	2026-07-21 09:21:27.321	2026-07-21 09:21:27.321	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
YzKQjrkFXqrSJA969k3RWzzgRiAvKS1Q	2026-07-28 09:21:27.732	yHxadzi3p9s0uR8p0ry8c7nBeolpGGA9	2026-07-21 09:21:27.732	2026-07-21 09:21:27.732	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
nFFLmh5NnRTf1UK24mZv8CBfPAIdOv8p	2026-07-28 09:21:29.096	dhaq6g6YvdZfJGT9oAtn03VgtHdL4d7G	2026-07-21 09:21:29.096	2026-07-21 09:21:29.096	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
OIBKqfuLRLLABplkCnRLiMBxOTZzuniA	2026-07-28 09:21:29.694	rUhRoFe59sfWdWwkEvCCCIQAhCWPnpDO	2026-07-21 09:21:29.694	2026-07-21 09:21:29.694	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fxIJBbELxiKXblDVpNyjTynB2LX3Csr9	2026-07-28 09:21:29.94	Bp15SpZTp8pP6ysuXchSHPJ4SgaDOApE	2026-07-21 09:21:29.94	2026-07-21 09:21:29.94	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
wQbGLLYrvEy7j1Uzwp9PamFL1RvYYitw	2026-07-28 09:21:30.166	zZ4uSf9VZ4Qb0JUCOgDcxCDIkheMAExG	2026-07-21 09:21:30.166	2026-07-21 09:21:30.166	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
gBqZoOn5jRU2QVgnOzokcaVcplnBwSaz	2026-07-28 09:21:31.033	W9iDgmYsL5MAz6n9pEkMmOzv2I4vpuWn	2026-07-21 09:21:31.033	2026-07-21 09:21:31.033	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jhYf9RbJesDXNw2zgRHdSGQS0jJKuQwq	2026-07-28 09:21:32.007	s8YywTrT5fto4uyFtzqidSCGa2NvQuNP	2026-07-21 09:21:32.007	2026-07-21 09:21:32.007	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
yeWQ4wSTvfSURxMwglEYOk5eGgUX7CHv	2026-07-28 09:21:32.304	pE32nfCC7FaSigsEdMkT1J6FZuCJdIWx	2026-07-21 09:21:32.304	2026-07-21 09:21:32.304	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
OgXhnQEQlrXPv4NypweboRnJmXdKE7mD	2026-07-28 09:21:32.531	KK59EboCNtuvgjvZXE6Ks3ZAKZxVsSoY	2026-07-21 09:21:32.531	2026-07-21 09:21:32.531	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
SIi94OSF7N5cCIlojLh5qeZTtVvIQhS5	2026-07-28 09:21:33.751	0zqxriYCGCvj1w0ZdFBylQjI8V8P9pvm	2026-07-21 09:21:33.753	2026-07-21 09:21:33.753	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
rgAmscW9wGaFQSjZGUJgFI1E24k5cCAm	2026-07-28 09:21:34.821	YG6XVXaFXV9SynDin3tny8mXC5SlC1aR	2026-07-21 09:21:34.821	2026-07-21 09:21:34.821	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
9OfHslpnok2uqFGjb36Frcl3lh91fW9x	2026-07-28 09:21:34.836	Ioc7v3Cuh7HgSc20zSUJzn6Kqn9TFIBI	2026-07-21 09:21:34.836	2026-07-21 09:21:34.836	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
8Bp1WM9p9tyD0rwQx08Ht25sMx0rSCRd	2026-07-28 16:05:27.716	YSGt9Pd4YNRxPgqrNIdJgE5ASamEF9TL	2026-07-21 16:05:27.716	2026-07-21 16:05:27.716	127.0.0.1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-IN) WindowsPowerShell/5.1.26100.8875	b032b8c4-fa17-4741-a2ea-34994bfa955b
IFdmyVkGkwgowoJsS5A3W6IuUz1ulwvt	2026-07-28 16:12:37.314	ARDwaSzJ6Km0tX7hdrqosMYQXS6IlRC8	2026-07-21 16:12:37.314	2026-07-21 16:12:37.314	127.0.0.1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-IN) WindowsPowerShell/5.1.26100.8875	b032b8c4-fa17-4741-a2ea-34994bfa955b
R9TWxrvHm7pIvyBHQzLKzG48q5hIzvut	2026-07-28 16:14:34.649	fbA0f5CQJeVbj796X0qvKiVxLpjSpjcx	2026-07-21 16:14:34.649	2026-07-21 16:14:34.649	127.0.0.1	node	b032b8c4-fa17-4741-a2ea-34994bfa955b
g3Nb1huGC1fQWuVh0kf2EB6ESyexmCXV	2026-07-28 16:15:20.232	ebh5jiKfzSOFGSEGFPlzEIg7PhkZF8GM	2026-07-21 16:15:20.232	2026-07-21 16:15:20.232	127.0.0.1	node	b032b8c4-fa17-4741-a2ea-34994bfa955b
sZHnRDjRZ5Z9ymEfK8r0dQSCRvx6ufYn	2026-07-29 09:47:19.518	QIN63svMBxdhhpU2bp9neMHlQQ8huYdq	2026-07-22 09:47:19.519	2026-07-22 09:47:19.519	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
MA5mFuEttxwc18Yej67J2TmxrlWmzMGD	2026-07-29 09:47:19.761	QwZrfh493zbuE3jofGeduLx5eAVd5cDE	2026-07-22 09:47:19.761	2026-07-22 09:47:19.761	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
nvBWAoWs5mjaiwyiE1t8RCsitroaMl7N	2026-07-29 09:47:19.762	g5dAewgDsI7L2En8yh6sPunJLwcyfXN4	2026-07-22 09:47:19.762	2026-07-22 09:47:19.762	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
Nv98UsjtPQNS4u3XPtXm9pIM0Qi5TGW7	2026-07-29 09:47:19.763	QgQgHYvn9qBKvexgw6rZ8HDSsVpaUFQG	2026-07-22 09:47:19.763	2026-07-22 09:47:19.763	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
kUGk1MgPOdsFHZenwkovK7Aa8UwiwY9J	2026-07-29 09:47:19.764	cdepGp3omUgj6bKde65ZR2i5E23kWqI2	2026-07-22 09:47:19.764	2026-07-22 09:47:19.764	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Oz4Mu7xOumTkzNYkRSMolu5cXdB77coW	2026-07-29 09:47:19.764	o8K0BylXyej3kVY4dXMAgDY1GV3fwMRP	2026-07-22 09:47:19.765	2026-07-22 09:47:19.765	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Gq6wp2fMqpj2HkLtX7T8aj4gJnuxT97Y	2026-07-29 09:47:19.765	V8YQNjDhRsUEjOz1bGz0DeFwWoHGCeO4	2026-07-22 09:47:19.765	2026-07-22 09:47:19.765	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
9WT5s6Ni4QaFgys26AwTVi33beRaZ1fO	2026-07-29 09:47:20.117	Ykqyi58VB5pkJVpxumfT6wxvlirOYmKT	2026-07-22 09:47:20.117	2026-07-22 09:47:20.117	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
RMtPRXHuJg28lHO7SWrcAeGDbpImY31H	2026-07-29 09:47:20.445	2wb1VVuS5XIvjl1dtxD7rCcDJscBe9xS	2026-07-22 09:47:20.445	2026-07-22 09:47:20.445	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
NvfvlFlyBcDOUpREc2YWQksGZ9DXWauk	2026-07-29 09:48:07.729	ppiKNGliaV5qlk1bzsbUfZO1O6qrpm8M	2026-07-22 09:48:07.729	2026-07-22 09:48:07.729	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
S70QJJecP0BOv6VEpZhOHOT378T8f6OF	2026-07-29 09:48:07.853	gTpgmuL4btPneKbgbgGkcBqpRNcjsQOk	2026-07-22 09:48:07.853	2026-07-22 09:48:07.853	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
sG2vdkxPIqyCtJEnAZiKS3PqQWVcJV9R	2026-07-29 09:48:07.975	jTqcxl6CkeQHLLChnlPFWNd8Ks2mqo1R	2026-07-22 09:48:07.975	2026-07-22 09:48:07.975	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
bR0iLzfVZXjA5ma0YtoeR0Ie8C6VogE8	2026-07-29 09:48:06.989	ESWSDjeDBITy8oWDDjD6g5Pv3duCVqWb	2026-07-22 09:48:06.989	2026-07-22 09:48:06.989	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
7d9Lxqcd7W15MPkXgEbRtDMOlu2q2lbj	2026-07-29 09:48:08.623	TrPkfDc7nEk05nLLQvPdGTeVCKcKyXrx	2026-07-22 09:48:08.623	2026-07-22 09:48:08.623	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
rLjjG3k9wLnekmQk4lwD3stgFUIiTIRX	2026-07-29 09:48:09.532	l0YkqtmjBkPXLNS5FVWbBvkSKJL6V32h	2026-07-22 09:48:09.533	2026-07-22 09:48:09.533	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
KNvMcBBmCQ4fwTxefxVvJ6uFKhhx3eG7	2026-07-29 09:48:09.534	iYt8cVPfh81mOPHmXb6peBJhUTOjH6UL	2026-07-22 09:48:09.534	2026-07-22 09:48:09.534	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1wmeyhdxJw5h7HK2r6RvziP1xrfmTtuX	2026-07-29 09:48:09.535	jHCaxc0oWkBo8B7IE0v76wVJyI9LCNuX	2026-07-22 09:48:09.535	2026-07-22 09:48:09.535	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
hj3Cu2VlO8oATSQGZ5lKmdcO22kou9fu	2026-07-29 09:48:09.536	Z3Fua9U4DlHZsyGsM1vMjpVN6sHXr4br	2026-07-22 09:48:09.536	2026-07-22 09:48:09.536	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
yg6N3xZsw6L4volbR4amdM28InnFKpii	2026-07-29 09:48:51.408	kpQbaUVCX5blF1uy1HCEdGAJllJWI7fX	2026-07-22 09:48:51.408	2026-07-22 09:48:51.408	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
frljChS5z7aGk8UBgiCY0sENwX2ESg2G	2026-07-29 09:48:51.42	rACnUjHclO2WlBT3FlMukp34O6W93idD	2026-07-22 09:48:51.421	2026-07-22 09:48:51.421	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Upb6IjBnmA5Avj6fFtSaP4oAGZUnUJuc	2026-07-29 09:48:53.466	IyM9zl9phEw3on1lSYvN0lrzVZIYa67K	2026-07-22 09:48:53.466	2026-07-22 09:48:53.466	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Gj7rwSArDVJH277WkC001tJX1Wq9RKwP	2026-07-29 09:48:54.454	PLCVHOckUOaVl9N1b3eM8dUCM7ujo9ww	2026-07-22 09:48:54.454	2026-07-22 09:48:54.454	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
vbkM1ge0hb4C9Jai60WX7YSiJMfX4n2W	2026-07-29 09:48:55.23	Md1HTgXbz2TAhxw10RCbQQSfch76kpN7	2026-07-22 09:48:55.23	2026-07-22 09:48:55.23	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
rpgcgvb9W5LGlaz0qkoarAchbZ3aPDjp	2026-07-29 09:48:55.71	H04W4XXkyL8DOxtsn8QKRqpTE3Fr61ip	2026-07-22 09:48:55.71	2026-07-22 09:48:55.71	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eeJsJKWFVCzCNbA0HmgIo76rirrGUYZC	2026-07-29 09:48:57.057	rfTGZfxRAJUxUV73bS6JtPM5lBPBk40O	2026-07-22 09:48:57.057	2026-07-22 09:48:57.057	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DLYc3UNx0YovbhCy1bQ49crSfSmj9diq	2026-07-29 09:48:57.001	MSiUvh2soHtk7UsQCNM5ilzRIswyGXTd	2026-07-22 09:48:57.001	2026-07-22 09:48:57.001	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Zw7uE21CVRV1qXApV8EtwoHG921xCWcx	2026-07-29 09:48:57.058	dIGrdhBIb2YjGB7RjmF1rtxpgNkXTBta	2026-07-22 09:48:57.058	2026-07-22 09:48:57.058	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
UVhqBBnqZaIYCgzAmcUlPE4KNmNolg7m	2026-07-29 09:48:57.004	zRiRyOzs1VEtpbg9iLMGC02WKo2DqMAU	2026-07-22 09:48:57.004	2026-07-22 09:48:57.004	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
GfU4dF5PilNcxE6pX4IEaITFVCg0X4Wn	2026-07-29 09:54:47.276	BZTi3aPpNKS0fWOBpffrsTAqrl3FWCy4	2026-07-22 09:54:47.276	2026-07-22 09:54:47.276	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
jYvS0GyJxn1ZyQIhjGE7OOVFcZQbZd8Q	2026-07-29 09:54:47.26	AcYwEgExlrwUoBX1YN0YJRBvVhFivVhr	2026-07-22 09:54:47.261	2026-07-22 09:54:47.261	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
MjPyTSYRx0pJ7DL4Y4327lWh5j6t8OBS	2026-07-29 09:54:47.952	bdsNnAx1wcgJYaaAbwHxAwmSunDHyRMv	2026-07-22 09:54:47.953	2026-07-22 09:54:47.953	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
zHGaToJxfpua0JjfejOJaZ6uqXSmUE8R	2026-07-29 09:54:47.957	L8j2xQN9tDTKhZrgH1uluwJP4jEa69uQ	2026-07-22 09:54:47.957	2026-07-22 09:54:47.957	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Ipw7ezp4eZajhXCPU6lDu8xn7WXUdNau	2026-07-29 09:54:48.499	5skGWbIWnEh94dBIv2tOTXG3nrTKdkcr	2026-07-22 09:54:48.499	2026-07-22 09:54:48.499	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0r9dXtWLDFbyIfGojK4SmhUg0RIA0Iue	2026-07-29 09:54:48.504	gNVk2JBIR9hEEcka7gwxI5CuUyGZvCrg	2026-07-22 09:54:48.506	2026-07-22 09:54:48.506	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
04N3Cn2PEI8r5MLJBML69CrqIE81WrFR	2026-07-29 09:54:49.732	f6amNUy0hEEVPy2uUw6li4VBtwzi2Dgi	2026-07-22 09:54:49.732	2026-07-22 09:54:49.732	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
xJL9IourIFsGlyYWG6ArJELCqw8liQFX	2026-07-29 09:54:49.815	hS2u9KKxBSu26ha6jAHQhR7JmVO9KiAy	2026-07-22 09:54:49.815	2026-07-22 09:54:49.815	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
ARjZLCe8eYevaa6jVGNVAHZWGerfhJqG	2026-07-29 09:54:51.209	hzMTV9srnZfblcGyGz9x93oQnWlkj1xo	2026-07-22 09:54:51.209	2026-07-22 09:54:51.209	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
KfXb2Iu7JoyD4QHd4imV9b2xvPqOcsaB	2026-07-29 13:26:33.227	Cuys4PqmZMlBO41MVO957OO0cGcn1B3s	2026-07-22 13:26:33.227	2026-07-22 13:26:33.227	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
qps3onP31OnyBHbpir6OAWlYgiFo9mgg	2026-07-29 13:26:33.419	XpEYBh9GKEv8ehV1X5E6zrfN156a3qNi	2026-07-22 13:26:33.419	2026-07-22 13:26:33.419	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
TnundRxv8zyxkBIOsU25YWOsMxid4lEJ	2026-07-29 13:26:33.42	liqJY2Pc0GWRxl1oe5UJPkcRHII9EaF5	2026-07-22 13:26:33.42	2026-07-22 13:26:33.42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
q2Or7i96SW5lOp1ykAHxvV9DKHvXh4kX	2026-07-29 13:26:33.421	XkSwblMNYC7zvPkPMDBuCSiIo0cInF27	2026-07-22 13:26:33.421	2026-07-22 13:26:33.421	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0dRmTloUsCXIjDyW0e6f4bxxJ0ChPIRT	2026-07-29 13:26:33.758	EWmgiBEnTx9DmC4ZmSZrx8IbhVlyeQbu	2026-07-22 13:26:33.758	2026-07-22 13:26:33.758	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ZOMDO9DppC2K8GeS0X3Xlt4RlDkAixQX	2026-07-29 13:26:33.794	qK88A8mQ98eyDKvQxdbKFochYJJ5om27	2026-07-22 13:26:33.794	2026-07-22 13:26:33.794	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
TAw8ZuX0vYooP8QSJ7sHu9JXN8U2hUcL	2026-07-29 13:26:34.749	Y5pZHzdvvindN93lQs67cuHhLz2LnLpk	2026-07-22 13:26:34.749	2026-07-22 13:26:34.749	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
ThXJgRCLpeuIICjGshTf2ZWXNBFOHOaP	2026-07-29 13:26:34.75	a59viwmoTmLfgSN5lhp699Y3zVRik20b	2026-07-22 13:26:34.75	2026-07-22 13:26:34.75	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Fm445mVNN83JAFeRhuIpGG8wSCrZIUs2	2026-07-29 13:26:34.751	c8TF9Ske0P3Y9FBPfR7z55s8WSB6JAHf	2026-07-22 13:26:34.751	2026-07-22 13:26:34.751	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
kf4Dx8c0TnvamNJQtHnyUB4VWc7Ba7Ob	2026-07-29 13:27:23.703	xqc5ZmHq839DoBncsM3XeZoI0pD3vfWd	2026-07-22 13:27:23.703	2026-07-22 13:27:23.703	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
DMLnFO8iFndWyHzuainSDKzr9LVov7Q4	2026-07-29 13:27:24.138	36UKZqqejdm5ckdXvsWuOndGhSoQi6VA	2026-07-22 13:27:24.138	2026-07-22 13:27:24.138	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
0TLKtAYhMimM0eDwUgfpS1N0wrVyl5UW	2026-07-29 13:27:24.733	UmaQp6b3EH2o54q7ZKPanj87jMERHLdE	2026-07-22 13:27:24.733	2026-07-22 13:27:24.733	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
OLuIkwlG0vB1jE1V3PT8J8oZtcAxMOyj	2026-07-29 13:27:25.55	VS6As28ng30lEydRkWyHyL2pF5IMDxx5	2026-07-22 13:27:25.55	2026-07-22 13:27:25.55	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
v0HvES266aG5EEZtpLmr7osuB1hLlFGz	2026-07-29 13:27:24.734	UjBtfrd66Kj3ZEbd6qnANFvyIJrchIIf	2026-07-22 13:27:24.734	2026-07-22 13:27:24.734	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
8WdgKFYlvkKQktDT9CDAZgyjpWvXrKad	2026-07-29 13:27:24.734	FR6gsT5aKAguwlFSNPZjEZxHBwMPOCbi	2026-07-22 13:27:24.734	2026-07-22 13:27:24.734	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
raehw9sFeItotoNh8Tyhtst1CuMYFbCG	2026-07-29 13:27:24.87	ASFX1I0xt66HCCPH5TXRpjtjl394W1uo	2026-07-22 13:27:24.871	2026-07-22 13:27:24.871	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
wX0lTVavWfjFthHxL6xj9NyxgBDDvdcb	2026-07-29 13:27:25.608	NiMCIMMyyhV9CFr0iLXHmS0GD6mqEFKS	2026-07-22 13:27:25.608	2026-07-22 13:27:25.608	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
YqS9lNCkEp7iXE46khRMJTd7IRHEwNDP	2026-07-29 13:27:25.608	TIt08gRDel18RUF0NfkGTL4d0zUsoZ1X	2026-07-22 13:27:25.608	2026-07-22 13:27:25.608	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
tAxFgr1Sfb32PT8AqEwuKllzLiHjG4QQ	2026-07-29 13:28:27.168	ZkZyU8V5DDi92iNtNlebOLBXdxGk7E4V	2026-07-22 13:28:27.168	2026-07-22 13:28:27.168	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
EtvBX0v30DjUVOTHml0FowCMKvZZxKRI	2026-07-29 13:28:28.34	UgfpUXqqxusW0rhM7k5itQJUiP8B5mZQ	2026-07-22 13:28:28.34	2026-07-22 13:28:28.34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
QQVxeMQExhB6bWezZGQKGyf4LZFZwYPr	2026-07-29 13:28:28.341	cizJeSsK45bXh1wmaOeLmohSBV0p1lH4	2026-07-22 13:28:28.341	2026-07-22 13:28:28.341	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
x6X22Pi5tAYoLMA3pxQNpTp09dqRkmQJ	2026-07-29 13:28:30.042	rBF1TL2OOruwyMe6YnKh5mDK9lbfg5ep	2026-07-22 13:28:30.042	2026-07-22 13:28:30.042	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
1aet0YgfC0xJWMRLsTp4khMcWxOeGlKg	2026-07-29 13:28:31.414	mkzvmIzakiOYMSAu9HxXFbcsDx8jMhTr	2026-07-22 13:28:31.414	2026-07-22 13:28:31.414	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
EKH2WqcH2bZV4hgwu3cje9ExfSQrRNOk	2026-07-29 13:28:31.441	cDBlFJ9HITicJBexNQMT49GNqzcv333m	2026-07-22 13:28:31.441	2026-07-22 13:28:31.441	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ey0o1bCvwR8UHJrQ6ewWxIvmbS8XTqJc	2026-07-29 13:28:31.443	iQSkGzyIfuPfMNh7LyWrl141fFgEPxh7	2026-07-22 13:28:31.443	2026-07-22 13:28:31.443	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
7OWXxPhRRKhBk4uQ9FoB4qsCZhH8s84Y	2026-07-29 13:28:30.043	NX4VEo9jxRXVQMeA8nA5pcky9qifHWaK	2026-07-22 13:28:30.043	2026-07-22 13:28:30.043	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
tawaXqEwiQiXf2fMCNvwzw0yTB8HacHX	2026-07-29 13:28:30.044	JkotBkPshkZ6qkM3UUw0jwjRDaW9678A	2026-07-22 13:28:30.044	2026-07-22 13:28:30.044	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
DnplDLwAdAmblUeb5tzlj77BZSpF15H0	2026-07-29 13:29:14.709	3vPU6vGtigGJsCsRt7MWrTBB0FD0SAiU	2026-07-22 13:29:14.709	2026-07-22 13:29:14.709	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ek2dnJyI63xRdCD3qlJxUmNthalaBooW	2026-07-29 13:29:15.147	wHizfU9BQvIFXdlCiWd2Vq6x4e3o6Dmx	2026-07-22 13:29:15.147	2026-07-22 13:29:15.147	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
cB78iLmFzYupZcGLuXhOns6r5knDigi4	2026-07-29 13:29:15.277	G5vOse9YbhSIGQzSHO03HnWURmWzv8TL	2026-07-22 13:29:15.277	2026-07-22 13:29:15.277	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
GgOBXeoJcnHdN6BrVPq6YQ8K0g1uIK5i	2026-07-29 13:29:15.41	sj0VCume7C3ULDgtpAZ5zKNKVxNTwJ3T	2026-07-22 13:29:15.41	2026-07-22 13:29:15.41	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
Ngjb9SGtsLjfjXSZXNAWVDWmgJjDDBq8	2026-07-29 13:29:15.957	RsZJQJVBgwa93e6DbCJ1ugwPlamsq54s	2026-07-22 13:29:15.957	2026-07-22 13:29:15.957	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fmYwwNjAHo1HODy9OMpvqkNWUkNe4OI0	2026-07-29 13:29:16.468	KLobiQjjFPpeE2Ezm9tfkDPZep8fZJ6x	2026-07-22 13:29:16.468	2026-07-22 13:29:16.468	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
w3h2kBYpQzfshdsLVXwxV1TdoEmzpkSm	2026-07-29 13:29:16.469	dQiYYKFniLJLoIulDcRvllrgC2fwhwjr	2026-07-22 13:29:16.469	2026-07-22 13:29:16.469	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
x2y2BZZQ2yz4WFAbgdFviMMucCjZNPmx	2026-07-29 13:29:16.469	bvoCkTEGv8OpLz7ZaJKQGAJsPmhlJiUu	2026-07-22 13:29:16.469	2026-07-22 13:29:16.469	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
arhoq8Z70wRyZBXYLJwaru8XpaDaxhzW	2026-07-29 13:29:16.469	MoPVOPxC7OJcyLXmYlMQ3uduQ8AM11B6	2026-07-22 13:29:16.469	2026-07-22 13:29:16.469	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Fan9aMQFnrWumHGmSEvfoRX6KJUZYy4L	2026-07-29 13:29:19.462	iGCgLrkTGyNJMMIR5sx7yQvr0h0oxf5R	2026-07-22 13:29:19.462	2026-07-22 13:29:19.462	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
eZYyla3dM39LAIXkFSLyAyRVvRUbJtvY	2026-07-29 13:29:22.544	cD0CwuPkKjeemTGxvFEqT6DIAKr7Gkjf	2026-07-22 13:29:22.544	2026-07-22 13:29:22.544	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
uQscWvVFGJQfURilHgPUbaWVaEaiUbis	2026-07-29 13:29:25.433	KOQABy1H9A8pHOVkaqCcX0yYLWJQLZoZ	2026-07-22 13:29:25.433	2026-07-22 13:29:25.433	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
5SMAdCQhpdHmNjesr2sul6c6ll8cfs1Y	2026-07-29 13:29:28.491	23Ldx9FlHz0elAwRlqARx42VZuXEe7xK	2026-07-22 13:29:28.491	2026-07-22 13:29:28.491	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Nuuy9HdtvzUTfrSgPx1IqD14Nh8dwXPL	2026-08-02 08:51:29.092	xUGZxqicN9sxVEn7OCna7GhSldyri2lR	2026-07-21 19:34:49.346	2026-07-26 08:51:29.092	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
mjVe193mwMR7nzdo8UZk0BGxDbxD9989	2026-08-04 20:54:05.026	klQ23g55GVeLCbOpRe8xPM2MdLqaMUEE	2026-07-28 20:54:05.026	2026-07-28 20:54:05.026	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
dB6PvzKAPvtvrLIsE3bzeTqWzizN8wdZ	2026-08-05 10:28:07.1	dvgAnKxB69u0XpSM78hxpJbfuWBue4kL	2026-07-29 10:28:07.1	2026-07-29 10:28:07.1	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
treMmBTjjM93jruWW8ILZJXGRtrqttQ6	2026-08-05 13:54:00.417	RfN27V2pdB51DEpwXFmRKs9C3pBBvoPf	2026-07-29 13:54:00.417	2026-07-29 13:54:00.417	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
4zC7gMWUT1XVZdc1GASMJEk2uC3LtLcd	2026-08-05 13:54:00.573	AAWV2rjOl1QOvJG3IqX9bxXXrzhYrnM3	2026-07-29 13:54:00.573	2026-07-29 13:54:00.573	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
7YF8KHdQmcmDmcx0nCKVI89679FmFo17	2026-08-05 13:54:00.574	7uUgTbuvozURQpQThUwisagap5I6x02w	2026-07-29 13:54:00.574	2026-07-29 13:54:00.574	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
sZ8apX00no1897kjBFA3O4O3dqZ8r1f8	2026-08-05 13:54:00.726	3TQm2k7D6cW6jknJCx6yc2lzg0cr4qOk	2026-07-29 13:54:00.726	2026-07-29 13:54:00.726	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
ZfY1Cry3x2Yzek8MF8NqVg666UTlt4nU	2026-08-05 13:53:59.685	Uj9JaPQNDj6KWNSMFusxAbSWgZr7Zlle	2026-07-29 13:53:59.685	2026-07-29 13:53:59.685	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
TWPNNFanV0VbUsEKnoI1Vhmkkb3dYVr2	2026-08-05 13:53:59.867	is3NxGDpNh8FbxLHmz8dASvP97n2Q2dL	2026-07-29 13:53:59.867	2026-07-29 13:53:59.867	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
ltXbtnILjVLu6Nm4RmswcYGlZrxXkOeC	2026-08-05 13:54:01.264	dhpERL0qsSALDe7ZUAWyeuaAGW6DTFLT	2026-07-29 13:54:01.264	2026-07-29 13:54:01.264	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
t19GUZ8ekWiJX5cwBnVmS4NPOFY8BLZB	2026-08-05 13:54:01.262	Wh3pB8zbFjcxW8eltuvGvFvwLjAiVRk6	2026-07-29 13:54:01.262	2026-07-29 13:54:01.262	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
J79Q2GFbGj7UyBF1K1KYCIGyHCan6tL6	2026-08-05 13:55:29.334	KdMBTupJuOVsjlF7vdyXVSfIo4BYaaG2	2026-07-29 13:55:29.334	2026-07-29 13:55:29.334	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
UZZ78RwGJsyy2EFjiliZavvJwC6azxAB	2026-08-05 13:55:29.335	z4JydL7n5EE7haJzrmwGCZrr9PAiLYMp	2026-07-29 13:55:29.335	2026-07-29 13:55:29.335	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
n7O38go9ij4SXFoEshGgXGAlAe8JaKU6	2026-08-05 13:55:28.821	WigumBdzOrv3G96oHKRooQUTTk4WmOqK	2026-07-29 13:55:28.821	2026-07-29 13:55:28.821	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
rKFw2PcYOYaK6jFPCrIV8rrUUC3epg5b	2026-08-05 13:55:30.427	nLixXwyOXUO9piapThWD2iH6ICNxn9vW	2026-07-29 13:55:30.427	2026-07-29 13:55:30.427	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
5OHZ1Fm0tyy7VlLdyUzYWeNZdaliKWnd	2026-08-05 13:55:30.509	YwxQT1vzmcx1iIiW3YFjj1VAHWWGNCVf	2026-07-29 13:55:30.509	2026-07-29 13:55:30.509	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
FXi7cIBbxy9n4bn91EqFlXe1oJbmotka	2026-08-05 13:55:30.51	TkirfcaiE4xpcfIrgipHS500TyEZip5Z	2026-07-29 13:55:30.51	2026-07-29 13:55:30.51	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
fBmc8KWa3QV3CNFvgo1gaoDtMIeXnCmo	2026-08-05 13:55:30.511	jgUXySTbvypSjYX9Hht7cr1YdSskEAeL	2026-07-29 13:55:30.511	2026-07-29 13:55:30.511	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
xFQy9C6P161xdFSdqcMySeMsdYLVE6XK	2026-08-05 13:55:28.854	OjTvD1MGxwxG44HrMH9NtnWXCm109Tmr	2026-07-29 13:55:28.854	2026-07-29 13:55:28.854	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
kUpRf1g53ZbgcjAQ4Wkol8VoCBD3JoMr	2026-08-05 13:56:01.824	sEUAEOk1y6TO2Gwz8qNzWAPs4i0z4k4q	2026-07-29 13:56:01.824	2026-07-29 13:56:01.824	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
Up5nxNmZqzmyuFkm08oI83j3c0Vojdrr	2026-08-05 13:56:02.888	8tFL2FhlhoLz9uH1NUziETMG35YBGhtB	2026-07-29 13:56:02.888	2026-07-29 13:56:02.888	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
4wqH8tk76pwdpwax5WSQSNM9wvhIPp2N	2026-08-05 13:56:03.529	TXN7zpU91dgAzVeIxn3NShdCmeV25PCI	2026-07-29 13:56:03.529	2026-07-29 13:56:03.529	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
6nZtrySQ8aGwExJwBcJZY9wDMQIshH08	2026-08-05 13:56:03.53	0P9czj8sC0wGAxVLhG8jKVZ7YTGjfnMK	2026-07-29 13:56:03.53	2026-07-29 13:56:03.53	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
XWihLdLSlglWgx0L0xaZnyMc0fVC09Au	2026-08-05 13:56:03.531	CWLom4iRn6YnMf3TVLGM6ELTiuXJBrTI	2026-07-29 13:56:03.531	2026-07-29 13:56:03.531	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
3PiVNUQjofHkb6zeY1W5sAQj2DtcWFqF	2026-08-05 13:56:03.532	y3VGzEG8vlbBDgQwwpBfhoXhvq0izMoP	2026-07-29 13:56:03.532	2026-07-29 13:56:03.532	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	b032b8c4-fa17-4741-a2ea-34994bfa955b
UR1poqFD8oFyvCuEhuFvW4pgtQ16VWTb	2026-08-05 13:56:03.531	IxrCuA7Ya3XWLqea3aSuGVVVofms9Owe	2026-07-29 13:56:03.531	2026-07-29 13:56:03.531	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
MuYY20wXaYClFEhcXeNb0B3tGJErqdsY	2026-08-05 13:56:02.13	R7h8u0FRbbEYVqhFWUGzSZEC7gdyzwPM	2026-07-29 13:56:02.13	2026-07-29 13:56:02.13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7827.55 Safari/537.36	0cf51ff6-db33-443e-a271-c7af2c1d7199
\.


--
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket (subject, status, category, "customerEmail", "customerName", "assignedToId", "aiSummary", "createdAt", "updatedAt", source, id) FROM stdin;
Unhappy with the service - Ticket #9105	OPEN	REFUND	grace29@example.com	Grace Hopper	\N	\N	2026-07-12 08:22:32.324	2026-07-21 10:03:32.325	WEB	31
Subscription cancelled but still charged - Ticket #8812	OPEN	REFUND	jack30@example.com	Jack Sparrow	\N	\N	2026-07-09 14:11:32.326	2026-07-21 10:03:32.327	WEB	32
Feature request: Dark mode - Ticket #864	OPEN	GENERAL	eve32@example.com	Eve Adams	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-17 22:15:32.329	2026-07-21 10:03:32.33	WEB	34
My account is locked - Ticket #1005	CLOSED	\N	bob33@example.com	Bob Jones	\N	\N	2026-07-04 12:18:32.331	2026-07-21 10:03:32.332	WEB	35
Cannot reset password - Ticket #6489	OPEN	TECHNICAL	grace34@example.com	Grace Hopper	\N	\N	2026-06-22 21:16:32.335	2026-07-21 10:03:32.336	WEB	36
Double charged on my credit card - Ticket #2580	OPEN	REFUND	diana35@example.com	Diana Prince	\N	\N	2026-07-08 13:18:32.337	2026-07-21 10:03:32.337	WEB	37
Refund requested for order - Ticket #7015	RESOLVED	REFUND	charlie38@example.com	Charlie Brown	\N	\N	2026-07-07 17:28:32.342	2026-07-21 10:03:32.342	WEB	40
My account is locked - Ticket #7515	OPEN	TECHNICAL	henry39@example.com	Henry Ford	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-13 21:41:32.343	2026-07-21 10:03:32.343	WEB	41
Cannot reset password - Ticket #6812	RESOLVED	TECHNICAL	diana40@example.com	Diana Prince	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-06-22 12:48:32.344	2026-07-21 10:03:32.344	WEB	42
Double charged on my credit card - Ticket #925	OPEN	REFUND	bob41@example.com	Bob Jones	\N	\N	2026-07-04 11:10:32.345	2026-07-21 10:03:32.345	WEB	43
Feature request: Dark mode - Ticket #1470	CLOSED	GENERAL	henry43@example.com	Henry Ford	\N	\N	2026-07-08 04:38:32.347	2026-07-21 10:03:32.347	WEB	45
Is there a student discount? - Ticket #7294	RESOLVED	GENERAL	eve44@example.com	Eve Adams	\N	\N	2026-07-06 10:03:32.348	2026-07-21 10:03:32.348	WEB	46
Where is my invoice? - Ticket #4459	CLOSED	GENERAL	charlie28@example.com	Charlie Brown	\N	\N	2026-07-15 04:33:32.323	2026-07-21 18:04:26.458	WEB	30
Feature request: Dark mode - Ticket #2786	RESOLVED	GENERAL	alice31@example.com	Alice Smith	\N	\N	2026-06-28 17:01:32.328	2026-07-21 18:04:26.458	WEB	33
App crashes on startup - Ticket #8365	OPEN	TECHNICAL	charlie16@example.com	Charlie Brown	\N	\N	2026-07-19 19:45:32.296	2026-07-27 05:24:43.921	WEB	18
Need help setting up integration - Ticket #6629	OPEN	TECHNICAL	jack0@example.com	Jack Sparrow	\N	\N	2026-06-22 14:59:32.222	2026-07-21 10:03:32.234	WEB	2
Double charged on my credit card - Ticket #3117	OPEN	REFUND	ivy1@example.com	Ivy League	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-06-30 08:11:32.243	2026-07-21 10:03:32.247	WEB	3
Cannot reset password - Ticket #276	OPEN	TECHNICAL	alice4@example.com	Alice Smith	\N	\N	2026-07-01 05:17:32.258	2026-07-21 10:03:32.258	WEB	6
Is there a student discount? - Ticket #1813	RESOLVED	GENERAL	grace5@example.com	Grace Hopper	\N	\N	2026-07-04 07:32:32.26	2026-07-21 10:03:32.262	WEB	7
App crashes on startup - Ticket #1587	RESOLVED	\N	frank6@example.com	Frank Castle	\N	\N	2026-07-06 06:01:32.264	2026-07-21 10:03:32.269	WEB	8
Cannot reset password - Ticket #5620	OPEN	TECHNICAL	bob13@example.com	Bob Jones	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-01 14:00:32.29	2026-07-21 10:03:32.29	WEB	15
Double charged on my credit card - Ticket #9508	RESOLVED	REFUND	charlie15@example.com	Charlie Brown	\N	\N	2026-07-06 08:39:32.293	2026-07-21 10:03:32.295	WEB	17
How do I upgrade my plan? - Ticket #4090	RESOLVED	GENERAL	charlie17@example.com	Charlie Brown	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-06-26 20:22:32.3	2026-07-21 10:03:32.3	WEB	19
App crashes on startup - Ticket #398	RESOLVED	TECHNICAL	diana21@example.com	Diana Prince	\N	\N	2026-06-27 03:37:32.309	2026-07-21 10:03:32.309	WEB	23
Where is my invoice? - Ticket #2570	CLOSED	GENERAL	grace25@example.com	Grace Hopper	\N	\N	2026-07-05 17:08:32.316	2026-07-21 10:03:32.318	WEB	27
App crashes on startup - Ticket #1956	OPEN	TECHNICAL	alice26@example.com	Alice Smith	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-03 07:51:32.32	2026-07-21 10:03:32.32	WEB	28
Is there a student discount? - Ticket #8437	RESOLVED	GENERAL	ivy27@example.com	Ivy League	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-19 03:35:32.321	2026-07-21 10:03:32.322	WEB	29
ysgdkxgkghjcgj	OPEN	\N	e2e@example.com	E2E User	\N	The customer submitted an end-to-end automated test ticket containing placeholder text without a specific support request. In response, automated agents sent a series of test replies to verify system messaging capabilities. The ticket currently remains open in the system as part of this automated testing process.	2026-07-21 06:18:09.42	2026-07-27 05:13:14.859	WEB	1
Subscription cancelled but still charged - Ticket #9246	OPEN	REFUND	jack47@example.com	Jack Sparrow	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-01 16:39:32.355	2026-07-21 10:03:32.355	WEB	49
App crashes on startup - Ticket #7790	CLOSED	TECHNICAL	henry48@example.com	Henry Ford	\N	\N	2026-07-20 03:56:32.356	2026-07-21 10:03:32.357	WEB	50
Cannot reset password - Ticket #7430	CLOSED	TECHNICAL	diana51@example.com	Diana Prince	\N	\N	2026-06-29 14:56:32.362	2026-07-21 10:03:32.362	WEB	53
Subscription cancelled but still charged - Ticket #2091	OPEN	REFUND	charlie52@example.com	Charlie Brown	\N	\N	2026-06-22 19:17:32.363	2026-07-21 10:03:32.363	WEB	54
Refund requested for order - Ticket #1187	OPEN	REFUND	ivy53@example.com	Ivy League	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-18 16:52:32.364	2026-07-21 10:03:32.364	WEB	55
API rate limit exceeded - Ticket #1099	OPEN	TECHNICAL	frank56@example.com	Frank Castle	\N	\N	2026-06-30 18:29:32.372	2026-07-21 10:03:32.373	WEB	58
Unhappy with the service - Ticket #2598	OPEN	REFUND	eve58@example.com	Eve Adams	\N	\N	2026-06-30 18:42:32.377	2026-07-21 10:03:32.378	WEB	60
Refund requested for order - Ticket #1325	OPEN	REFUND	grace64@example.com	Grace Hopper	\N	\N	2026-07-09 01:56:32.395	2026-07-21 10:03:32.395	WEB	66
Feature request: Dark mode - Ticket #9970	OPEN	GENERAL	grace65@example.com	Grace Hopper	\N	\N	2026-06-26 15:15:32.4	2026-07-21 10:03:32.402	WEB	67
My account is locked - Ticket #1910	RESOLVED	TECHNICAL	henry67@example.com	Henry Ford	\N	\N	2026-07-07 16:58:32.407	2026-07-21 10:03:32.408	WEB	69
API rate limit exceeded - Ticket #4942	CLOSED	TECHNICAL	diana70@example.com	Diana Prince	\N	\N	2026-07-03 06:35:32.42	2026-07-21 10:03:32.421	WEB	72
Need help setting up integration - Ticket #4255	RESOLVED	TECHNICAL	jack71@example.com	Jack Sparrow	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-13 14:45:32.424	2026-07-21 10:03:32.425	WEB	73
App crashes on startup - Ticket #7331	RESOLVED	TECHNICAL	eve73@example.com	Eve Adams	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-18 16:15:32.435	2026-07-21 10:03:32.436	WEB	75
Subscription cancelled but still charged - Ticket #3478	OPEN	REFUND	grace74@example.com	Grace Hopper	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-06-25 07:56:32.44	2026-07-21 10:03:32.44	WEB	76
Refund requested for order - Ticket #3628	RESOLVED	REFUND	frank77@example.com	Frank Castle	\N	\N	2026-06-30 16:08:32.453	2026-07-21 10:03:32.454	WEB	79
How do I upgrade my plan? - Ticket #6157	OPEN	GENERAL	charlie80@example.com	Charlie Brown	\N	\N	2026-07-13 15:43:32.466	2026-07-21 10:03:32.466	WEB	82
Double charged on my credit card - Ticket #9331	CLOSED	REFUND	ivy81@example.com	Ivy League	0cf51ff6-db33-443e-a271-c7af2c1d7199	\N	2026-07-15 10:05:32.467	2026-07-21 10:03:32.468	WEB	83
API rate limit exceeded - Ticket #6812	OPEN	TECHNICAL	eve84@example.com	Eve Adams	\N	\N	2026-06-26 07:02:32.48	2026-07-21 10:03:32.481	WEB	86
Where is my invoice? - Ticket #5856	OPEN	GENERAL	alice87@example.com	Alice Smith	\N	\N	2026-07-15 16:03:32.49	2026-07-21 10:03:32.49	WEB	89
How do I upgrade my plan? - Ticket #3593	OPEN	GENERAL	diana89@example.com	Diana Prince	\N	\N	2026-06-22 09:29:32.498	2026-07-21 10:03:32.498	WEB	91
Feature request: Dark mode - Ticket #2247	CLOSED	GENERAL	frank91@example.com	Frank Castle	\N	\N	2026-07-04 21:27:32.504	2026-07-21 10:03:32.505	WEB	93
API rate limit exceeded - Ticket #2095	OPEN	TECHNICAL	ivy97@example.com	Ivy League	\N	\N	2026-07-19 23:52:32.515	2026-07-21 18:04:26.458	WEB	99
Is there a student discount? - Ticket #5237	OPEN	GENERAL	jack98@example.com	Jack Sparrow	dee8ac3c-aef2-4882-9341-6793ee602d68	\N	2026-07-21 17:23:32.516	2026-07-26 08:51:42.643	WEB	100
Refund requested for order - Ticket #9346	OPEN	REFUND	charlie95@example.com	Charlie Brown	\N	\N	2026-07-20 02:46:32.513	2026-07-21 18:07:53.343	WEB	97
Unhappy with the service - Ticket #830	OPEN	REFUND	alice96@example.com	Alice Smith	\N	\N	2026-07-20 22:17:32.514	2026-07-21 18:28:21.823	WEB	98
App crashes on startup - Ticket #8478	OPEN	TECHNICAL	bob99@example.com	Bob Jones	\N	The customer, Bob Jones, reported that the app crashes on startup and requested urgent assistance regarding Ticket #8478. Customer support acknowledged the issue, apologized for the inconvenience, and informed the customer that the team is actively reviewing the problem. The ticket currently remains open while the technical team investigates the root cause to provide a resolution and follow-up update.	2026-07-21 00:50:32.517	2026-07-26 14:41:58.033	WEB	101
Unhappy with the service - Ticket #1437	OPEN	\N	diana11@example.com	Diana Prince	\N	\N	2026-07-20 11:14:32.282	2026-07-27 05:24:34.43	WEB	13
App crashes on startup - Ticket #8298	RESOLVED	TECHNICAL	alice94@example.com	Alice Smith	dee8ac3c-aef2-4882-9341-6793ee602d68	\N	2026-07-19 15:49:32.512	2026-07-21 19:29:29.535	WEB	96
API rate limit exceeded - Ticket #6137	OPEN	TECHNICAL	henry24@example.com	Henry Ford	\N	\N	2026-07-20 20:28:32.314	2026-07-21 10:08:55.505	WEB	26
App crashes on startup - Ticket #3257	OPEN	TECHNICAL	jack36@example.com	Jack Sparrow	\N	\N	2026-07-08 08:07:32.339	2026-07-21 18:04:26.458	WEB	38
Is there a student discount? - Ticket #3909	CLOSED	GENERAL	bob37@example.com	Bob Jones	\N	\N	2026-07-07 11:08:32.34	2026-07-21 18:04:26.458	WEB	39
App crashes on startup - Ticket #7378	OPEN	TECHNICAL	ivy42@example.com	Ivy League	\N	\N	2026-07-04 19:20:32.346	2026-07-21 18:04:26.458	WEB	44
Subscription cancelled but still charged - Ticket #3671	CLOSED	REFUND	charlie45@example.com	Charlie Brown	\N	\N	2026-07-02 16:47:32.351	2026-07-21 18:04:26.458	WEB	47
Where is my invoice? - Ticket #1766	OPEN	GENERAL	ivy46@example.com	Ivy League	\N	\N	2026-07-06 09:35:32.353	2026-07-21 18:04:26.458	WEB	48
App crashes on startup - Ticket #5197	RESOLVED	TECHNICAL	eve2@example.com	Eve Adams	\N	\N	2026-07-02 07:09:32.251	2026-07-21 18:04:26.458	WEB	4
Subscription cancelled but still charged - Ticket #5508	OPEN	REFUND	charlie3@example.com	Charlie Brown	\N	\N	2026-07-03 20:11:32.256	2026-07-21 18:04:26.458	WEB	5
Where is my invoice? - Ticket #5141	RESOLVED	GENERAL	alice7@example.com	Alice Smith	\N	\N	2026-07-07 07:43:32.271	2026-07-21 18:04:26.458	WEB	9
Feature request: Dark mode - Ticket #3707	RESOLVED	GENERAL	bob8@example.com	Bob Jones	\N	\N	2026-06-28 08:29:32.274	2026-07-21 18:04:26.458	WEB	10
Cannot reset password - Ticket #9403	OPEN	TECHNICAL	jack9@example.com	Jack Sparrow	\N	\N	2026-07-16 04:17:32.276	2026-07-21 18:04:26.458	WEB	11
Feature request: Dark mode - Ticket #2623	OPEN	GENERAL	jack10@example.com	Jack Sparrow	\N	\N	2026-07-02 20:38:32.279	2026-07-21 18:04:26.458	WEB	12
Need help setting up integration - Ticket #7274	RESOLVED	TECHNICAL	alice12@example.com	Alice Smith	\N	\N	2026-07-08 13:39:32.288	2026-07-21 18:04:26.458	WEB	14
My account is locked - Ticket #6690	OPEN	TECHNICAL	frank14@example.com	Frank Castle	\N	\N	2026-07-07 09:25:32.292	2026-07-21 18:04:26.458	WEB	16
App crashes on startup - Ticket #9036	RESOLVED	TECHNICAL	ivy18@example.com	Ivy League	\N	\N	2026-07-13 05:06:32.303	2026-07-21 18:04:26.458	WEB	20
Feature request: Dark mode - Ticket #6789	OPEN	GENERAL	eve19@example.com	Eve Adams	\N	\N	2026-07-12 05:59:32.305	2026-07-21 18:04:26.458	WEB	21
Unhappy with the service - Ticket #4380	OPEN	\N	frank20@example.com	Frank Castle	\N	\N	2026-07-16 16:03:32.306	2026-07-21 18:04:26.458	WEB	22
My account is locked - Ticket #9833	OPEN	TECHNICAL	eve22@example.com	Eve Adams	\N	\N	2026-07-03 05:40:32.31	2026-07-21 18:04:26.458	WEB	24
Cannot reset password - Ticket #565	CLOSED	TECHNICAL	alice23@example.com	Alice Smith	\N	\N	2026-07-12 01:18:32.312	2026-07-21 18:04:26.458	WEB	25
Feature request: Dark mode - Ticket #7847	RESOLVED	GENERAL	grace49@example.com	Grace Hopper	\N	\N	2026-07-11 12:43:32.359	2026-07-21 18:04:26.458	WEB	51
Subscription cancelled but still charged - Ticket #788	CLOSED	REFUND	diana50@example.com	Diana Prince	\N	\N	2026-07-10 07:47:32.36	2026-07-21 18:04:26.458	WEB	52
Double charged on my credit card - Ticket #4409	OPEN	REFUND	frank54@example.com	Frank Castle	\N	\N	2026-07-16 11:58:32.367	2026-07-21 18:04:26.458	WEB	56
Cannot reset password - Ticket #1035	RESOLVED	\N	henry55@example.com	Henry Ford	\N	\N	2026-07-15 17:22:32.369	2026-07-21 18:04:26.458	WEB	57
App crashes on startup - Ticket #1691	CLOSED	TECHNICAL	ivy57@example.com	Ivy League	\N	\N	2026-07-15 06:31:32.375	2026-07-21 18:04:26.458	WEB	59
How do I upgrade my plan? - Ticket #4355	CLOSED	GENERAL	bob59@example.com	Bob Jones	\N	\N	2026-07-06 19:49:32.38	2026-07-21 18:04:26.458	WEB	61
API rate limit exceeded - Ticket #9865	CLOSED	TECHNICAL	grace60@example.com	Grace Hopper	\N	\N	2026-07-03 19:20:32.386	2026-07-21 18:04:26.458	WEB	62
Need help setting up integration - Ticket #9179	OPEN	TECHNICAL	eve61@example.com	Eve Adams	\N	\N	2026-07-11 19:16:32.388	2026-07-21 18:04:26.458	WEB	63
Double charged on my credit card - Ticket #7984	OPEN	REFUND	eve62@example.com	Eve Adams	\N	\N	2026-07-15 23:29:32.391	2026-07-21 18:04:26.458	WEB	64
API rate limit exceeded - Ticket #1238	OPEN	TECHNICAL	alice63@example.com	Alice Smith	\N	\N	2026-07-04 15:35:32.393	2026-07-21 18:04:26.458	WEB	65
Refund requested for order - Ticket #6060	OPEN	REFUND	diana66@example.com	Diana Prince	\N	\N	2026-06-30 15:44:32.405	2026-07-21 18:04:26.458	WEB	68
Double charged on my credit card - Ticket #6086	OPEN	REFUND	jack68@example.com	Jack Sparrow	\N	\N	2026-07-19 21:50:32.41	2026-07-21 18:04:26.458	WEB	70
Is there a student discount? - Ticket #7078	OPEN	GENERAL	bob69@example.com	Bob Jones	\N	\N	2026-07-15 15:01:32.413	2026-07-21 18:04:26.458	WEB	71
My account is locked - Ticket #4901	OPEN	TECHNICAL	frank72@example.com	Frank Castle	\N	\N	2026-07-04 18:40:32.429	2026-07-21 18:04:26.458	WEB	74
Unhappy with the service - Ticket #3755	OPEN	REFUND	bob75@example.com	Bob Jones	\N	\N	2026-07-09 07:46:32.443	2026-07-21 18:04:26.458	WEB	77
Cannot reset password - Ticket #2841	RESOLVED	TECHNICAL	jack76@example.com	Jack Sparrow	\N	\N	2026-07-02 23:51:32.449	2026-07-21 18:04:26.458	WEB	78
Where is my invoice? - Ticket #350	RESOLVED	GENERAL	diana78@example.com	Diana Prince	\N	\N	2026-07-04 12:09:32.457	2026-07-21 18:04:26.458	WEB	80
API rate limit exceeded - Ticket #3612	RESOLVED	TECHNICAL	diana79@example.com	Diana Prince	\N	\N	2026-07-12 11:50:32.464	2026-07-21 18:04:26.458	WEB	81
Double charged on my credit card - Ticket #8186	OPEN	REFUND	grace82@example.com	Grace Hopper	\N	\N	2026-07-11 10:41:32.47	2026-07-21 18:04:26.458	WEB	84
Cannot reset password - Ticket #3466	OPEN	TECHNICAL	eve83@example.com	Eve Adams	\N	\N	2026-06-24 16:32:32.474	2026-07-21 18:04:26.458	WEB	85
Unhappy with the service - Ticket #6548	OPEN	REFUND	diana85@example.com	Diana Prince	\N	\N	2026-07-18 03:28:32.482	2026-07-21 18:04:26.458	WEB	87
How do I upgrade my plan? - Ticket #1432	CLOSED	\N	grace86@example.com	Grace Hopper	\N	\N	2026-06-29 02:43:32.485	2026-07-21 18:04:26.458	WEB	88
App crashes on startup - Ticket #6961	RESOLVED	TECHNICAL	jack88@example.com	Jack Sparrow	\N	\N	2026-07-20 09:19:32.496	2026-07-21 18:04:26.458	WEB	90
Double charged on my credit card - Ticket #2941	CLOSED	REFUND	frank90@example.com	Frank Castle	\N	\N	2026-06-24 08:35:32.501	2026-07-21 18:04:26.458	WEB	92
Feature request: Dark mode - Ticket #6799	OPEN	GENERAL	grace92@example.com	Grace Hopper	\N	\N	2026-06-27 04:54:32.508	2026-07-21 18:04:26.458	WEB	94
API rate limit exceeded - Ticket #9112	OPEN	TECHNICAL	henry93@example.com	Henry Ford	\N	\N	2026-06-29 02:53:32.51	2026-07-21 18:04:26.458	WEB	95
How do I create an account?	RESOLVED	GENERAL	sophia.sterling@example.com	Sophia Sterling	\N	Auto-resolved via Knowledge Base: How do I create an account?	2026-07-27 08:50:57.868	2026-07-27 08:51:04.586	WEB	109
Test E2E Ticket	OPEN	TECHNICAL	e2e@example.com	E2E User	\N	\N	2026-07-22 09:48:27.063	2026-07-22 13:29:29.752	WEB	102
Billing Overcharge — September Statement	OPEN	REFUND	jordan.mitchell@example.com	Jordan Mitchell	\N	Jordan Mitchell opened a support ticket regarding an overcharge on their September statement after being charged $149.99 twice instead of the standard $29.99 Basic plan fee. The support agent discovered that an automated system error had inadvertently enrolled the account in a Professional Add-On bundle, which was promptly removed to restore the correct subscription rate. The agent then processed a full $240.00 refund to the customer's active credit card, confirmed the legitimacy of an existing $15.00 referral credit, and had engineering resolve a cosmetic UI display bug. The customer confirmed receipt of the full $240.00 refund on their statement and verified that their October billing was correct, expressing complete satisfaction and marking the ticket as resolved.	2026-07-27 05:25:43.23	2026-07-27 05:27:23.698	WEB	5237
How to optimize PostgreSQL connection pool and index performance for high load?	OPEN	TECHNICAL	alex.rivera@techcorp.io	Alex Rivera	\N	\N	2026-07-27 05:43:50.526	2026-07-27 05:44:05.815	WEB	103
Request for annual subscription refund — accidental renewal	OPEN	REFUND	emily.watson@example.com	Emily Watson	\N	\N	2026-07-27 05:46:01.614	2026-07-27 05:46:03.973	WEB	104
PostgreSQL deadlock detected on high-concurrency UPSERT statements	OPEN	TECHNICAL	marcus.vance@databasedesigns.io	Marcus Vance	\N	\N	2026-07-27 05:56:06.007	2026-07-27 05:56:08.341	WEB	105
I forgot my password and cannot log in	RESOLVED	GENERAL	elena.rostova@example.com	Elena Rostova	\N	Auto-resolved via Knowledge Base: I forgot my password.	2026-07-27 07:14:48.731	2026-07-27 07:14:54.15	WEB	106
How do I create an account?	RESOLVED	GENERAL	sophia.sterling@example.com	Sophia Sterling	\N	Auto-resolved via Knowledge Base: How do I create an account?	2026-07-27 07:24:07.554	2026-07-27 07:24:12.885	WEB	108
Kubernetes pod CrashLoopBackOff with OOMKilled exit code 137	OPEN	TECHNICAL	liam.oconnor@cloudscale.io	Liam O'Connor	\N	Liam O'Connor reported that a production Kubernetes deployment in node pool us-east-1a is failing due to pods entering CrashLoopBackOff with an OOMKilled exit code 137. The customer requested assistance to inspect whether their Java heap configuration is exceeding cgroup v2 memory limits beyond the configured 1Gi limit. No troubleshooting steps or support responses have been provided in the conversation history yet. The ticket currently remains open and is awaiting technical review by an engineer.	2026-07-27 08:59:03.457	2026-07-28 06:05:50.469	WEB	110
Issue regarding my password	RESOLVED	GENERAL	tirth1357@gmail.com	Tirth Patel	\N	Auto-resolved via Knowledge Base: I forgot my password.	2026-07-28 10:10:38.529	2026-07-28 10:10:51.368	EMAIL	111
Issue Regarding Kubernetes Cluster	OPEN	TECHNICAL	tirth1357@gmail.com	Tirth Patel	\N	\N	2026-07-28 13:56:30.461	2026-07-28 13:56:39.02	EMAIL	112
Custom Kafka consumer group partition rebalance error	OPEN	TECHNICAL	devon.miles@techstack.io	Devon Miles	\N	Devon Miles reported an issue where their Apache Kafka consumer group is failing with a CommitFailedException during partition rebalances. The customer requested technical assistance to inspect their session.timeout.ms and max.poll.interval.ms configuration settings. No responses or troubleshooting actions have been provided yet as the ticket was recently submitted. The ticket currently remains open awaiting review by an engineer.	2026-07-27 07:14:54.158	2026-07-29 10:54:48.893	WEB	107
kubernetes	CLOSED	TECHNICAL	tirth1357@gmail.com	Tirth Patel	\N	\N	2026-07-28 13:57:56.201	2026-07-29 13:56:05.462	EMAIL	113
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, name, email, "emailVerified", image, "createdAt", "updatedAt", role, "deletedAt") FROM stdin;
b032b8c4-fa17-4741-a2ea-34994bfa955b	Admin	admin@example.com	t	\N	2026-07-21 06:17:47.862	2026-07-21 06:17:47.862	ADMIN	\N
0cf51ff6-db33-443e-a271-c7af2c1d7199	Support Agent	agent@example.com	t	\N	2026-07-21 06:17:48.114	2026-07-21 06:17:48.114	AGENT	\N
23777ff6-9304-4794-b393-d6624f8f76a7	Updated Playwright User	playwright_1784726957247@example.com_deleted_1784726959042	t	\N	2026-07-22 13:29:17.875	2026-07-22 13:29:19.044	AGENT	2026-07-22 13:29:19.042
dee8ac3c-aef2-4882-9341-6793ee602d68	agent 1	agent1@example.com	t	\N	2026-07-21 18:01:28.511	2026-07-27 09:28:06.645	AGENT	\N
1d43223d-884c-45df-9e79-4f619a8bd734	Updated Playwright User	playwright_1785333241961@example.com_deleted_1785333243782	t	\N	2026-07-29 13:54:03.018	2026-07-29 13:54:03.791	AGENT	2026-07-29 13:54:03.782
19e6c8aa-f310-4e86-861b-93d43666104f	Updated Playwright User	playwright_1785333331540@example.com_deleted_1785333332805	t	\N	2026-07-29 13:55:32.074	2026-07-29 13:55:32.808	AGENT	2026-07-29 13:55:32.805
d4242026-707c-4f9d-94cd-a3b5f070c191	Updated Playwright User	playwright_1784726795754@example.com_deleted_1784726797353	t	\N	2026-07-22 13:26:36.433	2026-07-22 13:26:37.362	AGENT	2026-07-22 13:26:37.353
c99b4e0b-cbcc-4358-b22e-3d122ab33ebc	Updated Playwright User	playwright_1784726846459@example.com_deleted_1784726848049	t	\N	2026-07-22 13:27:27.132	2026-07-22 13:27:28.05	AGENT	2026-07-22 13:27:28.049
0dfcb9ee-89a3-4453-9b1e-f61145a634fa	Updated Playwright User	playwright_1784726913200@example.com_deleted_1784726915089	t	\N	2026-07-22 13:28:34.098	2026-07-22 13:28:35.091	AGENT	2026-07-22 13:28:35.089
39aeba1d-33e5-429b-b6db-91d350ea4d3a	Updated Playwright User	playwright_1785333364603@example.com_deleted_1785333365971	t	\N	2026-07-29 13:56:05.156	2026-07-29 13:56:05.973	AGENT	2026-07-29 13:56:05.971
\.


--
-- Data for Name: verification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.verification (id, identifier, value, "expiresAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Name: ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_id_seq', 113, true);


--
-- Name: bam bam_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.bam
    ADD CONSTRAINT bam_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (name, id);


--
-- Name: job_common job_common_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job_common
    ADD CONSTRAINT job_common_pkey PRIMARY KEY (name, id);


--
-- Name: job_dependency job_dependency_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job_dependency
    ADD CONSTRAINT job_dependency_pkey PRIMARY KEY (child_name, child_id, parent_name, parent_id);


--
-- Name: queue queue_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (name);


--
-- Name: queue_stats queue_stats_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue_stats
    ADD CONSTRAINT queue_stats_pkey PRIMARY KEY (id, captured_on);


--
-- Name: queue_stats_20260727 queue_stats_20260727_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue_stats_20260727
    ADD CONSTRAINT queue_stats_20260727_pkey PRIMARY KEY (id, captured_on);


--
-- Name: queue_stats_20260728 queue_stats_20260728_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue_stats_20260728
    ADD CONSTRAINT queue_stats_20260728_pkey PRIMARY KEY (id, captured_on);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name, key);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: warning warning_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.warning
    ADD CONSTRAINT warning_pkey PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: email_log email_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log
    ADD CONSTRAINT email_log_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base knowledge_base_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.knowledge_base
    ADD CONSTRAINT knowledge_base_pkey PRIMARY KEY (id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: verification verification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification
    ADD CONSTRAINT verification_pkey PRIMARY KEY (id);


--
-- Name: job_common_i1; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i1 ON pgboss.job_common USING btree (name, COALESCE(singleton_key, ''::text)) WHERE ((state = 'created'::pgboss.job_state) AND (policy = 'short'::text));


--
-- Name: job_common_i2; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i2 ON pgboss.job_common USING btree (name, COALESCE(singleton_key, ''::text)) WHERE ((state = 'active'::pgboss.job_state) AND (policy = 'singleton'::text));


--
-- Name: job_common_i3; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i3 ON pgboss.job_common USING btree (name, state, COALESCE(singleton_key, ''::text)) WHERE ((state <= 'active'::pgboss.job_state) AND (policy = 'stately'::text));


--
-- Name: job_common_i4; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i4 ON pgboss.job_common USING btree (name, singleton_on, COALESCE(singleton_key, ''::text)) WHERE ((state <> 'cancelled'::pgboss.job_state) AND (singleton_on IS NOT NULL));


--
-- Name: job_common_i5; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_common_i5 ON pgboss.job_common USING btree (name, start_after) WHERE ((state < 'active'::pgboss.job_state) AND (NOT blocked));


--
-- Name: job_common_i6; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i6 ON pgboss.job_common USING btree (name, COALESCE(singleton_key, ''::text)) WHERE ((state <= 'active'::pgboss.job_state) AND (policy = 'exclusive'::text));


--
-- Name: job_common_i7; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_common_i7 ON pgboss.job_common USING btree (name, group_id) WHERE ((state = 'active'::pgboss.job_state) AND (group_id IS NOT NULL));


--
-- Name: job_common_i8; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_common_i8 ON pgboss.job_common USING btree (name, singleton_key) WHERE ((state = ANY (ARRAY['active'::pgboss.job_state, 'retry'::pgboss.job_state, 'failed'::pgboss.job_state])) AND (policy = 'key_strict_fifo'::text));


--
-- Name: job_common_i9; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_common_i9 ON pgboss.job_common USING btree (name, id) WHERE (blocking AND (state = 'completed'::pgboss.job_state));


--
-- Name: job_dep_parent_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_dep_parent_idx ON pgboss.job_dependency USING btree (parent_name, parent_id);


--
-- Name: queue_stats_i1; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX queue_stats_i1 ON ONLY pgboss.queue_stats USING btree (name, captured_on DESC) INCLUDE (deferred_count, queued_count, ready_count, active_count, failed_count, total_count);


--
-- Name: queue_stats_20260727_name_captured_on_deferred_count_queued_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX queue_stats_20260727_name_captured_on_deferred_count_queued_idx ON pgboss.queue_stats_20260727 USING btree (name, captured_on DESC) INCLUDE (deferred_count, queued_count, ready_count, active_count, failed_count, total_count);


--
-- Name: queue_stats_20260728_name_captured_on_deferred_count_queued_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX queue_stats_20260728_name_captured_on_deferred_count_queued_idx ON pgboss.queue_stats_20260728 USING btree (name, captured_on DESC) INCLUDE (deferred_count, queued_count, ready_count, active_count, failed_count, total_count);


--
-- Name: warning_i1; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX warning_i1 ON pgboss.warning USING btree (created_on DESC);


--
-- Name: account_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "account_userId_idx" ON public.account USING btree ("userId");


--
-- Name: email_log_messageId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "email_log_messageId_key" ON public.email_log USING btree ("messageId");


--
-- Name: session_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX session_token_key ON public.session USING btree (token);


--
-- Name: session_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "session_userId_idx" ON public.session USING btree ("userId");


--
-- Name: ticket_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ticket_createdAt_idx" ON public.ticket USING btree ("createdAt");


--
-- Name: ticket_status_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ticket_status_createdAt_idx" ON public.ticket USING btree (status, "createdAt");


--
-- Name: ticket_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ticket_status_idx ON public.ticket USING btree (status);


--
-- Name: user_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_email_key ON public."user" USING btree (email);


--
-- Name: verification_identifier_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX verification_identifier_idx ON public.verification USING btree (identifier);


--
-- Name: job_common_pkey; Type: INDEX ATTACH; Schema: pgboss; Owner: postgres
--

ALTER INDEX pgboss.job_pkey ATTACH PARTITION pgboss.job_common_pkey;


--
-- Name: queue_stats_20260727_name_captured_on_deferred_count_queued_idx; Type: INDEX ATTACH; Schema: pgboss; Owner: postgres
--

ALTER INDEX pgboss.queue_stats_i1 ATTACH PARTITION pgboss.queue_stats_20260727_name_captured_on_deferred_count_queued_idx;


--
-- Name: queue_stats_20260727_pkey; Type: INDEX ATTACH; Schema: pgboss; Owner: postgres
--

ALTER INDEX pgboss.queue_stats_pkey ATTACH PARTITION pgboss.queue_stats_20260727_pkey;


--
-- Name: queue_stats_20260728_name_captured_on_deferred_count_queued_idx; Type: INDEX ATTACH; Schema: pgboss; Owner: postgres
--

ALTER INDEX pgboss.queue_stats_i1 ATTACH PARTITION pgboss.queue_stats_20260728_name_captured_on_deferred_count_queued_idx;


--
-- Name: queue_stats_20260728_pkey; Type: INDEX ATTACH; Schema: pgboss; Owner: postgres
--

ALTER INDEX pgboss.queue_stats_pkey ATTACH PARTITION pgboss.queue_stats_20260728_pkey;


--
-- Name: job_common dlq_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job_common
    ADD CONSTRAINT dlq_fkey FOREIGN KEY (dead_letter) REFERENCES pgboss.queue(name) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: job_common q_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job_common
    ADD CONSTRAINT q_fkey FOREIGN KEY (name) REFERENCES pgboss.queue(name) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: queue queue_dead_letter_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.queue
    ADD CONSTRAINT queue_dead_letter_fkey FOREIGN KEY (dead_letter) REFERENCES pgboss.queue(name);


--
-- Name: schedule schedule_name_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_name_fkey FOREIGN KEY (name) REFERENCES pgboss.queue(name) ON DELETE CASCADE;


--
-- Name: subscription subscription_name_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_name_fkey FOREIGN KEY (name) REFERENCES pgboss.queue(name) ON DELETE CASCADE;


--
-- Name: account account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message message_ticketId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT "message_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES public.ticket(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ticket ticket_assignedToId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "ticket_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict rIs2beObgjOPsVLz8esfvC7hiitKkrIby7DV0KxYjjA2tnTrIjMXLdGAei5bans

