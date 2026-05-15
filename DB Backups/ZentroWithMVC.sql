--
-- PostgreSQL database dump
--

\restrict FzeBceXOHYqPHseh8AQhxs9zFQLbyamTBKR7Tqoir61XALCTqfORmfILGNa0fYE

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.0

-- Started on 2026-03-13 00:02:40

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

--
-- TOC entry 7 (class 2615 OID 58262)
-- Name: customers; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA customers;


ALTER SCHEMA customers OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 58263)
-- Name: general; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA general;


ALTER SCHEMA general OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 58264)
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 58265)
-- Name: misc; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA misc;


ALTER SCHEMA misc OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 58266)
-- Name: quotes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA quotes;


ALTER SCHEMA quotes OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 58267)
-- Name: security; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA security;


ALTER SCHEMA security OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 58268)
-- Name: templates; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA templates;


ALTER SCHEMA templates OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 58269)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 58307)
-- Name: customers; Type: TABLE; Schema: customers; Owner: postgres
--

CREATE TABLE customers.customers (
    customer_id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255),
    phone_number character varying(50),
    address character varying(255),
    appartment_suite character varying(100),
    city character varying(100),
    postalcode character varying(20),
    country character varying(100),
    user_id character varying(255),
    "CreatedAt" timestamp without time zone,
    "CreatedById" character varying(128),
    "ModifiedAt" timestamp without time zone,
    "ModifiedById" character varying(128),
    "IsActive" boolean DEFAULT false,
    "IsDeleted" boolean DEFAULT false,
    business_id integer
);


ALTER TABLE customers.customers OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 58317)
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: customers; Owner: postgres
--

CREATE SEQUENCE customers.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE customers.customers_customer_id_seq OWNER TO postgres;

--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 228
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: customers; Owner: postgres
--

ALTER SEQUENCE customers.customers_customer_id_seq OWNED BY customers.customers.customer_id;


--
-- TOC entry 229 (class 1259 OID 58318)
-- Name: Statistics; Type: TABLE; Schema: general; Owner: postgres
--

CREATE TABLE general."Statistics" (
    statistic_id integer NOT NULL,
    total_quotes integer DEFAULT 0 NOT NULL,
    total_quotes_value numeric(18,2) DEFAULT 0 NOT NULL,
    total_template integer DEFAULT 0 NOT NULL,
    total_customer integer DEFAULT 0 NOT NULL,
    business_id integer,
    created_at timestamp without time zone DEFAULT now(),
    created_by_id character varying(128),
    modified_at timestamp without time zone,
    modified_by_id character varying(128)
);


ALTER TABLE general."Statistics" OWNER TO postgres;

--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE "Statistics"; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON TABLE general."Statistics" IS 'Stores aggregated statistics for quotes, templates, and customers';


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_quotes; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_quotes IS 'Total number of quotes';


--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_quotes_value; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_quotes_value IS 'Total value of all quotes';


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_template; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_template IS 'Total number of templates';


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_customer; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_customer IS 'Total number of customers';


--
-- TOC entry 230 (class 1259 OID 58331)
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE; Schema: general; Owner: postgres
--

CREATE SEQUENCE general."Statistics_statistic_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE general."Statistics_statistic_id_seq" OWNER TO postgres;

--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 230
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general."Statistics_statistic_id_seq" OWNED BY general."Statistics".statistic_id;


--
-- TOC entry 231 (class 1259 OID 58332)
-- Name: business; Type: TABLE; Schema: general; Owner: postgres
--

CREATE TABLE general.business (
    business_id integer NOT NULL,
    name text NOT NULL,
    phone_number text,
    email text,
    address_first_line text,
    city_town text,
    postcode text,
    country text DEFAULT 'United Kingdom'::text,
    currency text DEFAULT 'GBP'::text,
    currency_identity text DEFAULT 'en-GB'::text
);


ALTER TABLE general.business OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 58342)
-- Name: business_business_id_seq; Type: SEQUENCE; Schema: general; Owner: postgres
--

CREATE SEQUENCE general.business_business_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE general.business_business_id_seq OWNER TO postgres;

--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 232
-- Name: business_business_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.business_business_id_seq OWNED BY general.business.business_id;


--
-- TOC entry 233 (class 1259 OID 58343)
-- Name: business_document; Type: TABLE; Schema: general; Owner: postgres
--

CREATE TABLE general.business_document (
    business_document_id integer NOT NULL,
    business_id integer NOT NULL,
    document_type integer,
    document_name text,
    expiry_date timestamp without time zone,
    actions text,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by integer NOT NULL
);


ALTER TABLE general.business_document OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 58353)
-- Name: business_document_business_document_id_seq; Type: SEQUENCE; Schema: general; Owner: postgres
--

CREATE SEQUENCE general.business_document_business_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE general.business_document_business_document_id_seq OWNER TO postgres;

--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 234
-- Name: business_document_business_document_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.business_document_business_document_id_seq OWNED BY general.business_document.business_document_id;


--
-- TOC entry 235 (class 1259 OID 58354)
-- Name: business_menu; Type: TABLE; Schema: general; Owner: postgres
--

CREATE TABLE general.business_menu (
    business_id integer NOT NULL,
    menu_id integer NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by integer NOT NULL,
    last_updated_on timestamp without time zone,
    last_updated_by integer
);


ALTER TABLE general.business_menu OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 58362)
-- Name: menu; Type: TABLE; Schema: general; Owner: postgres
--

CREATE TABLE general.menu (
    menu_id integer NOT NULL,
    parent_id integer NOT NULL,
    name text NOT NULL,
    link text NOT NULL,
    link_type integer NOT NULL,
    image_ref text,
    show_always boolean DEFAULT false NOT NULL,
    show_in_toolbar boolean DEFAULT false NOT NULL,
    sequence_number integer NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    last_updated_on timestamp without time zone
);


ALTER TABLE general.menu OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 58379)
-- Name: menu_menu_id_seq; Type: SEQUENCE; Schema: general; Owner: postgres
--

CREATE SEQUENCE general.menu_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE general.menu_menu_id_seq OWNER TO postgres;

--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 237
-- Name: menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.menu_menu_id_seq OWNED BY general.menu.menu_id;


--
-- TOC entry 238 (class 1259 OID 58380)
-- Name: Components; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory."Components" (
    "ComponentId" integer NOT NULL,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "BuildCost" numeric NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "PartNo" text DEFAULT ''::text NOT NULL,
    "SellPrice" numeric DEFAULT 0.0 NOT NULL,
    "Supplier" text,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer
);


ALTER TABLE inventory."Components" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 58395)
-- Name: Components_ComponentId_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory."Components" ALTER COLUMN "ComponentId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory."Components_ComponentId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 58396)
-- Name: MaterialComponents; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory."MaterialComponents" (
    "MatCompId" integer NOT NULL,
    "MaterialId" integer NOT NULL,
    "ComponentId" integer NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text
);


ALTER TABLE inventory."MaterialComponents" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 58406)
-- Name: MaterialComponents_MatCompId_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory."MaterialComponents" ALTER COLUMN "MatCompId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory."MaterialComponents_MatCompId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 58407)
-- Name: Materials; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory."Materials" (
    "MaterialId" integer NOT NULL,
    "Name" text,
    "Description" text,
    "SellPrice" numeric,
    "IsActive" boolean,
    "CreatedAt" timestamp without time zone,
    "CostPrice" numeric,
    "PartNo" text,
    "Supplier" text,
    "ModifiedAt" timestamp without time zone,
    "CreatedById" integer,
    "ModifiedById" integer,
    business_id integer
);


ALTER TABLE inventory."Materials" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 58413)
-- Name: Materials_MaterialId_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory."Materials" ALTER COLUMN "MaterialId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory."Materials_MaterialId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 244 (class 1259 OID 58414)
-- Name: MiscLookups; Type: TABLE; Schema: misc; Owner: postgres
--

CREATE TABLE misc."MiscLookups" (
    "CodeEnum" integer NOT NULL,
    "CodeName" text NOT NULL,
    "CodeText" text NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text
);


ALTER TABLE misc."MiscLookups" OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 58424)
-- Name: MiscLookups_CodeEnum_seq; Type: SEQUENCE; Schema: misc; Owner: postgres
--

ALTER TABLE misc."MiscLookups" ALTER COLUMN "CodeEnum" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME misc."MiscLookups_CodeEnum_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 246 (class 1259 OID 58425)
-- Name: code_lookup; Type: TABLE; Schema: misc; Owner: postgres
--

CREATE TABLE misc.code_lookup (
    code_name text NOT NULL,
    code_enum integer NOT NULL,
    code_text text
);


ALTER TABLE misc.code_lookup OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 58432)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 58437)
-- Name: UserRecords; Type: TABLE; Schema: quotes; Owner: postgres
--

CREATE TABLE quotes."UserRecords" (
    "RecStatusId" integer NOT NULL,
    "QuoteReference" text NOT NULL,
    "TempVersionId" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "MiscCodeEnum" integer NOT NULL,
    "MiscCodeName" text NOT NULL,
    "TotalCost" numeric NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "MiscLookupCodeEnum" integer,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "PDFLINK" text DEFAULT ''::text NOT NULL,
    "Status" text,
    "TotalCostPrice" numeric DEFAULT 0.0 NOT NULL,
    "TotalSellPrice" numeric DEFAULT 0.0 NOT NULL,
    "CustomerId" integer,
    business_id integer,
    "StatusId" integer
);


ALTER TABLE quotes."UserRecords" OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 58457)
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE; Schema: quotes; Owner: postgres
--

ALTER TABLE quotes."UserRecords" ALTER COLUMN "RecStatusId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME quotes."UserRecords_RecStatusId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 250 (class 1259 OID 58458)
-- Name: RefreshTokens; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security."RefreshTokens" (
    "Id" integer NOT NULL,
    "UserId" text NOT NULL,
    "Token" text NOT NULL,
    "ExpiryDate" timestamp with time zone NOT NULL,
    "IsRevoked" boolean DEFAULT false NOT NULL,
    "CreatedDate" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE security."RefreshTokens" OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 58471)
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

ALTER TABLE security."RefreshTokens" ALTER COLUMN "Id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME security."RefreshTokens_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 252 (class 1259 OID 58472)
-- Name: jwt_settings; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.jwt_settings (
    "Id" integer DEFAULT 1 NOT NULL,
    "Key" character varying(256) NOT NULL,
    "Issuer" character varying(100) NOT NULL,
    "Audience" character varying(100) NOT NULL,
    "AccessTokenExpiryMinutes" integer DEFAULT 15 NOT NULL,
    "RefreshTokenExpiryDays" integer DEFAULT 7 NOT NULL,
    "UpdatedAt" timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT "CK_jwt_settings_key_length" CHECK ((length(("Key")::text) >= 32)),
    CONSTRAINT "CK_jwt_settings_positive_expiry" CHECK ((("AccessTokenExpiryMinutes" > 0) AND ("RefreshTokenExpiryDays" > 0))),
    CONSTRAINT "CK_jwt_settings_single_row" CHECK (("Id" = 1))
);


ALTER TABLE security.jwt_settings OWNER TO postgres;

--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE jwt_settings; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON TABLE security.jwt_settings IS 'Stores global JWT configuration. Uses single-row pattern (Id always 1).';


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN jwt_settings."Key"; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON COLUMN security.jwt_settings."Key" IS 'Secret key for signing JWT tokens (minimum 256 bits / 32 chars).';


--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN jwt_settings."UpdatedAt"; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON COLUMN security.jwt_settings."UpdatedAt" IS 'UTC timestamp of last update for auditing.';


--
-- TOC entry 253 (class 1259 OID 58489)
-- Name: menu_access; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.menu_access (
    security_group_id integer NOT NULL,
    menu_id integer NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE security.menu_access OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 58497)
-- Name: roles; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.roles (
    "Id" text NOT NULL,
    "Name" character varying(256),
    "NormalizedName" character varying(256),
    "ConcurrencyStamp" text
);


ALTER TABLE security.roles OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 58503)
-- Name: roles_claims; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.roles_claims (
    "Id" integer NOT NULL,
    "RoleId" text NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


ALTER TABLE security.roles_claims OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 58510)
-- Name: roles_claims_Id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

ALTER TABLE security.roles_claims ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME security."roles_claims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 58511)
-- Name: security_group; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.security_group (
    security_group_id integer NOT NULL,
    parent_id integer NOT NULL,
    security_group_name text NOT NULL,
    api_path text NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE security.security_group OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 58523)
-- Name: security_group_members; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.security_group_members (
    security_group_id integer NOT NULL,
    user_id integer NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE security.security_group_members OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 58531)
-- Name: security_group_members_security_group_id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

CREATE SEQUENCE security.security_group_members_security_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE security.security_group_members_security_group_id_seq OWNER TO postgres;

--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 259
-- Name: security_group_members_security_group_id_seq; Type: SEQUENCE OWNED BY; Schema: security; Owner: postgres
--

ALTER SEQUENCE security.security_group_members_security_group_id_seq OWNED BY security.security_group_members.security_group_id;


--
-- TOC entry 260 (class 1259 OID 58532)
-- Name: security_group_sec_group_id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

CREATE SEQUENCE security.security_group_sec_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE security.security_group_sec_group_id_seq OWNER TO postgres;

--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 260
-- Name: security_group_sec_group_id_seq; Type: SEQUENCE OWNED BY; Schema: security; Owner: postgres
--

ALTER SEQUENCE security.security_group_sec_group_id_seq OWNED BY security.security_group.security_group_id;


--
-- TOC entry 261 (class 1259 OID 58533)
-- Name: user_claims; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.user_claims (
    "Id" integer NOT NULL,
    "UserId" text NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


ALTER TABLE security.user_claims OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 58540)
-- Name: user_claims_Id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

ALTER TABLE security.user_claims ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME security."user_claims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 263 (class 1259 OID 58541)
-- Name: user_logins; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.user_logins (
    "LoginProvider" character varying(128) NOT NULL,
    "ProviderKey" character varying(128) NOT NULL,
    "ProviderDisplayName" text,
    "UserId" text NOT NULL
);


ALTER TABLE security.user_logins OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 58549)
-- Name: user_roles; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.user_roles (
    "UserId" text NOT NULL,
    "RoleId" text NOT NULL
);


ALTER TABLE security.user_roles OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 58556)
-- Name: user_tokens; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.user_tokens (
    "UserId" text NOT NULL,
    "LoginProvider" character varying(128) NOT NULL,
    "Name" character varying(128) NOT NULL,
    "Value" text
);


ALTER TABLE security.user_tokens OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 58564)
-- Name: users; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.users (
    "Id" text NOT NULL,
    "BusinessId" integer NOT NULL,
    "UserId" integer NOT NULL,
    "FirstName" text NOT NULL,
    "LastName" text NOT NULL,
    "UserName" character varying(256),
    "NormalizedUserName" character varying(256),
    "Email" character varying(256),
    "NormalizedEmail" character varying(256),
    "EmailConfirmed" boolean NOT NULL,
    "PasswordHash" text,
    "SecurityStamp" text,
    "ConcurrencyStamp" text,
    "PhoneNumber" text,
    "PhoneNumberConfirmed" boolean NOT NULL,
    "TwoFactorEnabled" boolean NOT NULL,
    "LockoutEnd" timestamp with time zone,
    "LockoutEnabled" boolean NOT NULL,
    "AccessFailedCount" integer NOT NULL,
    "IsDeleted" boolean DEFAULT false NOT NULL,
    "PasswordResetToken" text,
    "PasswordResetTokenExpiry" timestamp with time zone
);


ALTER TABLE security.users OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 58581)
-- Name: users_UserId_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

ALTER TABLE security.users ALTER COLUMN "UserId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME security."users_UserId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 268 (class 1259 OID 58582)
-- Name: DependentQuestions; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."DependentQuestions" (
    "DependentQId" integer NOT NULL,
    "QOptionId" integer,
    "NextQuestionId" integer,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text
);


ALTER TABLE templates."DependentQuestions" OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 58590)
-- Name: DependentQuestions_DependentQId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."DependentQuestions" ALTER COLUMN "DependentQId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."DependentQuestions_DependentQId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 270 (class 1259 OID 58591)
-- Name: FieldTypes; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."FieldTypes" (
    "FieldTypeId" integer NOT NULL,
    "FieldName" text NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "DisplayName" text
);


ALTER TABLE templates."FieldTypes" OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 58600)
-- Name: FieldTypes_FieldTypeId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."FieldTypes" ALTER COLUMN "FieldTypeId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."FieldTypes_FieldTypeId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 272 (class 1259 OID 58601)
-- Name: Iframes; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."Iframes" (
    "PID" integer NOT NULL,
    "WebsiteName" text NOT NULL,
    "Link" text NOT NULL,
    "TempVersionId" integer NOT NULL,
    "Status" text,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "Partial_key" text,
    "Full_key" text,
    "TemplateId" integer,
    "BusinessId" integer
);


ALTER TABLE templates."Iframes" OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 58612)
-- Name: Iframes_PID_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."Iframes" ALTER COLUMN "PID" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."Iframes_PID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 274 (class 1259 OID 58613)
-- Name: MetafieldAnswers; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."MetafieldAnswers" (
    metafield_answer_id integer NOT NULL,
    template_version_id integer NOT NULL,
    quote_id integer NOT NULL,
    metafield_id integer NOT NULL,
    metafield_input text
);


ALTER TABLE templates."MetafieldAnswers" OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 58622)
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

CREATE SEQUENCE templates."MetafieldAnswers_metafield_answer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE templates."MetafieldAnswers_metafield_answer_id_seq" OWNER TO postgres;

--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 275
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE OWNED BY; Schema: templates; Owner: postgres
--

ALTER SEQUENCE templates."MetafieldAnswers_metafield_answer_id_seq" OWNED BY templates."MetafieldAnswers".metafield_answer_id;


--
-- TOC entry 276 (class 1259 OID 58623)
-- Name: Metafields; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."Metafields" (
    "PID" integer NOT NULL,
    "TempVersionId" integer NOT NULL,
    "Name" text NOT NULL,
    "FieldType" text NOT NULL,
    "Tag" text,
    "Visibility" text DEFAULT 'Admin only'::text NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "TableStyle" text,
    "MetafieldGuid" uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE templates."Metafields" OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 58638)
-- Name: Metafields_PID_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."Metafields" ALTER COLUMN "PID" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."Metafields_PID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 278 (class 1259 OID 58639)
-- Name: QuestionGroups; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."QuestionGroups" (
    "QuestionGroupId" integer NOT NULL,
    "Name" text NOT NULL,
    "DisplayOrder" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "TemplateVersionId" integer,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer,
    "GroupGuid" uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE templates."QuestionGroups" OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 58652)
-- Name: QuestionGroups_QuestionGroupId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."QuestionGroups" ALTER COLUMN "QuestionGroupId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."QuestionGroups_QuestionGroupId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 280 (class 1259 OID 58653)
-- Name: QuestionOptions; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."QuestionOptions" (
    "QOptionId" integer NOT NULL,
    "OptionText" text NOT NULL,
    "QuestionId" integer NOT NULL,
    "DisplayOrder" integer NOT NULL,
    "FieldTypeId" integer,
    "MaterialCompId" integer,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "MatCompName" text,
    "CreatedById" text,
    "ModifiedById" text,
    "OptionGuid" uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE templates."QuestionOptions" OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 58666)
-- Name: QuestionOptions_QOptionId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."QuestionOptions" ALTER COLUMN "QOptionId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."QuestionOptions_QOptionId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 282 (class 1259 OID 58667)
-- Name: Questions; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."Questions" (
    "QuestionId" integer NOT NULL,
    "Text" text NOT NULL,
    "IsRequired" boolean NOT NULL,
    "DisplayOrder" integer NOT NULL,
    "QuestionGroupId" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "ParentId" integer,
    "ValidFrom" timestamp with time zone,
    "ValidTo" timestamp with time zone,
    "TagId" text,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "TemplateVersionId" integer,
    "FieldTypeId" integer,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer,
    "QuestionGuid" uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE templates."Questions" OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 58682)
-- Name: Questions_QuestionId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."Questions" ALTER COLUMN "QuestionId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."Questions_QuestionId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 58683)
-- Name: TemplateItems; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."TemplateItems" (
    "TemplateItemId" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "ServiceName" character varying(255),
    "Description" character varying(1000),
    "Quantity" integer,
    "Unit" character varying(50),
    "ItemPrice" numeric(18,2),
    "Total" numeric(18,2),
    "TemplateVersion" integer,
    "RowId" text DEFAULT ''::text NOT NULL,
    "CreatedAt" timestamp with time zone,
    "IsActive" boolean DEFAULT false NOT NULL,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "QuoteId" integer,
    "CustomerId" integer,
    business_id integer
);


ALTER TABLE templates."TemplateItems" OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 58694)
-- Name: TemplateItems_TemplateItemId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."TemplateItems" ALTER COLUMN "TemplateItemId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."TemplateItems_TemplateItemId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 286 (class 1259 OID 58695)
-- Name: TemplateVersions; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."TemplateVersions" (
    "TempVersionId" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "TempValidFrom" timestamp with time zone,
    "TempValidTo" timestamp with time zone,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "TempVersion" integer,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer
);


ALTER TABLE templates."TemplateVersions" OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 58704)
-- Name: TemplateVersions_TempVersionId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."TemplateVersions" ALTER COLUMN "TempVersionId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."TemplateVersions_TempVersionId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 288 (class 1259 OID 58705)
-- Name: Templates; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."Templates" (
    "TemplateId" integer NOT NULL,
    "TemplateName" text NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "Description" text,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer,
    template_path text
);


ALTER TABLE templates."Templates" OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 58714)
-- Name: Templates_TemplateId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."Templates" ALTER COLUMN "TemplateId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."Templates_TemplateId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 290 (class 1259 OID 58715)
-- Name: UserAnswers; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."UserAnswers" (
    "UAnswerId" integer NOT NULL,
    "QuestionId" integer NOT NULL,
    "QOptionId" integer,
    "AnswerText" text,
    "DisplayOrder" integer,
    "DateTime" timestamp with time zone NOT NULL,
    "RecordId" integer,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "CustomerId" integer,
    "QuoteVersionId" integer DEFAULT 1,
    business_id integer,
    "ParentOptionId" integer
);


ALTER TABLE templates."UserAnswers" OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 58726)
-- Name: UserAnswers_UAnswerId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."UserAnswers" ALTER COLUMN "UAnswerId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."UserAnswers_UAnswerId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 292 (class 1259 OID 58727)
-- Name: UserRecords; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."UserRecords" (
    "RecStatusId" integer NOT NULL,
    "QuoteReference" text NOT NULL,
    "TempVersionId" integer NOT NULL,
    "TemplateId" integer NOT NULL,
    "MiscCodeEnum" integer NOT NULL,
    "MiscCodeName" text NOT NULL,
    "TotalCost" numeric NOT NULL,
    "IsActive" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone,
    "MiscLookupCodeEnum" integer,
    "ModifiedAt" timestamp with time zone,
    "PDFLINK" text DEFAULT ''::text NOT NULL,
    "CreatedById" text,
    "ModifiedById" text
);


ALTER TABLE templates."UserRecords" OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 58743)
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE; Schema: templates; Owner: postgres
--

ALTER TABLE templates."UserRecords" ALTER COLUMN "RecStatusId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME templates."UserRecords_RecStatusId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4976 (class 2604 OID 58744)
-- Name: customers customer_id; Type: DEFAULT; Schema: customers; Owner: postgres
--

ALTER TABLE ONLY customers.customers ALTER COLUMN customer_id SET DEFAULT nextval('customers.customers_customer_id_seq'::regclass);


--
-- TOC entry 4979 (class 2604 OID 58745)
-- Name: Statistics statistic_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics" ALTER COLUMN statistic_id SET DEFAULT nextval('general."Statistics_statistic_id_seq"'::regclass);


--
-- TOC entry 4985 (class 2604 OID 58746)
-- Name: business business_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business ALTER COLUMN business_id SET DEFAULT nextval('general.business_business_id_seq'::regclass);


--
-- TOC entry 4989 (class 2604 OID 58747)
-- Name: business_document business_document_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business_document ALTER COLUMN business_document_id SET DEFAULT nextval('general.business_document_business_document_id_seq'::regclass);


--
-- TOC entry 4992 (class 2604 OID 58748)
-- Name: menu menu_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.menu ALTER COLUMN menu_id SET DEFAULT nextval('general.menu_menu_id_seq'::regclass);


--
-- TOC entry 5012 (class 2604 OID 58749)
-- Name: security_group security_group_id; Type: DEFAULT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group ALTER COLUMN security_group_id SET DEFAULT nextval('security.security_group_sec_group_id_seq'::regclass);


--
-- TOC entry 5019 (class 2604 OID 58750)
-- Name: MetafieldAnswers metafield_answer_id; Type: DEFAULT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers" ALTER COLUMN metafield_answer_id SET DEFAULT nextval('templates."MetafieldAnswers_metafield_answer_id_seq"'::regclass);


--
-- TOC entry 5395 (class 0 OID 58307)
-- Dependencies: 227
-- Data for Name: customers; Type: TABLE DATA; Schema: customers; Owner: postgres
--

COPY customers.customers (customer_id, first_name, last_name, email, phone_number, address, appartment_suite, city, postalcode, country, user_id, "CreatedAt", "CreatedById", "ModifiedAt", "ModifiedById", "IsActive", "IsDeleted", business_id) FROM stdin;
19	Haseeb	Afzal	haseeb@gmail.com	32423422234	pattoki	pattoki	pattoki	2344234	Pakistan	\N	2025-11-03 17:47:45.587002	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	\N
20	Customer2	Customer2	Customer2@gmail.com	0987656789	\N	\N	\N	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N	\N	\N	\N	f	f	\N
21	Haseeb	Afzal	haseeb@gmail.com	234565432	sdfs	sdf	sdf	2332	Pakistan	\N	2025-12-29 09:34:53.234269	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
22	Abrar	Jabber	abrar@gmail.com	12345678	pattoki	pattoki	pattoki	4565	Pakistan	\N	2026-01-16 20:45:27.266183	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
23	Ahmad	Yaseen	hasee@gmail.com	45678765	pattoki	pattoki	pattoki	4500	Pakistan	\N	2026-01-16 20:49:56.173341	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
24	Ali	Akbar	Ali@gmail.com	2345654345	fsdfs	dsfs	zsds	dfds	dsfsf	\N	2026-01-16 20:59:40.980076	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	f	f	1
25	Ali	Akbar	Ali@gmail.com	2345654345	fsdfs	dsfs	zsds	dfds	dsfsf	\N	2026-01-16 21:08:17.931523	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
26	Ali	Akbar	Ali@gmail.com	2345654345	fsdfs	dsfs	zsds	dfds	dsfsf	\N	2026-01-16 21:08:36.733518	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
28	dsfds	sdfsf	sdfsdf	sdfsf	sdfsf	sdfsd	sdfsfd	sdsdf	sdfsdf	\N	2026-01-16 21:32:08.863376	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	f	f	1
29	fghjh	bh	nv@gmail.com	3457865	jhhj	jh	gjg	45678	hhk	\N	2026-01-16 21:49:19.315054	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
30	Haseeb	afzal	asdf@gmail.com	2345654	xdfd	dfgdg	dfgd	2345	sdfsd	\N	2026-01-16 21:53:12.357964	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	f	f	1
32	Ali	Khan	ali@test.com	03001234567	Lahore	sads	Lahore	2343	Pakistan	\N	2026-01-24 20:07:09.106127	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
31	Ahmad	Raza	ahmed@gmail.com	2345432	Karachi	Karachi	Karachi	12345	sdfsd	\N	2026-01-17 20:41:34.365318	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
27	Ahmad	Raza	ahmed@gmail.com	2345432	Karachi	Karachi	Karachi	12345	Belize	\N	2026-01-16 21:25:40.93076	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	f	f	1
33	abc	def	qwr	sf	sdf	\N	fdsfd	fs	Bahamas	\N	2026-02-22 14:41:03.983607	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
34	tesing customer 1	new customer	12345	3456	2345	\N	1241234	2334	Bahrain	\N	2026-02-22 14:48:14.946326	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	t	f	1
35	tesing 12323235	2353253255	Test1234567890@User.com	35252325	\N	\N	\N	\N	\N	a95100c7-40aa-492d-9c66-f54f8ecf94e1	\N	\N	\N	\N	f	f	1
36	customer	new	user1@Customer.com	+345678	\N	\N	\N	\N	\N	f567ed99-12c2-4479-b37d-9ee25d79b112	\N	\N	\N	\N	f	f	1
\.


--
-- TOC entry 5397 (class 0 OID 58318)
-- Dependencies: 229
-- Data for Name: Statistics; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general."Statistics" (statistic_id, total_quotes, total_quotes_value, total_template, total_customer, business_id, created_at, created_by_id, modified_at, modified_by_id) FROM stdin;
3	91	1816.00	107	7	1	2026-01-17 20:38:09.52139	29a8a07e-094a-48ea-82af-7221f1175cca	2026-01-17 21:05:46.001334	29a8a07e-094a-48ea-82af-7221f1175cca
4	96	1816.00	108	7	1	2026-01-22 19:05:00.585367	SYSTEM_SCHEDULER	2026-01-22 21:56:16.499798	29a8a07e-094a-48ea-82af-7221f1175cca
5	107	1816.00	108	7	1	2026-01-23 17:58:12.428378	29a8a07e-094a-48ea-82af-7221f1175cca	2026-01-23 18:35:35.489002	29a8a07e-094a-48ea-82af-7221f1175cca
6	107	1816.00	108	8	1	2026-01-24 20:07:09.226678	29a8a07e-094a-48ea-82af-7221f1175cca	2026-01-24 20:24:52.089813	29a8a07e-094a-48ea-82af-7221f1175cca
7	107	1816.00	0	8	1	2026-01-26 14:43:18.308664	29a8a07e-094a-48ea-82af-7221f1175cca	2026-01-26 14:43:18.308937	29a8a07e-094a-48ea-82af-7221f1175cca
8	110	1821.00	3	8	1	2026-02-04 16:49:07.87473	29a8a07e-094a-48ea-82af-7221f1175cca	2026-02-04 19:05:00.376047	SYSTEM_SCHEDULER
9	110	1821.00	9	8	1	2026-02-05 15:05:13.221681	29a8a07e-094a-48ea-82af-7221f1175cca	2026-02-05 16:59:27.022056	29a8a07e-094a-48ea-82af-7221f1175cca
10	111	1831.00	9	8	1	2026-02-06 20:24:42.85992	29a8a07e-094a-48ea-82af-7221f1175cca	2026-02-06 20:36:01.00931	29a8a07e-094a-48ea-82af-7221f1175cca
\.


--
-- TOC entry 5399 (class 0 OID 58332)
-- Dependencies: 231
-- Data for Name: business; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business (business_id, name, phone_number, email, address_first_line, city_town, postcode, country, currency, currency_identity) FROM stdin;
1	Elsys	+34986599411	admin@elsys	Calle Reconquista N9 Entresuelo Dcha	Vigo	36201	Spain	USD	en-US
\.


--
-- TOC entry 5401 (class 0 OID 58343)
-- Dependencies: 233
-- Data for Name: business_document; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business_document (business_document_id, business_id, document_type, document_name, expiry_date, actions, created_on, created_by) FROM stdin;
\.


--
-- TOC entry 5403 (class 0 OID 58354)
-- Dependencies: 235
-- Data for Name: business_menu; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business_menu (business_id, menu_id, created_on, created_by, last_updated_on, last_updated_by) FROM stdin;
\.


--
-- TOC entry 5404 (class 0 OID 58362)
-- Dependencies: 236
-- Data for Name: menu; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.menu (menu_id, parent_id, name, link, link_type, image_ref, show_always, show_in_toolbar, sequence_number, created_on, last_updated_on) FROM stdin;
1	0	Home	/	1	/images/home.svg	t	t	1	2024-10-03 08:21:19.922534	\N
3	0	Customers	/page/customers	1	/images/customers.svg	t	t	3	2024-10-03 08:25:57.762331	\N
5	0	Materials	/page/materials	1	/images/materials.svg	t	t	5	2024-10-03 08:25:57.762331	\N
4	0	Components	/page/components	1	/images/components.svg	t	t	4	2024-10-03 08:25:57.762331	\N
6	0	Templates	/page/templates	1	/images/templates.svg	t	t	6	2024-10-03 08:25:57.762331	\N
2	0	Quotes	/page/quotes	1	/images/quote.svg	t	t	2	2024-10-03 08:22:24.938075	\N
\.


--
-- TOC entry 5406 (class 0 OID 58380)
-- Dependencies: 238
-- Data for Name: Components; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."Components" ("ComponentId", "Name", "Description", "BuildCost", "IsActive", "CreatedAt", "PartNo", "SellPrice", "Supplier", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
24	Component 1	Component 1(Description)	2	t	2026-01-26 21:00:40.135943+05	Component 1(Part No)	2	Component 1(Supplier)	\N	\N	\N	1
25	Component 2	Component 2(Description)	3	t	2026-01-26 21:05:35.244622+05	Component 2(Part No)	3	Component 2(Supplier)	\N	\N	\N	1
26	Component 3	Component 3(Description)	3	t	2026-01-26 21:06:30.114491+05	Component 3(Part No)	10	Component 3(Supplier)	\N	\N	\N	1
31	qwwq	qw	5	t	2026-02-11 22:58:26.699083+05	12	3009	weq	\N	\N	\N	1
\.


--
-- TOC entry 5408 (class 0 OID 58396)
-- Dependencies: 240
-- Data for Name: MaterialComponents; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."MaterialComponents" ("MatCompId", "MaterialId", "ComponentId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
42	37	24	t	2026-01-26 21:00:40.344367+05	\N	\N	\N
43	38	25	t	2026-01-26 21:05:35.278738+05	\N	\N	\N
45	38	26	t	2026-02-11 22:45:03.355099+05	\N	\N	\N
46	39	31	t	2026-02-11 22:58:26.718604+05	\N	\N	\N
\.


--
-- TOC entry 5410 (class 0 OID 58407)
-- Dependencies: 242
-- Data for Name: Materials; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."Materials" ("MaterialId", "Name", "Description", "SellPrice", "IsActive", "CreatedAt", "CostPrice", "PartNo", "Supplier", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
37	Material 1	Material 1(Description)	3	t	2026-01-26 20:57:42.837518	2	Material 1(Part NO)	Material 1(Supplier)	\N	\N	\N	1
38	Material 2	Material 2 (Description)	4	t	2026-01-26 20:58:45.201596	3	Material 2(Part No)	Material 2 (Supplier)	\N	\N	\N	1
39	Material 3	Material 3 (Description)	6	t	2026-01-26 20:59:37.393877	5	Material 3(Part No)	Material 3 (Supplier)	\N	\N	\N	1
40	sd	21	32	t	2026-02-11 22:45:54.449433	321	new	31	\N	\N	\N	1
\.


--
-- TOC entry 5412 (class 0 OID 58414)
-- Dependencies: 244
-- Data for Name: MiscLookups; Type: TABLE DATA; Schema: misc; Owner: postgres
--

COPY misc."MiscLookups" ("CodeEnum", "CodeName", "CodeText", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
1	Quotes	Sent	t	2026-01-18 02:10:41.624946+05	2026-01-18 02:10:41.624946+05	\N	\N
2	Quotes	Requested	t	2026-01-18 02:10:41.624946+05	2026-01-18 02:10:41.624946+05	\N	\N
3	Quotes	Rejected	t	2026-01-18 02:10:41.624946+05	2026-01-18 02:10:41.624946+05	\N	\N
4	Quotes	In progress	t	2026-01-18 02:10:41.624946+05	2026-01-18 02:10:41.624946+05	\N	\N
5	Status	Active	t	2026-01-24 01:55:57.380987+05	2026-01-24 01:55:57.380987+05	\N	\N
6	Status	Inactive	t	2026-01-24 01:55:57.380987+05	2026-01-24 01:55:57.380987+05	\N	\N
\.


--
-- TOC entry 5414 (class 0 OID 58425)
-- Dependencies: 246
-- Data for Name: code_lookup; Type: TABLE DATA; Schema: misc; Owner: postgres
--

COPY misc.code_lookup (code_name, code_enum, code_text) FROM stdin;
gender	2	Female
gender	1	Male
account_status	2	Closed
account_status	1	Open
bool_list	2	No
bool_list	1	Yes
address_type	2	Work
address_type	1	Home
council	2	Stockton-on-Tees Borough Council
council	1	Middlesbrough Council
country	1	United Kingdom
customer_note_cat	1	General
customer_note_cat	2	Payments
customer_note_cat	3	Cancellations
vat_list	2	VAT Eligible
vat_list	1	VAT Exempt
customer_note_cat	4	Incidents
fuel_type	1	Petrol
fuel_type	2	Diesel
fuel_type	3	Electric
fuel_type	4	Hybrid
fuel_type	5	Hydrogen
transmission_type	1	Manual
transmission_type	2	Automatic
vehicle_body_type	1	Saloon
vehicle_body_type	2	Hatchback
vehicle_body_type	3	SUV
vehicle_body_type	4	Coupe
vehicle_body_type	5	Convertible
vehicle_body_type	6	Estate
vehicle_body_type	7	MPV
vehicle_body_type	8	Pickup
vehicle_body_type	9	Van
vehicle_body_type	10	Crossover
vehicle_body_type	11	Roadster
vehicle_body_type	12	Limousine
vehicle_body_type	13	Sports Car
vehicle_body_type	14	Microcar
vehicle_color	1	Black
vehicle_color	2	White
vehicle_color	3	Silver
vehicle_color	4	Grey
vehicle_color	5	Blue
vehicle_color	6	Red
vehicle_color	7	Green
vehicle_color	8	Yellow
vehicle_color	9	Orange
vehicle_color	10	Brown
vehicle_color	11	Gold
vehicle_color	12	Beige
vehicle_color	13	Purple
vehicle_color	14	Pink
vehicle_insurance_state	1	Insured
vehicle_insurance_state	2	Uninsured
vehicle_type	3	Motorbike
vehicle_type	2	Van
vehicle_type	1	Car
vehicle_pricing_type	1	Custom Pricing
vehicle_pricing_type	2	Grouping Pricing
vehicle_status	1	Active
vehicle_status	2	Inactive
vehicle_availability	1	Available
vehicle_tax_status	1	Taxed
vehicle_tax_status	2	Untaxed
vehicle_note_category	1	General
vehicle_note_category	2	Payments
vehicle_note_category	3	Cancellations
vehicle_note_category	4	Incidents
vehicle_pricing_type	3	Auto Assign
vehicle_service_type	1	Interim Service
vehicle_service_type	2	Full Service
vehicle_service_type	3	Major Service
vehicle_service_status	2	Completed
vehicle_service_status	1	In Progress
vehicle_mot_result	1	Pass
vehicle_mot_result	2	Fail
vehicle_service_type	4	Maintenance
council	5	Redcar & Cleveland Council
council	4	Darlington Council
council	3	Newcastle Council
vehicle_type	4	MPV
vehicle_type	6	Others
vehicle_type	5	Minibus
vehicle_availability	2	Inactive
vehicle_availability	3	Rented
damage_status	1	Repaired
damage_status	2	Repair In Progress
fault_attribution	2	Third Party
fault_attribution	1	Our Driver
damage_status	3	Write-off
vehicle_rental_type	2	Private Hire
vehicle_rental_type	1	Uber Rentals
billing_frequency	1	Daily
billing_frequency	2	Weekly
billing_frequency	3	Monthly
discount_type	2	Fixed Price
discount_type	1	None
contract_status	1	Active
discount_type	3	Percentage
contract_status	3	Cancelled
contract_note_category	1	General
contract_status	4	Pending
contract_status	2	Expired
contract_type	1	Private Vehicle Hire Rentals
invoice_status	1	Generated
invoice_status	2	Sent
invoice_status	4	Paid
invoice_status	5	Overdue
invoice_status	6	Cancelled
invoice_status	7	Refunded
invoice_status	8	Disputed
invoice_status	3	Partially Paid
\.


--
-- TOC entry 5415 (class 0 OID 58432)
-- Dependencies: 247
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20240924094643_Intial Create	8.0.8
20240925092332_Add autoincrement id to user	8.0.8
20240925093213_Intial Create	8.0.8
20240925094321_Intial Create	8.0.8
20240925103830_Initial create	8.0.8
\.


--
-- TOC entry 5416 (class 0 OID 58437)
-- Dependencies: 248
-- Data for Name: UserRecords; Type: TABLE DATA; Schema: quotes; Owner: postgres
--

COPY quotes."UserRecords" ("RecStatusId", "QuoteReference", "TempVersionId", "TemplateId", "MiscCodeEnum", "MiscCodeName", "TotalCost", "IsActive", "CreatedAt", "MiscLookupCodeEnum", "ModifiedAt", "CreatedById", "ModifiedById", "PDFLINK", "Status", "TotalCostPrice", "TotalSellPrice", "CustomerId", business_id, "StatusId") FROM stdin;
126	Q202545040021	41	35	0		10	t	2025-11-04 23:53:00.038698+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040021.pdf	Authorised	4	6	19	\N	\N
127	Q202545040022	41	35	0		8	t	2025-11-04 23:55:09.957779+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040022.pdf	Requested	4	4	19	\N	\N
135	Q202545050030	43	37	0		34	t	2025-11-05 20:21:11.565479+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050030.pdf	Requested	16	18	19	\N	\N
128	Q202545040023	41	35	0		10	t	2025-11-04 23:56:00.934103+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040023.pdf	Authorised	4	6	19	\N	\N
129	Q202545040024	41	35	0		0	t	2025-11-05 01:17:44.022551+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040024.pdf	Requested	0	0	19	\N	\N
106	Q202545030001	38	38	0		0	t	2025-11-03 22:48:35.461614+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030001.pdf	Requested	0	0	19	\N	\N
107	Q202545030002	38	38	0		0	t	2025-11-03 22:50:03.352471+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030002.pdf	Requested	0	0	19	\N	\N
108	Q202545030003	39	39	0		0	t	2025-11-03 22:55:49.068646+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030003.pdf	Requested	0	0	19	\N	\N
109	Q202545030004	39	39	0		0	t	2025-11-03 22:57:30.634574+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030004.pdf	Requested	0	0	19	\N	\N
110	Q202545030005	39	39	0		0	t	2025-11-03 22:59:03.706542+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030005.pdf	Requested	0	0	19	\N	\N
111	Q202545030006	39	39	0		0	t	2025-11-03 22:59:03.723757+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030006.pdf	Requested	0	0	19	\N	\N
112	Q202545030007	39	39	0		0	t	2025-11-03 23:01:36.7083+05	\N	\N	\N	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030007.pdf	Requested	0	0	19	\N	\N
113	Q202545030008	39	39	0		0	t	2025-11-04 00:04:45.104309+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030008.pdf	Requested	0	0	19	\N	\N
114	Q202545030009	39	39	0		0	t	2025-11-04 00:42:04.36855+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030009.pdf	Requested	0	0	19	\N	\N
115	Q202545030010	39	39	0		0	t	2025-11-04 00:45:37.87612+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030010.pdf	Requested	0	0	19	\N	\N
116	Q202545030011	39	39	0		0	t	2025-11-04 00:59:33.267043+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030011.pdf	Requested	0	0	19	\N	\N
117	Q202545030012	39	39	0		0	t	2025-11-04 01:24:19.290425+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030012.pdf	Requested	0	0	19	\N	\N
118	Q202545030013	40	40	0		0	t	2025-11-04 01:25:48.642663+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545030013.pdf	Requested	0	0	19	\N	\N
119	Q202545040014	40	40	0		0	t	2025-11-04 18:15:49.176753+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040014.pdf	Requested	0	0	19	\N	\N
120	Q202545040015	40	40	0		0	t	2025-11-04 18:15:59.0442+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040015.pdf	Requested	0	0	19	\N	\N
121	Q202545040016	40	40	0		0	t	2025-11-04 18:16:03.825347+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040016.pdf	Requested	0	0	19	\N	\N
122	Q202545040017	40	40	0		0	t	2025-11-04 19:52:29.184555+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040017.pdf	Authorised	0	0	19	\N	\N
123	Q202545040018	40	34	0		0	t	2025-11-04 19:57:47.933523+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040018.pdf	Requested	0	0	19	\N	\N
124	Q202545040019	40	34	0		0	t	2025-11-04 19:57:49.194468+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040019.pdf	Requested	0	0	19	\N	\N
125	Q202545040020	41	35	0		10	t	2025-11-04 23:51:33.059322+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040020.pdf	Authorised	4	6	19	\N	\N
130	Q202545040025	41	35	0		10	t	2025-11-05 01:22:11.467928+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040025.pdf	Authorised	4	6	19	\N	\N
136	Q202545050031	43	37	0		12	t	2025-11-05 20:22:28.965199+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050031.pdf	Requested	4	8	19	\N	\N
131	Q202545040026	41	35	0		8	t	2025-11-05 01:40:09.9571+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040026.pdf	Authorised	4	4	19	\N	\N
132	Q202545040027	41	35	0		0	t	2025-11-05 01:40:42.675231+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040027.pdf	Requested	0	0	19	\N	\N
133	Q202545040028	41	35	0		0	t	2025-11-05 01:40:58.862063+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545040028.pdf	Requested	0	0	19	\N	\N
134	Q202545050029	41	35	0		4	t	2025-11-05 19:22:53.528419+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050029.pdf	Requested	2	2	19	\N	\N
137	Q202545050032	41	35	0		8	t	2025-11-05 20:24:10.277275+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050032.pdf	Authorised	4	4	19	\N	\N
138	Q202545050033	41	35	0		0	t	2025-11-05 20:32:01.400228+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050033.pdf	Requested	0	0	19	\N	\N
139	Q202545050034	43	37	0		0	t	2025-11-05 20:32:13.088815+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050034.pdf	Requested	0	0	19	\N	\N
140	Q202545050035	39	33	0		0	t	2025-11-05 20:32:46.770624+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050035.pdf	Requested	0	0	19	\N	\N
141	Q202545050036	41	35	0		4	t	2025-11-05 20:34:03.751023+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050036.pdf	Requested	2	2	19	\N	\N
142	Q202545050037	41	35	0		4	t	2025-11-05 20:36:00.508478+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050037.pdf	Requested	2	2	19	\N	\N
143	Q202545050038	41	35	0		8	t	2025-11-05 20:46:53.393101+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050038.pdf	Authorised	4	4	19	\N	\N
144	Q202545050039	41	35	0		8	t	2025-11-05 20:47:36.274743+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050039.pdf	Requested	4	4	19	\N	\N
145	Q202545050040	41	35	0		8	t	2025-11-05 22:37:41.500728+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050040.pdf	Authorised	4	4	19	\N	\N
146	Q202545050041	41	35	0		8	t	2025-11-05 22:38:23.479047+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050041.pdf	Authorised	4	4	19	\N	\N
147	Q202545050042	41	35	0		4	t	2025-11-05 22:38:54.50767+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050042.pdf	Authorised	2	2	19	\N	\N
149	Q202545050044	41	35	0		4	t	2025-11-05 22:40:30.939342+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050044.pdf	Requested	2	2	19	\N	\N
148	Q202545050043	41	35	0		4	t	2025-11-05 22:39:45.958564+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050043.pdf	Authorised	2	2	19	\N	\N
150	Q202545050045	41	35	0		6	t	2025-11-05 22:42:27.554066+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050045.pdf	Authorised	2	4	19	\N	\N
181	Q202545070076	44	38	0		0	t	2025-11-07 20:26:02.537891+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
151	Q202545050046	41	35	0		10	t	2025-11-05 23:10:47.293529+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545050046.pdf	Authorised	4	6	19	\N	\N
152	Q202545060047	43	37	0		0	t	2025-11-06 19:52:22.740165+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
153	Q202545060048	43	37	0		0	t	2025-11-06 19:53:48.798614+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
154	Q202545060049	41	35	0		0	t	2025-11-06 19:57:35.848995+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
155	Q202545060050	41	35	0		0	t	2025-11-06 21:54:00.054665+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
156	Q202545060051	41	35	0		0	t	2025-11-06 22:03:00.098844+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
157	Q202545060052	41	35	0		0	t	2025-11-06 23:05:53.605526+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
158	Q202545060053	41	35	0		0	t	2025-11-06 23:09:22.578333+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Authorised	0	0	19	\N	\N
159	Q202545060054	41	35	0		0	t	2025-11-06 23:12:15.474857+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
160	Q202545060055	41	35	0		0	t	2025-11-06 23:14:11.87559+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060055.pdf	Requested	0	0	19	\N	\N
161	Q202545060056	41	35	0		6	t	2025-11-06 23:14:32.011933+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060056.pdf	Requested	2	4	19	\N	\N
162	Q202545060057	41	35	0		0	t	2025-11-06 23:14:59.330048+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
163	Q202545060058	41	35	0		4	t	2025-11-06 23:31:03.476828+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060058.pdf	Requested	2	2	19	\N	\N
164	Q202545060059	41	35	0		0	t	2025-11-06 23:31:08.311607+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060059.pdf	Requested	0	0	19	\N	\N
165	Q202545060060	41	35	0		0	t	2025-11-06 23:31:10.064615+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060060.pdf	Requested	0	0	19	\N	\N
182	Q202545070077	41	35	0		0	t	2025-11-07 20:28:22.929668+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
166	Q202545060061	41	35	0		6	t	2025-11-06 23:31:13.196726+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060061.pdf	Authorised	2	4	19	\N	\N
183	Q202545070078	41	35	0		0	t	2025-11-07 20:28:40.424944+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
167	Q202545060062	41	35	0		4	t	2025-11-06 23:31:44.656442+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202545060062.pdf	Authorised	2	2	19	\N	\N
168	Q202545060063	41	35	0		0	t	2025-11-06 23:32:21.702542+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Authorised	0	0	19	\N	\N
169	Q202545060064	41	35	0		0	t	2025-11-06 23:33:03.290718+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
170	Q202545060065	41	35	0		0	t	2025-11-06 23:45:43.451836+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
171	Q202545060066	41	35	0		0	t	2025-11-06 23:46:51.318101+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
172	Q202545060067	44	38	0		0	t	2025-11-06 23:50:33.861876+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
173	Q202545060068	44	38	0		0	t	2025-11-07 00:36:40.959064+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
174	Q202545070069	41	35	0		0	t	2025-11-07 18:10:44.712946+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
175	Q202545070070	41	35	0		0	t	2025-11-07 19:36:52.424465+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
176	Q202545070071	43	37	0		0	t	2025-11-07 19:41:43.521673+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
177	Q202545070072	39	33	0		0	t	2025-11-07 19:46:13.326435+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
178	Q202545070073	41	35	0		0	t	2025-11-07 20:05:43.886698+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
179	Q202545070074	44	38	0		0	t	2025-11-07 20:24:30.191762+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
180	Q202545070075	44	38	0		0	t	2025-11-07 20:25:03.664346+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
184	Q202545070079	44	38	0		0	t	2025-11-07 20:36:43.76786+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
185	Q202545070080	44	38	0		0	t	2025-11-07 20:55:34.493283+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
186	Q202545070081	44	38	0		0	t	2025-11-07 21:53:47.62196+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
187	Q202545070082	41	35	0		0	t	2025-11-07 22:01:57.798397+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
188	Q202545070083	44	38	0		0	t	2025-11-07 22:05:23.333689+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
189	Q202545070084	41	35	0		0	t	2025-11-07 22:05:34.28067+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
190	Q202545070085	41	35	0		0	t	2025-11-07 22:08:14.836476+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
191	Q202545070086	44	38	0		0	t	2025-11-07 22:10:05.601829+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
192	Q202545070087	44	38	0		0	t	2025-11-07 22:26:26.096625+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
193	Q202545070088	41	35	0		0	t	2025-11-07 22:54:39.452645+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
194	Q202545070089	44	38	0		0	t	2025-11-07 23:01:09.263771+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Authorised	0	0	19	\N	\N
195	Q202545080090	44	38	0		0	t	2025-11-08 18:26:04.996782+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
196	Q202545080091	44	38	0		0	t	2025-11-08 18:31:19.794833+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
197	Q202545080092	44	38	0		0	t	2025-11-08 18:48:24.254868+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
198	Q202545080093	44	38	0		0	t	2025-11-08 18:54:40.661252+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
199	Q202545080094	44	38	0		0	t	2025-11-08 19:21:08.433449+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Authorised	0	0	19	\N	\N
200	Q202545080095	44	38	0		0	t	2025-11-08 19:31:14.809593+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
201	Q202545080096	47	39	0		0	t	2025-11-08 21:16:24.710124+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
202	Q202545080097	48	41	0		0	t	2025-11-08 21:21:04.976117+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
203	Q202545080098	48	41	0		0	t	2025-11-08 21:22:09.378172+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
204	Q202545080099	48	41	0		0	t	2025-11-08 21:34:36.116362+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
205	Q202545080100	48	41	0		0	t	2025-11-08 22:43:36.459972+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
206	Q202545080101	48	41	0		0	t	2025-11-08 22:56:20.26886+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
207	Q202545080102	48	41	0		0	t	2025-11-08 23:25:45.245445+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
208	Q202545080103	48	41	0		0	t	2025-11-08 23:40:58.129985+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
209	Q202545080104	48	41	0		0	t	2025-11-08 23:50:14.722763+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
210	Q202545080105	48	41	0		0	t	2025-11-09 00:00:38.786484+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
211	Q202545080106	44	38	0		0	t	2025-11-09 00:00:56.352773+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
212	Q202545080107	48	41	0		0	t	2025-11-09 00:04:39.572531+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
213	Q202545080108	44	38	0		0	t	2025-11-09 00:05:09.144008+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
214	Q202545080109	48	41	0		0	t	2025-11-09 00:24:02.038507+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
215	Q202545080110	48	41	0		0	t	2025-11-09 00:53:00.962258+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
216	Q202545080111	48	41	0		0	t	2025-11-09 02:53:18.572259+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
217	Q202546140001	43	37	0		0	t	2025-11-14 18:14:26.477083+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
218	Q202546140002	48	41	0		0	t	2025-11-14 18:30:16.168155+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
219	Q202546140003	47	39	0		0	t	2025-11-14 18:30:56.072165+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
220	Q202546140004	43	37	0		0	t	2025-11-14 18:32:12.473614+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
221	Q202546140005	43	37	0		0	t	2025-11-14 18:34:26.25643+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
223	Q202546140007	43	37	0		0	t	2025-11-14 18:41:08.964527+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
222	Q202546140006	48	41	0		0	t	2025-11-14 18:38:09.133428+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Authorised	0	0	19	\N	\N
224	Q202546140008	47	39	0		0	t	2025-11-15 01:02:52.228452+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
225	Q202546140009	42	36	0		0	t	2025-11-15 01:09:21.111955+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
226	Q202546140010	44	38	0		0	t	2025-11-15 01:13:15.04954+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
227	Q202546150011	47	39	0		0	t	2025-11-15 20:58:21.311233+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
228	Q202546150012	48	41	0		0	t	2025-11-15 20:58:31.4787+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
229	Q202546150013	48	41	0		0	t	2025-11-15 21:08:47.203304+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
230	Q202546150014	48	41	0		0	t	2025-11-15 21:09:06.750595+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
231	Q202546150015	43	37	0		0	t	2025-11-16 00:00:53.113102+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
232	Q202546150016	43	37	0		0	t	2025-11-16 00:31:42.980693+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
233	Q202546150017	43	37	0		0	t	2025-11-16 00:33:09.532179+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
234	Q202547170001	50	43	0		0	t	2025-11-17 19:15:44.460073+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
235	Q202547170002	50	43	0		0	t	2025-11-17 20:39:32.052654+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
236	Q202547170003	50	43	0		0	t	2025-11-17 21:35:18.945655+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
237	Q202547180004	43	37	0		0	t	2025-11-19 01:34:43.186535+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202547180004.pdf	Requested	0	0	0	\N	\N
238	Q202547180005	46	40	0		0	t	2025-11-19 01:46:43.073751+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
239	Q202547180006	46	40	0		0	t	2025-11-19 01:50:46.36453+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
240	Q202547180007	50	43	0		0	t	2025-11-19 01:50:58.947305+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
241	Q202547180008	50	43	0		0	t	2025-11-19 04:18:19.172961+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
242	Q202547180009	50	43	0		0	t	2025-11-19 04:19:27.742371+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
243	Q202547190010	38	38	0		0	t	2025-11-20 00:36:34.427213+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202547190010.pdf	Requested	0	0	0	\N	\N
244	Q202547190011	40	34	0		0	t	2025-11-20 00:38:18.050112+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
245	Q202547190012	44	38	0		0	t	2025-11-20 00:42:12.367378+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
246	Q202547190013	44	38	0		0	t	2025-11-20 01:04:36.192569+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
247	Q202547190014	44	38	0		0	t	2025-11-20 01:04:57.595018+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
248	Q202547200015	50	43	0		0	t	2025-11-20 21:49:11.69459+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
249	Q202547210016	50	43	0		0	t	2025-11-22 01:31:35.208867+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
250	Q202547210017	50	43	0		0	t	2025-11-22 01:35:43.299235+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
251	Q202547210018	50	43	0		0	t	2025-11-22 02:35:43.504074+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
252	Q202547210019	50	43	0		0	t	2025-11-22 03:08:04.937086+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
253	Q202547220020	50	43	0		0	t	2025-11-22 19:06:29.450701+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
254	Q202547220021	50	43	0		0	t	2025-11-22 19:07:24.359431+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
255	Q202547220022	51	44	0		0	t	2025-11-22 21:49:45.429041+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
281	Q202548250020	51	44	0		12	t	2025-11-25 21:31:15.619142+05	\N	2025-11-25 21:31:45.165433+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	19	\N	\N
256	Q202547220023	51	44	0		72	t	2025-11-22 23:27:58.758929+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	36	36	19	\N	\N
257	Q202547230024	51	44	0		0	t	2025-11-24 00:10:09.553824+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
258	Q202547230025	51	44	0		0	t	2025-11-24 00:32:39.830764+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
259	Q202547230026	51	44	0		0	t	2025-11-24 00:33:43.283733+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
260	Q202547230027	51	44	0		0	t	2025-11-24 00:54:51.187984+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
261	Q202547230028	51	44	0		0	t	2025-11-24 01:02:58.685474+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
262	Q202548240001	51	44	0		0	t	2025-11-24 15:11:12.227456+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
263	Q202548240002	51	44	0		0	t	2025-11-24 20:19:37.29908+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
264	Q202548240003	51	44	0		0	t	2025-11-24 20:23:30.084512+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
265	Q202548240004	51	44	0		0	t	2025-11-24 21:36:45.845962+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
266	Q202548240005	51	44	0		0	t	2025-11-24 21:47:09.093572+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
267	Q202548240006	51	44	0		0	t	2025-11-24 22:09:23.447218+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
268	Q202548240007	51	44	0		0	t	2025-11-24 23:22:55.158081+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
269	Q202548240008	51	44	0		0	t	2025-11-24 23:31:14.269756+05	\N	2025-11-24 23:43:11.68658+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
270	Q202548240009	51	44	0		0	t	2025-11-24 23:43:21.844073+05	\N	2025-11-24 23:45:04.846811+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
275	Q202548250014	51	44	0		36	t	2025-11-25 18:19:56.997037+05	\N	2025-11-25 18:20:28.283949+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	14	22	19	\N	\N
276	Q202548250015	51	44	0		0	t	2025-11-25 18:28:07.532346+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
277	Q202548250016	51	44	0		0	t	2025-11-25 18:29:50.460258+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
278	Q202548250017	51	44	0		0	t	2025-11-25 18:30:17.357103+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
282	Q202548250021	51	44	0		12	t	2025-11-25 21:32:00.61626+05	\N	2025-11-25 21:34:56.545181+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	19	\N	\N
283	Q202548250022	51	44	0		0	t	2025-11-25 22:17:39.26139+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
284	Q202548250023	51	44	0		0	t	2025-11-25 22:18:25.868846+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
285	Q202548250024	51	44	0		0	t	2025-11-25 23:41:08.169517+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
271	Q202548240010	51	44	0		136	t	2025-11-24 23:48:22.04012+05	\N	2025-11-25 00:00:07.419448+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	16	20	19	\N	\N
298	Q202548270037	51	44	0		34	t	2025-11-27 23:20:42.120939+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	16	18	\N	\N	\N
273	Q202548240012	51	44	0		16	t	2025-11-25 00:43:32.156597+05	\N	2025-11-25 00:53:52.438141+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	10	19	\N	\N
286	Q202548250025	51	44	0		0	t	2025-11-25 23:57:41.327217+05	\N	2025-11-26 00:00:18.103571+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
279	Q202548250018	51	44	0		4	t	2025-11-25 21:28:17.720809+05	\N	2025-11-25 21:28:43.385945+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	2	2	19	\N	\N
280	Q202548250019	51	44	0		0	t	2025-11-25 21:29:04.034387+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
287	Q202548250026	51	44	0		0	t	2025-11-26 00:34:50.222631+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
272	Q202548240011	51	44	0		28	t	2025-11-25 00:00:19.042966+05	\N	2025-11-25 00:43:22.900762+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	12	16	19	\N	\N
274	Q202548240013	51	44	0		20	t	2025-11-25 01:12:47.008956+05	\N	2025-11-25 18:17:16.331745+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	8	12	19	\N	\N
288	Q202548250027	51	44	0		4	t	2025-11-26 00:41:07.289651+05	\N	2025-11-26 00:42:42.341225+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	2	2	19	\N	\N
289	Q202548250028	51	44	0		0	t	2025-11-26 00:49:02.087611+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
290	Q202548250029	51	44	0		0	t	2025-11-26 00:50:50.121521+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
291	Q202548250030	51	44	0		0	t	2025-11-26 00:59:47.802871+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
292	Q202548260031	51	44	0		0	t	2025-11-26 23:04:54.832091+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
295	Q202548260034	51	44	0		12	t	2025-11-26 23:29:09.371517+05	\N	2025-11-27 20:14:28.352269+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	19	\N	\N
293	Q202548260032	51	44	0		0	t	2025-11-26 23:06:47.012706+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	19	\N	\N
294	Q202548260033	51	44	0		28	t	2025-11-26 23:28:32.311486+05	\N	2025-11-26 23:29:32.281623+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	18	19	\N	\N
297	Q202548270036	51	44	0		20	t	2025-11-27 23:14:26.202202+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	10	\N	\N	\N
296	Q202548260035	51	44	0		0	t	2025-11-26 23:43:53.002025+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	0	0	\N	\N	\N
299	Q202548270038	51	44	0		16	t	2025-11-27 23:22:02.24888+05	\N	2025-11-27 23:23:41.810157+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270038.pdf	Requested	8	8	19	\N	\N
300	Q202548270039	51	44	0		36	t	2025-11-27 23:30:23.284272+05	\N	2025-11-27 23:33:39.569717+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270039.pdf	Authorised	16	20	19	\N	\N
301	Q202548270040	44	44	0		0	t	2025-11-27 23:31:28.396202+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270040.pdf	Requested	0	0	19	\N	\N
302	Q202548270041	51	44	0		50	t	2025-11-27 23:34:01.513604+05	\N	2025-11-27 23:44:22.452157+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270041.pdf	Requested	18	32	19	\N	\N
303	Q202548270042	51	44	0		8	t	2025-11-27 23:41:37.412933+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	4	4	\N	\N	\N
304	Q202548270043	51	44	0		20	t	2025-11-27 23:49:27.701592+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	10	\N	\N	\N
305	Q202548270044	51	44	0		16	t	2025-11-27 23:58:27.065421+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	8	8	\N	\N	\N
306	Q202548270045	51	44	0		42	t	2025-11-27 23:59:28.981851+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	20	22	\N	\N	\N
307	Q202548270046	51	44	0		22	t	2025-11-28 00:13:59.274374+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	12	\N	\N	\N
308	Q202548270047	51	44	0		12	t	2025-11-28 00:14:45.77907+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	\N	\N	\N
309	Q202548270048	51	44	0		22	t	2025-11-28 00:14:45.806116+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	12	\N	\N	\N
310	Q202548270049	51	44	0		12	t	2025-11-28 00:14:55.754016+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	\N	\N	\N
311	Q202548270050	51	44	0		12	t	2025-11-28 00:15:38.381862+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	\N	\N	\N
312	Q202548270051	51	44	0		12	t	2025-11-28 00:15:39.622245+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	\N	\N	\N
313	Q202548270052	51	44	0		12	t	2025-11-28 00:15:42.732023+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	6	6	\N	\N	\N
314	Q202548270053	51	44	0		22	t	2025-11-28 00:15:42.895462+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	10	12	\N	\N	\N
321	Q202548270060	51	44	0		50	t	2025-11-28 01:13:51.385428+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	20	30	\N	\N	\N
338	Q202548280077	51	44	0		0	t	2025-11-28 22:19:31.498868+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280077.pdf	Requested	0	0	19	\N	\N
316	Q202548270055	44	44	0		0	t	2025-11-28 00:18:53.464843+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270055.pdf	Requested	0	0	19	\N	\N
317	Q202548270056	44	44	0		0	t	2025-11-28 00:37:20.674982+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270056.pdf	Requested	0	0	19	\N	\N
315	Q202548270054	51	44	0		16	t	2025-11-28 00:17:57.473099+05	\N	2025-11-28 00:37:29.003104+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270054.pdf	Requested	8	8	19	\N	\N
343	Q202548280082	52	45	0		4	t	2025-11-28 23:13:38.013865+05	\N	2025-11-28 23:16:32.069133+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280082.pdf	Requested	2	2	19	\N	\N
328	Q202548270067	51	44	0		28	t	2025-11-28 01:53:33.883013+05	\N	2025-11-28 19:01:23.614885+05	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	10	18	20	\N	\N
326	Q202548270065	51	44	0		16	t	2025-11-28 01:38:43.533291+05	\N	2025-11-28 01:42:13.502338+05	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	8	8	20	\N	\N
335	Q202548280074	52	45	0		0	t	2025-11-28 21:16:42.711109+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280074.pdf	Requested	0	0	19	\N	\N
318	Q202548270057	51	44	0		28	t	2025-11-28 00:38:41.440356+05	\N	2025-11-28 00:39:05.566018+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270057.pdf	Requested	14	14	19	\N	\N
327	Q202548270066	51	44	0		42	t	2025-11-28 01:51:04.397492+05	\N	2025-11-28 01:52:16.860533+05	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	20	22	20	\N	\N
329	Q202548280068	49	42	0		0	t	2025-11-28 11:14:30.836145+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280068.pdf	Requested	0	0	19	\N	\N
330	Q202548280069	51	44	0		0	t	2025-11-28 11:14:40.969048+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280069.pdf	Requested	0	0	19	\N	\N
319	Q202548270058	51	44	0		26	t	2025-11-28 00:40:06.409732+05	\N	2025-11-28 01:18:37.477102+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548270058.pdf	Requested	10	16	19	\N	\N
322	Q202548270061	51	44	0		60	t	2025-11-28 01:19:37.851855+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	20	40	\N	\N	\N
323	Q202548270062	51	44	0		28	t	2025-11-28 01:21:35.271242+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	14	14	\N	\N	\N
324	Q202548270063	51	44	0		20	t	2025-11-28 01:22:57.404017+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	10	10	\N	\N	\N
325	Q202548270064	51	44	0		12	t	2025-11-28 01:23:21.357578+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	6	6	\N	\N	\N
320	Q202548270059	51	44	0		38	t	2025-11-28 01:08:44.361907+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	18	20	\N	\N	\N
332	Q202548280071	51	44	0		24	t	2025-11-28 18:53:53.481292+05	\N	2025-11-28 18:54:08.472173+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280071.pdf	Authorised	12	12	19	\N	\N
339	Q202548280078	52	45	0		12	t	2025-11-28 22:19:45.14466+05	\N	2025-11-28 22:19:54.261955+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280078.pdf	Requested	6	6	19	\N	\N
333	Q202548280072	44	44	0		6	t	2025-11-28 18:59:53.349675+05	\N	2025-11-28 19:00:31.00679+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280072.pdf	Requested	2	4	20	\N	\N
334	Q202548280073	44	44	0		0	t	2025-11-28 19:01:13.27174+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280073.pdf	Requested	0	0	20	\N	\N
340	Q202548280079	52	45	0		8	t	2025-11-28 22:35:00.897648+05	\N	2025-11-28 23:12:59.742922+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280079.pdf	Requested	4	4	19	\N	\N
342	Q202548280081	52	45	0		8	t	2025-11-28 22:37:42.585373+05	\N	2025-11-28 23:12:40.055101+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280081.pdf	Requested	4	4	19	\N	\N
336	Q202548280075	52	45	0		12	t	2025-11-28 22:18:20.531469+05	\N	2025-11-28 22:18:54.800173+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280075.pdf	Requested	6	6	19	\N	\N
331	Q202548280070	44	44	0		0	t	2025-11-28 18:53:17.086766+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280070.pdf	Requested	0	0	19	\N	\N
337	Q202548280076	52	45	0		0	t	2025-11-28 22:19:18.222058+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280076.pdf	Requested	0	0	19	\N	\N
341	Q202548280080	51	44	0		0	t	2025-11-28 22:36:01.699346+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280080.pdf	Requested	0	0	19	\N	\N
344	Q202548280083	52	45	0		6	t	2025-11-28 23:16:44.019044+05	\N	2025-11-28 23:17:16.071234+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280083.pdf	Requested	2	4	19	\N	\N
346	Q202548280085	45	45	0		0	t	2025-11-28 23:18:24.87175+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280085.pdf	Requested	0	0	19	\N	\N
345	Q202548280084	52	45	0		12	t	2025-11-28 23:17:29.140487+05	\N	2025-11-28 23:18:27.990503+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280084.pdf	Requested	6	6	19	\N	\N
347	Q202548280086	52	45	0		8	t	2025-11-28 23:48:49.45427+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N		Requested	4	4	\N	\N	\N
348	Q202548280087	52	45	0		12	t	2025-11-28 23:52:05.041185+05	\N	\N	316ccc2f-9ad9-4504-80d2-0a7e0051c86f	\N		Requested	6	6	20	\N	\N
373	Q202548290112	52	45	0		8	t	2025-11-29 19:30:21.509104+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290112.pdf	Requested	4	4	19	\N	\N
374	Q202548290113	52	45	0		8	t	2025-11-29 19:30:31.731388+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290113.pdf	Requested	4	4	19	\N	\N
354	Q202548280093	53	46	0		0	t	2025-11-29 01:30:03.345329+05	\N	2025-11-29 19:29:08.218622+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280093.pdf	Requested	0	0	19	\N	\N
355	Q202548290094	53	46	0		0	t	2025-11-29 19:29:09.368309+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290094.pdf	Requested	0	0	19	\N	\N
356	Q202548290095	53	46	0		0	t	2025-11-29 19:29:15.221428+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290095.pdf	Requested	0	0	19	\N	\N
349	Q202548280088	52	45	0		14	t	2025-11-29 00:14:40.757754+05	\N	2025-11-29 00:15:20.140617+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280088.pdf	Requested	6	8	19	\N	\N
357	Q202548290096	53	46	0		0	t	2025-11-29 19:29:16.097611+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290096.pdf	Requested	0	0	19	\N	\N
358	Q202548290097	53	46	0		0	t	2025-11-29 19:29:16.285236+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290097.pdf	Requested	0	0	19	\N	\N
359	Q202548290098	53	46	0		0	t	2025-11-29 19:29:16.482914+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290098.pdf	Requested	0	0	19	\N	\N
360	Q202548290099	53	46	0		0	t	2025-11-29 19:29:16.68541+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290099.pdf	Requested	0	0	19	\N	\N
361	Q202548290100	53	46	0		0	t	2025-11-29 19:29:19.144789+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290100.pdf	Requested	0	0	19	\N	\N
362	Q202548290101	53	46	0		0	t	2025-11-29 19:29:19.31205+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290101.pdf	Requested	0	0	19	\N	\N
363	Q202548290102	53	46	0		0	t	2025-11-29 19:29:19.488015+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290102.pdf	Requested	0	0	19	\N	\N
350	Q202548280089	52	45	0		8	t	2025-11-29 01:19:56.408191+05	\N	2025-11-29 01:20:26.707224+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280089.pdf	Requested	4	4	19	\N	\N
364	Q202548290103	53	46	0		0	t	2025-11-29 19:29:22.738624+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290103.pdf	Requested	0	0	19	\N	\N
365	Q202548290104	53	46	0		0	t	2025-11-29 19:29:22.934274+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290104.pdf	Requested	0	0	19	\N	\N
366	Q202548290105	53	46	0		0	t	2025-11-29 19:29:23.115138+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290105.pdf	Requested	0	0	19	\N	\N
367	Q202548290106	53	46	0		0	t	2025-11-29 19:29:29.753163+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290106.pdf	Requested	0	0	19	\N	\N
351	Q202548280090	52	45	0		8	t	2025-11-29 01:20:56.95413+05	\N	2025-11-29 19:29:39.754955+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280090.pdf	Requested	4	4	19	\N	\N
375	Q202548290114	52	45	0		8	t	2025-11-29 19:30:31.932412+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290114.pdf	Requested	4	4	19	\N	\N
368	Q202548290107	52	45	0		12	t	2025-11-29 19:29:41.811832+05	\N	2025-11-29 19:29:45.890243+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290107.pdf	Requested	6	6	19	\N	\N
352	Q202548280091	48	41	0		0	t	2025-11-29 01:29:15.248951+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280091.pdf	Requested	0	0	19	\N	\N
369	Q202548290108	52	45	0		12	t	2025-11-29 19:29:47.617913+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290108.pdf	Requested	6	6	19	\N	\N
353	Q202548280092	53	46	0		0	t	2025-11-29 01:29:33.457293+05	\N	2025-11-29 01:29:42.693121+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548280092.pdf	Requested	0	0	19	\N	\N
370	Q202548290109	52	45	0		8	t	2025-11-29 19:30:19.589758+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290109.pdf	Requested	4	4	19	\N	\N
376	Q202548290115	52	45	0		8	t	2025-11-29 19:30:32.038403+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290115.pdf	Requested	4	4	19	\N	\N
371	Q202548290110	52	45	0		8	t	2025-11-29 19:30:20.42626+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290110.pdf	Requested	4	4	19	\N	\N
372	Q202548290111	52	45	0		8	t	2025-11-29 19:30:21.275486+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290111.pdf	Requested	4	4	19	\N	\N
377	Q202548290116	52	45	0		12	t	2025-11-29 19:30:32.313153+05	\N	2025-11-29 19:30:41.028536+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290116.pdf	Requested	6	6	19	\N	\N
380	Q202548290119	51	44	0		4	t	2025-11-29 20:33:05.370824+05	\N	2025-11-29 20:33:34.314141+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290119.pdf	Requested	2	2	19	\N	\N
379	Q202548290118	51	44	0		8	t	2025-11-29 20:29:52.215867+05	\N	2025-11-29 20:32:45.777695+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290118.pdf	Requested	4	4	19	\N	\N
378	Q202548290117	52	45	0		10	t	2025-11-29 19:38:26.427397+05	\N	2025-11-29 19:39:03.366287+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290117.pdf	Requested	4	6	19	\N	\N
382	Q202548290121	51	44	0		12	t	2025-11-29 20:36:58.509081+05	\N	2025-11-29 20:49:26.759154+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290121.pdf	Requested	6	6	19	\N	\N
381	Q202548290120	51	44	0		4	t	2025-11-29 20:34:38.665976+05	\N	2025-11-29 20:36:49.168754+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290120.pdf	Requested	2	2	19	\N	\N
383	Q202548290122	51	44	0		6	t	2025-11-29 21:07:07.877642+05	\N	2025-11-29 21:09:53.141632+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290122.pdf	Requested	2	4	19	\N	\N
384	Q202548290123	51	44	0		42	t	2025-11-29 21:10:09.29962+05	\N	2025-11-29 21:10:45.623603+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290123.pdf	Requested	20	22	19	\N	\N
385	Q202548290124	51	44	0		26	t	2025-11-29 21:11:15.931604+05	\N	2025-11-29 21:15:49.620976+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290124.pdf	Requested	12	14	19	\N	\N
386	Q202548290125	51	44	0		44	t	2025-11-29 21:47:47.509454+05	\N	2025-11-29 21:48:23.808139+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290125.pdf	Requested	22	22	19	\N	\N
387	Q202548290126	51	44	0		0	t	2025-11-29 21:50:09.525508+05	\N	2025-11-29 22:17:12.644151+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290126.pdf	Requested	0	0	19	\N	\N
418	Q202549040022	61	53	0		0	t	2025-12-04 23:24:55.017367+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040022.pdf	Requested	0	0	19	\N	\N
394	Q202548290133	54	47	0		0	t	2025-11-30 01:57:11.566791+05	\N	2025-11-30 01:58:37.220197+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290133.pdf	Requested	0	0	19	\N	\N
388	Q202548290127	51	44	0		0	t	2025-11-29 21:52:17.537677+05	\N	2025-11-29 21:52:24.355309+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290127.pdf	Requested	0	0	19	\N	\N
419	Q202549040023	61	53	0		0	t	2025-12-04 23:25:58.915745+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040023.pdf	Requested	0	0	19	\N	\N
420	Q202549040024	61	53	0		0	t	2025-12-04 23:27:51.812472+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040024.pdf	Requested	0	0	19	\N	\N
421	Q202549040025	61	53	0		0	t	2025-12-04 23:35:04.952026+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040025.pdf	Requested	0	0	19	\N	\N
390	Q202548290129	51	44	0		6	t	2025-11-29 22:34:35.456189+05	\N	2025-11-29 23:45:07.516324+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290129.pdf	Requested	2	4	19	\N	\N
422	Q202549040026	47	39	0		0	t	2025-12-04 23:35:20.328894+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040026.pdf	Requested	0	0	19	\N	\N
397	Q202549010001	51	44	0		210	t	2025-12-01 19:35:33.090254+05	\N	2025-12-01 19:41:21.301159+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010001.pdf	Requested	104	106	19	\N	\N
392	Q202548290131	51	44	0		4	t	2025-11-30 00:07:22.092338+05	\N	2025-11-30 01:19:54.592669+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290131.pdf	Requested	2	2	19	\N	\N
398	Q202549010002	51	44	0		0	t	2025-12-01 19:41:38.998724+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010002.pdf	Requested	0	0	19	\N	\N
395	Q202548290134	51	44	0		110	t	2025-11-30 02:15:20.544125+05	\N	2025-11-30 02:17:04.765157+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290134.pdf	Requested	44	66	19	\N	\N
399	Q202549010003	51	44	0		0	t	2025-12-01 19:49:48.709294+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010003.pdf	Requested	0	0	19	\N	\N
400	Q202549010004	51	44	0		0	t	2025-12-01 20:08:27.727636+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010004.pdf	Requested	0	0	19	\N	\N
401	Q202549010005	54	47	0		0	t	2025-12-01 20:22:32.19129+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010005.pdf	Requested	0	0	19	\N	\N
393	Q202548290132	51	44	0		22	t	2025-11-30 01:20:17.149826+05	\N	2025-11-30 01:28:49.898231+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290132.pdf	Requested	8	14	19	\N	\N
389	Q202548290128	51	44	0		6	t	2025-11-29 21:52:33.067161+05	\N	2025-11-29 22:34:17.926036+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290128.pdf	Requested	2	4	19	\N	\N
402	Q202549010006	39	33	0		0	t	2025-12-01 20:23:45.016233+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010006.pdf	Requested	0	0	19	\N	\N
403	Q202549010007	54	47	0		0	t	2025-12-01 20:24:15.236482+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010007.pdf	Requested	0	0	19	\N	\N
404	Q202549010008	51	44	0		0	t	2025-12-01 22:43:50.11048+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010008.pdf	Requested	0	0	19	\N	\N
391	Q202548290130	51	44	0		10	t	2025-11-29 23:47:12.692703+05	\N	2025-11-30 00:07:02.140759+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290130.pdf	Requested	4	6	19	\N	\N
405	Q202549010009	57	49	0		0	t	2025-12-01 22:44:23.714906+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549010009.pdf	Requested	0	0	19	\N	\N
406	Q202549040010	59	51	0		0	t	2025-12-04 19:30:53.960636+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040010.pdf	Requested	0	0	19	\N	\N
407	Q202549040011	59	51	0		0	t	2025-12-04 19:34:42.099996+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040011.pdf	Requested	0	0	19	\N	\N
408	Q202549040012	48	41	0		6	t	2025-12-04 21:07:32.938519+05	\N	2025-12-04 21:07:39.466808+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040012.pdf	Requested	2	4	20	\N	\N
409	Q202549040013	43	37	0		0	t	2025-12-04 21:07:53.760024+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040013.pdf	Requested	0	0	19	\N	\N
410	Q202549040014	42	36	0		0	t	2025-12-04 21:08:53.168877+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040014.pdf	Requested	0	0	20	\N	\N
396	Q202548290135	54	47	0		0	t	2025-11-30 02:17:21.518997+05	\N	2025-11-30 02:18:30.160151+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202548290135.pdf	Requested	0	0	19	\N	\N
411	Q202549040015	44	38	0		0	t	2025-12-04 21:09:02.31217+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040015.pdf	Requested	0	0	19	\N	\N
412	Q202549040016	60	52	0		0	t	2025-12-04 21:09:17.147139+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040016.pdf	Requested	0	0	19	\N	\N
413	Q202549040017	60	52	0		0	t	2025-12-04 21:52:24.628017+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040017.pdf	Requested	0	0	19	\N	\N
414	Q202549040018	61	53	0		0	t	2025-12-04 22:10:04.017582+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040018.pdf	Requested	0	0	19	\N	\N
423	Q202549040027	61	53	0		0	t	2025-12-04 23:36:06.010108+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040027.pdf	Requested	0	0	19	\N	\N
415	Q202549040019	61	53	0		0	t	2025-12-04 22:56:35.487899+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040019.pdf	Requested	0	0	19	\N	\N
416	Q202549040020	43	37	0		0	t	2025-12-04 23:10:17.872984+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040020.pdf	Requested	0	0	19	\N	\N
417	Q202549040021	61	53	0		0	t	2025-12-04 23:10:27.98077+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040021.pdf	Requested	0	0	19	\N	\N
424	Q202549040028	50	43	0		0	t	2025-12-04 23:36:25.227696+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040028.pdf	Requested	0	0	19	\N	\N
425	Q202549040029	61	53	0		0	t	2025-12-04 23:49:39.878669+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040029.pdf	Requested	0	0	19	\N	\N
426	Q202549040030	51	44	0		0	t	2025-12-04 23:52:06.143305+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040030.pdf	Requested	0	0	19	\N	\N
427	Q202549040031	61	53	0		0	t	2025-12-04 23:56:51.433682+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040031.pdf	Requested	0	0	19	\N	\N
428	Q202549040032	61	53	0		0	t	2025-12-05 00:08:14.320665+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040032.pdf	Requested	0	0	19	\N	\N
429	Q202549040033	51	44	0		0	t	2025-12-05 00:08:29.022615+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040033.pdf	Requested	0	0	19	\N	\N
430	Q202549040034	61	53	0		0	t	2025-12-05 00:08:48.67788+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040034.pdf	Requested	0	0	19	\N	\N
431	Q202549040035	61	53	0		0	t	2025-12-05 00:17:50.927644+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040035.pdf	Requested	0	0	19	\N	\N
432	Q202549040036	49	42	0		0	t	2025-12-05 00:18:21.483959+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040036.pdf	Requested	0	0	20	\N	\N
433	Q202549040037	58	50	0		0	t	2025-12-05 00:18:29.780236+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040037.pdf	Requested	0	0	20	\N	\N
434	Q202549040038	50	43	0		0	t	2025-12-05 00:18:41.732477+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040038.pdf	Requested	0	0	19	\N	\N
435	Q202549040039	61	53	0		0	t	2025-12-05 00:23:19.97074+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040039.pdf	Requested	0	0	19	\N	\N
436	Q202549040040	61	53	0		0	t	2025-12-05 01:23:21.007596+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040040.pdf	Requested	0	0	19	\N	\N
437	Q202549040041	41	35	0		0	t	2025-12-05 01:28:19.586524+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040041.pdf	Requested	0	0	19	\N	\N
438	Q202549040042	61	53	0		4	t	2025-12-05 01:33:22.690222+05	\N	2025-12-05 01:35:58.306201+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040042.pdf	Requested	2	2	19	\N	\N
439	Q202549040043	61	53	0		0	t	2025-12-05 01:47:20.145876+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040043.pdf	Requested	0	0	19	\N	\N
440	Q202549040044	61	53	0		0	t	2025-12-05 01:47:34.18371+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040044.pdf	Requested	0	0	19	\N	\N
441	Q202549040045	61	53	0		0	t	2025-12-05 01:49:38.303485+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040045.pdf	Requested	0	0	19	\N	\N
442	Q202549040046	61	53	0		4	t	2025-12-05 01:54:33.45579+05	\N	2025-12-05 01:54:41.942006+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040046.pdf	Requested	2	2	19	\N	\N
444	Q202549040048	61	53	0		0	t	2025-12-05 01:58:09.721115+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040048.pdf	Requested	0	0	19	\N	\N
445	Q202549050049	61	53	0		4	t	2025-12-05 11:06:05.732141+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050049.pdf	Requested	2	2	\N	\N	\N
446	Q202549050050	61	53	0		4	t	2025-12-05 11:09:27.602037+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050050.pdf	Requested	2	2	\N	\N	\N
447	Q202549050051	61	53	0		4	t	2025-12-05 11:21:23.810197+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050051.pdf	Requested	2	2	\N	\N	\N
448	Q202549050052	61	53	0		4	t	2025-12-05 11:28:52.929171+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050052.pdf	Requested	2	2	\N	\N	\N
449	Q202549050053	61	53	0		6	t	2025-12-05 11:30:03.701122+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050053.pdf	Requested	2	4	\N	\N	\N
450	Q202549050054	61	53	0		4	t	2025-12-05 15:23:58.012233+05	\N	2025-12-05 15:24:01.602518+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050054.pdf	Requested	2	2	19	\N	\N
443	Q202549040047	51	44	0		6	t	2025-12-05 01:57:47.330076+05	\N	2025-12-05 15:30:38.312935+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549040047.pdf	Requested	2	4	19	\N	\N
453	Q202549050057	61	53	0		4	t	2025-12-05 15:41:08.975377+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050057.pdf	Requested	2	2	\N	\N	\N
451	Q202549050055	51	44	0		10	t	2025-12-05 15:38:31.806309+05	\N	2025-12-05 15:38:39.536681+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050055.pdf	Requested	4	6	19	\N	\N
452	Q202549050056	61	53	0		10	t	2025-12-05 15:38:53.090209+05	\N	2025-12-05 15:39:41.065803+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202549050056.pdf	Requested	4	6	19	\N	\N
457	Q202550080004	61	53	0		0	t	2025-12-08 19:10:30.961922+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080004.pdf	Requested	0	0	19	\N	\N
458	Q202550080005	61	53	0		0	t	2025-12-08 19:11:11.390369+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080005.pdf	Requested	0	0	19	\N	\N
454	Q202550080001	59	51	0		12	t	2025-12-08 17:31:01.974278+05	\N	2025-12-08 17:31:29.76389+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080001.pdf	Requested	6	6	20	\N	\N
459	Q202550080006	61	53	0		4	t	2025-12-08 19:17:00.809815+05	\N	2025-12-08 19:17:04.432159+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080006.pdf	Requested	2	2	19	\N	\N
461	Q202550080008	61	53	0		0	t	2025-12-08 20:06:34.776614+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080008.pdf	Requested	0	0	19	\N	\N
455	Q202550080002	59	51	0		12	t	2025-12-08 17:31:57.532994+05	\N	2025-12-08 17:32:04.70209+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080002.pdf	Requested	6	6	19	\N	\N
456	Q202550080003	61	53	0		0	t	2025-12-08 19:09:23.948548+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080003.pdf	Requested	0	0	19	\N	\N
462	Q202550080009	63	54	0		0	t	2025-12-08 21:44:50.248979+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080009.pdf	Requested	0	0	19	\N	\N
460	Q202550080007	61	53	0		10	t	2025-12-08 20:00:33.006769+05	\N	2025-12-08 20:03:55.13635+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080007.pdf	Requested	4	6	19	\N	\N
463	Q202550080010	63	54	0		0	t	2025-12-08 21:47:51.832177+05	\N	2025-12-08 21:47:55.761336+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080010.pdf	Requested	0	0	19	\N	\N
464	Q202550080011	63	54	0		0	t	2025-12-09 01:00:03.001301+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550080011.pdf	Requested	0	0	19	\N	\N
465	Q202550090012	51	44	0		6	t	2025-12-10 00:16:38.512506+05	\N	2025-12-10 00:16:44.771678+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550090012.pdf	Requested	2	4	19	\N	\N
466	Q202550090013	51	44	0		12	t	2025-12-10 00:47:10.740458+05	\N	2025-12-10 00:47:27.213369+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550090013.pdf	Requested	6	6	19	\N	\N
467	Q202550100014	75	56	0		0	t	2025-12-10 18:23:08.063926+05	\N	2025-12-10 18:23:50.94725+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100014.pdf	Requested	0	0	19	\N	\N
482	Q202550100029	52	45	0		10	t	2025-12-11 00:21:07.152344+05	\N	2025-12-11 00:21:15.605686+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100029.pdf	Requested	4	6	19	\N	\N
485	Q202550100032	52	45	0		4	t	2025-12-11 00:44:25.508783+05	\N	2025-12-11 00:47:36.657151+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100032.pdf	Requested	2	2	19	\N	\N
489	Q202550110036	80	44	0		36	t	2025-12-11 19:40:14.019289+05	\N	2025-12-11 19:42:13.018679+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110036.pdf	Requested	16	20	19	\N	\N
475	Q202550100022	52	45	0		10	t	2025-12-10 23:48:18.660725+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100022.pdf	Requested	4	6	19	\N	\N
497	Q202550110044	75	56	0		4	t	2025-12-11 19:46:38.658766+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110044.pdf	Requested	2	2	19	\N	\N
492	Q202550110039	39	33	0		0	t	2025-12-11 19:44:29.13059+05	\N	2025-12-11 19:44:35.832151+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110039.pdf	Requested	0	0	19	\N	\N
474	Q202550100021	52	45	0		20	t	2025-12-10 23:47:20.691253+05	\N	2025-12-10 23:48:31.940463+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100021.pdf	Requested	8	12	19	\N	\N
476	Q202550100023	52	45	0		10	t	2025-12-10 23:48:34.111097+05	\N	2025-12-10 23:48:50.807099+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100023.pdf	Requested	4	6	19	\N	\N
468	Q202550100015	75	56	0		4	t	2025-12-10 18:25:25.307157+05	\N	2025-12-10 18:27:40.311368+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100015.pdf	Requested	2	2	19	\N	\N
469	Q202550100016	75	56	0		0	t	2025-12-10 18:27:55.263727+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100016.pdf	Requested	0	0	19	\N	\N
470	Q202550100017	75	56	0		4	t	2025-12-10 18:45:42.713538+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100017.pdf	Requested	2	2	19	\N	\N
488	Q202550110035	82	58	0		4	t	2025-12-11 18:26:04.465468+05	\N	2025-12-11 18:27:34.560521+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110035.pdf	Requested	2	2	19	\N	\N
471	Q202550100018	75	56	0		4	t	2025-12-10 18:45:57.437483+05	\N	2025-12-10 18:46:00.252833+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100018.pdf	Requested	2	2	19	\N	\N
477	Q202550100024	52	45	0		16	t	2025-12-10 23:48:52.594643+05	\N	2025-12-11 00:04:04.665327+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100024.pdf	Requested	6	10	19	\N	\N
478	Q202550100025	52	45	0		12	t	2025-12-11 00:04:05.47421+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100025.pdf	Requested	4	8	19	\N	\N
479	Q202550100026	52	45	0		12	t	2025-12-11 00:04:07.003315+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100026.pdf	Requested	4	8	19	\N	\N
486	Q202550100033	52	45	0		10	t	2025-12-11 01:13:46.698317+05	\N	2025-12-11 01:14:26.343942+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100033.pdf	Requested	4	6	19	\N	\N
480	Q202550100027	52	45	0		18	t	2025-12-11 00:04:08.494184+05	\N	2025-12-11 00:06:08.490631+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100027.pdf	Requested	6	12	19	\N	\N
472	Q202550100019	75	56	0		0	t	2025-12-10 18:46:01.255177+05	\N	2025-12-10 18:46:31.857734+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100019.pdf	Requested	0	0	19	\N	\N
473	Q202550100020	75	56	0		0	t	2025-12-10 23:46:50.519642+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100020.pdf	Requested	0	0	19	\N	\N
483	Q202550100030	52	45	0		8	t	2025-12-11 00:21:23.987006+05	\N	2025-12-11 00:39:08.827879+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100030.pdf	Requested	4	4	19	\N	\N
490	Q202550110037	80	44	0		28	t	2025-12-11 19:42:12.838939+05	\N	2025-12-11 19:43:06.31661+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110037.pdf	Requested	14	14	19	\N	\N
484	Q202550100031	52	45	0		16	t	2025-12-11 00:39:26.002343+05	\N	2025-12-11 00:40:03.61871+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100031.pdf	Requested	6	10	19	\N	\N
481	Q202550100028	52	45	0		22	t	2025-12-11 00:16:15.30869+05	\N	2025-12-11 00:21:02.810271+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550100028.pdf	Requested	8	14	19	\N	\N
487	Q202550110034	82	58	0		4	t	2025-12-11 18:21:03.108054+05	\N	2025-12-11 18:21:10.840823+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110034.pdf	Requested	2	2	19	\N	\N
493	Q202550110040	57	49	0		0	t	2025-12-11 19:44:51.651331+05	\N	2025-12-11 19:44:59.801168+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110040.pdf	Requested	0	0	19	\N	\N
494	Q202550110041	58	50	0		0	t	2025-12-11 19:45:15.120471+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110041.pdf	Requested	0	0	19	\N	\N
501	Q202550110048	83	59	0		62	t	2025-12-11 19:55:20.322164+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110048.pdf	Requested	30	32	19	\N	\N
495	Q202550110042	75	56	0		4	t	2025-12-11 19:45:57.35463+05	\N	2025-12-11 19:46:35.452268+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110042.pdf	Requested	2	2	19	\N	\N
491	Q202550110038	80	44	0		24	t	2025-12-11 19:43:07.89408+05	\N	2025-12-11 19:43:44.321102+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110038.pdf	Requested	12	12	19	\N	\N
498	Q202550110045	83	59	0		96	t	2025-12-11 19:50:34.203677+05	\N	2025-12-11 19:51:09.063134+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110045.pdf	Requested	40	56	19	\N	\N
496	Q202550110043	75	56	0		4	t	2025-12-11 19:46:38.424982+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110043.pdf	Requested	2	2	19	\N	\N
499	Q202550110046	83	59	0		30	t	2025-12-11 19:51:28.60912+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110046.pdf	Requested	14	16	19	\N	\N
500	Q202550110047	83	59	0		266	t	2025-12-11 19:53:34.677453+05	\N	2025-12-11 19:55:08.03705+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110047.pdf	Requested	106	160	19	\N	\N
502	Q202550110049	80	44	0		6	t	2025-12-11 19:58:32.436158+05	\N	2025-12-11 19:58:45.965376+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110049.pdf	Requested	2	4	19	\N	\N
503	Q202550110050	85	61	0		0	t	2025-12-11 22:16:48.611498+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110050.pdf	Requested	0	0	19	\N	\N
504	Q202550110051	83	59	0		28	t	2025-12-11 22:17:06.783724+05	\N	2025-12-11 22:19:55.141133+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110051.pdf	Requested	12	16	19	\N	\N
505	Q202550110052	83	59	0		28	t	2025-12-11 22:20:14.637125+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110052.pdf	Requested	12	16	19	\N	\N
526	Q202550110073	83	59	0		34	t	2025-12-11 23:24:00.618409+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110073.pdf	Requested	16	18	19	\N	\N
513	Q202550110060	83	59	0		12	t	2025-12-11 22:38:16.063454+05	\N	2025-12-11 22:38:23.868242+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110060.pdf	Requested	6	6	19	\N	\N
507	Q202550110054	83	59	0		18	t	2025-12-11 22:32:12.613998+05	\N	2025-12-11 22:35:43.833766+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110054.pdf	Requested	6	12	19	\N	\N
514	Q202550110061	83	59	0		12	t	2025-12-11 22:38:33.300489+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110061.pdf	Requested	6	6	19	\N	\N
506	Q202550110053	83	59	0		136	t	2025-12-11 22:31:49.424128+05	\N	2025-12-11 22:32:04.395418+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110053.pdf	Requested	52	84	19	\N	\N
508	Q202550110055	83	59	0		46	t	2025-12-11 22:35:46.553312+05	\N	2025-12-11 22:35:58.112123+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110055.pdf	Requested	20	26	19	\N	\N
509	Q202550110056	83	59	0		46	t	2025-12-11 22:36:00.112643+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110056.pdf	Requested	20	26	19	\N	\N
519	Q202550110066	83	59	0		86	t	2025-12-11 23:19:26.72165+05	\N	2025-12-11 23:20:41.022823+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110066.pdf	Requested	34	52	19	\N	\N
515	Q202550110062	83	59	0		18	t	2025-12-11 22:39:00.348621+05	\N	2025-12-11 22:42:00.814657+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110062.pdf	Requested	8	10	19	\N	\N
516	Q202550110063	85	61	0		0	t	2025-12-11 22:57:08.255458+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110063.pdf	Requested	0	0	19	\N	\N
527	Q202550110074	83	59	0		32	t	2025-12-12 01:23:24.159395+05	\N	2025-12-12 01:24:38.320971+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110074.pdf	Requested	12	20	19	\N	\N
522	Q202550110069	83	59	0		84	t	2025-12-11 23:20:58.891784+05	\N	2025-12-11 23:22:25.353851+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110069.pdf	Requested	34	50	19	\N	\N
517	Q202550110064	86	62	0		0	t	2025-12-11 22:57:19.964588+05	\N	2025-12-11 23:07:45.363513+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110064.pdf	Requested	0	0	19	\N	\N
524	Q202550110071	83	59	0		42	t	2025-12-11 23:22:26.291815+05	\N	2025-12-11 23:23:33.332704+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110071.pdf	Requested	20	22	19	\N	\N
528	Q202550110075	81	57	0		0	t	2025-12-12 01:31:20.717548+05	\N	2025-12-12 01:31:30.916094+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110075.pdf	Requested	0	0	19	\N	\N
510	Q202550110057	83	59	0		52	t	2025-12-11 22:36:46.855997+05	\N	2025-12-11 22:37:30.287491+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110057.pdf	Requested	24	28	19	\N	\N
511	Q202550110058	83	59	0		52	t	2025-12-11 22:37:41.529447+05	\N	2025-12-11 22:37:51.119306+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110058.pdf	Requested	24	28	19	\N	\N
529	Q202550110076	81	57	0		0	t	2025-12-12 01:46:23.692702+05	\N	2025-12-12 01:46:57.573975+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110076.pdf	Requested	0	0	19	\N	\N
512	Q202550110059	83	59	0		20	t	2025-12-11 22:37:52.760349+05	\N	2025-12-11 22:38:03.730126+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110059.pdf	Requested	8	12	19	\N	\N
518	Q202550110065	83	59	0		86	t	2025-12-11 23:18:55.79515+05	\N	2025-12-11 23:19:12.178124+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110065.pdf	Requested	34	52	19	\N	\N
520	Q202550110067	83	59	0		38	t	2025-12-11 23:19:56.733188+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110067.pdf	Requested	18	20	19	\N	\N
521	Q202550110068	83	59	0		38	t	2025-12-11 23:19:58.433496+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110068.pdf	Requested	18	20	19	\N	\N
536	Q202550120083	59	51	0		6	t	2025-12-12 21:43:49.122168+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120083.pdf	Requested	2	4	19	\N	\N
523	Q202550110070	83	59	0		42	t	2025-12-11 23:21:51.278626+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110070.pdf	Requested	20	22	19	\N	\N
531	Q202550120078	59	51	0		8	t	2025-12-12 21:28:13.503786+05	\N	2025-12-12 23:11:37.733647+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120078.pdf	Requested	4	4	19	\N	\N
525	Q202550110072	83	59	0		76	t	2025-12-11 23:23:34.611432+05	\N	2025-12-11 23:23:59.223671+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550110072.pdf	Requested	30	46	19	\N	\N
533	Q202550120080	59	51	0		10	t	2025-12-12 21:36:59.999264+05	\N	2025-12-12 21:38:40.608044+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120080.pdf	Requested	4	6	19	\N	\N
530	Q202550120077	85	61	0		10	t	2025-12-12 20:13:50.692541+05	\N	2025-12-12 21:29:13.731796+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120077.pdf	Requested	4	6	19	\N	\N
537	Q202550120084	59	51	0		14	t	2025-12-12 23:13:05.882705+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120084.pdf	Requested	6	8	19	\N	\N
532	Q202550120079	52	45	0		16	t	2025-12-12 21:29:40.422831+05	\N	2025-12-12 21:36:38.579346+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120079.pdf	Requested	6	10	19	\N	\N
538	Q202550120085	59	51	0		14	t	2025-12-12 23:13:08.715521+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120085.pdf	Requested	6	8	19	\N	\N
535	Q202550120082	59	51	0		12	t	2025-12-12 21:41:18.246277+05	\N	2025-12-12 21:42:53.234839+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120082.pdf	Requested	4	8	19	\N	\N
534	Q202550120081	59	51	0		14	t	2025-12-12 21:39:13.402897+05	\N	2025-12-12 23:12:13.948588+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120081.pdf	Requested	6	8	19	\N	\N
539	Q202550120086	59	51	0		10	t	2025-12-12 23:13:08.911114+05	\N	2025-12-12 23:29:09.484276+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120086.pdf	Requested	4	6	19	\N	\N
540	Q202550120087	88	64	0		4	t	2025-12-12 23:33:48.618772+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120087.pdf	Requested	2	2	\N	\N	\N
541	Q202550120088	88	64	0		8	t	2025-12-12 23:57:49.976625+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120088.pdf	Requested	4	4	\N	\N	\N
542	Q202550120089	88	64	0		8	t	2025-12-13 00:15:07.582307+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120089.pdf	Requested	4	4	\N	\N	\N
543	Q202550120090	52	45	0		20	t	2025-12-13 00:19:35.977323+05	\N	2025-12-13 00:20:51.09937+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120090.pdf	Requested	8	12	19	\N	\N
548	Q202550130095	59	51	0		6	t	2025-12-13 19:51:55.396673+05	\N	2025-12-13 19:53:03.243447+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550130095.pdf	Requested	2	4	19	\N	\N
549	Q202550130096	88	64	0		4	t	2025-12-13 20:48:43.881073+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550130096.pdf	Requested	2	2	\N	\N	\N
550	Q202550130097	88	64	0		4	t	2025-12-13 20:52:25.481612+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550130097.pdf	Requested	2	2	\N	\N	\N
567	Q202552230013	105	78	0		0	t	2025-12-24 00:32:52.576242+05	\N	2025-12-24 00:33:00.359137+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230013.pdf	Requested	0	0	19	1	\N
551	Q202550130098	59	51	0		52	t	2025-12-13 20:54:04.448209+05	\N	2025-12-13 20:54:24.794887+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550130098.pdf	Requested	26	26	19	\N	\N
559	Q202552230005	141	113	0		6	t	2025-12-23 18:31:53.829649+05	\N	2025-12-23 18:32:12.527775+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230005.pdf	Authorised	2	4	19	1	\N
560	Q202552230006	141	113	0		4	t	2025-12-23 21:18:49.68098+05	\N	2025-12-23 21:28:37.274889+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230006.pdf	Requested	2	2	19	1	\N
561	Q202552230007	141	113	0		0	t	2025-12-23 21:35:27.485715+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230007.pdf	Requested	0	0	19	1	\N
544	Q202550120091	80	44	0		18	t	2025-12-13 00:21:08.290014+05	\N	2025-12-13 00:22:24.626691+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120091.pdf	Requested	6	12	19	\N	\N
562	Q202552230008	141	113	0		4	t	2025-12-23 21:38:45.662484+05	\N	2025-12-23 21:38:48.854803+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230008.pdf	Requested	2	2	19	1	\N
545	Q202550120092	81	57	0		0	t	2025-12-13 01:18:20.029145+05	\N	2025-12-13 01:18:38.127+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120092.pdf	Requested	0	0	19	\N	\N
563	Q202552230009	142	114	0		0	t	2025-12-23 21:46:30.119887+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230009.pdf	Requested	0	0	19	1	\N
552	Q202551150001	95	70	0		0	t	2025-12-15 23:38:35.509297+05	\N	2025-12-15 23:41:02.245542+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202551150001.pdf	Requested	0	0	19	\N	\N
554	Q202551170003	82	58	0		10	t	2025-12-17 20:10:20.851017+05	\N	2025-12-17 20:11:27.154757+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202551170003.pdf	Requested	4	6	19	\N	\N
564	Q202552230010	58	50	0		0	t	2025-12-24 00:29:46.701101+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230010.pdf	Requested	0	0	19	1	\N
546	Q202550120093	83	59	0		24	t	2025-12-13 01:18:56.154518+05	\N	2025-12-13 01:19:18.698033+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120093.pdf	Requested	10	14	19	\N	\N
547	Q202550120094	88	64	0		8	t	2025-12-13 01:20:00.059811+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202550120094.pdf	Requested	4	4	\N	\N	\N
574	Q202501310001	113	86	0		0	t	2025-12-31 20:54:43.890218+05	\N	2025-12-31 20:54:47.46812+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202501310001.pdf	Requested	0	0	21	1	\N
568	Q202552260014	155	121	0		0	t	2025-12-26 23:00:05.946032+05	\N	2025-12-26 23:00:15.033316+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552260014.pdf	Requested	0	0	19	1	\N
555	Q202552220001	82	58	0		12	t	2025-12-22 23:35:48.299907+05	\N	2025-12-22 23:36:26.856437+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552220001.pdf	Requested	4	8	19	\N	\N
556	Q202552220002	82	58	0		4	t	2025-12-22 23:44:05.928826+05	\N	2025-12-22 23:44:15.670202+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552220002.pdf	Requested	2	2	19	1	\N
553	Q202551160002	82	58	0		12	t	2025-12-16 22:55:17.009116+05	\N	2025-12-16 22:55:59.636343+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202551160002.pdf	Requested	4	8	19	\N	\N
565	Q202552230011	94	69	0		6	t	2025-12-24 00:30:06.275322+05	\N	2025-12-24 00:30:18.311315+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230011.pdf	Requested	2	4	19	1	\N
557	Q202552220003	82	58	0		4	t	2025-12-23 01:36:43.684532+05	\N	2025-12-23 01:36:47.285288+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552220003.pdf	Requested	2	2	19	1	\N
558	Q202552230004	141	113	0		4	t	2025-12-23 18:30:22.225324+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230004.pdf	Requested	2	2	\N	1	\N
569	Q202552260015	155	121	0		4	t	2025-12-26 23:01:46.926951+05	\N	2025-12-26 23:01:54.778984+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552260015.pdf	Requested	2	2	19	1	\N
566	Q202552230012	85	61	0		12	t	2025-12-24 00:31:10.276904+05	\N	2025-12-24 00:31:45.94346+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202552230012.pdf	Requested	4	8	19	1	\N
570	Q202501290001	183	141	0		0	t	2025-12-29 14:35:23.154128+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202501290001.pdf	Requested	0	0	21	1	\N
571	Q202501290001	204	151	0		0	t	2025-12-29 16:21:09.66025+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202501290001.pdf	Requested	0	0	21	1	\N
572	Q202501310001	117	90	0		0	t	2025-12-31 19:59:13.762332+05	\N	2025-12-31 19:59:18.50725+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202501310001.pdf	Requested	0	0	21	1	\N
573	Q202501310001	258	170	0		0	t	2025-12-31 20:00:57.177641+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202501310001.pdf	Requested	0	0	21	1	\N
575	Q202601010006	172	135	0		0	t	2026-01-01 21:16:16.581182+05	\N	2026-01-01 21:16:58.8841+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601010006.pdf	Requested	0	0	21	1	\N
576	Q202601010007	309	201	0		4	t	2026-01-01 21:17:21.06839+05	\N	2026-01-01 21:17:46.398797+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601010007.pdf	Requested	2	2	21	1	\N
578	Q202601010009	311	201	0		0	t	2026-01-01 21:20:33.046968+05	\N	2026-01-01 21:20:53.685041+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601010009.pdf	Requested	0	0	21	1	\N
577	Q202601010008	310	201	0		8	t	2026-01-01 21:19:22.490973+05	\N	2026-01-01 21:19:37.042961+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601010008.pdf	Requested	4	4	21	1	\N
579	Q202601010010	312	201	0		4	t	2026-01-01 21:22:00.978252+05	\N	2026-01-01 21:22:29.153822+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601010010.pdf	Requested	2	2	21	1	\N
580	Q202601020011	344	208	0		22	t	2026-01-03 01:06:25.180802+05	\N	2026-01-03 01:07:26.718414+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601020011.pdf	Requested	11	11	21	1	\N
581	Q202601030012	352	212	0		12	t	2026-01-03 20:00:14.505041+05	\N	2026-01-03 20:07:39.347109+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030012.pdf	Requested	6	6	21	1	\N
593	Q202601030024	355	213	0		4	t	2026-01-04 02:08:47.065134+05	\N	2026-01-04 02:09:03.277175+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030024.pdf	Requested	2	2	21	1	\N
582	Q202601030013	353	212	0		20	t	2026-01-03 20:13:37.905876+05	\N	2026-01-03 20:13:52.778603+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030013.pdf	Requested	10	10	21	1	\N
600	Q202602050002	356	213	0		66	t	2026-01-05 19:15:37.614504+05	\N	2026-01-05 19:16:14.846975+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050002.pdf	Requested	33	33	21	1	\N
583	Q202601030014	353	212	0		20	t	2026-01-03 20:40:41.547787+05	\N	2026-01-03 20:41:17.05141+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030014.pdf	Requested	10	10	21	1	\N
594	Q202601030025	355	213	0		22	t	2026-01-04 02:09:23.7098+05	\N	2026-01-04 02:09:29.952203+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030025.pdf	Requested	11	11	21	1	\N
590	Q202601030021	355	213	0		44	t	2026-01-04 01:47:22.254206+05	\N	2026-01-04 01:47:46.867796+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030021.pdf	Requested	22	22	21	1	\N
585	Q202601030016	354	213	0		6	t	2026-01-04 01:26:32.526622+05	\N	2026-01-04 01:28:07.01395+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030016.pdf	Requested	3	3	21	1	\N
599	Q202602050001	356	213	0		22	t	2026-01-05 19:11:58.304844+05	\N	2026-01-05 19:12:13.633092+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050001.pdf	Requested	11	11	21	1	\N
586	Q202601030017	355	213	0		22	t	2026-01-04 01:30:11.660316+05	\N	2026-01-04 01:30:22.233478+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030017.pdf	Requested	11	11	21	1	\N
606	Q202602050008	357	213	0		14	t	2026-01-05 23:09:46.361819+05	\N	2026-01-05 23:13:10.067264+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050008.pdf	Requested	7	7	21	1	\N
591	Q202601030022	355	213	0		22	t	2026-01-04 01:48:06.024071+05	\N	2026-01-04 01:48:13.931463+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030022.pdf	Requested	11	11	21	1	\N
608	Q202602050010	357	213	0		60	t	2026-01-05 23:24:25.254718+05	\N	2026-01-05 23:33:03.626424+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050010.pdf	Requested	30	30	21	1	\N
587	Q202601030018	355	213	0		22	t	2026-01-04 01:32:29.317242+05	\N	2026-01-04 01:32:42.00728+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030018.pdf	Requested	11	11	21	1	\N
595	Q202601030026	355	213	0		10	t	2026-01-04 02:09:57.579741+05	\N	2026-01-04 02:15:00.354996+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030026.pdf	Requested	5	5	21	1	\N
584	Q202601030015	354	213	0		24	t	2026-01-03 20:47:13.263973+05	\N	2026-01-03 20:56:13.239573+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030015.pdf	Requested	12	12	21	1	\N
588	Q202601030019	355	213	0		16	t	2026-01-04 01:33:08.762403+05	\N	2026-01-04 01:33:25.687339+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030019.pdf	Requested	8	8	21	1	\N
592	Q202601030023	355	213	0		28	t	2026-01-04 01:48:44.017013+05	\N	2026-01-04 01:49:07.338865+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030023.pdf	Requested	14	14	21	1	\N
589	Q202601030020	355	213	0		10	t	2026-01-04 01:43:21.81707+05	\N	2026-01-04 01:43:31.333472+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030020.pdf	Requested	5	5	21	1	\N
601	Q202602050003	357	213	0		18	t	2026-01-05 19:30:57.408772+05	\N	2026-01-05 19:31:18.643815+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050003.pdf	Requested	9	9	21	1	\N
614	Q202602050016	357	213	0		56	t	2026-01-06 00:36:33.680296+05	\N	2026-01-06 00:36:53.287405+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050016.pdf	Requested	28	28	21	1	\N
612	Q202602050014	357	213	0		24	t	2026-01-06 00:03:48.591434+05	\N	2026-01-06 00:24:07.310369+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050014.pdf	Requested	12	12	21	1	\N
605	Q202602050007	357	213	0		16	t	2026-01-05 21:17:51.868486+05	\N	2026-01-05 21:18:44.4946+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050007.pdf	Requested	8	8	21	1	\N
596	Q202601030027	355	213	0		16	t	2026-01-04 02:22:25.337154+05	\N	2026-01-04 02:22:53.621951+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030027.pdf	Requested	8	8	21	1	\N
597	Q202601030028	356	213	0		50	t	2026-01-04 02:27:06.603616+05	\N	2026-01-04 02:27:57.04608+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030028.pdf	Requested	25	25	21	1	\N
602	Q202602050004	357	213	0		20	t	2026-01-05 20:31:45.430094+05	\N	2026-01-05 20:32:02.658406+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050004.pdf	Requested	10	10	21	1	\N
598	Q202601030029	356	213	0		54	t	2026-01-04 02:30:15.153136+05	\N	2026-01-05 19:11:35.202748+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202601030029.pdf	Requested	27	27	21	1	\N
604	Q202602050006	357	213	0		4	t	2026-01-05 21:15:26.926271+05	\N	2026-01-05 21:17:29.619557+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050006.pdf	Requested	2	2	21	1	\N
603	Q202602050005	357	213	0		12	t	2026-01-05 21:02:47.588423+05	\N	2026-01-05 21:06:24.839629+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050005.pdf	Requested	6	6	21	1	\N
609	Q202602050011	357	213	0		26	t	2026-01-05 23:40:32.289809+05	\N	2026-01-05 23:47:58.71687+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050011.pdf	Requested	13	13	21	1	\N
607	Q202602050009	357	213	0		76	t	2026-01-05 23:15:07.204958+05	\N	2026-01-05 23:23:59.674655+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050009.pdf	Requested	38	38	21	1	\N
611	Q202602050013	357	213	0		0	t	2026-01-05 23:58:13.625349+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050013.pdf	Requested	0	0	21	1	\N
610	Q202602050012	357	213	0		26	t	2026-01-05 23:57:41.042199+05	\N	2026-01-05 23:58:25.111595+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050012.pdf	Requested	13	13	21	1	\N
613	Q202602050015	357	213	0		36	t	2026-01-06 00:27:13.509851+05	\N	2026-01-06 00:27:56.36382+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050015.pdf	Requested	18	18	21	1	\N
615	Q202602050017	357	213	0		32	t	2026-01-06 00:42:34.042412+05	\N	2026-01-06 00:45:11.761392+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050017.pdf	Requested	16	16	21	1	\N
616	Q202602050018	357	213	0		48	t	2026-01-06 00:45:44.875767+05	\N	2026-01-06 00:46:08.182641+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050018.pdf	Requested	24	24	21	1	\N
617	Q202602050019	357	213	0		36	t	2026-01-06 00:57:13.98893+05	\N	2026-01-06 01:00:06.604734+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050019.pdf	Requested	18	18	21	1	\N
632	Q202602060034	360	213	0		12	t	2026-01-06 23:27:49.049111+05	\N	2026-01-07 00:17:50.631273+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060034.pdf	Requested	6	6	21	1	\N
623	Q202602050025	357	213	0		20	t	2026-01-06 01:17:03.686984+05	\N	2026-01-06 01:17:30.056006+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050025.pdf	Requested	10	10	21	1	\N
618	Q202602050020	357	213	0		22	t	2026-01-06 01:04:58.692859+05	\N	2026-01-06 01:05:36.500002+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050020.pdf	Requested	11	11	21	1	\N
625	Q202602050027	358	213	0		66	t	2026-01-06 01:37:16.629042+05	\N	2026-01-06 01:41:42.422084+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050027.pdf	Requested	33	33	21	1	\N
626	Q202602060028	358	213	0		56	t	2026-01-06 22:29:30.96489+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060028.pdf	Requested	28	28	\N	1	\N
627	Q202602060029	358	213	0		44	t	2026-01-06 22:32:18.992441+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060029.pdf	Requested	22	22	\N	1	\N
619	Q202602050021	357	213	0		40	t	2026-01-06 01:05:56.945695+05	\N	2026-01-06 01:06:47.557821+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050021.pdf	Requested	20	20	21	1	\N
624	Q202602050026	357	213	0		28	t	2026-01-06 01:30:39.181555+05	\N	2026-01-06 01:31:02.893112+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050026.pdf	Requested	14	14	21	1	\N
628	Q202602060030	358	213	0		36	t	2026-01-06 22:46:14.290343+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060030.pdf	Requested	18	18	\N	1	\N
629	Q202602060031	358	213	0		38	t	2026-01-06 22:47:19.023255+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060031.pdf	Requested	19	19	\N	1	\N
630	Q202602060032	358	213	0		36	t	2026-01-06 22:48:24.262914+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060032.pdf	Requested	18	18	\N	1	\N
620	Q202602050022	357	213	0		20	t	2026-01-06 01:08:21.631178+05	\N	2026-01-06 01:09:13.011801+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050022.pdf	Requested	10	10	21	1	\N
621	Q202602050023	357	213	0		4	t	2026-01-06 01:09:24.521406+05	\N	2026-01-06 01:09:26.569125+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050023.pdf	Requested	2	2	21	1	\N
631	Q202602060033	359	213	0		4	t	2026-01-06 23:18:42.660511+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060033.pdf	Requested	2	2	\N	1	\N
634	Q202602060036	360	213	0		60	t	2026-01-07 00:19:25.675094+05	\N	2026-01-07 00:19:45.052877+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060036.pdf	Requested	30	30	21	1	\N
622	Q202602050024	357	213	0		52	t	2026-01-06 01:09:39.004656+05	\N	2026-01-06 01:16:48.643596+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602050024.pdf	Requested	26	26	21	1	\N
635	Q202602060037	360	213	0		46	t	2026-01-07 00:22:14.334915+05	\N	2026-01-07 00:23:44.931482+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060037.pdf	Requested	23	23	21	1	\N
633	Q202602060035	360	213	0		58	t	2026-01-07 00:18:05.519463+05	\N	2026-01-07 00:18:25.70032+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060035.pdf	Requested	29	29	21	1	\N
636	Q202602060038	360	213	0		52	t	2026-01-07 00:42:26.52505+05	\N	2026-01-07 00:43:16.531397+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602060038.pdf	Requested	26	26	21	1	\N
637	Q202602070039	360	213	0		4	t	2026-01-08 00:57:15.16496+05	\N	2026-01-08 00:57:24.257646+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602070039.pdf	Requested	2	2	21	1	\N
643	Q202602080045	360	213	0		0	t	2026-01-09 02:03:18.512271+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602080045.pdf	Requested	0	0	21	1	\N
658	Q202604230011	360	213	0		0	t	2026-01-23 23:27:18.368712+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230011.pdf	\N	0	0	21	1	4
659	Q202604230012	360	213	0		0	t	2026-01-23 23:27:21.598169+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230012.pdf	\N	0	0	21	1	4
660	Q202604230013	360	213	0		0	t	2026-01-23 23:27:23.933615+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230013.pdf	\N	0	0	21	1	4
638	Q202602070040	360	213	0		4	t	2026-01-08 01:07:21.916846+05	\N	2026-01-08 01:22:50.340698+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602070040.pdf	Requested	2	2	21	1	\N
639	Q202602080041	360	213	0		6	t	2026-01-08 22:16:21.128741+05	\N	2026-01-08 22:31:52.66391+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602080041.pdf	Requested	3	3	21	1	\N
644	Q202602090046	40	34	0		0	t	2026-01-09 19:20:28.002558+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602090046.pdf	Requested	0	0	21	1	\N
647	Q202603170001	360	213	0		8	t	2026-01-18 01:51:45.647647+05	\N	2026-01-18 02:05:34.296101+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202603170001.pdf	Requested	4	4	21	1	\N
648	Q202604220001	213	154	0		0	t	2026-01-23 02:29:28.366202+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604220001.pdf	Requested	0	0	21	1	\N
649	Q202604220002	213	154	0		0	t	2026-01-23 02:30:09.273921+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604220002.pdf	Requested	0	0	22	1	\N
661	Q202604230014	360	213	0		0	t	2026-01-23 23:35:31.531323+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230014.pdf	\N	0	0	21	1	4
662	Q202604230015	360	213	0		0	t	2026-01-23 23:35:35.454503+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230015.pdf	\N	0	0	21	1	4
640	Q202602080042	360	213	0		0	t	2026-01-08 23:23:48.369583+05	\N	2026-01-08 23:25:44.578872+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602080042.pdf	Requested	0	0	21	1	\N
645	Q202602100047	360	213	0		4	t	2026-01-10 23:33:38.782973+05	\N	2026-01-10 23:53:44.591371+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602100047.pdf	Requested	2	2	21	1	\N
650	Q202604220003	213	154	0		0	t	2026-01-23 02:37:22.717125+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604220003.pdf	In progress	0	0	21	1	\N
641	Q202602080043	360	213	0		0	t	2026-01-09 00:04:42.388441+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602080043.pdf	Requested	0	0	21	1	\N
646	Q202602100048	362	215	0		16	t	2026-01-10 23:59:18.450379+05	\N	2026-01-11 00:02:49.552583+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602100048.pdf	Requested	8	8	21	1	\N
651	Q202604220004	360	213	0		0	t	2026-01-23 02:56:16.478951+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604220004.pdf	In progress	0	0	21	1	\N
642	Q202602080044	360	213	0		0	t	2026-01-09 01:49:20.413555+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202602080044.pdf	Requested	0	0	21	1	\N
652	Q202604230005	360	213	0		0	t	2026-01-23 22:58:12.238868+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230005.pdf	\N	0	0	21	1	4
653	Q202604230006	360	213	0		0	t	2026-01-23 22:58:17.979397+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230006.pdf	\N	0	0	21	1	4
654	Q202604230007	360	213	0		0	t	2026-01-23 22:58:18.785721+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230007.pdf	\N	0	0	21	1	4
655	Q202604230008	360	213	0		0	t	2026-01-23 22:58:19.240841+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230008.pdf	\N	0	0	21	1	4
656	Q202604230009	360	213	0		0	t	2026-01-23 22:58:19.61514+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230009.pdf	\N	0	0	21	1	4
657	Q202604230010	360	213	0		0	t	2026-01-23 22:58:19.824223+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202604230010.pdf	\N	0	0	21	1	4
664	Q202606040002	374	225	0		0	t	2026-02-04 21:49:07.616874+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606040002.pdf	\N	0	0	21	1	4
665	Q202606040003	374	225	0		0	t	2026-02-04 21:54:38.565698+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606040003.pdf	\N	0	0	21	1	4
663	Q202606040001	373	224	0		5	t	2026-02-04 20:02:20.438132+05	\N	2026-02-04 20:02:24.549913+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606040001.pdf	Requested	2	3	21	1	\N
666	Q202606060004	385	233	0		0	t	2026-02-07 01:24:42.445994+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606060004.pdf	\N	0	0	21	1	4
667	Q202606060005	385	233	0		10	t	2026-02-07 01:26:10.221196+05	\N	2026-03-10 01:52:43.421851+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	C:\\PDF Scheduler\\Test Outputs\\Q202606060005.pdf	Requested	4	6	21	1	\N
668	Q202606070006	387	234	0		0	t	2026-02-07 22:54:06.981595+05	\N	2026-02-07 22:54:10.772842+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606070006.pdf	Requested	0	0	21	1	\N
675	Q202607100006	395	234	0		5	t	2026-02-10 20:14:24.008379+05	\N	2026-02-10 20:36:08.798603+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100006.pdf	Requested	2	3	23	1	\N
683	Q202610030001	402	237	0		5	t	2026-03-03 23:32:08.077025+05	\N	2026-03-03 23:32:55.988677+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202610030001.pdf	Requested	2	3	21	1	\N
669	Q202606070007	387	234	0		0	t	2026-02-07 22:55:20.689032+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202606070007.pdf	Requested	0	0	24	1	\N
676	Q202607110007	395	234	0		10	t	2026-02-11 21:41:52.439817+05	\N	2026-02-11 21:42:48.844296+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110007.pdf	Requested	4	6	22	1	\N
679	Q202607110010	401	237	0		0	t	2026-02-11 21:45:39.269158+05	\N	2026-02-11 21:47:31.342152+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110010.pdf	Requested	0	0	22	1	\N
680	Q202607110011	402	237	0		5	t	2026-02-11 21:46:40.671948+05	\N	2026-03-03 23:32:05.956877+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110011.pdf	Requested	2	3	21	1	\N
687	Q202611090001	404	237	0		0	t	2026-03-10 01:53:28.957013+05	\N	2026-03-10 01:53:56.360071+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202611090001.pdf	Requested	0	0	34	1	\N
670	Q202607100001	372	223	0		25	t	2026-02-10 19:42:48.181464+05	\N	2026-02-10 19:59:28.284699+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100001.pdf	Requested	10	15	22	1	\N
677	Q202607110008	399	235	0		10	t	2026-02-11 21:43:39.380751+05	\N	2026-02-11 21:43:57.636629+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110008.pdf	Requested	4	6	22	1	\N
672	Q202607100003	394	234	0		0	t	2026-02-10 20:03:29.022853+05	\N	2026-02-10 20:03:45.552379+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100003.pdf	Requested	0	0	23	1	\N
674	Q202607100005	396	235	0		0	t	2026-02-10 20:05:18.281903+05	\N	2026-02-10 20:14:04.970792+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100005.pdf	Requested	0	0	22	1	\N
671	Q202607100002	392	234	0		5	t	2026-02-10 20:00:38.848111+05	\N	2026-02-10 23:55:49.445693+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100002.pdf	Requested	2	3	23	1	\N
678	Q202607110009	400	237	0		5	t	2026-02-11 21:45:05.192474+05	\N	2026-02-11 21:45:11.394782+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110009.pdf	Requested	2	3	21	1	\N
673	Q202607100004	395	234	0		0	t	2026-02-10 20:04:25.693241+05	\N	2026-02-10 20:04:31.774335+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607100004.pdf	Requested	0	0	21	1	\N
681	Q202607110012	402	237	0		0	t	2026-02-11 21:48:33.225285+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110012.pdf	Requested	0	0	22	1	\N
682	Q202607110013	402	237	0		0	t	2026-02-11 21:49:13.866523+05	\N	2026-03-10 01:51:59.384492+05	29a8a07e-094a-48ea-82af-7221f1175cca	\N	C:\\PDF Scheduler\\Test Outputs\\Q202607110013.pdf	Authorised	0	0	24	1	\N
\.


--
-- TOC entry 5418 (class 0 OID 58458)
-- Dependencies: 250
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security."RefreshTokens" ("Id", "UserId", "Token", "ExpiryDate", "IsRevoked", "CreatedDate") FROM stdin;
1	29a8a07e-094a-48ea-82af-7221f1175cca	80XMku34UbMzow43wkYxWvSbmL8B1HIBeDpGCG2iZJbPL93/pBAWxSki3cQ1cOKMegIEkiAkN08hPSLtPIB7dw==	2026-01-14 21:24:53.339148+05	t	2026-01-07 21:24:53.339864+05
2	29a8a07e-094a-48ea-82af-7221f1175cca	VlntpabfYvTdsIyOzAyrG55fzQSoJ8uLB6XNPD6F1vj1SLeDfZnaGntNReG95lo+n62/IBom/pf14Bht+/aSfw==	2026-01-14 21:48:39.53188+05	t	2026-01-07 21:48:39.531881+05
3	29a8a07e-094a-48ea-82af-7221f1175cca	zotavqgeWwShta/+FvQcDLcrYyyP9+lpIPTfB/0TkxBYBLUPkjYSoRmG8q92kFKPxoTuXErjZf5w7qwipUXvxA==	2026-01-15 00:46:36.162411+05	t	2026-01-08 00:46:36.163175+05
4	29a8a07e-094a-48ea-82af-7221f1175cca	po4qmVVNnpbv6nXiFw91KrsTcUVeV6kaSvssmIfyhK9EMuUKShfKQ/bfkwWKoJIIjZ2UMw1VZV6Ona6Qs+AUNw==	2026-01-15 01:09:13.86743+05	t	2026-01-08 01:09:13.867431+05
5	29a8a07e-094a-48ea-82af-7221f1175cca	VQGzJMO3mI3FT6WlwmBaO7v4hlFryA3pPlqD6b0bABvqK2jSgf5AESCJoq2Q8sgCirtJuPW6Vg+m7jaFXr7ryg==	2026-01-15 20:55:43.006453+05	t	2026-01-08 20:55:43.007601+05
6	29a8a07e-094a-48ea-82af-7221f1175cca	jGAGW19bmqFGTLE10pPpeRdSokK9RWOI0z4IlYiznGCarNFb7MJPcmrnhGkaL6zvJXVRKixT8dd1ylmMw8hYEQ==	2026-01-15 22:21:02.230893+05	t	2026-01-08 22:21:02.231604+05
7	29a8a07e-094a-48ea-82af-7221f1175cca	YSB7s2Ap4nZH9X84x295BpaWKzprwiT9BdsfA5bwiSVPdmIHi1hqQyfpbIW4cdBT48AgTGdM+XDrX1gDQoqcNw==	2026-01-15 23:00:04.594863+05	t	2026-01-08 23:00:04.595368+05
8	29a8a07e-094a-48ea-82af-7221f1175cca	6JWIz8+ZzRNNF/I/NUr7aNjqIKPyHZuTVxp1KWfnodIvT5hUjTihzUz/yGHSpJ0CY/QjPS3VL8ed9YRe0gLT/g==	2026-01-15 23:24:40.518357+05	t	2026-01-08 23:24:40.518358+05
9	29a8a07e-094a-48ea-82af-7221f1175cca	PU0Tsjq/+OMgCIrxTPzPvLhfwG5Jaxvc0VrUYwOJd5Vk9AI1cIhLTjqZ9PJeeIOhYlbVJ0viLBu34qy7oGK9tA==	2026-01-16 22:53:57.147659+05	t	2026-01-09 22:53:57.147977+05
10	29a8a07e-094a-48ea-82af-7221f1175cca	yBUvt1nwEU7Wzd0N5pN1Hsx9mZDisYGAM7bM1pPA9qAIRLQX/2quBpvjqx7FFMfxULAk/wMckBqAgnGElql8gA==	2026-01-16 23:44:35.150814+05	t	2026-01-09 23:44:35.150975+05
11	29a8a07e-094a-48ea-82af-7221f1175cca	AWuW3Ug9BaAq/TVZySjyqi5VD1xceCjynFMzhlJBM/dMjE4uNi4E6olmommyOQ2+ne0u3I6A1prfnlByPM3BlQ==	2026-01-17 00:20:43.122091+05	t	2026-01-10 00:20:43.122424+05
12	29a8a07e-094a-48ea-82af-7221f1175cca	vVeOP5uUYZNfvo25RLViDLkp47uKXH4j/iBtmg8105lroGWvX7EWAVbABv6beMGDubAOHvF6lJ9JnkzCZhSxPQ==	2026-01-17 00:58:17.249737+05	t	2026-01-10 00:58:17.250831+05
13	29a8a07e-094a-48ea-82af-7221f1175cca	AUkX+/oWSwqNm/gn1FYLufSFKQG7QpfUZ/NWcMlfbMpHcj36WXJK5stb4NdInohUa73tsfnFJNsGKF6oBQaphA==	2026-01-17 01:03:52.719871+05	t	2026-01-10 01:03:52.719873+05
14	29a8a07e-094a-48ea-82af-7221f1175cca	+JQgb5wAPFxS+7QKP/dIIghRxZdYtpl4s4puOmnOlsdxAaa5uPWYLZVTv45G8zZjx+TQSOdeHHcG+fRuxWVCkA==	2026-01-17 01:38:10.945289+05	t	2026-01-10 01:38:10.945988+05
15	29a8a07e-094a-48ea-82af-7221f1175cca	Fq+D79M6w6HLzGGisTx2Mbk0wAENyOyTy/zkHvWU4S4E/oTzFArfho4kx6xO03DNdZgGINvJKQDPFsGSd81hKw==	2026-01-17 20:11:27.441016+05	t	2026-01-10 20:11:27.441217+05
16	29a8a07e-094a-48ea-82af-7221f1175cca	1ApTgo96wVs2tM1f7W441ypD5/WEMydD5Nfr2XXQdhSZh+VQfO5WTy67MgSakEz1BGptIn+0el/vKCNyF3jlrw==	2026-01-17 23:43:13.263304+05	t	2026-01-10 23:43:13.263729+05
17	29a8a07e-094a-48ea-82af-7221f1175cca	YL+VfdmDwJkym0zK98nqcutIT87UbMZl/SW2lfKOcjunXa3N7MX8h8goSxicT1DQWcd4AGNrmF18nNF4RUkXJg==	2026-01-18 00:01:22.512711+05	t	2026-01-11 00:01:22.512714+05
18	29a8a07e-094a-48ea-82af-7221f1175cca	k4YG3QI7SXwsIplChbz0Y+ZoEwvi+P347DC4eH1u4T9QvfAhhtHpNMR2ZmWElmSxVZ3jqkiEblF1qe63+/HTUA==	2026-01-18 00:48:05.319067+05	t	2026-01-11 00:48:05.319452+05
19	29a8a07e-094a-48ea-82af-7221f1175cca	McaeElMFgDFLyd7LGTvSbDFQPD58wx90moU8w29tQfaQlQvSsk4dwWeYofbcfgba/42f9Qu+KrRcCZ85JSjJdg==	2026-01-23 18:58:01.833921+05	t	2026-01-16 18:58:01.835074+05
20	29a8a07e-094a-48ea-82af-7221f1175cca	g1qcvmtd7HiWPehadY1xdSi36y+izZ/X4xwidnN3NS/YWDvQuJnMBBV2izmZSxc/ew/8AMRViAcmZ7ZYoq7utQ==	2026-01-24 01:42:05.587757+05	t	2026-01-17 01:42:05.588975+05
21	29a8a07e-094a-48ea-82af-7221f1175cca	FIDnzsik1z2VpY4qf4J5UQuhLQF+lQxVax0Xr/XmEgSMLsqMZqlefhMElEf9Lf++5GWpFkzaVl0/c1ZWIkXhlA==	2026-01-24 01:58:34.540428+05	t	2026-01-17 01:58:34.541096+05
22	29a8a07e-094a-48ea-82af-7221f1175cca	491JhpLsBCcwChbxZVazGwerg2iQo2KC1n6SwRYID5C2ovE975x2vmukfRD5g8NTu+6GOQ2aG5jW3oCkJhtMcw==	2026-01-24 02:14:54.239456+05	t	2026-01-17 02:14:54.240121+05
23	29a8a07e-094a-48ea-82af-7221f1175cca	T4iDdCF9a1UGUUygjMFhchw4M7gGHUVP+ZiJ7kJL+48wsZhKqXWYhPu8sxwhzZpxbdyGHynq35aXcpuRFYX5yQ==	2026-01-24 02:31:20.743163+05	t	2026-01-17 02:31:20.74347+05
24	29a8a07e-094a-48ea-82af-7221f1175cca	hf9NUro9YUzVu+HW8EuRm5xa4o+t+Pitf3ae2WzNynP2Q7TbSK2AXMqs0w7yDsvru08iIBt/4EI83WgIo5kIgA==	2026-01-24 02:45:30.28302+05	t	2026-01-17 02:45:30.283276+05
25	29a8a07e-094a-48ea-82af-7221f1175cca	570gloyrIZlYkKF/mXvGGEansNj/T5dhpNf14gC/0MSvj8bmsArLYfhTSy9wc4g+Ib3Rp0hNycbUUtxcC9sh1w==	2026-01-24 02:49:55.656001+05	t	2026-01-17 02:49:55.656003+05
26	29a8a07e-094a-48ea-82af-7221f1175cca	DhUpHCN6dEd6GNE5MQ075k3/Znn9xV3/XP8lQStVHZrHAZ262tb36xHRhxMt8Xi/xftPtXypcbef9UsJQ0njlQ==	2026-01-24 19:08:08.263484+05	t	2026-01-17 19:08:08.264582+05
27	29a8a07e-094a-48ea-82af-7221f1175cca	moWggI8yd6/hpBRyoC8FVdKYqvWqxx+EZEKA7H4DbWJJPFqJLgtD9En5iE6FPQDdr7ritkKvV7ODXRCi34SUuw==	2026-01-25 01:29:56.969231+05	t	2026-01-18 01:29:56.970197+05
28	29a8a07e-094a-48ea-82af-7221f1175cca	18jWlTNdOQ8r+gRTy90hoOkv4IoTW41Lmyo0QfAYiZDSl/SmrEiMOw+iQ3Q4d11kBAavDoYvDWSmEvK/ubHTqw==	2026-01-25 02:00:39.705761+05	t	2026-01-18 02:00:39.705765+05
29	29a8a07e-094a-48ea-82af-7221f1175cca	hKVE4L4D2HMSo9EamTvkFaZhlU8fN1zc19urMSCe66G+njcqi5BsrtCs1msQ8A/xXn8TejoI/j9cPbGhFQKVaQ==	2026-01-25 02:55:16.925977+05	t	2026-01-18 02:55:16.926558+05
30	29a8a07e-094a-48ea-82af-7221f1175cca	gGTSGpdKtWq/dfjJlaoldvlTlkSvsEYOCo9+KuijhdlVPYqjtRPcEAcWqEBGcKukBmdmylaJdHwdIuP3uCm0tQ==	2026-01-28 16:42:51.049026+05	t	2026-01-21 16:42:51.049318+05
31	29a8a07e-094a-48ea-82af-7221f1175cca	fqWtyaECG/cf3H88eplL2dCZ+s3CY85hFImA4VyrP32KvCtqKEPd4GTX5RukjoSeDvGdGdbOyaMTwszYpb2tTQ==	2026-01-28 16:47:00.415924+05	t	2026-01-21 16:47:00.416186+05
32	29a8a07e-094a-48ea-82af-7221f1175cca	k+N2XLIq5H7kmq4pRyZ4/jVtW84O6u6sJDeLcQ6PyVoJZf0Zf2t8hFiAnQe4aCRBnpu7S5ZAaEiv01H2oLfYXw==	2026-01-28 17:21:36.990216+05	t	2026-01-21 17:21:36.990219+05
33	29a8a07e-094a-48ea-82af-7221f1175cca	7+neKED79kn8IjtJp6Iwtu24ldRF3WAaVNWocAWFW4IvcewQuBggU5TQ2s1wCXuKxC8NlF3CAODQleRICx4eYQ==	2026-01-28 17:55:48.260399+05	t	2026-01-21 17:55:48.260742+05
34	29a8a07e-094a-48ea-82af-7221f1175cca	osbz1NvhXXD9hwLDkiLJW+cJ0m5qhFEWWNqbExHRuBmFDc8KOfUZVwx7hEaCUTZVeqSmyOoakroBxR1JGuFZ2w==	2026-01-28 18:14:02.07952+05	t	2026-01-21 18:14:02.080273+05
35	29a8a07e-094a-48ea-82af-7221f1175cca	mNMPvMsN3ESSLdpCDtQoHgMLXtiL4a6c69JlEYC2Os4Lbe6/3PheoqsOvLD5o/XLA+6yWylKGq+komZVQNMSgw==	2026-01-28 18:17:12.150618+05	t	2026-01-21 18:17:12.151126+05
36	29a8a07e-094a-48ea-82af-7221f1175cca	Q7GQxg8nVBdIN6gy/Gj5DX3Lk83xnLya1zbqnwuBpwbMwy+05Y1CsTsq/rc1GRABoUtqo2h2bxFsFxn9dJyeRg==	2026-01-28 19:43:15.643382+05	t	2026-01-21 19:43:15.643594+05
37	29a8a07e-094a-48ea-82af-7221f1175cca	r9abbo3XYsHUetyJFYz8Vt3Qjd1dC9XbRByzHmznhm6dcZiWfayp3vKzgntsdLEt7dkNoLfkaB6tdHJUTjX0lg==	2026-01-28 19:48:14.477056+05	t	2026-01-21 19:48:14.477185+05
38	29a8a07e-094a-48ea-82af-7221f1175cca	EjnL48jnD7Ajti6yuwRKhWF8E5qixhu7zRcww8t4nIIFlBWw4RAz9llOORaCvor7I8TBVg7tkWsz2sExcJf6mg==	2026-01-28 19:56:22.424281+05	t	2026-01-21 19:56:22.424283+05
39	29a8a07e-094a-48ea-82af-7221f1175cca	T3QKZE4ph+ztlo2oypMmO/VmlNyyNDc+u2uf66ye+zdnNFH6yneeBRjtAESGBJcqN0vDhEdMfpPfkFX4C5rGOA==	2026-01-28 19:59:39.652102+05	t	2026-01-21 19:59:39.652264+05
40	29a8a07e-094a-48ea-82af-7221f1175cca	5oB/hiwFewppV0wFh6jgMvF+n/G9cX3J+HK7fSnc/nHMURzK0dEKaFaO/RvXh53n2pCT7XxoXLDfR5BT/nL2sQ==	2026-01-28 20:32:31.808743+05	t	2026-01-21 20:32:31.808913+05
41	29a8a07e-094a-48ea-82af-7221f1175cca	57me4xb/HMj7TOXjhCYbF2X55M8XWpOwAI37go6YYgTY2senJF6t+ehbTrtiTwSGqh391uELTNCk9UlW+7KW1g==	2026-01-28 20:51:05.849511+05	t	2026-01-21 20:51:05.849693+05
42	29a8a07e-094a-48ea-82af-7221f1175cca	69E9D/I6qf54WH006qEhLDkC7nneiOLZ2AQE5UDPZxkpLMh6jXwNbTpeRDUcxxsKwKkcYWd3WtrpHhxYY/JvmA==	2026-01-28 21:02:08.870678+05	t	2026-01-21 21:02:08.870968+05
63	29a8a07e-094a-48ea-82af-7221f1175cca	U7CxDhMuni2n+oKRFfV2fIdbgCH+gh9T9SYs7S+FcGbGRil+OF5S/OgLB0h7EFCkXe4xrJAPrZSKsHF7y1k8Jw==	2026-01-30 23:20:13.846147+05	t	2026-01-23 23:20:13.846353+05
43	29a8a07e-094a-48ea-82af-7221f1175cca	PShVyxWUM+bkmJl1xPcyehyNvKSXeQ2WUm+Swu6Mejsu0i6Kf+aEUPgVc5GBQNvhVSBCGgUyyTZqcOA8CtHFbA==	2026-01-28 22:40:36.918339+05	t	2026-01-21 22:40:36.918581+05
64	29a8a07e-094a-48ea-82af-7221f1175cca	07ErDU5UuKx7ltGylZKgQpbj6iWlK4pQPvoEEBpIJZPvKdlbWpRn7KINHEZWEtQnm0iIKejp7Jy4WjC4KWxkQw==	2026-01-30 23:34:30.496114+05	t	2026-01-23 23:34:30.496267+05
44	29a8a07e-094a-48ea-82af-7221f1175cca	LMjQ4R5pmHEnq+acow7m1aq+uXGljLyeVL4QwIIPVmFuN8lL5SuHiaieFaw+WYqrjOTwo5HIrafAB1oVhuXxjw==	2026-01-28 22:54:41.676466+05	t	2026-01-21 22:54:41.676677+05
45	29a8a07e-094a-48ea-82af-7221f1175cca	UI2PrKYYeU8mcA13czPRS4xLjFzuz6al8JXhAopRyxDAcr2gMRxjo1IlKPi+svtZOJp1WWAncpsv3dnQI2Eemg==	2026-01-28 23:09:08.905416+05	t	2026-01-21 23:09:08.905616+05
65	29a8a07e-094a-48ea-82af-7221f1175cca	ojCzIOarMTsJxvb9I27NQO+4NN6zivRz+1PWM2iaqLUPUMCtD8tPsB3OsBorMZoVOGa6Y9anQjVQss7R1q8JNw==	2026-01-30 23:46:02.246623+05	t	2026-01-23 23:46:02.246809+05
46	29a8a07e-094a-48ea-82af-7221f1175cca	OBMBi2lWkmi10wmZAlK5BOtq5lylyuZ/1s0DkFaV4rUwKUECZwOAYtmJ3VNdxUlcF0RZmWf+hSmCh2Apgtgodg==	2026-01-28 23:17:58.287326+05	t	2026-01-21 23:17:58.287554+05
66	29a8a07e-094a-48ea-82af-7221f1175cca	wSuSLIyV6mFrUfMZwgfYmx82M6D/10w4SjQczxRJgqPdFxgt5HBXLCHUxUFX4Ko95LkWyg8CmRGBEQipXyrVrg==	2026-01-31 01:43:41.474647+05	t	2026-01-24 01:43:41.474793+05
47	29a8a07e-094a-48ea-82af-7221f1175cca	BbrK8LSij/NPOMMixpMc6uH7mNgJnJrOO9RWRLyJ3ks70ECD3TqQnt63QJJ5FZzmRkDCj3AI/XDORasrJRK+Gw==	2026-01-28 23:42:28.72311+05	t	2026-01-21 23:42:28.723414+05
48	29a8a07e-094a-48ea-82af-7221f1175cca	JkTqvW4GBlWTcAUvYIxoG1PGZvmES5vHUxjVQW0HT+KYHrwJh01Cts6bnmiS4ZSUinVnlLGX/Zjuv4lN/WpptQ==	2026-01-29 21:55:31.746053+05	t	2026-01-22 21:55:31.747887+05
67	29a8a07e-094a-48ea-82af-7221f1175cca	jVnnP1r+L6VICUPklvmM+RIlL+K0QI9jQU9izKQHx59RC5kIeFjMB/fDXTDWHCnTTK6280SdvGUifsmvadgjJw==	2026-01-31 01:57:34.881889+05	t	2026-01-24 01:57:34.882072+05
49	29a8a07e-094a-48ea-82af-7221f1175cca	BBAajhzdv3rHwQhlXqHmFSDn2Vm65fBdnpzxmQno0IIiWBjDYIcz8ahrT/+wMWgv4BSeZYmV0ANzTrMVnXEhow==	2026-01-29 22:11:50.364233+05	t	2026-01-22 22:11:50.364235+05
68	29a8a07e-094a-48ea-82af-7221f1175cca	ZN33YlBps1RBPEFTEqt/N85iaG2fWej/EmVn5zxzRUS9BTRqdU+b1gOHG8HHLL+NbJAiJ4nIjODxXYw0oFaQEA==	2026-01-31 20:14:12.622854+05	t	2026-01-24 20:14:12.623067+05
50	29a8a07e-094a-48ea-82af-7221f1175cca	w1LeoyDxKMAPvF96lNHXEvjGfeJqcvQf72tLxaU1rzV1QT+pxsuOqAxvQTWUfhi6xv9FyPAUEr7tzX1DRkbFJA==	2026-01-29 22:27:25.714299+05	t	2026-01-22 22:27:25.714302+05
51	29a8a07e-094a-48ea-82af-7221f1175cca	cEJNxtYRLdrWQ0HK6L+YNDUxlRbiVeBJ+XCOKvvDcvSaNWjbgpwNS3bkzTC9p6o6I2Faf9HKNlx0Dsn3wqI5SQ==	2026-01-29 22:58:43.934551+05	t	2026-01-22 22:58:43.93489+05
69	29a8a07e-094a-48ea-82af-7221f1175cca	lC1fZjnDYXB+Fc/TstRuAZTTpwPhsQ6tn/cCV7VWx6lHL37RYrxgrhTIvTKRRlf6zs50o6QtNWvLW17HjTE7Xg==	2026-01-31 20:29:00.100648+05	t	2026-01-24 20:29:00.100651+05
52	29a8a07e-094a-48ea-82af-7221f1175cca	dwcEoDYBE5akH2S5CuVa6yKUdIWL+HdnmDrH19PehoarNm4bqYbG+YpiIoobRXcDZ72ZKi6JNn7XMaH0jlp+fg==	2026-01-29 23:36:31.717841+05	t	2026-01-22 23:36:31.717845+05
70	29a8a07e-094a-48ea-82af-7221f1175cca	08Net0OcXeGv6bXH3BwV/GgJ0UxxyMOkwxfMGaLsnDHpDZoUeJ7U6WdMRxncougP4fmAABLlkqMc9K4RPbwMUA==	2026-01-31 21:06:31.1863+05	t	2026-01-24 21:06:31.186534+05
53	29a8a07e-094a-48ea-82af-7221f1175cca	38CBlPvcgFvZzAbYeEaAoaJYIO3Pl0h3HKiYXqmeN0gN30jjNljnWXflx5ZK/2G5ICPBO7ZsdptU3lnDTfX1yw==	2026-01-29 23:58:04.691769+05	t	2026-01-22 23:58:04.692066+05
54	29a8a07e-094a-48ea-82af-7221f1175cca	MDGFncvkW1jJGPMLXHWZ5Zymavjs0KP3WpIFv0LxlNqqBWJD0ZO7xz9cHcrQMlv79foODzF84cMaN/9JvgIvqQ==	2026-01-30 00:40:32.100583+05	t	2026-01-23 00:40:32.10083+05
71	29a8a07e-094a-48ea-82af-7221f1175cca	uXh6JDaLrSRW9emDCsYWmY5GSZVrZWofILYmfVmgkmKeb0jTop1PaBNO1vYYASft7/zvnYB5tScJSMGDMLX55g==	2026-01-31 21:54:12.310206+05	t	2026-01-24 21:54:12.310399+05
55	29a8a07e-094a-48ea-82af-7221f1175cca	Vp2OfCHo8qNrDZLLeXMWZjrFRTob5ag8DkgWdHJ36NNMfQIbulgu+IIiBa+nkrShsoWUQBhbiC9xjFAd4Spsig==	2026-01-30 00:42:17.806983+05	t	2026-01-23 00:42:17.806985+05
72	29a8a07e-094a-48ea-82af-7221f1175cca	lOkNM2lJ45lDm+k1nceoq2Vtwaka28yndPKI4QVEWb444LduIm2BIcJ56+MYOp7ys1QxVTtO0I4FX5KHN8C0bw==	2026-01-31 22:53:40.207874+05	t	2026-01-24 22:53:40.208023+05
56	29a8a07e-094a-48ea-82af-7221f1175cca	XM2zw3BRGFvU1H45mY5MIs3OVtCD+lN9DtjnG4ZFcW5v+27dVWnH41qMsDRGXetyUBfEAXo9uiDdesZunHXGew==	2026-01-30 00:59:19.129995+05	t	2026-01-23 00:59:19.129997+05
57	29a8a07e-094a-48ea-82af-7221f1175cca	+I/ZnkQMUfUBYyWl4NVsPafjbc/ZHGi7UFtTuQztNNAqeHv8KMeoGV1CbZ/Xo6hEsfiAwxG9yacJ8vuqYqfmdQ==	2026-01-30 02:27:52.849034+05	t	2026-01-23 02:27:52.849231+05
73	29a8a07e-094a-48ea-82af-7221f1175cca	mFlUPtaT/xSZp+7uvPsCPQYEev5SqQWnZp9giTZ9H3/ULXnFQEYwDefBF3jFq90dl6mwXVaSR8hjJGobSoDg7w==	2026-01-31 23:18:55.635814+05	t	2026-01-24 23:18:55.635984+05
58	29a8a07e-094a-48ea-82af-7221f1175cca	L9iPdtVUqWkNF63qB1W/RsooJqxMLSbbNO7JPuz4XQMfBqN+L1swzLYr7LTzFIfumr3Zg4d3Wv4IOEzPI44QQQ==	2026-01-30 02:36:39.07927+05	t	2026-01-23 02:36:39.079473+05
74	29a8a07e-094a-48ea-82af-7221f1175cca	7wzDWYODAYfpc2H4lcdv09f0jEEBy36GESfodK7PEfuxh9XN+titchFLfC+Oq7/9JL27O3rfYHudCJ0hOJDEEQ==	2026-01-31 23:37:58.98446+05	t	2026-01-24 23:37:58.984823+05
59	29a8a07e-094a-48ea-82af-7221f1175cca	uogOfUllA6wRLNZ6iY2Te4FVST/7ufRkk0+Vm13uWIWL15XC9Aa5SJPQMXU/o/g5VgpTzzFGeg3LRJ3t8hmXfw==	2026-01-30 02:53:52.397255+05	t	2026-01-23 02:53:52.397258+05
60	29a8a07e-094a-48ea-82af-7221f1175cca	KPBLPq1iWCkkve5J5WFVQLF80o74tEB/E6FUD2BM3UKHh+ZZw5m/Sgxc3flsWoHtbU2IhyCmQJ4l0vLhJBgJAQ==	2026-01-30 19:59:11.866882+05	t	2026-01-23 19:59:11.867066+05
61	29a8a07e-094a-48ea-82af-7221f1175cca	m8h7gVYU1mU3qyfkz4DnKNuCVZkxjTpQhxTFBHFXUWTu9RKdIcIZyOJtmmExBXNP1MDuGK8hi5/MFmq/CNGnfA==	2026-01-30 22:34:50.502481+05	t	2026-01-23 22:34:50.502753+05
62	29a8a07e-094a-48ea-82af-7221f1175cca	AkDSXR3oBAhAs7k++d7GKUHrWJoWVT3S40oaqPKcDyiKVVlfjFJh7FLxyv+B61aJCcctnh89HDb+4PJYu1Oung==	2026-01-30 22:55:28.328941+05	t	2026-01-23 22:55:28.328943+05
75	29a8a07e-094a-48ea-82af-7221f1175cca	PiiWyMw1fah1+CpsSBO2o61CHfJtXhzWJeWvyr+AbSUaavsahg4ysymUQ+p0NjqXFLS6vtyv30vLKg0oFy0YkA==	2026-02-24 00:29:02.338163+05	t	2026-01-25 00:29:02.338319+05
76	29a8a07e-094a-48ea-82af-7221f1175cca	51i5MhMeCfUfPHiQZQEyAIsfY+PbkU8vUNjrZIxaFzG4oGRqfQAJ4ynQK5u/ZUf+bg07+e+nw7rHy8x2HHQ3yQ==	2026-03-06 21:33:46.771447+05	t	2026-02-04 21:33:46.771735+05
77	29a8a07e-094a-48ea-82af-7221f1175cca	BJpuBy4W61Yw7G887KRQ5oZyWSDHY/ydB2gvE7ufl2pYdbBgmFagmkahoa15xVedYd+ZBPh++ECX1L7EL5FLNg==	2026-03-06 23:18:56.132427+05	t	2026-02-04 23:18:56.132742+05
78	29a8a07e-094a-48ea-82af-7221f1175cca	71HDdgo2DuycCiHXe4BQ32zSoPLZOB8OTs3w4pGvPZy9tbyMq/eTrnx+/diNroI4MiJawnYdCZthM1sRfWQwYQ==	2026-03-07 19:19:42.649716+05	t	2026-02-05 19:19:42.649861+05
79	29a8a07e-094a-48ea-82af-7221f1175cca	/BzCjwqvtuGHK4NCEraDk9D6Hy0u0r7uLQtvyN4F7Aqc9vLw9VIRxUhLpTHuREULzNDiHpLh4KGh6g/JS1CXaQ==	2026-03-07 19:59:17.025915+05	t	2026-02-05 19:59:17.026336+05
80	29a8a07e-094a-48ea-82af-7221f1175cca	k3qlWw0VvtyFmI7rJsXpJz8QvqNTBRj84dNYfHj6SoN6LUHQuXt3HNcBVKpjY7qea3s1MjrIcrP1F2H4QUIVaQ==	2026-03-09 01:22:21.390016+05	t	2026-02-07 01:22:21.390256+05
81	29a8a07e-094a-48ea-82af-7221f1175cca	NldP0WcW9w5oMIwyxyXnTXG5/6URhtsoOKCoIKSVPcOKwSDuELqiDXwS4Ol4m2WFgDEWPIqsKSPD+rbqsDb/ug==	2026-03-09 01:24:14.691029+05	f	2026-02-07 01:24:14.691031+05
\.


--
-- TOC entry 5420 (class 0 OID 58472)
-- Dependencies: 252
-- Data for Name: jwt_settings; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.jwt_settings ("Id", "Key", "Issuer", "Audience", "AccessTokenExpiryMinutes", "RefreshTokenExpiryDays", "UpdatedAt") FROM stdin;
1	your-very-strong-random-key-here-at-least-32-chars-replace-in-production	QuoteBuilderBackend.API	QuoteBuilderBackend.API	43200	30	2026-01-24 23:45:49.913408+05
\.


--
-- TOC entry 5421 (class 0 OID 58489)
-- Dependencies: 253
-- Data for Name: menu_access; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.menu_access (security_group_id, menu_id, last_modified, date_created) FROM stdin;
1	1	2025-02-07 17:14:11.180757	2025-02-07 17:14:11.180757
1	2	2025-02-07 17:14:11.180757	2025-02-07 17:14:11.180757
1	5	2025-03-24 08:32:53.785453	2025-03-24 08:32:53.785453
1	6	2025-03-25 11:10:18.074092	2025-03-25 11:10:18.074092
1	3	2025-05-12 03:45:27.570716	2025-05-12 03:45:27.570716
1	4	2025-05-12 03:45:27.570716	2025-05-12 03:45:27.570716
\.


--
-- TOC entry 5422 (class 0 OID 58497)
-- Dependencies: 254
-- Data for Name: roles; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.roles ("Id", "Name", "NormalizedName", "ConcurrencyStamp") FROM stdin;
\.


--
-- TOC entry 5423 (class 0 OID 58503)
-- Dependencies: 255
-- Data for Name: roles_claims; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.roles_claims ("Id", "RoleId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- TOC entry 5425 (class 0 OID 58511)
-- Dependencies: 257
-- Data for Name: security_group; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.security_group (security_group_id, parent_id, security_group_name, api_path, last_modified, date_created) FROM stdin;
1	0	Admin	 	2025-02-01 03:05:29.461107	2025-02-01 03:05:29.461107
2	1	Quotes	 	2025-02-01 03:06:09.518109	2025-02-01 03:06:09.518109
6	1	Templates	 	2025-02-14 10:59:10.5886	2025-03-24 08:31:00.896504
3	1	Customers	 	2025-02-01 03:07:53.436961	2025-02-01 03:07:53.436961
4	1	Components	 	2025-02-01 03:07:53.436961	2025-02-01 03:07:53.436961
5	1	Materials	 	2025-02-01 03:08:37.239612	2025-02-01 03:08:37.239612
\.


--
-- TOC entry 5426 (class 0 OID 58523)
-- Dependencies: 258
-- Data for Name: security_group_members; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.security_group_members (security_group_id, user_id, last_modified, date_created) FROM stdin;
1	7	2025-03-24 08:46:33.348676	2025-03-24 08:46:33.348676
\.


--
-- TOC entry 5429 (class 0 OID 58533)
-- Dependencies: 261
-- Data for Name: user_claims; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_claims ("Id", "UserId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- TOC entry 5431 (class 0 OID 58541)
-- Dependencies: 263
-- Data for Name: user_logins; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_logins ("LoginProvider", "ProviderKey", "ProviderDisplayName", "UserId") FROM stdin;
\.


--
-- TOC entry 5432 (class 0 OID 58549)
-- Dependencies: 264
-- Data for Name: user_roles; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_roles ("UserId", "RoleId") FROM stdin;
\.


--
-- TOC entry 5433 (class 0 OID 58556)
-- Dependencies: 265
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_tokens ("UserId", "LoginProvider", "Name", "Value") FROM stdin;
\.


--
-- TOC entry 5434 (class 0 OID 58564)
-- Dependencies: 266
-- Data for Name: users; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.users ("Id", "BusinessId", "UserId", "FirstName", "LastName", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp", "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd", "LockoutEnabled", "AccessFailedCount", "IsDeleted", "PasswordResetToken", "PasswordResetTokenExpiry") FROM stdin;
29a8a07e-094a-48ea-82af-7221f1175cca	1	7	Test	User	Test1@User.com	TEST1@USER.COM	Test1@User.com	TEST1@USER.COM	t	AQAAAAIAAYagAAAAEM1WvhBWmmJyontPtRrDo0bCH424VMPtUOvcTbVjc4+rEQ0jq0+yHtSTaZwk51YAXA==	M72NRCMREEGQQXH3DMZJBAWIIOL2VLHO	2e519cdd-de41-4567-b751-d35caf8fff2f	\N	f	f	\N	f	0	f	\N	\N
80caf7f6-88d4-4c4c-aca9-448ec3145d7d	1	10	CustomerFn	Ln	Test2@User.com	TEST2@USER.COM	Test2@User.com	TEST2@USER.COM	f	AQAAAAIAAYagAAAAEERHHwS1RS285IUyytiDJAQiFnU02aX3Ox6Sbk/cizgAsKWQkNThM2zIpUjzk/2U2g==	JPZCMF66KYJNMYYKM7UQPXIVLXA34BAW	8e5bac06-816e-4c59-b0d6-df8f659ed2b7	1234567890	f	f	\N	t	0	f	\N	\N
42a4dedf-5420-4190-ac65-936a3c844148	1	11	FFF	LLL	Test999@User.com	TEST999@USER.COM	Test999@User.com	TEST999@USER.COM	f	AQAAAAIAAYagAAAAEKBuJcvqkvWBGMsDSaOrAVTe0+WFc/uREf0wxvK23Lb4iykG0mMojPCFiHO/uFGVvQ==	6RS3MOCRWX73KDIBZHRWBTX6XTXYX3ZE	bf80ce61-9dae-419e-b2cb-57b9949d86c7	999999999999	f	f	\N	t	0	f	\N	\N
6969437e-0e8d-47ee-ab90-b4f7b8b939a8	1	12	FF1	LL1	FF1@LL1User.com	FF1@LL1USER.COM	FF1@LL1User.com	FF1@LL1USER.COM	f	AQAAAAIAAYagAAAAEM8ErOsf87nM/Wln04SE747DGOJp9sRFGFmfKxx9nT/hGZpHjZXRqiBpQP3LCZo1VA==	7C7542GSKE5M73UNEUKBKQBLGEGY7CFM	8e4294ed-3924-446f-896f-c4255cbb5521	9876543210	f	f	\N	t	0	f	\N	\N
add1d088-91dc-43ef-aedf-7b2605258030	1	13	AA	BB	AABB1@User.com	AABB1@USER.COM	AABB1@User.com	AABB1@USER.COM	f	AQAAAAIAAYagAAAAEKtf2A0VIPA95rsWmc8MUDg5ds8DzWl/kRpWWMOANRJe6NEiBAGsHgASXm89IlZxSw==	2GDTP4U6IHUFJUBKWQKMLUTWEC77GT2I	e996476e-96ee-4994-8b97-73b6b54e901c	9877899871	f	f	\N	t	0	f	\N	\N
79742c55-004b-4ffb-95ce-99cd3b53dbe9	1	14	Test	Customer1	Customer1@User.com	CUSTOMER1@USER.COM	Customer1@User.com	CUSTOMER1@USER.COM	f	AQAAAAIAAYagAAAAEBuJtBCNZJ31YQatrwjUhNbo0/Mp5sRvh4DlfYomws6r/Wf7E91kXHumylffsRHmKg==	LA6SQX6USG5KM6XVMKNUQJFHSSJE4G7A	b7c06b43-710a-4cd2-815e-4f5c21973a9e	1233211234	f	f	\N	t	0	f	\N	\N
024a8570-b94c-48a2-9fad-6d599f8e7f37	1	15	fasdfas	gasgag	CustomerTest1@User.com	CUSTOMERTEST1@USER.COM	CustomerTest1@User.com	CUSTOMERTEST1@USER.COM	f	AQAAAAIAAYagAAAAEBAEcR0IEpX26e8f9M5oviL7K4ATToprMAcRRSxTQs1W84YuyBwtAEOcSGML2pZHqg==	BGGMEIRTVAQLDFHVVPUMZCI65RBDSZKT	74c0af67-c682-4159-bba0-3a88d8aa2bf9	1231425251	f	f	\N	t	0	f	\N	\N
9eb51366-5040-42d8-80a8-1d0e4541b6ba	1	16	Muhammad	Asim	Test1@Customer.com	TEST1@CUSTOMER.COM	Test1@Customer.com	TEST1@CUSTOMER.COM	f	AQAAAAIAAYagAAAAEK3hKR0tlhMfk3xy8/qaKxSJdTtKeu6X7jfejc87khlfIAZNQKv2RzDQlMrHtkEFRg==	2NCLILAMUP4U445M4UCNTWFUFPSCBBWT	33685851-aecb-45ac-894d-bd070b3ff6e0	1234567890	f	f	\N	t	0	f	\N	\N
8ab4d4de-0444-4f4c-b8df-adcabc84fe48	1	17	Muhammad	Asim	TestCustomer@1234.com	TESTCUSTOMER@1234.COM	TestCustomer@1234.com	TESTCUSTOMER@1234.COM	f	AQAAAAIAAYagAAAAEFtWOXtg60bW+U+TtdK6//+0g5jgsf5AVz7Uu0TbB6pSRRDH8PADRI5Vkp1rAzCvZA==	J4LK24HU2BLL4CEJUEYAEWUIZHGP2LAU	21ba4efd-94f2-4ce1-a387-4cb2f4215575	1234554321	f	f	\N	t	0	f	\N	\N
e0aa48e6-bdaa-4f2c-ae18-d8fe504f67c1	1	18	Test	Customer1	Test123@Customer123.com	TEST123@CUSTOMER123.COM	Test123@Customer123.com	TEST123@CUSTOMER123.COM	f	AQAAAAIAAYagAAAAEHHNgDHieltQT/TMS6XczocQqUeApIjLyEzuHHGOO7GJH66+Uw4KHdEtMvHI0KYSNQ==	4JZRAGGNZS3ZYB2NESTTXADBOKNY5INW	4a557b0e-6053-40aa-88d7-d1645522f548	1233211231	f	f	\N	t	0	f	\N	\N
316ccc2f-9ad9-4504-80d2-0a7e0051c86f	1	19	Customer2	Customer2	Customer2@gmail.com	CUSTOMER2@GMAIL.COM	Customer2@gmail.com	CUSTOMER2@GMAIL.COM	f	AQAAAAIAAYagAAAAEL01X3lj4zUSTgx86rYwrgeLv3mmKZ3mccSBYGSBv8k44rnNewh2WLvWw5oc94H/aQ==	YUT47EP2KUXI22BDXMAFENMZQH6GO27K	a92b6fe7-c632-4353-9e3a-8af89600b872	0987656789	f	f	\N	t	0	f	\N	\N
a95100c7-40aa-492d-9c66-f54f8ecf94e1	0	20	tesing 12323235	2353253255	Test1234567890@User.com	TEST1234567890@USER.COM	Test1234567890@User.com	TEST1234567890@USER.COM	f	AQAAAAIAAYagAAAAEIP6josK5kNY9Wc57FwYvI+bUXSmZ0lNrUs+TQM2gX/Lz4COedNmfvAsXyp2Xv14KA==	HKWGUJHH433PWOOMLJT7X4WPSX35LQ7H	e0d508cf-5f04-44ec-871c-44d6f7c9fb96	35252325	f	f	\N	t	0	f	\N	\N
f567ed99-12c2-4479-b37d-9ee25d79b112	0	21	customer	new	user1@Customer.com	USER1@CUSTOMER.COM	user1@Customer.com	USER1@CUSTOMER.COM	f	AQAAAAIAAYagAAAAEARwKOc3v5BoBF2KNW5j1c1JrhkKAyVclY7nUOg/++8LEoD/gCjuB+UCd6lMCgDSnA==	OQUWZVH3XB5NWPYSFZ5PDLBDRUTRPAS3	870a240a-8a69-49e8-b9a2-6613483407d3	+345678	f	f	\N	t	0	f	\N	\N
\.


--
-- TOC entry 5436 (class 0 OID 58582)
-- Dependencies: 268
-- Data for Name: DependentQuestions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."DependentQuestions" ("DependentQId", "QOptionId", "NextQuestionId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
187	1162	693	t	2026-01-26 21:17:45.155393+05	2026-01-26 21:17:45.155532+05	\N	\N
188	1178	700	t	2026-01-26 21:25:02.315046+05	2026-01-26 21:25:02.315048+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
189	1187	703	t	2026-01-26 21:25:25.734695+05	2026-01-26 21:25:25.734696+05	\N	\N
190	1199	709	t	2026-02-04 21:45:06.595235+05	2026-02-04 21:45:06.595381+05	\N	\N
191	1207	713	t	2026-02-04 21:59:48.216398+05	2026-02-04 21:59:48.216399+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
192	1215	717	t	2026-02-04 23:30:00.294737+05	2026-02-04 23:30:00.294737+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
193	1235	727	t	2026-02-07 22:53:17.10338+05	2026-02-07 22:53:17.103438+05	\N	\N
194	1246	733	t	2026-02-10 18:31:37.703055+05	2026-02-10 18:31:37.703145+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
195	1252	737	t	2026-02-10 20:00:19.537909+05	2026-02-10 20:00:19.537964+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
196	1260	741	t	2026-02-10 20:02:19.738217+05	2026-02-10 20:02:19.738217+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
197	1268	745	t	2026-02-10 20:03:04.129121+05	2026-02-10 20:03:04.129122+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
198	1276	749	t	2026-02-10 20:04:17.329713+05	2026-02-10 20:04:17.329713+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca
\.


--
-- TOC entry 5438 (class 0 OID 58591)
-- Dependencies: 270
-- Data for Name: FieldTypes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."FieldTypes" ("FieldTypeId", "FieldName", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "DisplayName") FROM stdin;
1	Select list	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Dropdown list
2	Checkboxes	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Checkboxes
3	Radio buttons	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Radio buttons
4	Table	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Table
5	Input	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Numeric Input
6	Input	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Text Input
7	Input	t	2025-08-31 01:03:07.915+05	\N	\N	\N	Date Input
\.


--
-- TOC entry 5440 (class 0 OID 58601)
-- Dependencies: 272
-- Data for Name: Iframes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Iframes" ("PID", "WebsiteName", "Link", "TempVersionId", "Status", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "Partial_key", "Full_key", "TemplateId", "BusinessId") FROM stdin;
141	new Iframe	https://localhost:7222/page/template/default/bmV3IElmcmFtZeY2KrF5ft7Jrl2IDh5nNtJ7ykZmYN3gWpe-3C2B895Gm0n2nypsPJr0OhtF2mcRuosXEMCwvlb9	387	Active	t	2026-02-09 19:09:31.513996+05	\N	\N	\N	k5HQfxMSHAsllMomtL1dGXjEqGV6Jktj	k5HQfxMSHAsllMomtL1dGXjEqGV6Jktjm0n2nypsPJr0OhtF2mcRuosXEMCwvlb9	234	1
142	123	https://localhost:7222/page/template/default/MTIzB5BeVcg8d2JjydhO6jLdOhYChiupaKjBfINxy8ykDA4Rlxna8cOiUraeTemFyUJ26RkB4HdBnWV	385	Active	t	2026-02-09 19:24:46.045627+05	\N	\N	\N	TCZmAcmBZP8lsCV0IJT4QQzfUhCfinmh	TCZmAcmBZP8lsCV0IJT4QQzfUhCfinmhRlxna8cOiUraeTemFyUJ26RkB4HdBnWV	233	1
143	new	https://localhost:7222/page/template/default/bmV3PmZi6oWorMmY8l-yaU6ldgKHkRs0COW8zlPmCSafXCEyBUifNhQH6iz3gNZ5tMuVBq51pdcaXmC	387	Active	t	2026-02-10 18:30:00.458073+05	\N	\N	\N	7BNplnt83a6P2go907wsZR2NHELUkWHU	7BNplnt83a6P2go907wsZR2NHELUkWHUyBUifNhQH6iz3gNZ5tMuVBq51pdcaXmC	234	1
144	dsf	https://localhost:7222/page/template/default/ZHNmoWpbtiTOqUD70KmkAPEo8sur48x-_VwPnAw6fxYfVX8I9ESOF3rCKEWb97U11y4AVS2hx2cnU43	402	Active	t	2026-02-22 19:41:41.812917+05	\N	\N	\N	MYNEwQDlGDXQcl7fY0jPcGWXQcg0P8ET	MYNEwQDlGDXQcl7fY0jPcGWXQcg0P8ETI9ESOF3rCKEWb97U11y4AVS2hx2cnU43	237	1
145	sdv	https://localhost:7222/page/template/default/c2R2HCxewWIEBhVQtIk10AQOZeVdVhDeOtSktnkivVfHO_UnWxpBSkW2Eu1jT9cAMaX8eGPtTje3TlH	389	Active	t	2026-02-22 19:49:09.359918+05	\N	\N	\N	ycGJFWCZ2CVvjkY4OFKZrmN9yWzV4PIj	ycGJFWCZ2CVvjkY4OFKZrmN9yWzV4PIjnWxpBSkW2Eu1jT9cAMaX8eGPtTje3TlH	236	1
\.


--
-- TOC entry 5442 (class 0 OID 58613)
-- Dependencies: 274
-- Data for Name: MetafieldAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."MetafieldAnswers" (metafield_answer_id, template_version_id, quote_id, metafield_id, metafield_input) FROM stdin;
99	395	675	419	df
100	395	676	419	hgv
101	395	676	420	nb
\.


--
-- TOC entry 5444 (class 0 OID 58623)
-- Dependencies: 276
-- Data for Name: Metafields; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Metafields" ("PID", "TempVersionId", "Name", "FieldType", "Tag", "Visibility", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "TableStyle", "MetafieldGuid") FROM stdin;
397	374	Metafield 1	Single Line Text	Tag 1	Customer and Admin	t	2026-02-04 21:38:47.03162+05	\N	7	\N	\N	1f98e1c5-f86e-44f5-89ce-5cd416c4e45c
398	374	Metafield 2	Single Line Text	TIMEFRAME	Customer and Admin	t	2026-02-04 21:57:55.34465+05	\N	7	\N	\N	445ac7c7-cff7-4aad-9c00-f04a96c546f2
399	374	Metafield 3	Single Line Text	TimeFrame	Admin only	t	2026-02-04 21:57:55.365873+05	\N	7	\N	\N	7e77b70e-02ac-40a5-8f2c-d6c6ccd38178
400	375	Metafield 1	Single Line Text	Tag 1	Customer and Admin	t	2026-02-04 21:59:47.881487+05	2026-02-04 21:59:47.881684+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1f98e1c5-f86e-44f5-89ce-5cd416c4e45c
401	375	Metafield 2	Single Line Text	TIMEFRAME	Customer and Admin	t	2026-02-04 21:59:47.882249+05	2026-02-04 21:59:47.88225+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	445ac7c7-cff7-4aad-9c00-f04a96c546f2
402	375	Metafield 3.0	Single Line Text	TimeFrame	Admin only	t	2026-02-04 21:59:47.882302+05	2026-02-04 21:59:48.323152+05	7	7	\N	7e77b70e-02ac-40a5-8f2c-d6c6ccd38178
403	376	Metafield 1	Single Line Text	Tag 1	Customer and Admin	t	2026-02-04 23:30:00.150362+05	2026-02-04 23:30:00.150363+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1f98e1c5-f86e-44f5-89ce-5cd416c4e45c
404	376	Metafield 2	Single Line Text	TIMEFRAME	Customer and Admin	t	2026-02-04 23:30:00.150517+05	2026-02-04 23:30:00.150517+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	445ac7c7-cff7-4aad-9c00-f04a96c546f2
405	376	Metafield 3.0	Single Line Text	TimeFrame	Admin only	t	2026-02-04 23:30:00.150545+05	2026-02-04 23:30:00.150545+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	7e77b70e-02ac-40a5-8f2c-d6c6ccd38178
406	381	Metafield 1	Single Line Text	Tag 1	Customer and Admin	t	2026-02-05 21:32:22.295732+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	1f98e1c5-f86e-44f5-89ce-5cd416c4e45c
407	381	Metafield 2	Single Line Text	TIMEFRAME	Customer and Admin	t	2026-02-05 21:32:22.296025+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	445ac7c7-cff7-4aad-9c00-f04a96c546f2
408	381	Metafield 3.0	Single Line Text	TimeFrame	Admin only	t	2026-02-05 21:32:22.296027+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	7e77b70e-02ac-40a5-8f2c-d6c6ccd38178
409	387	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-07 22:53:31.272345+05	\N	7	\N	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
410	387	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-07 22:53:38.812256+05	\N	7	\N	\N	9349861e-e164-4f2f-b2a3-8612408937ff
411	391	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-10 18:31:37.542755+05	2026-02-10 18:31:37.542895+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
412	391	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-10 18:31:37.544366+05	2026-02-10 18:31:37.544366+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	9349861e-e164-4f2f-b2a3-8612408937ff
413	392	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-10 20:00:19.415588+05	2026-02-10 20:00:19.415723+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
414	392	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-10 20:00:19.417674+05	2026-02-10 20:00:19.417675+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	9349861e-e164-4f2f-b2a3-8612408937ff
415	393	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-10 20:02:19.675405+05	2026-02-10 20:02:19.675405+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
416	393	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-10 20:02:19.675571+05	2026-02-10 20:02:19.675571+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	9349861e-e164-4f2f-b2a3-8612408937ff
417	394	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-10 20:03:04.032321+05	2026-02-10 20:03:04.032321+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
418	394	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-10 20:03:04.032669+05	2026-02-10 20:03:04.032669+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	9349861e-e164-4f2f-b2a3-8612408937ff
419	395	Metafield 1	Single Line Text	\N	Customer and Admin	t	2026-02-10 20:04:17.260867+05	2026-02-10 20:04:17.260868+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c553f0fe-9cb3-44a6-bbb4-e0d56cacabb9
420	395	Metafield 2	Single Line Text	\N	Admin only	t	2026-02-10 20:04:17.260976+05	2026-02-10 20:04:17.260976+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	9349861e-e164-4f2f-b2a3-8612408937ff
421	398	Meta 1	Single Line Text	abc	Customer and Admin	t	2026-02-10 21:01:40.897165+05	\N	7	\N	\N	91f88d46-1a66-417f-a9dc-a19366cba364
422	399	meta 1	Single Line Text	qwe	Customer and Admin	t	2026-02-10 21:02:17.779231+05	\N	7	\N	\N	e1a8ad7f-ae15-43da-9d62-74c3efb68324
423	403	meta 1	Single Line Text	qwe	Customer and Admin	t	2026-02-17 02:55:37.178252+05	2026-02-17 02:55:37.178432+05	7	29a8a07e-094a-48ea-82af-7221f1175cca	\N	e1a8ad7f-ae15-43da-9d62-74c3efb68324
424	403	new	Single Line Text	\N	Admin only	t	2026-02-17 02:55:37.555081+05	\N	7	\N	\N	1d146cfc-6a48-4f5a-b584-0c64fc789124
\.


--
-- TOC entry 5446 (class 0 OID 58639)
-- Dependencies: 278
-- Data for Name: QuestionGroups; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionGroups" ("QuestionGroupId", "Name", "DisplayOrder", "TemplateId", "IsActive", "CreatedAt", "TemplateVersionId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "GroupGuid") FROM stdin;
474	Group 1	1	223	t	2026-01-26 21:10:48.698632+05	371	\N	\N	\N	1	0454d374-6c6b-476a-97b0-b64e0a0d2ae8
475	Group 2	2	223	t	2026-01-26 21:10:58.347243+05	371	\N	\N	\N	1	b7bad921-32ef-449e-a96d-ac1708a6ac32
476	Group 1	1	223	t	\N	372	2026-01-26 21:25:01.225688+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	0454d374-6c6b-476a-97b0-b64e0a0d2ae8
477	Group 2	2	223	t	\N	372	2026-01-26 21:25:01.816317+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b7bad921-32ef-449e-a96d-ac1708a6ac32
478	Group 1	1	224	t	2026-02-04 20:00:49.03022+05	373	\N	\N	\N	1	7f383143-5ebb-4bbf-97a2-73539ef3ca65
479	Group 2	2	224	t	2026-02-04 20:00:53.677731+05	373	\N	\N	\N	1	aca0110a-273b-4b2e-8875-8440a738250c
480	Group 1	1	225	t	2026-02-04 21:36:20.499046+05	374	\N	\N	\N	1	c6c8a30b-7c85-4b0a-aceb-4489cf9f4795
481	Group 2	2	225	t	2026-02-04 21:36:25.534309+05	374	\N	\N	\N	1	1def5821-e9d3-4293-989b-4baf0624315d
482	Group 1	1	225	t	\N	375	2026-02-04 21:59:47.919371+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c6c8a30b-7c85-4b0a-aceb-4489cf9f4795
483	Group 2	2	225	t	\N	375	2026-02-04 21:59:48.071436+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	1def5821-e9d3-4293-989b-4baf0624315d
484	Group 1	1	225	t	\N	376	2026-02-04 23:30:00.159522+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c6c8a30b-7c85-4b0a-aceb-4489cf9f4795
485	Group 2	2	225	t	\N	376	2026-02-04 23:30:00.229584+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	1def5821-e9d3-4293-989b-4baf0624315d
486	Group 1	1	225	t	2026-02-05 21:32:22.285791+05	381	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	c6c8a30b-7c85-4b0a-aceb-4489cf9f4795
487	Group 2	2	225	t	2026-02-05 21:32:22.286214+05	381	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	1def5821-e9d3-4293-989b-4baf0624315d
488	Group 1	1	231	t	2026-02-05 21:50:37.892535+05	383	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	865792cd-6df9-487f-83df-7e00ba820c40
489	Group 1	2	231	t	2026-02-05 21:57:57.173368+05	383	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	07c61905-7660-4039-8397-02d105307115
490	Group 1	3	231	t	2026-02-05 21:58:22.546889+05	383	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	89a8aa1a-eb11-4812-a0ff-9497f6a3783a
491	Group 1	1	232	t	2026-02-05 21:59:55.178852+05	384	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	e9a18d83-79f8-440a-957c-13bf3a912723
492	Group 1	1	233	t	2026-02-07 01:24:59.454142+05	385	\N	\N	\N	1	6ce8bdd1-cca6-405c-a667-8f85c1b9e036
493	Group 1	1	234	t	2026-02-07 22:50:16.667686+05	386	\N	\N	\N	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
494	Group 2	2	234	t	2026-02-07 22:50:23.980058+05	386	\N	\N	\N	1	b87dc1c0-432e-4b82-befe-acf2014c1637
495	Group 3	3	234	t	2026-02-07 22:50:28.448748+05	386	\N	\N	\N	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
496	Group 1	1	234	t	\N	387	2026-02-07 22:52:05.567645+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
497	Group 2	2	234	t	\N	387	2026-02-07 22:52:05.584639+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
498	Group 3	3	234	t	\N	387	2026-02-07 22:52:05.58773+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
499	Group 1	1	236	t	2026-02-09 22:13:55.156764+05	389	\N	\N	\N	1	cf45a306-1475-4843-9449-45a151c4b194
500	group 1	1	235	t	2026-02-09 22:57:44.763784+05	388	\N	\N	\N	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
501	Group 1	2	235	t	2026-02-09 22:59:51.436907+05	388	\N	\N	\N	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
502	group 1	1	235	t	\N	390	2026-02-10 00:15:37.240475+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
503	Group 1	2	235	t	\N	390	2026-02-10 00:15:37.278904+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
504	Group 1	1	234	t	\N	391	2026-02-10 18:31:37.580266+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
505	Group 2	2	234	t	\N	391	2026-02-10 18:31:37.656145+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
506	Group 3	3	234	t	\N	391	2026-02-10 18:31:37.68086+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
507	Group 1	4	234	t	2026-02-10 18:31:37.786243+05	391	\N	\N	\N	1	2cb56f5a-ed60-40c9-9c99-e4676b3d35d1
508	Group 1	1	234	t	\N	392	2026-02-10 20:00:19.433546+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
509	Group 2	2	234	t	\N	392	2026-02-10 20:00:19.49272+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
510	Group 3	3	234	t	\N	392	2026-02-10 20:00:19.520932+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
511	Group 1	4	234	t	\N	392	2026-02-10 20:00:19.524684+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	2cb56f5a-ed60-40c9-9c99-e4676b3d35d1
512	Group 1	1	234	t	\N	393	2026-02-10 20:02:19.680448+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
513	Group 2	2	234	t	\N	393	2026-02-10 20:02:19.708669+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
514	Group 3	3	234	t	\N	393	2026-02-10 20:02:19.731995+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
515	Group 1	4	234	t	\N	393	2026-02-10 20:02:19.734892+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	2cb56f5a-ed60-40c9-9c99-e4676b3d35d1
516	Group 1	1	234	t	\N	394	2026-02-10 20:03:04.039621+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
517	Group 2	2	234	t	\N	394	2026-02-10 20:03:04.07164+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
518	Group 3	3	234	t	\N	394	2026-02-10 20:03:04.122047+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
519	Group 1	4	234	t	\N	394	2026-02-10 20:03:04.124762+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	2cb56f5a-ed60-40c9-9c99-e4676b3d35d1
520	Group 1	1	234	t	\N	395	2026-02-10 20:04:17.268439+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	f23b3bfd-27d3-4e70-a038-c029e1ab5a90
521	Group 2	2	234	t	\N	395	2026-02-10 20:04:17.305073+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	b87dc1c0-432e-4b82-befe-acf2014c1637
522	Group 3	3	234	t	\N	395	2026-02-10 20:04:17.321875+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ecc9eff-b21a-4c8e-bf2f-40d2a77fcc02
523	Group 1	4	234	t	\N	395	2026-02-10 20:04:17.325825+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	2cb56f5a-ed60-40c9-9c99-e4676b3d35d1
524	group 1	1	235	t	\N	396	2026-02-10 20:05:08.091619+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
525	Group 1	2	235	t	\N	396	2026-02-10 20:05:08.114451+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
527	Group 1	2	235	t	\N	397	2026-02-10 20:54:59.470213+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
526	group 1jj	1	235	t	\N	397	2026-02-10 20:54:59.535487+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
528	Group 1	1	233	t	\N	398	2026-02-10 21:01:40.847117+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6ce8bdd1-cca6-405c-a667-8f85c1b9e036
529	group 1jj	1	235	t	\N	399	2026-02-10 21:02:17.746295+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
530	Group 1	2	235	t	\N	399	2026-02-10 21:02:17.766904+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
531	group 1	1	237	t	2026-02-11 21:44:33.113277+05	400	\N	\N	\N	1	c3aecc31-72fb-4234-8aa4-58d6da096e73
532	group 1	1	237	t	\N	401	2026-02-11 21:45:29.319827+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c3aecc31-72fb-4234-8aa4-58d6da096e73
533	group 1	1	237	t	\N	402	2026-02-11 21:46:32.167156+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c3aecc31-72fb-4234-8aa4-58d6da096e73
534	group 1jj	1	235	t	\N	403	2026-02-17 02:55:37.204938+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	73bc4c51-75d1-476a-bb4f-5652dd365d9b
535	Group 1	2	235	t	\N	403	2026-02-17 02:55:37.385704+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	be06d5cf-ae23-4ad5-afc8-2c8adf83d8f4
536	group 1	1	237	t	\N	404	2026-03-10 01:53:17.382612+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c3aecc31-72fb-4234-8aa4-58d6da096e73
\.


--
-- TOC entry 5448 (class 0 OID 58653)
-- Dependencies: 280
-- Data for Name: QuestionOptions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionOptions" ("QOptionId", "OptionText", "QuestionId", "DisplayOrder", "FieldTypeId", "MaterialCompId", "IsActive", "CreatedAt", "ModifiedAt", "MatCompName", "CreatedById", "ModifiedById", "OptionGuid") FROM stdin;
1158	List 1 with Material	690	1	\N	37	t	2026-01-26 21:13:37.052524+05	2026-01-26 21:13:37.052918+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	96bb2a83-7313-43e9-ba82-1ae4eeedc11f
1159	List 2 with Component	690	2	\N	24	t	2026-01-26 21:13:37.217548+05	2026-01-26 21:13:37.217549+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6114ab3d-afee-46a0-a2af-77ba73d74370
1160	List 3 with Nothing	690	3	\N	\N	t	2026-01-26 21:13:37.254355+05	2026-01-26 21:13:37.254357+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	f4c8a9d2-355d-41a2-b943-a04f59fc059b
1161	Checkbox 1 with Material	691	1	\N	37	t	2026-01-26 21:15:15.464286+05	2026-01-26 21:15:15.464288+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4b8e8e34-bb2c-4514-8a86-289ea3225432
1163	Radio 1 with Material	692	1	\N	37	t	2026-01-26 21:16:17.282294+05	2026-01-26 21:16:17.282297+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	9d0da2c5-cd26-4de5-ad08-20dd42f788f2
1164	Radio 2 with Component	692	2	\N	24	t	2026-01-26 21:16:17.323244+05	2026-01-26 21:16:17.323246+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	bf5417e6-85b4-4afe-88a2-46f060cf3c74
1165	List 1 with Material	693	1	\N	37	t	2026-01-26 21:17:19.773056+05	2026-01-26 21:17:19.773059+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1962b9d8-68ee-4398-b28d-a528bc958781
1166	List 2 with Component	693	2	\N	24	t	2026-01-26 21:17:19.821673+05	2026-01-26 21:17:19.821675+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	88139fb8-7f0a-4292-8e6b-62205f8c0df5
1162	Checkbox 2 with Component and dependent	691	2	\N	25	t	2026-01-26 21:15:15.506519+05	2026-01-26 21:17:45.028138+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d98d8fca-420e-40a3-86f0-bbf7a6b2af4c
1167	Table 1 with Material 1	694	1	\N	37	t	2026-01-26 21:19:06.218479+05	2026-01-26 21:19:06.21848+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	e19213d9-30a4-4d34-b41f-21e36df10483
1168	Table 2 with Material 2	694	2	\N	38	t	2026-01-26 21:19:06.240092+05	2026-01-26 21:19:06.240093+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	3f2dcdfc-e1d4-4d76-8003-2cd676ffa0fb
1169	Table 3 with Material 3	694	3	\N	39	t	2026-01-26 21:19:06.26135+05	2026-01-26 21:19:06.261352+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	5d26b46b-061d-491e-a4e3-d73170a7d35c
1170	List 1 with Material	695	1	\N	37	t	2026-01-26 21:20:16.801459+05	2026-01-26 21:20:16.80146+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4dc801c0-f1f2-4e95-ae43-e7c6253e67ea
1172	CheckBox 1 With material	696	1	\N	37	t	2026-01-26 21:21:15.307687+05	2026-01-26 21:21:15.307688+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6f587cea-d65e-4fa2-97d6-ec4f43d5f13f
1173	Checkbox 2 with Component	696	2	\N	26	t	2026-01-26 21:21:15.384433+05	2026-01-26 21:21:15.384433+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	be6f0d6a-3b6f-4d62-816e-968a66c34711
1171	List 2 with Component and dependent	695	2	\N	25	t	2026-01-26 21:20:16.846973+05	2026-01-26 21:21:34.066383+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4b275470-911d-47f2-8f38-e6aea302f097
1174	List 1 with Material	697	1	\N	37	t	\N	2026-01-26 21:25:01.33355+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	96bb2a83-7313-43e9-ba82-1ae4eeedc11f
1175	List 2 with Component	697	2	\N	24	t	\N	2026-01-26 21:25:01.355499+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6114ab3d-afee-46a0-a2af-77ba73d74370
1176	List 3 with Nothing	697	3	\N	\N	t	\N	2026-01-26 21:25:01.376515+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	f4c8a9d2-355d-41a2-b943-a04f59fc059b
1179	Radio 1 with Material	699	1	\N	37	t	\N	2026-01-26 21:25:01.59845+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	9d0da2c5-cd26-4de5-ad08-20dd42f788f2
1180	Radio 2 with Component	699	2	\N	24	t	\N	2026-01-26 21:25:01.622375+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	bf5417e6-85b4-4afe-88a2-46f060cf3c74
1181	List 1 with Material	700	1	\N	37	t	\N	2026-01-26 21:25:01.723157+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1962b9d8-68ee-4398-b28d-a528bc958781
1182	List 2 with Component	700	2	\N	24	t	\N	2026-01-26 21:25:01.776579+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	88139fb8-7f0a-4292-8e6b-62205f8c0df5
1183	Table 1 with Material 1	701	1	\N	37	t	\N	2026-01-26 21:25:01.978081+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	e19213d9-30a4-4d34-b41f-21e36df10483
1184	Table 2 with Material 2	701	2	\N	38	t	\N	2026-01-26 21:25:02.005988+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	3f2dcdfc-e1d4-4d76-8003-2cd676ffa0fb
1185	Table 3 with Material 3	701	3	\N	39	t	\N	2026-01-26 21:25:02.02838+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	5d26b46b-061d-491e-a4e3-d73170a7d35c
1188	CheckBox 1 With material	703	1	\N	37	t	\N	2026-01-26 21:25:02.171174+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6f587cea-d65e-4fa2-97d6-ec4f43d5f13f
1189	Checkbox 2 with Component	703	2	\N	26	t	\N	2026-01-26 21:25:02.195649+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	be6f0d6a-3b6f-4d62-816e-968a66c34711
1177	Checkbox 1 with Material	698	1	\N	37	t	\N	2026-01-26 21:25:02.577325+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4b8e8e34-bb2c-4514-8a86-289ea3225432
1178	Checkbox 2 with Component and dependent	698	2	\N	25	t	\N	2026-01-26 21:25:02.639493+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d98d8fca-420e-40a3-86f0-bbf7a6b2af4c
1186	List 1 with Material	702	1	\N	37	t	\N	2026-01-26 21:25:25.540745+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4dc801c0-f1f2-4e95-ae43-e7c6253e67ea
1187	List 2 with Component and dependent	702	2	\N	25	t	\N	2026-01-26 21:25:25.587415+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4b275470-911d-47f2-8f38-e6aea302f097
1190	Answer 1	704	1	\N	37	t	2026-02-04 20:01:16.184437+05	2026-02-04 20:01:16.184548+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22a34d08-74d1-4095-82d9-d14dfeae5ba3
1191	Answer 2	704	2	\N	24	t	2026-02-04 20:01:16.309914+05	2026-02-04 20:01:16.309915+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	3e912de4-f7cf-4abe-93d8-353d44af5acb
1192	Checkbox 1	705	1	\N	37	t	2026-02-04 20:01:59.961016+05	2026-02-04 20:01:59.961017+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	46ae7d46-286e-4f57-b725-8efdb2136268
1193	Checkbox 2 with Nothing	705	2	\N	\N	t	2026-02-04 20:01:59.98026+05	2026-02-04 20:01:59.98026+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	251a858a-7f9d-46ed-a3af-0251ef194e3d
1194	Answer 1 with Material	706	1	\N	37	t	2026-02-04 21:37:32.895332+05	2026-02-04 21:37:32.895466+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	5543affc-5f34-438d-bd75-e528607d6f61
1195	Answer 2 with Component	706	2	\N	24	t	2026-02-04 21:37:33.085386+05	2026-02-04 21:37:33.085387+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	0b356f59-ad35-40ec-aa42-f929d8db42aa
1196	Answer 1 with Material	707	1	\N	37	t	2026-02-04 21:38:30.76729+05	2026-02-04 21:38:30.767292+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4914c697-37d2-4fd3-8e14-bc05d164c351
1197	Answer 2 with Component	707	2	\N	26	t	2026-02-04 21:38:30.80029+05	2026-02-04 21:38:30.800291+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3977567-8c8c-408a-9997-04682f04758c
1198	Answer 1 with Material	708	1	\N	38	t	2026-02-04 21:42:42.309426+05	2026-02-04 21:42:42.309427+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6927dc33-4721-4b9f-8b1e-01bbe5727997
1200	List 1 with material	709	1	\N	38	t	2026-02-04 21:43:37.645263+05	2026-02-04 21:43:37.645265+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	c11f18d8-80af-4d7c-8c45-e6a8bffa83db
1201	List 2 with Component	709	2	\N	26	t	2026-02-04 21:43:37.660364+05	2026-02-04 21:43:37.660366+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4dc7e108-96c8-4a80-a064-95c13e30e885
1199	Answer 2 with Component and have dependent	708	2	\N	26	t	2026-02-04 21:42:42.336668+05	2026-02-04 21:45:06.502412+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	90b5ca1f-ca2e-4222-807d-72dd84233ff4
1202	Answer 1 with Material	710	1	\N	37	t	\N	2026-02-04 21:59:47.969522+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	5543affc-5f34-438d-bd75-e528607d6f61
1203	Answer 2 with Component	710	2	\N	24	t	\N	2026-02-04 21:59:47.987439+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	0b356f59-ad35-40ec-aa42-f929d8db42aa
1204	Answer 1 with Material	711	1	\N	37	t	\N	2026-02-04 21:59:48.033866+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4914c697-37d2-4fd3-8e14-bc05d164c351
1205	Answer 2 with Component	711	2	\N	26	t	\N	2026-02-04 21:59:48.049908+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3977567-8c8c-408a-9997-04682f04758c
1206	Answer 1 with Material	712	1	\N	38	t	\N	2026-02-04 21:59:48.113053+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6927dc33-4721-4b9f-8b1e-01bbe5727997
1207	Answer 2 with Component and have dependent	712	2	\N	26	t	\N	2026-02-04 21:59:48.128225+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	90b5ca1f-ca2e-4222-807d-72dd84233ff4
1208	List 1 with material	713	1	\N	38	t	\N	2026-02-04 21:59:48.161928+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	c11f18d8-80af-4d7c-8c45-e6a8bffa83db
1209	List 2 with Component	713	2	\N	26	t	\N	2026-02-04 21:59:48.170064+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4dc7e108-96c8-4a80-a064-95c13e30e885
1212	Answer 1 with Material	715	1	\N	37	t	\N	2026-02-04 23:30:00.208706+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4914c697-37d2-4fd3-8e14-bc05d164c351
1213	Answer 2 with Component	715	2	\N	26	t	\N	2026-02-04 23:30:00.218427+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3977567-8c8c-408a-9997-04682f04758c
1214	Answer 1 with Material	716	1	\N	38	t	\N	2026-02-04 23:30:00.251146+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6927dc33-4721-4b9f-8b1e-01bbe5727997
1215	Answer 2 with Component and have dependent	716	2	\N	26	t	\N	2026-02-04 23:30:00.254222+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	90b5ca1f-ca2e-4222-807d-72dd84233ff4
1216	List 1 with material	717	1	\N	38	t	\N	2026-02-04 23:30:00.278383+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	c11f18d8-80af-4d7c-8c45-e6a8bffa83db
1217	List 2 with Component	717	2	\N	26	t	\N	2026-02-04 23:30:00.28137+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	4dc7e108-96c8-4a80-a064-95c13e30e885
1210	Answer 1 with Material	714	1	\N	37	t	\N	2026-02-04 23:30:00.326463+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	5543affc-5f34-438d-bd75-e528607d6f61
1211	Answer 2 with Component	714	2	\N	24	t	\N	2026-02-04 23:30:00.333975+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	0b356f59-ad35-40ec-aa42-f929d8db42aa
1218	Answer 3 For Version 3	714	3	\N	\N	t	2026-02-04 23:30:00.347152+05	2026-02-04 23:30:00.347152+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	c4f39593-0b82-4539-91b1-6c0b879d5519
1219	Answer 1 with Material	718	1	\N	37	t	2026-02-05 21:32:22.292707+05	\N	Material	29a8a07e-094a-48ea-82af-7221f1175cca	\N	5543affc-5f34-438d-bd75-e528607d6f61
1220	Answer 2 with Component	718	2	\N	24	t	2026-02-05 21:32:22.292965+05	\N	Component	29a8a07e-094a-48ea-82af-7221f1175cca	\N	0b356f59-ad35-40ec-aa42-f929d8db42aa
1221	Answer 3 For Version 3	718	3	\N	\N	t	2026-02-05 21:32:22.292966+05	\N		29a8a07e-094a-48ea-82af-7221f1175cca	\N	c4f39593-0b82-4539-91b1-6c0b879d5519
1222	Answer 1 with Material	719	1	\N	37	t	2026-02-05 21:32:22.293007+05	\N	Material	29a8a07e-094a-48ea-82af-7221f1175cca	\N	4914c697-37d2-4fd3-8e14-bc05d164c351
1223	Answer 2 with Component	719	2	\N	26	t	2026-02-05 21:32:22.293008+05	\N	Component	29a8a07e-094a-48ea-82af-7221f1175cca	\N	d3977567-8c8c-408a-9997-04682f04758c
1224	Answer 1 with Material	720	1	\N	38	t	2026-02-05 21:32:22.29301+05	\N	Material	29a8a07e-094a-48ea-82af-7221f1175cca	\N	6927dc33-4721-4b9f-8b1e-01bbe5727997
1225	Answer 2 with Component and have dependent	720	2	\N	26	t	2026-02-05 21:32:22.29301+05	\N	Component	29a8a07e-094a-48ea-82af-7221f1175cca	\N	90b5ca1f-ca2e-4222-807d-72dd84233ff4
1226	List 1 with material	721	1	\N	38	t	2026-02-05 21:32:22.293052+05	\N	Material	29a8a07e-094a-48ea-82af-7221f1175cca	\N	c11f18d8-80af-4d7c-8c45-e6a8bffa83db
1227	List 2 with Component	721	2	\N	26	t	2026-02-05 21:32:22.293053+05	\N	Component	29a8a07e-094a-48ea-82af-7221f1175cca	\N	4dc7e108-96c8-4a80-a064-95c13e30e885
1228	List 1	722	1	\N	37	t	2026-02-07 01:25:30.336506+05	2026-02-07 01:25:30.336651+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	402a9ed7-815d-443f-855e-045b37a8d12e
1229	List 2	722	2	\N	24	t	2026-02-07 01:25:30.590454+05	2026-02-07 01:25:30.590456+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	31ef88f2-29b7-468c-b0fd-a735d2d470d9
1230	Checkbox 1	723	1	\N	37	t	2026-02-07 01:25:57.093522+05	2026-02-07 01:25:57.093522+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22d71106-c89d-4387-afd6-8c58f9544b61
1231	Checkbox 2	723	2	\N	24	t	2026-02-07 01:25:57.137584+05	2026-02-07 01:25:57.137586+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	b5f4f93f-6c95-4e22-af4b-29d9b1722a2d
1232	Answer 1.1.1	724	1	\N	37	t	2026-02-07 22:51:10.390217+05	2026-02-07 22:51:10.390277+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1233	Answer 1.1.2	724	2	\N	26	t	2026-02-07 22:51:10.431925+05	2026-02-07 22:51:10.431926+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1236	Answer 2.2.1	726	1	\N	\N	t	2026-02-07 22:52:05.622957+05	2026-02-07 22:52:30.387269+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1237	Answer 2.2.2	726	2	\N	37	t	2026-02-07 22:52:05.628651+05	2026-02-07 22:52:30.394262+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1238	Answer 1.2.1	727	1	\N	38	t	2026-02-07 22:53:10.800929+05	2026-02-07 22:53:10.800967+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1234	Answer 1.1.1	725	1	\N	37	t	\N	2026-02-07 22:53:17.059578+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1235	Answer 1.1.2	725	2	\N	26	t	\N	2026-02-07 22:53:17.064777+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1239	Answer 1	728	1	\N	\N	t	2026-02-09 22:58:29.428628+05	2026-02-09 22:58:29.428686+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1240	a1	728	2	\N	\N	t	2026-02-09 23:00:32.595522+05	2026-02-09 23:00:32.595523+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1241	a1	729	1	\N	37	t	2026-02-09 23:05:30.98406+05	2026-02-09 23:05:30.984061+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1242	Answer 1	730	1	\N	\N	t	\N	2026-02-10 00:15:37.263238+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1243	a1	730	2	\N	\N	t	\N	2026-02-10 00:15:37.266878+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1244	a1	731	1	\N	37	t	\N	2026-02-10 00:15:37.276428+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1245	Answer 1.1.1	732	1	\N	37	t	\N	2026-02-10 18:31:37.621081+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1246	Answer 1.1.2	732	2	\N	26	t	\N	2026-02-10 18:31:37.630784+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1247	Answer 1.2.1	733	1	\N	38	t	\N	2026-02-10 18:31:37.64713+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1248	Answer 2.2.1	734	1	\N	\N	t	\N	2026-02-10 18:31:37.670563+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1249	Answer 2.2.2	734	2	\N	37	t	\N	2026-02-10 18:31:37.675318+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1250	Answe 1	735	1	\N	37	t	2026-02-10 18:32:16.350671+05	2026-02-10 18:32:16.350762+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	f16f267a-a163-4e0c-8de8-6aa5c03b464f
1251	Answer 1.1.1	736	1	\N	37	t	\N	2026-02-10 20:00:19.461433+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1252	Answer 1.1.2	736	2	\N	26	t	\N	2026-02-10 20:00:19.48398+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1254	Answer 2.2.1	738	1	\N	\N	t	\N	2026-02-10 20:00:19.509408+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1255	Answer 2.2.2	738	2	\N	37	t	\N	2026-02-10 20:00:19.512063+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1256	Answe 1	739	1	\N	37	t	\N	2026-02-10 20:00:19.518473+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	f16f267a-a163-4e0c-8de8-6aa5c03b464f
1253	Answer 1.2.1	737	1	\N	38	t	\N	2026-02-10 20:00:19.689437+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1257	1223331331131	737	2	\N	\N	t	2026-02-10 20:00:19.714614+05	2026-02-10 20:00:19.714833+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	e0c61eac-63c9-4902-ac6d-ee82829ab8f6
1258	a1	737	3	\N	\N	t	2026-02-10 20:00:19.721331+05	2026-02-10 20:00:19.721332+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	eb46a006-43b6-4154-b094-57f98e08e7f2
1259	Answer 1.1.1	740	1	\N	37	t	\N	2026-02-10 20:02:19.689323+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1260	Answer 1.1.2	740	2	\N	26	t	\N	2026-02-10 20:02:19.692276+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1262	1223331331131	741	2	\N	\N	t	\N	2026-02-10 20:02:19.773748+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	e0c61eac-63c9-4902-ac6d-ee82829ab8f6
1263	a1	741	3	\N	\N	t	\N	2026-02-10 20:02:19.777096+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	eb46a006-43b6-4154-b094-57f98e08e7f2
1270	1223331331131	745	2	\N	\N	t	\N	2026-02-10 20:03:04.064968+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	e0c61eac-63c9-4902-ac6d-ee82829ab8f6
1264	Answer 2.2.1	742	1	\N	\N	t	\N	2026-02-10 20:02:19.715923+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1269	Answer 1.2.1	745	1	\N	38	t	\N	2026-02-10 20:03:04.060909+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1268	Answer 1.1.2	744	2	\N	26	t	\N	2026-02-10 20:03:04.1585+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1279	a1	749	3	\N	\N	t	\N	2026-02-10 20:04:17.301726+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	eb46a006-43b6-4154-b094-57f98e08e7f2
1265	Answer 2.2.2	742	2	\N	37	t	\N	2026-02-10 20:02:19.719322+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1266	Answe 1	743	1	\N	37	t	\N	2026-02-10 20:02:19.728899+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	f16f267a-a163-4e0c-8de8-6aa5c03b464f
1261	Answer 1.2.1	741	1	\N	38	t	\N	2026-02-10 20:02:19.769058+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1271	a1	745	3	\N	\N	t	\N	2026-02-10 20:03:04.068199+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	eb46a006-43b6-4154-b094-57f98e08e7f2
1273	Answer 2.2.2	746	2	\N	37	t	\N	2026-02-10 20:03:04.097137+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1274	Answe 1	747	1	\N	37	t	\N	2026-02-10 20:03:04.119748+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	f16f267a-a163-4e0c-8de8-6aa5c03b464f
1267	Answer 1.1.1	744	1	\N	37	t	\N	2026-02-10 20:03:04.154775+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1280	Answer 2.2.1	750	1	\N	\N	t	\N	2026-02-10 20:04:17.312297+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1282	Answe 1	751	1	\N	37	t	\N	2026-02-10 20:04:17.319708+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	f16f267a-a163-4e0c-8de8-6aa5c03b464f
1272	Answer 2.2.1	746	1	\N	\N	t	\N	2026-02-10 20:03:04.091414+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	7a0ff953-9868-4dc2-8f8f-73b3ce34e813
1277	Answer 1.2.1	749	1	\N	38	t	\N	2026-02-10 20:04:17.292856+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	24ede0fa-1c0d-478e-807a-14d7d17c075c
1278	1223331331131	749	2	\N	\N	t	\N	2026-02-10 20:04:17.295865+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	e0c61eac-63c9-4902-ac6d-ee82829ab8f6
1281	Answer 2.2.2	750	2	\N	37	t	\N	2026-02-10 20:04:17.313891+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	49928be5-ea26-4e7a-8dd9-043a2ac3c417
1275	Answer 1.1.1	748	1	\N	37	t	\N	2026-02-10 20:04:17.361225+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	719cc9b4-6ef6-48ca-91b9-48824182a76d
1276	Answer 1.1.2	748	2	\N	26	t	\N	2026-02-10 20:04:17.366534+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	33bc51a5-9de4-4115-93b0-001e119a143b
1285	a1	753	1	\N	37	t	\N	2026-02-10 20:05:08.112042+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1283	Answer 1	752	1	\N	\N	t	\N	2026-02-10 20:05:08.164032+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1284	a1	752	2	\N	\N	t	\N	2026-02-10 20:05:08.169018+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1286	Answer 1	754	1	\N	\N	t	\N	2026-02-10 20:54:59.454942+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1287	a1	754	2	\N	\N	t	\N	2026-02-10 20:54:59.457668+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1288	a1	755	1	\N	37	t	\N	2026-02-10 20:54:59.466934+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1289	List 1	756	1	\N	37	t	\N	2026-02-10 21:01:40.856289+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	402a9ed7-815d-443f-855e-045b37a8d12e
1290	List 2	756	2	\N	24	t	\N	2026-02-10 21:01:40.858639+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	31ef88f2-29b7-468c-b0fd-a735d2d470d9
1291	Checkbox 1	757	1	\N	37	t	\N	2026-02-10 21:01:40.863541+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22d71106-c89d-4387-afd6-8c58f9544b61
1292	Checkbox 2	757	2	\N	24	t	\N	2026-02-10 21:01:40.865041+05	Component	\N	29a8a07e-094a-48ea-82af-7221f1175cca	b5f4f93f-6c95-4e22-af4b-29d9b1722a2d
1293	Answer 1	758	1	\N	\N	t	\N	2026-02-10 21:02:17.755532+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1294	a1	758	2	\N	\N	t	\N	2026-02-10 21:02:17.757788+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1295	a1	759	1	\N	37	t	\N	2026-02-10 21:02:17.764202+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1296	answer 1	760	1	\N	37	t	2026-02-11 21:44:52.232838+05	2026-02-11 21:44:52.232897+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3aa4dcb-3bcd-4068-b1ca-775eb3014cbb
1297	answer 1	761	1	\N	37	t	\N	2026-02-11 21:45:29.39208+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3aa4dcb-3bcd-4068-b1ca-775eb3014cbb
1298	answer 1	762	1	\N	37	t	\N	2026-02-11 21:46:32.178298+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3aa4dcb-3bcd-4068-b1ca-775eb3014cbb
1299	a1	763	1	\N	\N	t	2026-02-11 21:46:32.20949+05	2026-02-11 21:46:32.209491+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	06880a2a-c171-44c7-9248-aac0ca0cf3a2
1300	Answer 1	764	1	\N	\N	t	\N	2026-02-17 02:55:37.310403+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	6035af5a-071e-4ad1-ae46-a51714f07be2
1301	a1	764	2	\N	\N	t	\N	2026-02-17 02:55:37.361748+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	aec80fc2-38ff-41fb-af6f-cf44103859f8
1302	a1	765	1	\N	37	t	\N	2026-02-17 02:55:37.379368+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	ff22aa73-61da-4dcf-9288-917928d54f2a
1304	a1	767	1	\N	\N	t	\N	2026-03-10 01:53:17.481238+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	06880a2a-c171-44c7-9248-aac0ca0cf3a2
1303	answer 1	766	1	\N	37	t	\N	2026-03-10 01:53:17.6722+05	Material	\N	29a8a07e-094a-48ea-82af-7221f1175cca	d3aa4dcb-3bcd-4068-b1ca-775eb3014cbb
1305	ad	766	2	\N	\N	t	2026-03-10 01:53:17.693943+05	2026-03-10 01:53:17.694107+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	a14d714f-acb3-417e-8304-7ed903cf6326
\.


--
-- TOC entry 5450 (class 0 OID 58667)
-- Dependencies: 282
-- Data for Name: Questions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Questions" ("QuestionId", "Text", "IsRequired", "DisplayOrder", "QuestionGroupId", "TemplateId", "ParentId", "ValidFrom", "ValidTo", "TagId", "IsActive", "CreatedAt", "TemplateVersionId", "FieldTypeId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "QuestionGuid") FROM stdin;
690	Select the List	t	1	474	223	\N	\N	\N	\N	t	2026-01-26 21:13:36.852859+05	371	1	2026-01-26 21:13:36.852978+05	\N	\N	1	4e9db8e4-2984-495d-8da3-98ab27a88f90
692	Select the RdioButton	t	3	474	223	\N	\N	\N	\N	t	2026-01-26 21:16:17.227106+05	371	3	2026-01-26 21:16:17.227107+05	\N	\N	1	46e86803-fa47-4a7f-bab0-6729e6ab0f02
693	Select the dependent List	t	4	474	223	\N	\N	\N	\N	t	2026-01-26 21:17:19.721264+05	371	1	2026-01-26 21:17:19.721267+05	\N	\N	1	48ae5549-220a-4e8b-9243-c30ea716f6a8
691	Select the CheckBox	f	2	474	223	\N	\N	\N	\N	t	2026-01-26 21:15:15.428759+05	371	1	2026-01-26 21:17:45.004345+05	\N	\N	1	29f9418c-9ebf-4b20-9f63-d24935566749
694	Select the Table	f	5	475	223	\N	\N	\N	\N	t	2026-01-26 21:19:06.198835+05	371	4	2026-01-26 21:19:06.198838+05	\N	\N	1	ff864914-169f-4710-81b0-141c8a5422d6
696	Checkbox inside List	f	7	475	223	\N	\N	\N	\N	t	2026-01-26 21:21:15.20466+05	371	2	2026-01-26 21:21:15.204661+05	\N	\N	1	3fee2c29-fe3c-4f8e-9509-b0ddabf1dfed
695	Select the List with dependentQuestion	t	6	475	223	\N	\N	\N	\N	t	2026-01-26 21:20:16.752607+05	371	1	2026-01-26 21:21:34.041672+05	\N	\N	1	6bd03d6c-0ef2-473f-98c6-a98341d71c5a
697	Select the List	t	1	476	223	\N	\N	\N	\N	t	\N	372	1	2026-01-26 21:25:01.301388+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	4e9db8e4-2984-495d-8da3-98ab27a88f90
699	Select the RdioButton	t	3	476	223	\N	\N	\N	\N	t	\N	372	3	2026-01-26 21:25:01.557035+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	46e86803-fa47-4a7f-bab0-6729e6ab0f02
700	Select the dependent List	t	4	476	223	\N	\N	\N	\N	t	\N	372	1	2026-01-26 21:25:01.676172+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	48ae5549-220a-4e8b-9243-c30ea716f6a8
701	Select the Table	f	5	477	223	\N	\N	\N	\N	t	\N	372	4	2026-01-26 21:25:01.8837+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ff864914-169f-4710-81b0-141c8a5422d6
703	Checkbox inside List	f	7	477	223	\N	\N	\N	\N	t	\N	372	2	2026-01-26 21:25:02.14425+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	3fee2c29-fe3c-4f8e-9509-b0ddabf1dfed
698	Select the CheckBox	f	2	476	223	\N	\N	\N	\N	t	\N	372	2	2026-01-26 21:25:02.538161+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	29f9418c-9ebf-4b20-9f63-d24935566749
702	Select the List with dependentQuestion	t	6	477	223	\N	\N	\N	\N	t	\N	372	1	2026-01-26 21:25:25.50198+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	6bd03d6c-0ef2-473f-98c6-a98341d71c5a
704	Question 1	f	1	478	224	\N	\N	\N	\N	t	2026-02-04 20:01:16.025571+05	373	1	2026-02-04 20:01:16.025674+05	\N	\N	1	ffae87a7-f1f2-49ab-8fd4-5dd7c270ce9e
705	Question 2  isRequired	t	2	478	224	\N	\N	\N	\N	t	2026-02-04 20:01:59.938535+05	373	2	2026-02-04 20:01:59.938536+05	\N	\N	1	054a6252-749a-49c8-a29d-84b6df61d66c
706	Question 1	t	1	480	225	\N	\N	\N	\N	t	2026-02-04 21:37:32.686914+05	374	1	2026-02-04 21:37:32.687054+05	\N	\N	1	3344202f-ef6b-4c20-b918-a46c56d79a07
707	Question 2	t	2	480	225	\N	\N	\N	\N	t	2026-02-04 21:38:30.709351+05	374	2	2026-02-04 21:38:30.709353+05	\N	\N	1	65d0a0cc-5caf-487d-b456-62774e203934
709	Question 2 inside question 1	f	4	481	225	\N	\N	\N	\N	t	2026-02-04 21:43:37.582314+05	374	1	2026-02-04 21:43:37.582316+05	\N	\N	1	7a44a0fd-8a4c-40e1-be4c-cdd392814f63
708	Have Dependent Questions	t	3	481	225	\N	\N	\N	\N	t	2026-02-04 21:42:42.264151+05	374	2	2026-02-04 21:45:06.466818+05	\N	\N	1	079dfb77-ef11-45a4-bf18-2d9dd2a79d15
710	Question 1	t	1	482	225	\N	\N	\N	\N	t	\N	375	1	2026-02-04 21:59:47.943585+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	3344202f-ef6b-4c20-b918-a46c56d79a07
711	Question 2	t	2	482	225	\N	\N	\N	\N	t	\N	375	2	2026-02-04 21:59:48.009605+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	65d0a0cc-5caf-487d-b456-62774e203934
712	Have Dependent Questions	t	3	483	225	\N	\N	\N	\N	t	\N	375	2	2026-02-04 21:59:48.080887+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	079dfb77-ef11-45a4-bf18-2d9dd2a79d15
713	Question 2 inside question 1	f	4	483	225	\N	\N	\N	\N	t	\N	375	1	2026-02-04 21:59:48.145821+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	7a44a0fd-8a4c-40e1-be4c-cdd392814f63
715	Question 2	t	2	484	225	\N	\N	\N	\N	t	\N	376	2	2026-02-04 23:30:00.199531+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	65d0a0cc-5caf-487d-b456-62774e203934
716	Have Dependent Questions	t	3	485	225	\N	\N	\N	\N	t	\N	376	2	2026-02-04 23:30:00.238467+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	079dfb77-ef11-45a4-bf18-2d9dd2a79d15
717	Question 2 inside question 1	f	4	485	225	\N	\N	\N	\N	t	\N	376	1	2026-02-04 23:30:00.266282+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	7a44a0fd-8a4c-40e1-be4c-cdd392814f63
714	Question 1	t	1	484	225	\N	\N	\N	\N	t	\N	376	1	2026-02-04 23:30:00.32035+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	3344202f-ef6b-4c20-b918-a46c56d79a07
718	Question 1	t	1	484	225	\N	\N	\N	\N	t	2026-02-05 21:32:22.288878+05	381	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	3344202f-ef6b-4c20-b918-a46c56d79a07
719	Question 2	t	2	484	225	\N	\N	\N	\N	t	2026-02-05 21:32:22.293004+05	381	2	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	65d0a0cc-5caf-487d-b456-62774e203934
720	Have Dependent Questions	t	3	485	225	\N	\N	\N	\N	t	2026-02-05 21:32:22.293009+05	381	2	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	079dfb77-ef11-45a4-bf18-2d9dd2a79d15
721	Question 2 inside question 1	f	4	485	225	\N	\N	\N	\N	t	2026-02-05 21:32:22.293051+05	381	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	7a44a0fd-8a4c-40e1-be4c-cdd392814f63
722	Question 1	t	1	492	233	\N	\N	\N	\N	t	2026-02-07 01:25:30.075551+05	385	1	2026-02-07 01:25:30.075685+05	\N	\N	1	e3a5ea3a-eee4-46da-abf8-56b31dc6fe52
723	Question 2	f	2	492	233	\N	\N	\N	\N	t	2026-02-07 01:25:57.017993+05	385	2	2026-02-07 01:25:57.017996+05	\N	\N	1	eb74f6f3-0889-4d17-aabf-12c6296b9ce1
724	Question 1.1	t	1	493	234	\N	\N	\N	\N	t	2026-02-07 22:51:10.302617+05	386	2	2026-02-07 22:51:10.302667+05	\N	\N	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
726	Question 2.1	f	2	497	234	\N	\N	\N	\N	t	2026-02-07 22:52:05.61642+05	387	1	2026-02-07 22:52:30.383477+05	\N	\N	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
727	Question 1.2	f	3	496	234	\N	\N	\N	\N	t	2026-02-07 22:53:10.789453+05	387	1	2026-02-07 22:53:10.789453+05	\N	\N	1	fbee2d6b-849b-482e-a962-dd340db90516
725	Question 1.1	t	1	496	234	\N	\N	\N	\N	t	\N	387	2	2026-02-07 22:53:17.056353+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
728	Question1	f	1	500	235	\N	\N	\N	\N	t	2026-02-09 22:58:29.335905+05	388	3	2026-02-09 23:00:32.591763+05	\N	\N	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
729	question 1	t	2	500	235	\N	\N	\N	\N	t	2026-02-09 23:05:30.960228+05	388	4	2026-02-09 23:05:30.960229+05	\N	\N	1	c7ebdb8f-34db-4040-b85d-be842b16d694
730	Question1	f	1	502	235	\N	\N	\N	\N	t	\N	390	3	2026-02-10 00:15:37.251009+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
731	question 1	t	2	502	235	\N	\N	\N	\N	t	\N	390	4	2026-02-10 00:15:37.270514+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c7ebdb8f-34db-4040-b85d-be842b16d694
732	Question 1.1	t	1	504	234	\N	\N	\N	\N	t	\N	391	2	2026-02-10 18:31:37.596576+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
733	Question 1.2	f	3	504	234	\N	\N	\N	\N	t	\N	391	1	2026-02-10 18:31:37.64033+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fbee2d6b-849b-482e-a962-dd340db90516
734	Question 2.1	f	2	505	234	\N	\N	\N	\N	t	\N	391	1	2026-02-10 18:31:37.665746+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
735	Question 1	t	4	505	234	\N	\N	\N	\N	t	2026-02-10 18:32:16.284107+05	391	3	2026-02-10 18:32:16.284308+05	\N	\N	1	815df52b-6026-4680-b00f-c0df0dc44b06
736	Question 1.1	t	1	508	234	\N	\N	\N	\N	t	\N	392	2	2026-02-10 20:00:19.446656+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
738	Question 2.1	f	2	509	234	\N	\N	\N	\N	t	\N	392	1	2026-02-10 20:00:19.496687+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
739	Question 1	t	4	509	234	\N	\N	\N	\N	t	\N	392	3	2026-02-10 20:00:19.514642+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	815df52b-6026-4680-b00f-c0df0dc44b06
737	Question 1.2	f	2	508	234	\N	\N	\N	\N	t	\N	392	4	2026-02-10 20:00:19.668519+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fbee2d6b-849b-482e-a962-dd340db90516
740	Question 1.1	t	1	512	234	\N	\N	\N	\N	t	\N	393	2	2026-02-10 20:02:19.683511+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
742	Question 2.1	f	2	513	234	\N	\N	\N	\N	t	\N	393	1	2026-02-10 20:02:19.712348+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
743	Question 1	t	4	513	234	\N	\N	\N	\N	t	\N	393	3	2026-02-10 20:02:19.724652+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	815df52b-6026-4680-b00f-c0df0dc44b06
741	Question 1.2	t	2	512	234	\N	\N	\N	\N	t	\N	393	6	2026-02-10 20:02:19.766613+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fbee2d6b-849b-482e-a962-dd340db90516
745	Question 1.2	t	2	516	234	\N	\N	\N	\N	t	\N	394	6	2026-02-10 20:03:04.056675+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fbee2d6b-849b-482e-a962-dd340db90516
746	Question 2.1	f	2	517	234	\N	\N	\N	\N	t	\N	394	1	2026-02-10 20:03:04.082302+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
744	Question 1.1	t	1	516	234	\N	\N	\N	\N	t	\N	394	6	2026-02-10 20:03:04.152166+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
750	Question 2.1	f	2	521	234	\N	\N	\N	\N	t	\N	395	1	2026-02-10 20:04:17.309342+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	43632ef1-45f9-4348-b8ec-97edea7f2b18
751	Question 1	t	4	521	234	\N	\N	\N	\N	t	\N	395	3	2026-02-10 20:04:17.31697+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	815df52b-6026-4680-b00f-c0df0dc44b06
747	Question 1	t	4	517	234	\N	\N	\N	\N	t	\N	394	3	2026-02-10 20:03:04.103336+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	815df52b-6026-4680-b00f-c0df0dc44b06
748	Question 1.1	t	1	520	234	\N	\N	\N	\N	t	\N	395	7	2026-02-10 20:04:17.358333+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	ac343cfb-5736-438d-a750-941dcbc8d4f7
749	Question 1.2	t	2	520	234	\N	\N	\N	\N	t	\N	395	6	2026-02-10 20:04:17.287767+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fbee2d6b-849b-482e-a962-dd340db90516
753	question 1	t	2	524	235	\N	\N	\N	\N	t	\N	396	4	2026-02-10 20:05:08.108746+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c7ebdb8f-34db-4040-b85d-be842b16d694
752	Question1	f	1	524	235	\N	\N	\N	\N	t	\N	396	5	2026-02-10 20:05:08.149341+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
754	Question1	f	1	526	235	\N	\N	\N	\N	t	\N	397	5	2026-02-10 20:54:59.44499+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
755	question 1	t	2	526	235	\N	\N	\N	\N	t	\N	397	4	2026-02-10 20:54:59.460138+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c7ebdb8f-34db-4040-b85d-be842b16d694
756	Question 1	t	1	528	233	\N	\N	\N	\N	t	\N	398	1	2026-02-10 21:01:40.851865+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	e3a5ea3a-eee4-46da-abf8-56b31dc6fe52
757	Question 2	f	2	528	233	\N	\N	\N	\N	t	\N	398	2	2026-02-10 21:01:40.860712+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	eb74f6f3-0889-4d17-aabf-12c6296b9ce1
758	Question1	f	1	529	235	\N	\N	\N	\N	t	\N	399	5	2026-02-10 21:02:17.751754+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
759	question 1	t	2	529	235	\N	\N	\N	\N	t	\N	399	4	2026-02-10 21:02:17.761043+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c7ebdb8f-34db-4040-b85d-be842b16d694
760	question 1	f	1	531	237	\N	\N	\N	\N	t	2026-02-11 21:44:52.140839+05	400	3	2026-02-11 21:44:52.14089+05	\N	\N	1	5ef86a5d-1a85-4482-921a-95e0dfa06be7
761	question 1	f	1	532	237	\N	\N	\N	\N	t	\N	401	2	2026-02-11 21:45:29.384699+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	5ef86a5d-1a85-4482-921a-95e0dfa06be7
762	question 1	f	1	533	237	\N	\N	\N	\N	t	\N	402	2	2026-02-11 21:46:32.172186+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	5ef86a5d-1a85-4482-921a-95e0dfa06be7
763	question 2	f	2	533	237	\N	\N	\N	\N	t	2026-02-11 21:46:32.202767+05	402	1	2026-02-11 21:46:32.202768+05	\N	\N	1	fa57cce4-c866-4e25-a25b-7d55bce43a78
764	Question1	f	1	534	235	\N	\N	\N	\N	t	\N	403	5	2026-02-17 02:55:37.223038+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	23c449f7-2551-4250-90d3-04e27d6c6f2c
765	question 1	t	2	534	235	\N	\N	\N	\N	t	\N	403	4	2026-02-17 02:55:37.370331+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	c7ebdb8f-34db-4040-b85d-be842b16d694
767	question 2	f	2	536	237	\N	\N	\N	\N	t	\N	404	1	2026-03-10 01:53:17.475975+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	fa57cce4-c866-4e25-a25b-7d55bce43a78
766	question 1	f	1	536	237	\N	\N	\N	\N	t	\N	404	4	2026-03-10 01:53:17.65179+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1	5ef86a5d-1a85-4482-921a-95e0dfa06be7
\.


--
-- TOC entry 5452 (class 0 OID 58683)
-- Dependencies: 284
-- Data for Name: TemplateItems; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateItems" ("TemplateItemId", "TemplateId", "ServiceName", "Description", "Quantity", "Unit", "ItemPrice", "Total", "TemplateVersion", "RowId", "CreatedAt", "IsActive", "ModifiedAt", "CreatedById", "ModifiedById", "QuoteId", "CustomerId", business_id) FROM stdin;
53	237	kjb	 mn	4	6t	10.00	40.00	402	1	\N	f	\N	\N	\N	682	24	1
\.


--
-- TOC entry 5454 (class 0 OID 58695)
-- Dependencies: 286
-- Data for Name: TemplateVersions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateVersions" ("TempVersionId", "TemplateId", "TempValidFrom", "TempValidTo", "IsActive", "CreatedAt", "TempVersion", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
371	223	2026-01-26 21:10:37.506391+05	\N	t	\N	1	\N	\N	\N	1
372	223	2026-01-26 21:25:01.140222+05	\N	t	2026-01-26 21:25:01.140225+05	2	2026-01-26 21:25:01.140974+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
373	224	2026-02-04 20:00:41.566816+05	\N	t	\N	1	\N	\N	\N	1
374	225	2026-02-04 21:36:12.195906+05	\N	t	\N	1	\N	\N	\N	1
375	225	2026-02-04 21:59:47.841446+05	\N	t	2026-02-04 21:59:47.841448+05	2	2026-02-04 21:59:47.841946+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
377	226	2026-02-05 20:05:13.149586+05	\N	t	2026-02-05 20:05:13.149413+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
378	227	2026-02-05 20:05:27.831778+05	\N	t	2026-02-05 20:05:27.831777+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
379	228	2026-02-05 20:05:48.298071+05	\N	t	2026-02-05 20:05:48.298071+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
380	229	2026-02-05 20:28:35.125631+05	\N	t	2026-02-05 20:28:35.125243+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
376	225	2026-02-04 23:30:00.094623+05	2026-02-05 21:32:21.774507+05	t	2026-02-04 23:30:00.094628+05	3	2026-02-05 21:32:21.774508+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
381	225	2026-02-05 21:32:21.775034+05	\N	t	2026-02-05 21:32:21.775507+05	4	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
382	230	2026-02-05 21:36:11.372368+05	2026-02-05 21:41:20.991982+05	t	2026-02-05 21:36:11.372365+05	1	2026-02-05 21:41:20.991984+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1
383	231	2026-02-05 21:48:55.821733+05	\N	t	2026-02-05 21:48:55.821733+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
384	232	2026-02-05 21:59:27.002345+05	\N	t	2026-02-05 21:59:27.002345+05	1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1
385	233	2026-02-07 01:23:38.205566+05	\N	t	\N	1	\N	\N	\N	1
386	234	2026-02-07 22:50:05.3831+05	\N	t	\N	1	\N	\N	\N	1
387	234	2026-02-07 22:52:05.557202+05	\N	t	2026-02-07 22:52:05.557203+05	2	2026-02-07 22:52:05.55738+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
388	235	2026-02-09 19:27:45.175705+05	\N	t	\N	1	\N	\N	\N	1
389	236	2026-02-09 19:33:22.009991+05	\N	t	\N	1	\N	\N	\N	1
390	235	2026-02-10 00:15:37.18955+05	\N	t	2026-02-10 00:15:37.189599+05	2	2026-02-10 00:15:37.189793+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
391	234	2026-02-10 18:31:37.420818+05	\N	t	2026-02-10 18:31:37.42111+05	3	2026-02-10 18:31:37.421405+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
392	234	2026-02-10 20:00:19.340793+05	\N	t	2026-02-10 20:00:19.341056+05	4	2026-02-10 20:00:19.341418+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
393	234	2026-02-10 20:02:19.66838+05	\N	t	2026-02-10 20:02:19.668381+05	5	2026-02-10 20:02:19.668381+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
394	234	2026-02-10 20:03:04.028285+05	\N	t	2026-02-10 20:03:04.028285+05	6	2026-02-10 20:03:04.028286+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
395	234	2026-02-10 20:04:17.251656+05	\N	t	2026-02-10 20:04:17.251656+05	7	2026-02-10 20:04:17.251656+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
396	235	2026-02-10 20:05:08.080515+05	\N	t	2026-02-10 20:05:08.080515+05	3	2026-02-10 20:05:08.080515+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
397	235	2026-02-10 20:54:59.423872+05	\N	t	2026-02-10 20:54:59.423873+05	4	2026-02-10 20:54:59.423873+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
398	233	2026-02-10 21:01:40.841921+05	\N	t	2026-02-10 21:01:40.841921+05	2	2026-02-10 21:01:40.841921+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
399	235	2026-02-10 21:02:17.741924+05	\N	t	2026-02-10 21:02:17.741925+05	5	2026-02-10 21:02:17.741925+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
400	237	2026-02-11 21:44:26.019867+05	\N	t	\N	1	\N	\N	\N	1
401	237	2026-02-11 21:45:29.303462+05	\N	t	2026-02-11 21:45:29.303463+05	2	2026-02-11 21:45:29.303646+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
402	237	2026-02-11 21:46:32.14894+05	\N	t	2026-02-11 21:46:32.148941+05	3	2026-02-11 21:46:32.148942+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
403	235	2026-02-17 02:55:36.884616+05	\N	t	2026-02-17 02:55:36.884859+05	6	2026-02-17 02:55:36.885012+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
404	237	2026-03-10 01:53:17.312001+05	\N	t	2026-03-10 01:53:17.312245+05	4	2026-03-10 01:53:17.312427+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	1
\.


--
-- TOC entry 5456 (class 0 OID 58705)
-- Dependencies: 288
-- Data for Name: Templates; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Templates" ("TemplateId", "TemplateName", "IsActive", "CreatedAt", "Description", "ModifiedAt", "CreatedById", "ModifiedById", business_id, template_path) FROM stdin;
223	Template 1	t	2026-01-26 21:10:37.512453+05	Template 1(Description)	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
224	New Template For Preview	t	2026-02-04 20:00:41.571502+05	New Template For Preview	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
225	Preview_Testing	t	2026-02-04 21:36:12.200717+05	Preview_Testing	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	/UploadTemplate/file_main.odt
226	New Template For Testing 	t	2026-02-05 20:05:13.149039+05	New Template For Testing 	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
227	New Template For Testing 	t	2026-02-05 20:05:27.831776+05	\N	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
228	New Template New Template 	t	2026-02-05 20:05:48.29807+05	New Template New Template 	2026-02-05 20:08:59.395405+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1	\N
229	Template New	t	2026-02-05 20:28:35.124165+05	Template New	2026-02-05 20:33:00.740219+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1	\N
230	Full Latest Template 	t	2026-02-05 21:36:11.371075+05	Full Latest Template 	2026-02-05 21:41:20.965682+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1	\N
231	Full Latest Template 5/2/26	t	2026-02-05 21:48:55.821731+05	Full Latest Template 5/2/26	2026-02-05 21:58:22.478141+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1	\N
232	New Template 5/2/26	t	2026-02-05 21:59:27.002343+05	New Template 5/2/26	2026-02-05 21:59:55.117328+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	1	\N
233	Template 1	t	2026-02-07 01:23:38.211237+05	Template 1	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
234	Template 12345ABCDEF	t	2026-02-07 22:50:05.383952+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	/UploadTemplate/file_main.odt
235	New temp  1	t	2026-02-09 19:27:45.1777+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
236	very new test	f	2026-02-09 19:33:22.011077+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
237	new new new new	t	2026-02-11 21:44:26.021274+05		\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	1	\N
\.


--
-- TOC entry 5458 (class 0 OID 58715)
-- Dependencies: 290
-- Data for Name: UserAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."UserAnswers" ("UAnswerId", "QuestionId", "QOptionId", "AnswerText", "DisplayOrder", "DateTime", "RecordId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "CustomerId", "QuoteVersionId", business_id, "ParentOptionId") FROM stdin;
4245	704	1190		\N	2026-02-04 20:02:22.786372+05	663	t	2026-02-04 20:02:22.786199+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	\N
4247	705	1193		\N	2026-02-04 20:02:24.53416+05	663	t	2026-02-04 20:02:24.534159+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	\N
4248	722	1228		\N	2026-02-07 01:31:24.229652+05	667	t	2026-02-07 01:31:24.229356+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	0
4252	722	1228		\N	2026-02-07 22:43:41.220389+05	667	t	\N	2026-02-07 22:43:41.220593+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	0
4260	697	1174		\N	2026-02-10 19:48:27.950675+05	670	t	2026-02-10 19:48:27.950675+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4263	699	1179		\N	2026-02-10 19:52:03.182852+05	670	t	2026-02-10 19:52:03.182851+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4265	701	1183	3	\N	2026-02-10 19:56:14.032981+05	670	t	2026-02-10 19:56:14.03298+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4274	736	1252		\N	2026-02-10 20:00:55.34581+05	671	t	2026-02-10 20:00:55.34581+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	23	1	1	\N
4297	750	1280		\N	2026-02-10 20:15:45.958384+05	675	t	2026-02-10 20:15:45.958383+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	23	1	1	\N
4298	748	\N	1a	\N	2026-02-10 20:16:03.697439+05	675	t	2026-02-10 20:16:03.697438+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	23	1	1	\N
4288	744	\N	123	\N	2026-02-10 20:03:45.548036+05	672	t	2026-02-10 20:03:45.548036+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	23	1	1	\N
4289	748	\N	sadasd	\N	2026-02-10 20:04:31.769646+05	673	t	2026-02-10 20:04:31.769645+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	\N
4290	752	\N	2131	\N	2026-02-10 20:05:25.063762+05	674	t	2026-02-10 20:05:25.063762+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4291	753	1285	0	\N	2026-02-10 20:05:42.045248+05	674	t	2026-02-10 20:05:42.045247+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4292	752	\N	2131	\N	2026-02-10 20:12:12.342357+05	674	t	\N	2026-02-10 20:12:12.342357+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4293	753	1285	0	\N	2026-02-10 20:12:12.342358+05	674	t	\N	2026-02-10 20:12:12.342358+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4295	752	\N	111112222vv	\N	2026-02-10 20:14:04.95113+05	674	t	2026-02-10 20:14:04.95113+05	2026-02-10 20:14:04.951131+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4300	748	\N	1a	\N	2026-02-10 20:16:40.886405+05	675	t	\N	2026-02-10 20:16:40.886405+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	23	2	1	\N
4301	748	\N	1112222	\N	2026-02-10 20:16:40.891196+05	675	t	2026-02-10 20:16:40.891195+05	2026-02-10 20:16:40.891197+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	23	2	1	\N
4303	750	1280		\N	2026-02-10 20:35:53.218946+05	675	t	2026-02-10 20:35:53.218946+05	2026-02-10 20:35:53.218947+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	23	2	1	\N
4304	751	1282		\N	2026-02-10 20:36:08.775355+05	675	t	2026-02-10 20:36:08.775354+05	2026-02-10 20:36:08.775356+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	23	2	1	\N
4328	762	1298		\N	2026-03-03 23:32:55.978053+05	683	t	2026-03-03 23:32:55.978053+05	2026-03-03 23:32:55.978054+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	\N
4306	736	1251		\N	2026-02-10 23:55:49.342385+05	671	t	2026-02-10 23:55:49.342117+05	2026-02-10 23:55:49.342386+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	23	2	1	\N
4307	748	\N	fdsgf	\N	2026-02-11 21:42:05.119937+05	676	t	2026-02-11 21:42:05.119832+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4308	748	\N	fdsgf	\N	2026-02-11 21:42:29.603167+05	676	t	\N	2026-02-11 21:42:29.603312+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4309	748	\N	fd	\N	2026-02-11 21:42:29.619994+05	676	t	2026-02-11 21:42:29.619993+05	2026-02-11 21:42:29.619995+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4310	751	1282		\N	2026-02-11 21:42:46.374829+05	676	t	2026-02-11 21:42:46.374828+05	2026-02-11 21:42:46.37483+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4311	750	1281		\N	2026-02-11 21:42:48.815766+05	676	t	2026-02-11 21:42:48.815765+05	2026-02-11 21:42:48.815767+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	22	2	1	\N
4312	758	\N	hjb	\N	2026-02-11 21:43:47.376736+05	677	t	2026-02-11 21:43:47.376735+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4314	759	1295	2	\N	2026-02-11 21:43:57.630805+05	677	t	2026-02-11 21:43:57.630804+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	22	1	1	\N
4315	760	1296		\N	2026-02-11 21:45:11.384906+05	678	t	2026-02-11 21:45:11.384905+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	\N
4318	763	1299		\N	2026-02-11 21:47:00.576116+05	680	t	2026-02-11 21:47:00.576115+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	21	1	1	\N
4322	762	1298		\N	2026-03-03 23:32:01.369992+05	680	t	2026-03-03 23:32:01.369763+05	2026-03-03 23:32:01.370728+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	\N
4323	763	1299		\N	2026-03-03 23:32:05.94869+05	680	t	2026-03-03 23:32:05.94869+05	2026-03-03 23:32:05.948691+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	\N
4324	762	1298	\N	\N	2026-03-03 23:32:08.139593+05	683	t	2026-03-03 23:32:08.139593+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	1	1	\N
4325	763	1299	\N	\N	2026-03-03 23:32:08.146107+05	683	t	2026-03-03 23:32:08.146107+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	\N	1	1	\N
4327	763	1299	\N	\N	2026-03-03 23:32:50.189659+05	683	t	\N	2026-03-03 23:32:50.189659+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	2	1	\N
4331	763	\N		\N	2026-03-10 01:51:59.373211+05	682	t	2026-03-10 01:51:59.37321+05	2026-03-10 01:51:59.373212+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	24	2	1	\N
4334	723	1230		\N	2026-03-10 01:52:39.803207+05	667	t	2026-03-10 01:52:39.803206+05	2026-03-10 01:52:39.803208+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	\N
4335	722	\N		\N	2026-03-10 01:52:43.40919+05	667	t	2026-03-10 01:52:43.409189+05	2026-03-10 01:52:43.409191+05	29a8a07e-094a-48ea-82af-7221f1175cca	29a8a07e-094a-48ea-82af-7221f1175cca	21	2	1	\N
4339	766	1305	20	\N	2026-03-10 01:53:54.408516+05	687	t	2026-03-10 01:53:54.408515+05	\N	29a8a07e-094a-48ea-82af-7221f1175cca	\N	34	1	1	\N
\.


--
-- TOC entry 5460 (class 0 OID 58727)
-- Dependencies: 292
-- Data for Name: UserRecords; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."UserRecords" ("RecStatusId", "QuoteReference", "TempVersionId", "TemplateId", "MiscCodeEnum", "MiscCodeName", "TotalCost", "IsActive", "CreatedAt", "MiscLookupCodeEnum", "ModifiedAt", "PDFLINK", "CreatedById", "ModifiedById") FROM stdin;
\.


--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 228
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: customers; Owner: postgres
--

SELECT pg_catalog.setval('customers.customers_customer_id_seq', 36, true);


--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 230
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general."Statistics_statistic_id_seq"', 10, true);


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 232
-- Name: business_business_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.business_business_id_seq', 1, false);


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 234
-- Name: business_document_business_document_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.business_document_business_document_id_seq', 1, false);


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 237
-- Name: menu_menu_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.menu_menu_id_seq', 9, true);


--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 239
-- Name: Components_ComponentId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."Components_ComponentId_seq"', 31, true);


--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 241
-- Name: MaterialComponents_MatCompId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."MaterialComponents_MatCompId_seq"', 46, true);


--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 243
-- Name: Materials_MaterialId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."Materials_MaterialId_seq"', 40, true);


--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 245
-- Name: MiscLookups_CodeEnum_seq; Type: SEQUENCE SET; Schema: misc; Owner: postgres
--

SELECT pg_catalog.setval('misc."MiscLookups_CodeEnum_seq"', 1, false);


--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 249
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE SET; Schema: quotes; Owner: postgres
--

SELECT pg_catalog.setval('quotes."UserRecords_RecStatusId_seq"', 687, true);


--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 251
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."RefreshTokens_Id_seq"', 81, true);


--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 256
-- Name: roles_claims_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."roles_claims_Id_seq"', 1, false);


--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 259
-- Name: security_group_members_security_group_id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security.security_group_members_security_group_id_seq', 1, false);


--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 260
-- Name: security_group_sec_group_id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security.security_group_sec_group_id_seq', 7, true);


--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 262
-- Name: user_claims_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."user_claims_Id_seq"', 1, false);


--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 267
-- Name: users_UserId_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."users_UserId_seq"', 21, true);


--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 269
-- Name: DependentQuestions_DependentQId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."DependentQuestions_DependentQId_seq"', 198, true);


--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 271
-- Name: FieldTypes_FieldTypeId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."FieldTypes_FieldTypeId_seq"', 1, false);


--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 273
-- Name: Iframes_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Iframes_PID_seq"', 145, true);


--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 275
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."MetafieldAnswers_metafield_answer_id_seq"', 101, true);


--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 277
-- Name: Metafields_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Metafields_PID_seq"', 424, true);


--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 279
-- Name: QuestionGroups_QuestionGroupId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionGroups_QuestionGroupId_seq"', 536, true);


--
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 281
-- Name: QuestionOptions_QOptionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionOptions_QOptionId_seq"', 1305, true);


--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 283
-- Name: Questions_QuestionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Questions_QuestionId_seq"', 767, true);


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 285
-- Name: TemplateItems_TemplateItemId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateItems_TemplateItemId_seq"', 53, true);


--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 287
-- Name: TemplateVersions_TempVersionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateVersions_TempVersionId_seq"', 404, true);


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 289
-- Name: Templates_TemplateId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Templates_TemplateId_seq"', 237, true);


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 291
-- Name: UserAnswers_UAnswerId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."UserAnswers_UAnswerId_seq"', 4339, true);


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 293
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."UserRecords_RecStatusId_seq"', 1, false);


--
-- TOC entry 5042 (class 2606 OID 58752)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: customers; Owner: postgres
--

ALTER TABLE ONLY customers.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 5047 (class 2606 OID 58754)
-- Name: Statistics Statistics_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics"
    ADD CONSTRAINT "Statistics_pkey" PRIMARY KEY (statistic_id);


--
-- TOC entry 5051 (class 2606 OID 58756)
-- Name: business_document business_document_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business_document
    ADD CONSTRAINT business_document_pkey PRIMARY KEY (business_document_id);


--
-- TOC entry 5049 (class 2606 OID 58758)
-- Name: business business_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business
    ADD CONSTRAINT business_pkey PRIMARY KEY (business_id);


--
-- TOC entry 5053 (class 2606 OID 58760)
-- Name: menu menu_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (menu_id);


--
-- TOC entry 5058 (class 2606 OID 58762)
-- Name: Components PK_Components; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Components"
    ADD CONSTRAINT "PK_Components" PRIMARY KEY ("ComponentId");


--
-- TOC entry 5062 (class 2606 OID 58764)
-- Name: MaterialComponents PK_MaterialComponents; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "PK_MaterialComponents" PRIMARY KEY ("MatCompId");


--
-- TOC entry 5065 (class 2606 OID 58766)
-- Name: Materials PK_Materials; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Materials"
    ADD CONSTRAINT "PK_Materials" PRIMARY KEY ("MaterialId");


--
-- TOC entry 5067 (class 2606 OID 58768)
-- Name: MiscLookups PK_MiscLookups; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "PK_MiscLookups" PRIMARY KEY ("CodeEnum");


--
-- TOC entry 5069 (class 2606 OID 58770)
-- Name: code_lookup code_lookup_pkey; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc.code_lookup
    ADD CONSTRAINT code_lookup_pkey PRIMARY KEY (code_name, code_enum);


--
-- TOC entry 5071 (class 2606 OID 58772)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 5075 (class 2606 OID 58774)
-- Name: UserRecords PK_UserRecords; Type: CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."UserRecords"
    ADD CONSTRAINT "PK_UserRecords" PRIMARY KEY ("RecStatusId");


--
-- TOC entry 5083 (class 2606 OID 58776)
-- Name: jwt_settings PK_jwt_settings; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.jwt_settings
    ADD CONSTRAINT "PK_jwt_settings" PRIMARY KEY ("Id");


--
-- TOC entry 5087 (class 2606 OID 58778)
-- Name: roles PK_roles; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles
    ADD CONSTRAINT "PK_roles" PRIMARY KEY ("Id");


--
-- TOC entry 5091 (class 2606 OID 58780)
-- Name: roles_claims PK_roles_claims; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles_claims
    ADD CONSTRAINT "PK_roles_claims" PRIMARY KEY ("Id");


--
-- TOC entry 5098 (class 2606 OID 58782)
-- Name: user_claims PK_user_claims; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_claims
    ADD CONSTRAINT "PK_user_claims" PRIMARY KEY ("Id");


--
-- TOC entry 5101 (class 2606 OID 58784)
-- Name: user_logins PK_user_logins; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_logins
    ADD CONSTRAINT "PK_user_logins" PRIMARY KEY ("LoginProvider", "ProviderKey");


--
-- TOC entry 5104 (class 2606 OID 58786)
-- Name: user_roles PK_user_roles; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "PK_user_roles" PRIMARY KEY ("UserId", "RoleId");


--
-- TOC entry 5106 (class 2606 OID 58788)
-- Name: user_tokens PK_user_tokens; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_tokens
    ADD CONSTRAINT "PK_user_tokens" PRIMARY KEY ("UserId", "LoginProvider", "Name");


--
-- TOC entry 5109 (class 2606 OID 58790)
-- Name: users PK_users; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


--
-- TOC entry 5081 (class 2606 OID 58792)
-- Name: RefreshTokens RefreshTokens_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security."RefreshTokens"
    ADD CONSTRAINT "RefreshTokens_pkey" PRIMARY KEY ("Id");


--
-- TOC entry 5085 (class 2606 OID 58794)
-- Name: menu_access menu_access_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.menu_access
    ADD CONSTRAINT menu_access_pkey PRIMARY KEY (security_group_id, menu_id);


--
-- TOC entry 5095 (class 2606 OID 58796)
-- Name: security_group_members security_group_members_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group_members
    ADD CONSTRAINT security_group_members_pkey PRIMARY KEY (security_group_id, user_id);


--
-- TOC entry 5093 (class 2606 OID 58798)
-- Name: security_group security_group_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group
    ADD CONSTRAINT security_group_pkey PRIMARY KEY (security_group_id);


--
-- TOC entry 5124 (class 2606 OID 58800)
-- Name: MetafieldAnswers MetafieldAnswers_pkey; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT "MetafieldAnswers_pkey" PRIMARY KEY (metafield_answer_id);


--
-- TOC entry 5116 (class 2606 OID 58802)
-- Name: DependentQuestions PK_DependentQuestions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "PK_DependentQuestions" PRIMARY KEY ("DependentQId");


--
-- TOC entry 5120 (class 2606 OID 58804)
-- Name: FieldTypes PK_FieldTypes; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "PK_FieldTypes" PRIMARY KEY ("FieldTypeId");


--
-- TOC entry 5122 (class 2606 OID 58806)
-- Name: Iframes PK_Iframes; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Iframes"
    ADD CONSTRAINT "PK_Iframes" PRIMARY KEY ("PID");


--
-- TOC entry 5128 (class 2606 OID 58808)
-- Name: Metafields PK_Metafields; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Metafields"
    ADD CONSTRAINT "PK_Metafields" PRIMARY KEY ("PID");


--
-- TOC entry 5135 (class 2606 OID 58810)
-- Name: QuestionGroups PK_QuestionGroups; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "PK_QuestionGroups" PRIMARY KEY ("QuestionGroupId");


--
-- TOC entry 5142 (class 2606 OID 58812)
-- Name: QuestionOptions PK_QuestionOptions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "PK_QuestionOptions" PRIMARY KEY ("QOptionId");


--
-- TOC entry 5153 (class 2606 OID 58814)
-- Name: Questions PK_Questions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "PK_Questions" PRIMARY KEY ("QuestionId");


--
-- TOC entry 5157 (class 2606 OID 58816)
-- Name: TemplateItems PK_TemplateItems; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT "PK_TemplateItems" PRIMARY KEY ("TemplateItemId");


--
-- TOC entry 5163 (class 2606 OID 58818)
-- Name: TemplateVersions PK_TemplateVersions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "PK_TemplateVersions" PRIMARY KEY ("TempVersionId");


--
-- TOC entry 5168 (class 2606 OID 58820)
-- Name: Templates PK_Templates; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "PK_Templates" PRIMARY KEY ("TemplateId");


--
-- TOC entry 5179 (class 2606 OID 58822)
-- Name: UserAnswers PK_UserAnswers; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "PK_UserAnswers" PRIMARY KEY ("UAnswerId");


--
-- TOC entry 5186 (class 2606 OID 58824)
-- Name: UserRecords PK_UserRecords; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "PK_UserRecords" PRIMARY KEY ("RecStatusId");


--
-- TOC entry 5040 (class 1259 OID 58825)
-- Name: IX_customers_BusinessId; Type: INDEX; Schema: customers; Owner: postgres
--

CREATE INDEX "IX_customers_BusinessId" ON customers.customers USING btree (business_id);


--
-- TOC entry 5043 (class 1259 OID 58826)
-- Name: IX_Statistics_BusinessId; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_BusinessId" ON general."Statistics" USING btree (business_id);


--
-- TOC entry 5044 (class 1259 OID 58827)
-- Name: IX_Statistics_CreatedById; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_CreatedById" ON general."Statistics" USING btree (created_by_id);


--
-- TOC entry 5045 (class 1259 OID 58828)
-- Name: IX_Statistics_ModifiedById; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_ModifiedById" ON general."Statistics" USING btree (modified_by_id);


--
-- TOC entry 5054 (class 1259 OID 58829)
-- Name: IX_Components_BusinessId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_BusinessId" ON inventory."Components" USING btree (business_id);


--
-- TOC entry 5055 (class 1259 OID 58830)
-- Name: IX_Components_CreatedById; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_CreatedById" ON inventory."Components" USING btree ("CreatedById");


--
-- TOC entry 5056 (class 1259 OID 58831)
-- Name: IX_Components_ModifiedById; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_ModifiedById" ON inventory."Components" USING btree ("ModifiedById");


--
-- TOC entry 5059 (class 1259 OID 58832)
-- Name: IX_MaterialComponents_ComponentId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_MaterialComponents_ComponentId" ON inventory."MaterialComponents" USING btree ("ComponentId");


--
-- TOC entry 5060 (class 1259 OID 58833)
-- Name: IX_MaterialComponents_MaterialId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_MaterialComponents_MaterialId" ON inventory."MaterialComponents" USING btree ("MaterialId");


--
-- TOC entry 5063 (class 1259 OID 58834)
-- Name: IX_Materials_BusinessId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Materials_BusinessId" ON inventory."Materials" USING btree (business_id);


--
-- TOC entry 5072 (class 1259 OID 58835)
-- Name: IX_UserRecords_BusinessId; Type: INDEX; Schema: quotes; Owner: postgres
--

CREATE INDEX "IX_UserRecords_BusinessId" ON quotes."UserRecords" USING btree (business_id);


--
-- TOC entry 5073 (class 1259 OID 58836)
-- Name: IX_UserRecords_StatusId; Type: INDEX; Schema: quotes; Owner: postgres
--

CREATE INDEX "IX_UserRecords_StatusId" ON quotes."UserRecords" USING btree ("StatusId");


--
-- TOC entry 5107 (class 1259 OID 58837)
-- Name: EmailIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "EmailIndex" ON security.users USING btree ("NormalizedEmail");


--
-- TOC entry 5089 (class 1259 OID 58838)
-- Name: IX_roles_claims_RoleId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_roles_claims_RoleId" ON security.roles_claims USING btree ("RoleId");


--
-- TOC entry 5076 (class 1259 OID 58839)
-- Name: IX_security_RefreshTokens_ExpiryDate; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_ExpiryDate" ON security."RefreshTokens" USING btree ("ExpiryDate") WITH (fillfactor='100', deduplicate_items='true');


--
-- TOC entry 5077 (class 1259 OID 58840)
-- Name: IX_security_RefreshTokens_Token; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "IX_security_RefreshTokens_Token" ON security."RefreshTokens" USING btree ("Token") WITH (fillfactor='100', deduplicate_items='true');


--
-- TOC entry 5078 (class 1259 OID 58841)
-- Name: IX_security_RefreshTokens_Token_IsRevoked; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_Token_IsRevoked" ON security."RefreshTokens" USING btree ("Token", "IsRevoked") WITH (fillfactor='100', deduplicate_items='true');


--
-- TOC entry 5079 (class 1259 OID 58842)
-- Name: IX_security_RefreshTokens_UserId_IsRevoked; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_UserId_IsRevoked" ON security."RefreshTokens" USING btree ("UserId", "IsRevoked") WITH (fillfactor='100', deduplicate_items='true');


--
-- TOC entry 5096 (class 1259 OID 58843)
-- Name: IX_user_claims_UserId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_claims_UserId" ON security.user_claims USING btree ("UserId");


--
-- TOC entry 5099 (class 1259 OID 58844)
-- Name: IX_user_logins_UserId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_logins_UserId" ON security.user_logins USING btree ("UserId");


--
-- TOC entry 5102 (class 1259 OID 58845)
-- Name: IX_user_roles_RoleId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_roles_RoleId" ON security.user_roles USING btree ("RoleId");


--
-- TOC entry 5088 (class 1259 OID 58846)
-- Name: RoleNameIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "RoleNameIndex" ON security.roles USING btree ("NormalizedName");


--
-- TOC entry 5110 (class 1259 OID 58847)
-- Name: UserNameIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "UserNameIndex" ON security.users USING btree ("NormalizedUserName");


--
-- TOC entry 5111 (class 1259 OID 58848)
-- Name: IX_DependentQuestions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_CreatedById" ON templates."DependentQuestions" USING btree ("CreatedById");


--
-- TOC entry 5112 (class 1259 OID 58849)
-- Name: IX_DependentQuestions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_ModifiedById" ON templates."DependentQuestions" USING btree ("ModifiedById");


--
-- TOC entry 5113 (class 1259 OID 58850)
-- Name: IX_DependentQuestions_NextQuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_NextQuestionId" ON templates."DependentQuestions" USING btree ("NextQuestionId");


--
-- TOC entry 5114 (class 1259 OID 58851)
-- Name: IX_DependentQuestions_QOptionId_NextQuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE UNIQUE INDEX "IX_DependentQuestions_QOptionId_NextQuestionId" ON templates."DependentQuestions" USING btree ("QOptionId", "NextQuestionId");


--
-- TOC entry 5117 (class 1259 OID 58852)
-- Name: IX_FieldTypes_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_FieldTypes_CreatedById" ON templates."FieldTypes" USING btree ("CreatedById");


--
-- TOC entry 5118 (class 1259 OID 58853)
-- Name: IX_FieldTypes_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_FieldTypes_ModifiedById" ON templates."FieldTypes" USING btree ("ModifiedById");


--
-- TOC entry 5125 (class 1259 OID 58854)
-- Name: IX_Metafields_Guid_VersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Metafields_Guid_VersionId" ON templates."Metafields" USING btree ("MetafieldGuid", "TempVersionId");


--
-- TOC entry 5126 (class 1259 OID 58855)
-- Name: IX_Metafields_MetafieldGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Metafields_MetafieldGuid" ON templates."Metafields" USING btree ("MetafieldGuid");


--
-- TOC entry 5129 (class 1259 OID 58856)
-- Name: IX_QuestionGroups_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_BusinessId" ON templates."QuestionGroups" USING btree (business_id);


--
-- TOC entry 5130 (class 1259 OID 58857)
-- Name: IX_QuestionGroups_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_CreatedById" ON templates."QuestionGroups" USING btree ("CreatedById");


--
-- TOC entry 5131 (class 1259 OID 58858)
-- Name: IX_QuestionGroups_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_ModifiedById" ON templates."QuestionGroups" USING btree ("ModifiedById");


--
-- TOC entry 5132 (class 1259 OID 58859)
-- Name: IX_QuestionGroups_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_TemplateId" ON templates."QuestionGroups" USING btree ("TemplateId");


--
-- TOC entry 5133 (class 1259 OID 58860)
-- Name: IX_QuestionGroups_TemplateVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_TemplateVersionId" ON templates."QuestionGroups" USING btree ("TemplateVersionId");


--
-- TOC entry 5136 (class 1259 OID 58861)
-- Name: IX_QuestionOptions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_CreatedById" ON templates."QuestionOptions" USING btree ("CreatedById");


--
-- TOC entry 5137 (class 1259 OID 58862)
-- Name: IX_QuestionOptions_FieldTypeId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_FieldTypeId" ON templates."QuestionOptions" USING btree ("FieldTypeId");


--
-- TOC entry 5138 (class 1259 OID 58863)
-- Name: IX_QuestionOptions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_ModifiedById" ON templates."QuestionOptions" USING btree ("ModifiedById");


--
-- TOC entry 5139 (class 1259 OID 58864)
-- Name: IX_QuestionOptions_OptionGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_OptionGuid" ON templates."QuestionOptions" USING btree ("OptionGuid");


--
-- TOC entry 5140 (class 1259 OID 58865)
-- Name: IX_QuestionOptions_QuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_QuestionId" ON templates."QuestionOptions" USING btree ("QuestionId");


--
-- TOC entry 5143 (class 1259 OID 58866)
-- Name: IX_Questions_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_BusinessId" ON templates."Questions" USING btree (business_id);


--
-- TOC entry 5144 (class 1259 OID 58867)
-- Name: IX_Questions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_CreatedById" ON templates."Questions" USING btree ("CreatedById");


--
-- TOC entry 5145 (class 1259 OID 58868)
-- Name: IX_Questions_FieldTypeId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_FieldTypeId" ON templates."Questions" USING btree ("FieldTypeId");


--
-- TOC entry 5146 (class 1259 OID 58869)
-- Name: IX_Questions_Guid_VersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_Guid_VersionId" ON templates."Questions" USING btree ("QuestionGuid", "TemplateVersionId");


--
-- TOC entry 5147 (class 1259 OID 58870)
-- Name: IX_Questions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_ModifiedById" ON templates."Questions" USING btree ("ModifiedById");


--
-- TOC entry 5148 (class 1259 OID 58871)
-- Name: IX_Questions_QuestionGroupId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_QuestionGroupId" ON templates."Questions" USING btree ("QuestionGroupId");


--
-- TOC entry 5149 (class 1259 OID 58872)
-- Name: IX_Questions_QuestionGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_QuestionGuid" ON templates."Questions" USING btree ("QuestionGuid");


--
-- TOC entry 5150 (class 1259 OID 58873)
-- Name: IX_Questions_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_TemplateId" ON templates."Questions" USING btree ("TemplateId");


--
-- TOC entry 5151 (class 1259 OID 58874)
-- Name: IX_Questions_TemplateVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_TemplateVersionId" ON templates."Questions" USING btree ("TemplateVersionId");


--
-- TOC entry 5154 (class 1259 OID 58875)
-- Name: IX_TemplateItems_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateItems_BusinessId" ON templates."TemplateItems" USING btree (business_id);


--
-- TOC entry 5155 (class 1259 OID 58876)
-- Name: IX_TemplateItems_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateItems_TemplateId" ON templates."TemplateItems" USING btree ("TemplateId");


--
-- TOC entry 5158 (class 1259 OID 58877)
-- Name: IX_TemplateVersions_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_BusinessId" ON templates."TemplateVersions" USING btree (business_id);


--
-- TOC entry 5159 (class 1259 OID 58878)
-- Name: IX_TemplateVersions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_CreatedById" ON templates."TemplateVersions" USING btree ("CreatedById");


--
-- TOC entry 5160 (class 1259 OID 58879)
-- Name: IX_TemplateVersions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_ModifiedById" ON templates."TemplateVersions" USING btree ("ModifiedById");


--
-- TOC entry 5161 (class 1259 OID 58880)
-- Name: IX_TemplateVersions_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_TemplateId" ON templates."TemplateVersions" USING btree ("TemplateId");


--
-- TOC entry 5164 (class 1259 OID 58881)
-- Name: IX_Templates_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_BusinessId" ON templates."Templates" USING btree (business_id);


--
-- TOC entry 5165 (class 1259 OID 58882)
-- Name: IX_Templates_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_CreatedById" ON templates."Templates" USING btree ("CreatedById");


--
-- TOC entry 5166 (class 1259 OID 58883)
-- Name: IX_Templates_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_ModifiedById" ON templates."Templates" USING btree ("ModifiedById");


--
-- TOC entry 5169 (class 1259 OID 58884)
-- Name: IX_UserAnswers_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_BusinessId" ON templates."UserAnswers" USING btree (business_id);


--
-- TOC entry 5170 (class 1259 OID 58885)
-- Name: IX_UserAnswers_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_CreatedById" ON templates."UserAnswers" USING btree ("CreatedById");


--
-- TOC entry 5171 (class 1259 OID 58886)
-- Name: IX_UserAnswers_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_ModifiedById" ON templates."UserAnswers" USING btree ("ModifiedById");


--
-- TOC entry 5172 (class 1259 OID 58887)
-- Name: IX_UserAnswers_ParentOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_ParentOptionId" ON templates."UserAnswers" USING btree ("ParentOptionId");


--
-- TOC entry 5173 (class 1259 OID 58888)
-- Name: IX_UserAnswers_QOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QOptionId" ON templates."UserAnswers" USING btree ("QOptionId");


--
-- TOC entry 5174 (class 1259 OID 58889)
-- Name: IX_UserAnswers_QuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuestionId" ON templates."UserAnswers" USING btree ("QuestionId");


--
-- TOC entry 5175 (class 1259 OID 58890)
-- Name: IX_UserAnswers_QuestionId_ParentOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuestionId_ParentOptionId" ON templates."UserAnswers" USING btree ("QuestionId", "ParentOptionId");


--
-- TOC entry 5176 (class 1259 OID 58891)
-- Name: IX_UserAnswers_QuoteVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuoteVersionId" ON templates."UserAnswers" USING btree ("QuoteVersionId");


--
-- TOC entry 5177 (class 1259 OID 58892)
-- Name: IX_UserAnswers_RecordId_QuoteVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_RecordId_QuoteVersionId" ON templates."UserAnswers" USING btree ("RecordId", "QuoteVersionId");


--
-- TOC entry 5180 (class 1259 OID 58893)
-- Name: IX_UserRecords_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_CreatedById" ON templates."UserRecords" USING btree ("CreatedById");


--
-- TOC entry 5181 (class 1259 OID 58894)
-- Name: IX_UserRecords_MiscLookupCodeEnum; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_MiscLookupCodeEnum" ON templates."UserRecords" USING btree ("MiscLookupCodeEnum");


--
-- TOC entry 5182 (class 1259 OID 58895)
-- Name: IX_UserRecords_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_ModifiedById" ON templates."UserRecords" USING btree ("ModifiedById");


--
-- TOC entry 5183 (class 1259 OID 58896)
-- Name: IX_UserRecords_TempVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_TempVersionId" ON templates."UserRecords" USING btree ("TempVersionId");


--
-- TOC entry 5184 (class 1259 OID 58897)
-- Name: IX_UserRecords_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_TemplateId" ON templates."UserRecords" USING btree ("TemplateId");


--
-- TOC entry 5187 (class 2606 OID 58898)
-- Name: customers fk_customers_business; Type: FK CONSTRAINT; Schema: customers; Owner: postgres
--

ALTER TABLE ONLY customers.customers
    ADD CONSTRAINT fk_customers_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5188 (class 2606 OID 58903)
-- Name: Statistics FK_Statistics_Business; Type: FK CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics"
    ADD CONSTRAINT "FK_Statistics_Business" FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5190 (class 2606 OID 58908)
-- Name: MaterialComponents FK_MaterialComponents_Components_ComponentId; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "FK_MaterialComponents_Components_ComponentId" FOREIGN KEY ("ComponentId") REFERENCES inventory."Components"("ComponentId") ON DELETE CASCADE;


--
-- TOC entry 5191 (class 2606 OID 58913)
-- Name: MaterialComponents FK_MaterialComponents_Materials_MaterialId; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "FK_MaterialComponents_Materials_MaterialId" FOREIGN KEY ("MaterialId") REFERENCES inventory."Materials"("MaterialId") ON DELETE CASCADE;


--
-- TOC entry 5189 (class 2606 OID 58918)
-- Name: Components fk_components_business; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Components"
    ADD CONSTRAINT fk_components_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5192 (class 2606 OID 58923)
-- Name: Materials fk_materials_business; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Materials"
    ADD CONSTRAINT fk_materials_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5193 (class 2606 OID 58928)
-- Name: MiscLookups FK_MiscLookups_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "FK_MiscLookups_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5194 (class 2606 OID 58933)
-- Name: MiscLookups FK_MiscLookups_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "FK_MiscLookups_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5195 (class 2606 OID 58938)
-- Name: UserRecords fk_userrecords_business; Type: FK CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."UserRecords"
    ADD CONSTRAINT fk_userrecords_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5196 (class 2606 OID 58943)
-- Name: roles_claims FK_roles_claims_roles_RoleId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles_claims
    ADD CONSTRAINT "FK_roles_claims_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES security.roles("Id") ON DELETE CASCADE;


--
-- TOC entry 5197 (class 2606 OID 58948)
-- Name: user_claims FK_user_claims_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_claims
    ADD CONSTRAINT "FK_user_claims_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5198 (class 2606 OID 58953)
-- Name: user_logins FK_user_logins_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_logins
    ADD CONSTRAINT "FK_user_logins_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5199 (class 2606 OID 58958)
-- Name: user_roles FK_user_roles_roles_RoleId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "FK_user_roles_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES security.roles("Id") ON DELETE CASCADE;


--
-- TOC entry 5200 (class 2606 OID 58963)
-- Name: user_roles FK_user_roles_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "FK_user_roles_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5201 (class 2606 OID 58968)
-- Name: user_tokens FK_user_tokens_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_tokens
    ADD CONSTRAINT "FK_user_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5202 (class 2606 OID 58973)
-- Name: DependentQuestions FK_DependentQuestions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5203 (class 2606 OID 58978)
-- Name: DependentQuestions FK_DependentQuestions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5204 (class 2606 OID 58983)
-- Name: DependentQuestions FK_DependentQuestions_QuestionOptions_QOptionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_QuestionOptions_QOptionId" FOREIGN KEY ("QOptionId") REFERENCES templates."QuestionOptions"("QOptionId");


--
-- TOC entry 5205 (class 2606 OID 58988)
-- Name: DependentQuestions FK_DependentQuestions_Questions_NextQuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_Questions_NextQuestionId" FOREIGN KEY ("NextQuestionId") REFERENCES templates."Questions"("QuestionId");


--
-- TOC entry 5206 (class 2606 OID 58993)
-- Name: FieldTypes FK_FieldTypes_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "FK_FieldTypes_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5207 (class 2606 OID 58998)
-- Name: FieldTypes FK_FieldTypes_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "FK_FieldTypes_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5208 (class 2606 OID 59003)
-- Name: Iframes FK_Iframes_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Iframes"
    ADD CONSTRAINT "FK_Iframes_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5212 (class 2606 OID 59008)
-- Name: Metafields FK_Metafields_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Metafields"
    ADD CONSTRAINT "FK_Metafields_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5213 (class 2606 OID 59013)
-- Name: QuestionGroups FK_QuestionGroups_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5214 (class 2606 OID 59018)
-- Name: QuestionGroups FK_QuestionGroups_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5215 (class 2606 OID 59023)
-- Name: QuestionGroups FK_QuestionGroups_TemplateVersions_TemplateVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_TemplateVersions_TemplateVersionId" FOREIGN KEY ("TemplateVersionId") REFERENCES templates."TemplateVersions"("TempVersionId");


--
-- TOC entry 5216 (class 2606 OID 59028)
-- Name: QuestionGroups FK_QuestionGroups_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5218 (class 2606 OID 59033)
-- Name: QuestionOptions FK_QuestionOptions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5219 (class 2606 OID 59038)
-- Name: QuestionOptions FK_QuestionOptions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5220 (class 2606 OID 59043)
-- Name: QuestionOptions FK_QuestionOptions_FieldTypes_FieldTypeId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_FieldTypes_FieldTypeId" FOREIGN KEY ("FieldTypeId") REFERENCES templates."FieldTypes"("FieldTypeId");


--
-- TOC entry 5221 (class 2606 OID 59048)
-- Name: QuestionOptions FK_QuestionOptions_Questions_QuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_Questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES templates."Questions"("QuestionId") ON DELETE CASCADE;


--
-- TOC entry 5222 (class 2606 OID 59053)
-- Name: Questions FK_Questions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5223 (class 2606 OID 59058)
-- Name: Questions FK_Questions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5224 (class 2606 OID 59063)
-- Name: Questions FK_Questions_FieldTypes_FieldTypeId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_FieldTypes_FieldTypeId" FOREIGN KEY ("FieldTypeId") REFERENCES templates."FieldTypes"("FieldTypeId");


--
-- TOC entry 5225 (class 2606 OID 59068)
-- Name: Questions FK_Questions_QuestionGroups_QuestionGroupId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_QuestionGroups_QuestionGroupId" FOREIGN KEY ("QuestionGroupId") REFERENCES templates."QuestionGroups"("QuestionGroupId") ON DELETE CASCADE;


--
-- TOC entry 5226 (class 2606 OID 59073)
-- Name: Questions FK_Questions_TemplateVersions_TemplateVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_TemplateVersions_TemplateVersionId" FOREIGN KEY ("TemplateVersionId") REFERENCES templates."TemplateVersions"("TempVersionId");


--
-- TOC entry 5227 (class 2606 OID 59078)
-- Name: Questions FK_Questions_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5229 (class 2606 OID 59083)
-- Name: TemplateItems FK_TemplateItems_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT "FK_TemplateItems_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5231 (class 2606 OID 59088)
-- Name: TemplateVersions FK_TemplateVersions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5232 (class 2606 OID 59093)
-- Name: TemplateVersions FK_TemplateVersions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5233 (class 2606 OID 59098)
-- Name: TemplateVersions FK_TemplateVersions_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5235 (class 2606 OID 59103)
-- Name: Templates FK_Templates_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "FK_Templates_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5236 (class 2606 OID 59108)
-- Name: Templates FK_Templates_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "FK_Templates_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5238 (class 2606 OID 59113)
-- Name: UserAnswers FK_UserAnswers_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5239 (class 2606 OID 59118)
-- Name: UserAnswers FK_UserAnswers_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5240 (class 2606 OID 59123)
-- Name: UserAnswers FK_UserAnswers_QuestionOptions_QOptionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_QuestionOptions_QOptionId" FOREIGN KEY ("QOptionId") REFERENCES templates."QuestionOptions"("QOptionId");


--
-- TOC entry 5241 (class 2606 OID 59128)
-- Name: UserAnswers FK_UserAnswers_Questions_QuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_Questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES templates."Questions"("QuestionId") ON DELETE CASCADE;


--
-- TOC entry 5243 (class 2606 OID 59133)
-- Name: UserRecords FK_UserRecords_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5244 (class 2606 OID 59138)
-- Name: UserRecords FK_UserRecords_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5245 (class 2606 OID 59143)
-- Name: UserRecords FK_UserRecords_MiscLookups_MiscLookupCodeEnum; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_MiscLookups_MiscLookupCodeEnum" FOREIGN KEY ("MiscLookupCodeEnum") REFERENCES misc."MiscLookups"("CodeEnum");


--
-- TOC entry 5246 (class 2606 OID 59148)
-- Name: UserRecords FK_UserRecords_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5247 (class 2606 OID 59153)
-- Name: UserRecords FK_UserRecords_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5209 (class 2606 OID 59158)
-- Name: MetafieldAnswers fk_metafield; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_metafield FOREIGN KEY (metafield_id) REFERENCES templates."Metafields"("PID") ON DELETE RESTRICT;


--
-- TOC entry 5217 (class 2606 OID 59163)
-- Name: QuestionGroups fk_questiongroups_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT fk_questiongroups_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5228 (class 2606 OID 59168)
-- Name: Questions fk_questions_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT fk_questions_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5210 (class 2606 OID 59173)
-- Name: MetafieldAnswers fk_quote; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_quote FOREIGN KEY (quote_id) REFERENCES quotes."UserRecords"("RecStatusId") ON DELETE RESTRICT;


--
-- TOC entry 5211 (class 2606 OID 59178)
-- Name: MetafieldAnswers fk_template_version; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_template_version FOREIGN KEY (template_version_id) REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE RESTRICT;


--
-- TOC entry 5230 (class 2606 OID 59183)
-- Name: TemplateItems fk_templateitems_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT fk_templateitems_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5237 (class 2606 OID 59188)
-- Name: Templates fk_templates_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT fk_templates_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5234 (class 2606 OID 59193)
-- Name: TemplateVersions fk_templateversions_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT fk_templateversions_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5242 (class 2606 OID 59198)
-- Name: UserAnswers fk_useranswers_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT fk_useranswers_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


-- Completed on 2026-03-13 00:02:40

--
-- PostgreSQL database dump complete
--

\unrestrict FzeBceXOHYqPHseh8AQhxs9zFQLbyamTBKR7Tqoir61XALCTqfORmfILGNa0fYE

