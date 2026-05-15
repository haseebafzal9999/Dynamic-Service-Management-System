--
-- PostgreSQL database dump
--

\restrict nim5Vj8llDzwW3YcrEEYEnWCt5wJeYSNKp6IfGWjCXIhJGx8XeZbgCuEddKgoA9

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.0

-- Started on 2026-03-30 23:06:12

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
-- TOC entry 7 (class 2615 OID 81544)
-- Name: customers; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA customers;


ALTER SCHEMA customers OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 81545)
-- Name: general; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA general;


ALTER SCHEMA general OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 81546)
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 81547)
-- Name: misc; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA misc;


ALTER SCHEMA misc OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 81548)
-- Name: quotes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA quotes;


ALTER SCHEMA quotes OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 81549)
-- Name: security; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA security;


ALTER SCHEMA security OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 81550)
-- Name: templates; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA templates;


ALTER SCHEMA templates OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 81551)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 81589)
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
    business_id integer,
    company character varying(255)
);


ALTER TABLE customers.customers OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 81599)
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
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 228
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: customers; Owner: postgres
--

ALTER SEQUENCE customers.customers_customer_id_seq OWNED BY customers.customers.customer_id;


--
-- TOC entry 229 (class 1259 OID 81600)
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
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE "Statistics"; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON TABLE general."Statistics" IS 'Stores aggregated statistics for quotes, templates, and customers';


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_quotes; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_quotes IS 'Total number of quotes';


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_quotes_value; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_quotes_value IS 'Total value of all quotes';


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_template; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_template IS 'Total number of templates';


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN "Statistics".total_customer; Type: COMMENT; Schema: general; Owner: postgres
--

COMMENT ON COLUMN general."Statistics".total_customer IS 'Total number of customers';


--
-- TOC entry 230 (class 1259 OID 81613)
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
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 230
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general."Statistics_statistic_id_seq" OWNED BY general."Statistics".statistic_id;


--
-- TOC entry 231 (class 1259 OID 81614)
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
    currency_identity text DEFAULT 'en-GB'::text,
    timezoneid character varying(100),
    website text,
    address_line_2 text
);


ALTER TABLE general.business OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 81624)
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
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 232
-- Name: business_business_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.business_business_id_seq OWNED BY general.business.business_id;


--
-- TOC entry 233 (class 1259 OID 81625)
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
-- TOC entry 234 (class 1259 OID 81635)
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
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 234
-- Name: business_document_business_document_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.business_document_business_document_id_seq OWNED BY general.business_document.business_document_id;


--
-- TOC entry 235 (class 1259 OID 81636)
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
-- TOC entry 236 (class 1259 OID 81644)
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
-- TOC entry 237 (class 1259 OID 81661)
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
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 237
-- Name: menu_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: general; Owner: postgres
--

ALTER SEQUENCE general.menu_menu_id_seq OWNED BY general.menu.menu_id;


--
-- TOC entry 238 (class 1259 OID 81662)
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
-- TOC entry 239 (class 1259 OID 81677)
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
-- TOC entry 240 (class 1259 OID 81678)
-- Name: MaterialComponentHistory; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory."MaterialComponentHistory" (
    "HistoryId" integer NOT NULL,
    "MaterialComponentId" integer NOT NULL,
    "MaterialComponentType" text NOT NULL,
    "MaterialId" integer,
    "ComponentId" integer,
    "Name" text,
    "Description" text,
    "CostPrice" numeric,
    "SellPrice" numeric,
    "IsActive" boolean,
    "PartNo" text,
    "Supplier" text,
    "CreatedAt" timestamp with time zone,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer
);


ALTER TABLE inventory."MaterialComponentHistory" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 81686)
-- Name: MaterialComponentHistory_HistoryId_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory."MaterialComponentHistory" ALTER COLUMN "HistoryId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory."MaterialComponentHistory_HistoryId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 81687)
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
-- TOC entry 243 (class 1259 OID 81697)
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
-- TOC entry 244 (class 1259 OID 81698)
-- Name: Materials; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory."Materials" (
    "MaterialId" integer NOT NULL,
    "Name" text,
    "Description" text,
    "SellPrice" numeric,
    "IsActive" boolean,
    "CreatedAt" timestamp with time zone,
    "CostPrice" numeric,
    "PartNo" text,
    "Supplier" text,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    business_id integer
);


ALTER TABLE inventory."Materials" OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 81704)
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
-- TOC entry 246 (class 1259 OID 81705)
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
-- TOC entry 247 (class 1259 OID 81715)
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
-- TOC entry 248 (class 1259 OID 81716)
-- Name: code_lookup; Type: TABLE; Schema: misc; Owner: postgres
--

CREATE TABLE misc.code_lookup (
    code_name text NOT NULL,
    code_enum integer NOT NULL,
    code_text text
);


ALTER TABLE misc.code_lookup OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 81723)
-- Name: countries; Type: TABLE; Schema: misc; Owner: postgres
--

CREATE TABLE misc.countries (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE misc.countries OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 81730)
-- Name: countries_id_seq; Type: SEQUENCE; Schema: misc; Owner: postgres
--

CREATE SEQUENCE misc.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE misc.countries_id_seq OWNER TO postgres;

--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 250
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: misc; Owner: postgres
--

ALTER SEQUENCE misc.countries_id_seq OWNED BY misc.countries.id;


--
-- TOC entry 251 (class 1259 OID 81731)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 81736)
-- Name: QuoteRevisions; Type: TABLE; Schema: quotes; Owner: postgres
--

CREATE TABLE quotes."QuoteRevisions" (
    "QuoteRevisionId" integer NOT NULL,
    "QuoteId" integer NOT NULL,
    "CreatedBy" character varying(128) NOT NULL,
    "CreatedAt" timestamp without time zone NOT NULL,
    "StatusId" integer
);


ALTER TABLE quotes."QuoteRevisions" OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 81743)
-- Name: QuoteRevisions_QuoteRevisionId_seq; Type: SEQUENCE; Schema: quotes; Owner: postgres
--

CREATE SEQUENCE quotes."QuoteRevisions_QuoteRevisionId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE quotes."QuoteRevisions_QuoteRevisionId_seq" OWNER TO postgres;

--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 253
-- Name: QuoteRevisions_QuoteRevisionId_seq; Type: SEQUENCE OWNED BY; Schema: quotes; Owner: postgres
--

ALTER SEQUENCE quotes."QuoteRevisions_QuoteRevisionId_seq" OWNED BY quotes."QuoteRevisions"."QuoteRevisionId";


--
-- TOC entry 254 (class 1259 OID 81744)
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
-- TOC entry 255 (class 1259 OID 81764)
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
-- TOC entry 256 (class 1259 OID 81765)
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
-- TOC entry 257 (class 1259 OID 81778)
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

CREATE SEQUENCE security."RefreshTokens_Id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE security."RefreshTokens_Id_seq" OWNER TO postgres;

--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 257
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE OWNED BY; Schema: security; Owner: postgres
--

ALTER SEQUENCE security."RefreshTokens_Id_seq" OWNED BY security."RefreshTokens"."Id";


--
-- TOC entry 258 (class 1259 OID 81779)
-- Name: jwt_settings; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.jwt_settings (
    "Id" integer DEFAULT 1 NOT NULL,
    "Key" character varying(256) NOT NULL,
    "Issuer" character varying(100) NOT NULL,
    "Audience" character varying(100) NOT NULL,
    "AccessTokenExpiryMinutes" integer DEFAULT 15 NOT NULL,
    "RefreshTokenExpiryDays" integer DEFAULT 7 NOT NULL,
    "UpdatedAt" timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    CONSTRAINT "CK_jwt_settings_key_length" CHECK ((length(("Key")::text) >= 32)),
    CONSTRAINT "CK_jwt_settings_positive_expiry" CHECK ((("AccessTokenExpiryMinutes" > 0) AND ("RefreshTokenExpiryDays" > 0))),
    CONSTRAINT "CK_jwt_settings_single_row" CHECK (("Id" = 1))
);


ALTER TABLE security.jwt_settings OWNER TO postgres;

--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE jwt_settings; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON TABLE security.jwt_settings IS 'Stores global JWT configuration. Uses single-row pattern (Id always 1).';


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN jwt_settings."Key"; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON COLUMN security.jwt_settings."Key" IS 'Secret key for signing JWT tokens (minimum 256 bits / 32 chars).';


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN jwt_settings."UpdatedAt"; Type: COMMENT; Schema: security; Owner: postgres
--

COMMENT ON COLUMN security.jwt_settings."UpdatedAt" IS 'UTC timestamp of last update for auditing.';


--
-- TOC entry 259 (class 1259 OID 81796)
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
-- TOC entry 260 (class 1259 OID 81804)
-- Name: roles; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.roles (
    "Id" text NOT NULL,
    "Name" character varying(256),
    "NormalizedName" character varying(256),
    "ConcurrencyStamp" text,
    "RoleId" integer NOT NULL
);


ALTER TABLE security.roles OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 81811)
-- Name: roles_RoleId_seq; Type: SEQUENCE; Schema: security; Owner: postgres
--

ALTER TABLE security.roles ALTER COLUMN "RoleId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME security."roles_RoleId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 262 (class 1259 OID 81812)
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
-- TOC entry 263 (class 1259 OID 81819)
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
-- TOC entry 264 (class 1259 OID 81820)
-- Name: security_group; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.security_group (
    security_group_id integer NOT NULL,
    parent_id integer NOT NULL,
    security_group_name text NOT NULL,
    api_path text NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    date_created timestamp without time zone DEFAULT now() NOT NULL,
    business_id integer,
    description text
);


ALTER TABLE security.security_group OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 81832)
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
-- TOC entry 266 (class 1259 OID 81840)
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
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 266
-- Name: security_group_members_security_group_id_seq; Type: SEQUENCE OWNED BY; Schema: security; Owner: postgres
--

ALTER SEQUENCE security.security_group_members_security_group_id_seq OWNED BY security.security_group_members.security_group_id;


--
-- TOC entry 267 (class 1259 OID 81841)
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
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 267
-- Name: security_group_sec_group_id_seq; Type: SEQUENCE OWNED BY; Schema: security; Owner: postgres
--

ALTER SEQUENCE security.security_group_sec_group_id_seq OWNED BY security.security_group.security_group_id;


--
-- TOC entry 268 (class 1259 OID 81842)
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
-- TOC entry 269 (class 1259 OID 81849)
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
-- TOC entry 270 (class 1259 OID 81850)
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
-- TOC entry 271 (class 1259 OID 81858)
-- Name: user_roles; Type: TABLE; Schema: security; Owner: postgres
--

CREATE TABLE security.user_roles (
    "UserId" text NOT NULL,
    "RoleId" text NOT NULL
);


ALTER TABLE security.user_roles OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 81865)
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
-- TOC entry 273 (class 1259 OID 81873)
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
    "IsDeleted" boolean DEFAULT false,
    "PasswordResetPin" character varying(6),
    "PasswordResetPinExpiry" timestamp with time zone,
    "PasswordResetToken" text,
    "PasswordResetTokenExpiry" timestamp with time zone,
    "Address" character varying(255),
    "AddressLine2" character varying(255),
    "City" character varying(100),
    "Postcode" character varying(50),
    "CountryId" integer
);


ALTER TABLE security.users OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 81889)
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
-- TOC entry 275 (class 1259 OID 81890)
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
-- TOC entry 276 (class 1259 OID 81898)
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
-- TOC entry 277 (class 1259 OID 81899)
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
-- TOC entry 278 (class 1259 OID 81908)
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
-- TOC entry 279 (class 1259 OID 81909)
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
-- TOC entry 280 (class 1259 OID 81920)
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
-- TOC entry 281 (class 1259 OID 81921)
-- Name: MetafieldAnswers; Type: TABLE; Schema: templates; Owner: postgres
--

CREATE TABLE templates."MetafieldAnswers" (
    metafield_answer_id integer NOT NULL,
    template_version_id integer NOT NULL,
    quote_id integer NOT NULL,
    metafield_id integer NOT NULL,
    metafield_input text,
    "QuoteRevisionId" integer
);


ALTER TABLE templates."MetafieldAnswers" OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 81930)
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
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 282
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE OWNED BY; Schema: templates; Owner: postgres
--

ALTER SEQUENCE templates."MetafieldAnswers_metafield_answer_id_seq" OWNED BY templates."MetafieldAnswers".metafield_answer_id;


--
-- TOC entry 283 (class 1259 OID 81931)
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
    "MetafieldGuid" uuid DEFAULT gen_random_uuid() NOT NULL,
    "DisplayOrder" integer DEFAULT 1 NOT NULL
);


ALTER TABLE templates."Metafields" OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 81948)
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
-- TOC entry 285 (class 1259 OID 81949)
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
-- TOC entry 286 (class 1259 OID 81962)
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
-- TOC entry 287 (class 1259 OID 81963)
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
    "OptionGuid" uuid DEFAULT gen_random_uuid() NOT NULL,
    "MaterialComponentAssociationId" integer
);


ALTER TABLE templates."QuestionOptions" OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 81976)
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
-- TOC entry 289 (class 1259 OID 81977)
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
-- TOC entry 290 (class 1259 OID 81992)
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
-- TOC entry 291 (class 1259 OID 81993)
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
    "CreatedAt" timestamp with time zone,
    "IsActive" boolean DEFAULT false NOT NULL,
    "ModifiedAt" timestamp with time zone,
    "CreatedById" text,
    "ModifiedById" text,
    "QuoteId" integer,
    "CustomerId" integer,
    business_id integer,
    "QuoteRevisionId" integer,
    "CostPrice" numeric(18,2),
    "LevelNumber" integer
);


ALTER TABLE templates."TemplateItems" OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 82002)
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
-- TOC entry 293 (class 1259 OID 82003)
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
    business_id integer,
    template_path text
);


ALTER TABLE templates."TemplateVersions" OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 82012)
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
-- TOC entry 295 (class 1259 OID 82013)
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
-- TOC entry 296 (class 1259 OID 82022)
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
-- TOC entry 297 (class 1259 OID 82023)
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
    "ParentOptionId" integer,
    "QuoteRevisionId" integer
);


ALTER TABLE templates."UserAnswers" OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 82034)
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
-- TOC entry 299 (class 1259 OID 82035)
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
-- TOC entry 300 (class 1259 OID 82051)
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
-- TOC entry 4992 (class 2604 OID 82052)
-- Name: customers customer_id; Type: DEFAULT; Schema: customers; Owner: postgres
--

ALTER TABLE ONLY customers.customers ALTER COLUMN customer_id SET DEFAULT nextval('customers.customers_customer_id_seq'::regclass);


--
-- TOC entry 4995 (class 2604 OID 82053)
-- Name: Statistics statistic_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics" ALTER COLUMN statistic_id SET DEFAULT nextval('general."Statistics_statistic_id_seq"'::regclass);


--
-- TOC entry 5001 (class 2604 OID 82054)
-- Name: business business_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business ALTER COLUMN business_id SET DEFAULT nextval('general.business_business_id_seq'::regclass);


--
-- TOC entry 5005 (class 2604 OID 82055)
-- Name: business_document business_document_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business_document ALTER COLUMN business_document_id SET DEFAULT nextval('general.business_document_business_document_id_seq'::regclass);


--
-- TOC entry 5008 (class 2604 OID 82056)
-- Name: menu menu_id; Type: DEFAULT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.menu ALTER COLUMN menu_id SET DEFAULT nextval('general.menu_menu_id_seq'::regclass);


--
-- TOC entry 5017 (class 2604 OID 82057)
-- Name: countries id; Type: DEFAULT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc.countries ALTER COLUMN id SET DEFAULT nextval('misc.countries_id_seq'::regclass);


--
-- TOC entry 5020 (class 2604 OID 82058)
-- Name: QuoteRevisions QuoteRevisionId; Type: DEFAULT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."QuoteRevisions" ALTER COLUMN "QuoteRevisionId" SET DEFAULT nextval('quotes."QuoteRevisions_QuoteRevisionId_seq"'::regclass);


--
-- TOC entry 5025 (class 2604 OID 82059)
-- Name: RefreshTokens Id; Type: DEFAULT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security."RefreshTokens" ALTER COLUMN "Id" SET DEFAULT nextval('security."RefreshTokens_Id_seq"'::regclass);


--
-- TOC entry 5033 (class 2604 OID 82060)
-- Name: security_group security_group_id; Type: DEFAULT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group ALTER COLUMN security_group_id SET DEFAULT nextval('security.security_group_sec_group_id_seq'::regclass);


--
-- TOC entry 5040 (class 2604 OID 82061)
-- Name: MetafieldAnswers metafield_answer_id; Type: DEFAULT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers" ALTER COLUMN metafield_answer_id SET DEFAULT nextval('templates."MetafieldAnswers_metafield_answer_id_seq"'::regclass);


--
-- TOC entry 5429 (class 0 OID 81589)
-- Dependencies: 227
-- Data for Name: customers; Type: TABLE DATA; Schema: customers; Owner: postgres
--

COPY customers.customers (customer_id, first_name, last_name, email, phone_number, address, appartment_suite, city, postalcode, country, user_id, "CreatedAt", "CreatedById", "ModifiedAt", "ModifiedById", "IsActive", "IsDeleted", business_id, company) FROM stdin;
2	Testing 2	Customer 2	Test2@Customer2.com	+234567	NY	N/A	NY	1100	Bahrain	\N	2026-03-27 18:35:24.19479	74ca72ad-4e91-4384-89eb-925be075e300	\N	\N	t	f	1	Company 2
3	Testing 3	Customer 3	Test3@Customer3.com	+234567	NY	N/A	NY	1100	Zimbabwe	\N	2026-03-27 18:35:50.71644	74ca72ad-4e91-4384-89eb-925be075e300	\N	\N	t	f	1	Company 3
1	New	Customer	Test1@Customer1.com	+34567	NY	N/A	NY	12000	Albania	025061e6-e30b-4dee-bafc-6230e032ac54	2026-03-26 14:14:13.297499	\N	2026-03-28 15:10:14.009984	025061e6-e30b-4dee-bafc-6230e032ac54	t	f	1	Company 1
\.


--
-- TOC entry 5431 (class 0 OID 81600)
-- Dependencies: 229
-- Data for Name: Statistics; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general."Statistics" (statistic_id, total_quotes, total_quotes_value, total_template, total_customer, business_id, created_at, created_by_id, modified_at, modified_by_id) FROM stdin;
1	0	0.00	0	0	1	2026-03-25 19:05:00.466298	SYSTEM_SCHEDULER	2026-03-25 19:05:00.466459	SYSTEM_SCHEDULER
2	0	0.00	0	0	2	2026-03-25 19:05:00.695723	SYSTEM_SCHEDULER	2026-03-25 19:05:00.695724	SYSTEM_SCHEDULER
3	0	0.00	0	0	2	2026-03-26 19:05:00.199906	SYSTEM_SCHEDULER	2026-03-26 19:05:00.200097	SYSTEM_SCHEDULER
4	0	0.00	0	0	1	2026-03-26 19:05:00.287879	SYSTEM_SCHEDULER	2026-03-26 19:05:00.28788	SYSTEM_SCHEDULER
5	0	0.00	0	0	3	2026-03-26 19:05:00.309982	SYSTEM_SCHEDULER	2026-03-26 19:05:00.309984	SYSTEM_SCHEDULER
6	1	60.00	0	2	1	2026-03-27 16:51:01.057765	74ca72ad-4e91-4384-89eb-925be075e300	2026-03-27 19:01:17.304667	74ca72ad-4e91-4384-89eb-925be075e300
8	0	0.00	0	0	3	2026-03-28 19:05:00.704057	SYSTEM_SCHEDULER	2026-03-28 19:05:00.705239	SYSTEM_SCHEDULER
9	0	0.00	0	0	2	2026-03-28 19:05:00.817848	SYSTEM_SCHEDULER	2026-03-28 19:05:00.81785	SYSTEM_SCHEDULER
10	0	0.00	0	0	4	2026-03-28 19:05:00.925395	SYSTEM_SCHEDULER	2026-03-28 19:05:00.925396	SYSTEM_SCHEDULER
7	9	9630.00	2	3	1	2026-03-28 14:28:39.351252	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 19:16:23.583275	ce8bb747-624d-46c2-9d76-da557a53dd90
11	0	0.00	0	0	2	2026-03-30 14:17:14.382247	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	2026-03-30 14:17:14.382448	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada
\.


--
-- TOC entry 5433 (class 0 OID 81614)
-- Dependencies: 231
-- Data for Name: business; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business (business_id, name, phone_number, email, address_first_line, city_town, postcode, country, currency, currency_identity, timezoneid, website, address_line_2) FROM stdin;
1	Business 1	+12345678	business1@gmail.com		NY	12000	Albania	USD	en-US	Pakistan Standard Time	/business1/website	
2	Business 2	+12345678	business2@gmail.com		NY	12000	Albania	USD	en-US	Pakistan Standard Time	/business2/website	
3	Business 3	+12345678	business3@gmail.com		NY	12000	Albania	USD	en-US	PST	/business3/website	
4	Business 4	+12345678	business4@gmail.com		NY	12000	Peru	USD	en-US	Pakistan Standard Time	/business4/website	
\.


--
-- TOC entry 5435 (class 0 OID 81625)
-- Dependencies: 233
-- Data for Name: business_document; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business_document (business_document_id, business_id, document_type, document_name, expiry_date, actions, created_on, created_by) FROM stdin;
\.


--
-- TOC entry 5437 (class 0 OID 81636)
-- Dependencies: 235
-- Data for Name: business_menu; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business_menu (business_id, menu_id, created_on, created_by, last_updated_on, last_updated_by) FROM stdin;
\.


--
-- TOC entry 5438 (class 0 OID 81644)
-- Dependencies: 236
-- Data for Name: menu; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.menu (menu_id, parent_id, name, link, link_type, image_ref, show_always, show_in_toolbar, sequence_number, created_on, last_updated_on) FROM stdin;
1	0	Home	/	1	/images/home.svg	t	t	1	2026-03-25 23:24:22.125625	\N
2	0	Quotes	/page/quotes	1	/images/quote.svg	t	t	2	2026-03-25 23:24:22.125625	\N
3	0	Customers	/page/customers	1	/images/customers.svg	t	t	3	2026-03-25 23:24:22.125625	\N
4	0	Components	/page/components	1	/images/components.svg	t	t	4	2026-03-25 23:24:22.125625	\N
5	0	Materials	/page/materials	1	/images/materials.svg	t	t	5	2026-03-25 23:24:22.125625	\N
6	0	Templates	/page/templates	1	/images/templates.svg	t	t	6	2026-03-25 23:24:22.125625	\N
\.


--
-- TOC entry 5440 (class 0 OID 81662)
-- Dependencies: 238
-- Data for Name: Components; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."Components" ("ComponentId", "Name", "Description", "BuildCost", "IsActive", "CreatedAt", "PartNo", "SellPrice", "Supplier", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
1	Component 1	Comp Descrption 1	100	t	2026-03-27 21:40:02.061741+05	Part 1	200	John	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
2	Component 2	Comp Description 2	200	t	2026-03-27 21:43:16.507716+05	Part 2	400	Dave	2026-03-27 21:49:59.159324+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	1
\.


--
-- TOC entry 5442 (class 0 OID 81678)
-- Dependencies: 240
-- Data for Name: MaterialComponentHistory; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."MaterialComponentHistory" ("HistoryId", "MaterialComponentId", "MaterialComponentType", "MaterialId", "ComponentId", "Name", "Description", "CostPrice", "SellPrice", "IsActive", "PartNo", "Supplier", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
1	1	Material	\N	\N	Material 1	Mat Description 1	10	20	t	Part 1	Doe	2026-03-27 21:39:39.169631+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
2	1	Component	\N	\N	Component 1	Comp Descrption 1	100	200	t	Part 1	John	2026-03-27 21:40:02.306498+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
3	1	MaterialComponent	1	1	\N	\N	\N	\N	t	\N	\N	2026-03-27 21:40:02.335563+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	\N
4	2	Component	\N	\N	Component 2	Comp Descrption 2	200	400	t	Part 2	dave	2026-03-27 21:43:16.609487+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
5	2	Material	\N	\N	Material 2	Mat Description 2	20	40	t	Part 2	smith	2026-03-27 21:47:44.882283+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
6	2	Component	\N	\N	Component 2	Comp Description 2	200	400	t	Part 2	Dave	2026-03-27 21:49:59.202212+05	2026-03-27 21:49:59.159324+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	1
7	2	MaterialComponent	1	2	\N	\N	\N	\N	t	\N	\N	2026-03-27 21:49:59.212802+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	\N
8	3	MaterialComponent	2	2	\N	\N	\N	\N	t	\N	\N	2026-03-27 21:49:59.216739+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	\N
\.


--
-- TOC entry 5444 (class 0 OID 81687)
-- Dependencies: 242
-- Data for Name: MaterialComponents; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."MaterialComponents" ("MatCompId", "MaterialId", "ComponentId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
1	1	1	t	2026-03-27 21:40:02.227564+05	\N	\N	\N
2	1	2	t	2026-03-27 21:49:59.161503+05	\N	\N	\N
3	2	2	t	2026-03-27 21:49:59.161842+05	\N	\N	\N
\.


--
-- TOC entry 5446 (class 0 OID 81698)
-- Dependencies: 244
-- Data for Name: Materials; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."Materials" ("MaterialId", "Name", "Description", "SellPrice", "IsActive", "CreatedAt", "CostPrice", "PartNo", "Supplier", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
1	Material 1	Mat Description 1	20	t	2026-03-27 21:39:38.987113+05	10	Part 1	Doe	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
2	Material 2	Mat Description 2	40	t	2026-03-27 21:47:44.871129+05	20	Part 2	smith	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1
\.


--
-- TOC entry 5448 (class 0 OID 81705)
-- Dependencies: 246
-- Data for Name: MiscLookups; Type: TABLE DATA; Schema: misc; Owner: postgres
--

COPY misc."MiscLookups" ("CodeEnum", "CodeName", "CodeText", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
1	Quotes	Sent	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
2	Quotes	Requested	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
3	Quotes	Rejected	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
4	Quotes	In Progress	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
5	Status	Active	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
6	Status	Inactive	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
7	Visibility	Customer and Admin	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
8	Visibility	Admin Only	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
9	Field Type	Single Line Text	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
10	Material	Material	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
11	Component	Component	t	2026-03-25 23:24:22.125625+05	2026-03-25 23:24:22.125625+05	\N	\N
\.


--
-- TOC entry 5450 (class 0 OID 81716)
-- Dependencies: 248
-- Data for Name: code_lookup; Type: TABLE DATA; Schema: misc; Owner: postgres
--

COPY misc.code_lookup (code_name, code_enum, code_text) FROM stdin;
account_status	1	Open
account_status	2	Closed
address_type	1	Home
address_type	2	Work
billing_frequency	1	Daily
billing_frequency	2	Weekly
billing_frequency	3	Monthly
bool_list	1	Yes
bool_list	2	No
contract_status	1	Active
contract_status	2	Expired
contract_status	3	Cancelled
contract_status	4	Pending
fuel_type	1	Petrol
fuel_type	2	Diesel
fuel_type	3	Electric
fuel_type	4	Hybrid
gender	1	Male
gender	2	Female
invoice_status	1	Generated
invoice_status	2	Sent
invoice_status	3	Partially Paid
invoice_status	4	Paid
vehicle_status	1	Active
vehicle_status	2	Inactive
\.


--
-- TOC entry 5451 (class 0 OID 81723)
-- Dependencies: 249
-- Data for Name: countries; Type: TABLE DATA; Schema: misc; Owner: postgres
--

COPY misc.countries (id, name, is_active, created_on) FROM stdin;
1	Afghanistan	t	2026-03-25 23:24:22.125625
2	Albania	t	2026-03-25 23:24:22.125625
3	Algeria	t	2026-03-25 23:24:22.125625
4	Andorra	t	2026-03-25 23:24:22.125625
5	Angola	t	2026-03-25 23:24:22.125625
6	Argentina	t	2026-03-25 23:24:22.125625
7	Armenia	t	2026-03-25 23:24:22.125625
8	Australia	t	2026-03-25 23:24:22.125625
9	Austria	t	2026-03-25 23:24:22.125625
10	Azerbaijan	t	2026-03-25 23:24:22.125625
11	Bahamas	t	2026-03-25 23:24:22.125625
12	Bahrain	t	2026-03-25 23:24:22.125625
13	Bangladesh	t	2026-03-25 23:24:22.125625
14	Belarus	t	2026-03-25 23:24:22.125625
15	Belgium	t	2026-03-25 23:24:22.125625
16	Belize	t	2026-03-25 23:24:22.125625
17	Benin	t	2026-03-25 23:24:22.125625
18	Bhutan	t	2026-03-25 23:24:22.125625
19	Bolivia	t	2026-03-25 23:24:22.125625
20	Bosnia and Herzegovina	t	2026-03-25 23:24:22.125625
21	Botswana	t	2026-03-25 23:24:22.125625
22	Brazil	t	2026-03-25 23:24:22.125625
23	Brunei	t	2026-03-25 23:24:22.125625
24	Bulgaria	t	2026-03-25 23:24:22.125625
25	Burkina Faso	t	2026-03-25 23:24:22.125625
26	Burundi	t	2026-03-25 23:24:22.125625
27	Cambodia	t	2026-03-25 23:24:22.125625
28	Cameroon	t	2026-03-25 23:24:22.125625
29	Canada	t	2026-03-25 23:24:22.125625
30	Chile	t	2026-03-25 23:24:22.125625
31	China	t	2026-03-25 23:24:22.125625
32	Colombia	t	2026-03-25 23:24:22.125625
33	Costa Rica	t	2026-03-25 23:24:22.125625
34	Croatia	t	2026-03-25 23:24:22.125625
35	Cuba	t	2026-03-25 23:24:22.125625
36	Cyprus	t	2026-03-25 23:24:22.125625
37	Czech Republic	t	2026-03-25 23:24:22.125625
38	Denmark	t	2026-03-25 23:24:22.125625
39	Dominican Republic	t	2026-03-25 23:24:22.125625
40	Ecuador	t	2026-03-25 23:24:22.125625
41	Egypt	t	2026-03-25 23:24:22.125625
42	El Salvador	t	2026-03-25 23:24:22.125625
43	Estonia	t	2026-03-25 23:24:22.125625
44	Ethiopia	t	2026-03-25 23:24:22.125625
45	Fiji	t	2026-03-25 23:24:22.125625
46	Finland	t	2026-03-25 23:24:22.125625
47	France	t	2026-03-25 23:24:22.125625
48	Germany	t	2026-03-25 23:24:22.125625
49	Ghana	t	2026-03-25 23:24:22.125625
50	Greece	t	2026-03-25 23:24:22.125625
51	Guatemala	t	2026-03-25 23:24:22.125625
52	Honduras	t	2026-03-25 23:24:22.125625
53	Hong Kong	t	2026-03-25 23:24:22.125625
54	Hungary	t	2026-03-25 23:24:22.125625
55	Iceland	t	2026-03-25 23:24:22.125625
56	India	t	2026-03-25 23:24:22.125625
57	Indonesia	t	2026-03-25 23:24:22.125625
58	Iran	t	2026-03-25 23:24:22.125625
59	Iraq	t	2026-03-25 23:24:22.125625
60	Ireland	t	2026-03-25 23:24:22.125625
61	Israel	t	2026-03-25 23:24:22.125625
62	Italy	t	2026-03-25 23:24:22.125625
63	Jamaica	t	2026-03-25 23:24:22.125625
64	Japan	t	2026-03-25 23:24:22.125625
65	Jordan	t	2026-03-25 23:24:22.125625
66	Kazakhstan	t	2026-03-25 23:24:22.125625
67	Kenya	t	2026-03-25 23:24:22.125625
68	Kuwait	t	2026-03-25 23:24:22.125625
69	Laos	t	2026-03-25 23:24:22.125625
70	Latvia	t	2026-03-25 23:24:22.125625
71	Lebanon	t	2026-03-25 23:24:22.125625
72	Libya	t	2026-03-25 23:24:22.125625
73	Liechtenstein	t	2026-03-25 23:24:22.125625
74	Lithuania	t	2026-03-25 23:24:22.125625
75	Luxembourg	t	2026-03-25 23:24:22.125625
76	Madagascar	t	2026-03-25 23:24:22.125625
77	Malaysia	t	2026-03-25 23:24:22.125625
78	Maldives	t	2026-03-25 23:24:22.125625
79	Mali	t	2026-03-25 23:24:22.125625
80	Malta	t	2026-03-25 23:24:22.125625
81	Mauritius	t	2026-03-25 23:24:22.125625
82	Mexico	t	2026-03-25 23:24:22.125625
83	Monaco	t	2026-03-25 23:24:22.125625
84	Mongolia	t	2026-03-25 23:24:22.125625
85	Montenegro	t	2026-03-25 23:24:22.125625
86	Morocco	t	2026-03-25 23:24:22.125625
87	Mozambique	t	2026-03-25 23:24:22.125625
88	Myanmar	t	2026-03-25 23:24:22.125625
89	Namibia	t	2026-03-25 23:24:22.125625
90	Nepal	t	2026-03-25 23:24:22.125625
91	Netherlands	t	2026-03-25 23:24:22.125625
92	New Zealand	t	2026-03-25 23:24:22.125625
93	Nigeria	t	2026-03-25 23:24:22.125625
94	North Korea	t	2026-03-25 23:24:22.125625
95	Norway	t	2026-03-25 23:24:22.125625
96	Oman	t	2026-03-25 23:24:22.125625
97	Pakistan	t	2026-03-25 23:24:22.125625
98	Panama	t	2026-03-25 23:24:22.125625
99	Paraguay	t	2026-03-25 23:24:22.125625
100	Peru	t	2026-03-25 23:24:22.125625
101	Philippines	t	2026-03-25 23:24:22.125625
102	Poland	t	2026-03-25 23:24:22.125625
103	Portugal	t	2026-03-25 23:24:22.125625
104	Qatar	t	2026-03-25 23:24:22.125625
105	Romania	t	2026-03-25 23:24:22.125625
106	Russia	t	2026-03-25 23:24:22.125625
107	Rwanda	t	2026-03-25 23:24:22.125625
108	Saudi Arabia	t	2026-03-25 23:24:22.125625
109	Senegal	t	2026-03-25 23:24:22.125625
110	Serbia	t	2026-03-25 23:24:22.125625
111	Singapore	t	2026-03-25 23:24:22.125625
112	Slovakia	t	2026-03-25 23:24:22.125625
113	Slovenia	t	2026-03-25 23:24:22.125625
114	South Africa	t	2026-03-25 23:24:22.125625
115	South Korea	t	2026-03-25 23:24:22.125625
116	Spain	t	2026-03-25 23:24:22.125625
117	Sri Lanka	t	2026-03-25 23:24:22.125625
118	Sweden	t	2026-03-25 23:24:22.125625
119	Switzerland	t	2026-03-25 23:24:22.125625
120	Syria	t	2026-03-25 23:24:22.125625
121	Taiwan	t	2026-03-25 23:24:22.125625
122	Tajikistan	t	2026-03-25 23:24:22.125625
123	Tanzania	t	2026-03-25 23:24:22.125625
124	Thailand	t	2026-03-25 23:24:22.125625
125	Tunisia	t	2026-03-25 23:24:22.125625
126	Turkey	t	2026-03-25 23:24:22.125625
127	Uganda	t	2026-03-25 23:24:22.125625
128	Ukraine	t	2026-03-25 23:24:22.125625
129	United Arab Emirates	t	2026-03-25 23:24:22.125625
130	United Kingdom	t	2026-03-25 23:24:22.125625
131	United States	t	2026-03-25 23:24:22.125625
132	Uruguay	t	2026-03-25 23:24:22.125625
133	Uzbekistan	t	2026-03-25 23:24:22.125625
134	Venezuela	t	2026-03-25 23:24:22.125625
135	Vietnam	t	2026-03-25 23:24:22.125625
136	Yemen	t	2026-03-25 23:24:22.125625
137	Zambia	t	2026-03-25 23:24:22.125625
138	Zimbabwe	t	2026-03-25 23:24:22.125625
\.


--
-- TOC entry 5453 (class 0 OID 81731)
-- Dependencies: 251
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
-- TOC entry 5454 (class 0 OID 81736)
-- Dependencies: 252
-- Data for Name: QuoteRevisions; Type: TABLE DATA; Schema: quotes; Owner: postgres
--

COPY quotes."QuoteRevisions" ("QuoteRevisionId", "QuoteId", "CreatedBy", "CreatedAt", "StatusId") FROM stdin;
1	1	74ca72ad-4e91-4384-89eb-925be075e300	2026-03-27 18:43:36.336915	4
2	1	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 14:26:38.713146	4
3	2	025061e6-e30b-4dee-bafc-6230e032ac54	2026-03-28 15:10:14.486352	4
4	3	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 17:06:28.799389	4
5	4	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 17:34:11.130271	4
6	5	025061e6-e30b-4dee-bafc-6230e032ac54	2026-03-28 17:39:08.928928	2
7	5	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 17:52:37.882872	4
8	6	025061e6-e30b-4dee-bafc-6230e032ac54	2026-03-28 18:45:52.734166	2
9	7	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 18:48:39.697167	4
10	8	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 19:15:44.708632	4
11	9	ce8bb747-624d-46c2-9d76-da557a53dd90	2026-03-28 19:16:23.553534	4
\.


--
-- TOC entry 5456 (class 0 OID 81744)
-- Dependencies: 254
-- Data for Name: UserRecords; Type: TABLE DATA; Schema: quotes; Owner: postgres
--

COPY quotes."UserRecords" ("RecStatusId", "QuoteReference", "TempVersionId", "TemplateId", "MiscCodeEnum", "MiscCodeName", "TotalCost", "IsActive", "CreatedAt", "MiscLookupCodeEnum", "ModifiedAt", "CreatedById", "ModifiedById", "PDFLINK", "Status", "TotalCostPrice", "TotalSellPrice", "CustomerId", business_id, "StatusId") FROM stdin;
3	Q20261303003	4	1	0		0	t	2026-03-28 22:06:28.776466+05	\N	2026-03-28 22:08:35.767163+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	businesses/1/customers/3/quotes/3/documents/Q20261303003.pdf	In Progress	0	0	3	1	4
2	Q20261303002	4	1	0		0	t	2026-03-28 20:10:14.343178+05	\N	2026-03-28 22:14:13.800134+05	025061e6-e30b-4dee-bafc-6230e032ac54	ce8bb747-624d-46c2-9d76-da557a53dd90		In Progress	0	0	1	1	4
4	Q20261303004	4	1	0		0	t	2026-03-28 22:34:11.110649+05	\N	2026-03-28 22:37:13.545857+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	businesses/1/customers/1/quotes/4/documents/Q20261303004.pdf	In Progress	0	0	1	1	4
5	Q20261303005	4	1	0		0	t	2026-03-28 22:39:08.915959+05	\N	2026-03-28 22:52:37.977171+05	025061e6-e30b-4dee-bafc-6230e032ac54	\N	businesses/1/customers/1/quotes/5/documents/Q20261303005.pdf	In Progress	0	0	1	1	4
6	Q20261303006	8	1	0		4980	t	2026-03-28 23:45:52.550928+05	\N	2026-03-28 23:45:53.270862+05	025061e6-e30b-4dee-bafc-6230e032ac54	\N			460	4520	1	1	2
7	Q20261303007	1	1	0		30	t	2026-03-28 23:48:39.684958+05	\N	2026-03-28 23:52:06.662723+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	businesses/1/customers/2/quotes/7/documents/Q20261303007.pdf	In Progress	10	20	2	1	4
8	Q20261303008	8	1	0		0	t	2026-03-29 00:15:44.552773+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	businesses/1/customers/3/quotes/8/documents/Q20261303008.pdf	In Progress	0	0	3	1	4
9	Q20261303009	8	1	0		0	t	2026-03-29 00:16:21.47823+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	businesses/1/customers/3/quotes/9/documents/Q20261303009.pdf	In Progress	0	0	3	1	4
1	Q20261303001	1	1	0		4620	t	2026-03-27 23:43:36.216579+05	\N	2026-03-30 20:10:02.732582+05	74ca72ad-4e91-4384-89eb-925be075e300	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	businesses/1/customers/2/quotes/1/documents/Q20261303001.pdf	In Progress	340	4280	2	1	4
\.


--
-- TOC entry 5458 (class 0 OID 81765)
-- Dependencies: 256
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security."RefreshTokens" ("Id", "UserId", "Token", "ExpiryDate", "IsRevoked", "CreatedDate") FROM stdin;
1	a1b2c3d4-e5f6-7890-abcd-ef1234567890	z0qwTIpJfqqhVZr380QI5twJ8eoLZsK5Y/E6VLe8ybBamLrIFv++ZW/l8Ku7q2ypZlWjrJ30RiL9V2HjsqoHag==	2026-04-01 23:24:46.056219+05	t	2026-03-25 23:24:46.056222+05
6	c0cc5298-18c0-49f5-907d-2487d8ca004f	c7MJ2JcKupQg8VUNdrJ5tvEBVswRIihoQSaO8Yvwq5yOoXK99lSvuZh3R84rNeWvx5H3opGhRlvZsA0MIJfG/A==	2026-04-01 23:46:46.136615+05	f	2026-03-25 23:46:46.136617+05
3	a1b2c3d4-e5f6-7890-abcd-ef1234567890	k09c1YwZTh35X+22KQ3kNQVDLz2ZuAeK+ZrNnxTOE+kuJbdpTZD7whSkIBf3NmBpfJMEkB5NL63yY/w5EXtSmQ==	2026-04-01 23:36:39.163542+05	t	2026-03-25 23:36:39.163545+05
2	ce8bb747-624d-46c2-9d76-da557a53dd90	uBvskNi0G2lODUukR7CKpoBg/pZtQLEhvjFeb7awczSpaPVNXGGZgfr+FrQH4DdOxCnTG+4ZWMfPr8h8kOV4YQ==	2026-04-01 23:26:19.830432+05	t	2026-03-25 23:26:19.830434+05
8	ce8bb747-624d-46c2-9d76-da557a53dd90	/j9jz+W1Z81F0r5ODHSJPL2LnoNeGQe0PZZbwiK+5mUNkiSbw3+Rl2Io5sfHl0H5a0gTqi3ibUEVL6vYFn5x2g==	2026-04-02 18:56:40.627551+05	t	2026-03-26 18:56:40.627786+05
12	4205be3f-3f45-4edc-a39b-38def5cd18f1	8ENbeCh6tLycVP2VK4y+Byp1Bdk3z/jh+Nad6JKWoHOAPMkURQnJ50bSwZTr/Doz+Y3cM9UtAYYHf0aSIwIkOA==	2026-04-02 21:50:44.054391+05	f	2026-03-26 21:50:44.054393+05
13	6a6fb513-3965-473c-a638-c8e1f3187582	28vKTKvFzyVbRkGPcN7VuNyMCSIR+0Qw5Z2989jNyp+owPkjr+YzrLywn2vcrDPIrlGWMCVVtrRmpNNVhuIgVg==	2026-04-02 22:47:30.877771+05	f	2026-03-26 22:47:30.87802+05
5	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	CwtWxN1PI4HojsHlO4PlbEdS4HNoithueNVXVQxHAtHhwDwX+ZuK/I0LS+u+Pe02WqUOFJbZaVefhM+8Q888jA==	2026-04-01 23:39:46.308855+05	t	2026-03-25 23:39:46.308857+05
7	a1b2c3d4-e5f6-7890-abcd-ef1234567890	9A/dDIbuDUgXyTdLLqlT4Q9s2nCQExwdv5xC6YmFbSGyKCcIOp2RO40vlsEUUgvRmIvqJA69qRJvAlnLyuz8LA==	2026-04-02 00:01:17.245901+05	t	2026-03-26 00:01:17.245905+05
16	e59050a3-2863-4b7b-9203-205663803773	o72uyV5hBkp/9QwGV+3KyRZ44C3oELH4hEFj+sVax1Ru28u4AJ1SPNG+e4g55Lb5fXCdmB0SlKoxOV6PrnuVxw==	2026-04-03 00:05:44.311294+05	f	2026-03-27 00:05:44.311296+05
14	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	OpDXuSEvQS36jdBcetZTsYZNgp6TGuyvfgqQA23Spwz0w+0RtI2DAgpr6YVoilJoKTBKrrvc7S8dZBUcnapT0w==	2026-04-02 23:28:54.225304+05	t	2026-03-26 23:28:54.22554+05
9	ce8bb747-624d-46c2-9d76-da557a53dd90	glTMiWAzbP68axAyton6WcTafK85udknsnz6pZVcb8aSusqrrBfWo/cubbADtcGV54Sn5wCP+TkRoUd8gIK+Xg==	2026-04-02 19:05:08.168002+05	t	2026-03-26 19:05:08.168004+05
18	ce8bb747-624d-46c2-9d76-da557a53dd90	eSJuD4pQ48ogSs6Mc6774Sj2NXU0vHYkIhX7NQoFe7RvIE3s7Ay5Ccsg+vOm9WeNehhnXKsRkGkDOS0wIncLRQ==	2026-04-03 18:54:04.800274+05	t	2026-03-27 18:54:04.800424+05
15	a1b2c3d4-e5f6-7890-abcd-ef1234567890	65poE85XHlKCJChynIv1ptZpERkaMD9RvnKqh9IdO1M6DfboHGBHpUzpR6ocrRcYaOLF8gOWFbIF3Qup9ICTCA==	2026-04-03 00:02:16.354795+05	t	2026-03-27 00:02:16.355001+05
20	a1b2c3d4-e5f6-7890-abcd-ef1234567890	suC4dZd3p75XLoGnIV3vn+J7Clh0nBGb429A3e9Smu3oOogPYu31nnOl80rCGaKAYEA2j9ZS0sMo8P3WksF5sQ==	2026-04-03 19:11:48.600708+05	f	2026-03-27 19:11:48.600931+05
19	ce8bb747-624d-46c2-9d76-da557a53dd90	D5hVefm7TtzXOgMsdMt3H02tSeH8Pt2KXeRZq+Src9c1uilaZNy/K9xaf0erl8qOe4jh52AGkawCK4zmrP0pPw==	2026-04-03 19:01:52.266699+05	t	2026-03-27 19:01:52.266866+05
4	ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	6RszquQGgxFvg2Xz1jVo23mvIHrpcw8u82CxxDr9VFQN1/YYt+x4PJ6ICB/kNo/4Ng47zV+xJCrIqlPRmvaSFA==	2026-04-01 23:37:52.769771+05	t	2026-03-25 23:37:52.769773+05
22	ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	To6j4WyWQq2LTSqSbZpXL4RvAQBTayWUXdNuvawC75Kexx8nLcEIaFazm4a7V4h96QRbIX33Ezl/de5LcKarRw==	2026-04-03 19:20:59.04777+05	f	2026-03-27 19:20:59.047983+05
11	74ca72ad-4e91-4384-89eb-925be075e300	t6WZNdneycnhNckGfukPs8yRm34t06BnIdT4DUGwz9bOOolnDEN0RepNbzs3+lA8Ojy9bmy9BNTiExgZ1lFQ5A==	2026-04-02 21:48:01.812941+05	t	2026-03-26 21:48:01.813226+05
23	74ca72ad-4e91-4384-89eb-925be075e300	DJaGFaT4si8EVh8HfSvo/zED75TNKo4/rSeHR1JBAF3GBbXohTpy048tJnZk3Dsh3fG2EFmrqPDoVniA+IH/CQ==	2026-04-03 19:30:52.736601+05	t	2026-03-27 19:30:52.736603+05
24	74ca72ad-4e91-4384-89eb-925be075e300	ORQPiC56n0fNbY4B2nbJcxPOwfZnowScLZDuGJ+rJitvkJhPHMGPVsdZ0gbhLSBHUp6UzU537aUfUsN0BGxWlg==	2026-04-03 21:37:53.312757+05	t	2026-03-27 21:37:53.312916+05
25	74ca72ad-4e91-4384-89eb-925be075e300	mMmnA+o1JFYuI9jKBCNStYRLjpRp9NUk0qCd7AN9PDDY7rHhYyknfPDxbQo0lT9fJeZEDsQd15CbIFE5W9xflw==	2026-04-03 21:58:30.194852+05	t	2026-03-27 21:58:30.194853+05
26	74ca72ad-4e91-4384-89eb-925be075e300	or39lr/OHEMdbZaFPPSyNas7G0Q62u2Gfi0jeCIxVkxp2OyRuirWmuMasLKlTYOb4MT5K1XCM2okQO9T5k7f8g==	2026-04-03 22:18:49.563782+05	t	2026-03-27 22:18:49.563785+05
27	74ca72ad-4e91-4384-89eb-925be075e300	vu06N0W8VUuETW0ObDZDZ1xdYx/mSx3a9561UZ6dfMrs69/vZP5uU8/h7oYGrSlJC4pVC6GGxS8UNmUdEod+WQ==	2026-04-03 23:05:43.265565+05	t	2026-03-27 23:05:43.266174+05
28	74ca72ad-4e91-4384-89eb-925be075e300	ADAXI5v44FFRwJ9Db9g1SZMgKDn+92u/N9WPevO3YjoLxKeHLfzgXOFCpu7UJ1wL/xBNkKhtZ5NwV8l6nRjnww==	2026-04-03 23:33:10.039958+05	t	2026-03-27 23:33:10.03996+05
29	74ca72ad-4e91-4384-89eb-925be075e300	dcR42zq/M4ICgEXCuPz+qoch+sEZCt0b0GVJIX8yeFwWfJopt9cEX+sDPxzcpFAHKx2elAo8vEAd/fi3ILhPIQ==	2026-04-03 23:54:07.243362+05	t	2026-03-27 23:54:07.243367+05
30	74ca72ad-4e91-4384-89eb-925be075e300	AOFhor5feTdvzVoyc0Wonk73qZ6w2DMdL9nanmUg7aVWdU/h/K5Adqr7x4YIqrIv0oTpHf80UnnEgh8OQfoqBQ==	2026-04-04 00:15:19.884017+05	f	2026-03-28 00:15:19.884308+05
21	ce8bb747-624d-46c2-9d76-da557a53dd90	ebB/q9w/E6u9jW6f1JdeVFn3OdN12kBAFHMzUedZT/ASvj9gl1kiyVyxiKknpZDr0+a5h+G6+9fopTtW0/rPgA==	2026-04-03 19:16:22.961461+05	t	2026-03-27 19:16:22.961462+05
32	ce8bb747-624d-46c2-9d76-da557a53dd90	OiGk8t9a9fyfo6VSdlWSgb922ygC1qWFDKo0+aWzoa/xFI2dOKZlbYxpqF/iuAkcjbXPahIuWdlXAQ5Xir6bhA==	2026-04-04 19:03:42.957425+05	t	2026-03-28 19:03:42.957427+05
31	31cbf32e-5d54-4e86-8b1f-13e4765be45e	qz/io6h/TIrdBN3AcELor3Z9kQya4a4I6DdQlRTHF9xph5/q+6YYN4DsJKIms6PE22EbS2GWRiMYL1wZ2b9TpQ==	2026-04-04 18:50:42.817784+05	t	2026-03-28 18:50:42.818098+05
33	ce8bb747-624d-46c2-9d76-da557a53dd90	SbEpk28svQI1gXRx3PZCfzZStL1pGyvNroBQfvTihRJz4pmxUXIK3fjCrCm8pS8BWlX/75mUyu5ZZ6xFjdpiMA==	2026-04-04 19:25:15.950618+05	t	2026-03-28 19:25:15.95062+05
35	ce8bb747-624d-46c2-9d76-da557a53dd90	obstEVLI9KWdBUNnAMPgC3pVWWOGAzID69NZRupeareh/pqp4cyXFkhWTMxEsMSbPwiL2rqEUxVkkxt94VORlQ==	2026-04-04 19:36:58.937088+05	t	2026-03-28 19:36:58.93709+05
10	025061e6-e30b-4dee-bafc-6230e032ac54	0EzhPR+fxdHWz7b/xs/TZny3gBdxj5pO3uf4QxPfSf27r2o8nnTm7ZlUr3S+Fcm6f/fj+mJeV87HbhPrIFRItQ==	2026-04-02 19:16:48.657794+05	t	2026-03-26 19:16:48.658535+05
37	025061e6-e30b-4dee-bafc-6230e032ac54	Wh6j7/8C/Xg35HVSguiJy+pIm4WUgQ7vCJsIqCYKb2BSqb9MkNMOjbvduP14M4NVo5Lq9/HqX6jJuJ13qtIiow==	2026-04-04 20:00:57.521316+05	t	2026-03-28 20:00:57.521318+05
36	ce8bb747-624d-46c2-9d76-da557a53dd90	kSYA6tC4MYGQhXGQvj+73mcfXdRAZ3XY36xrsIavtzTCXmjeKFJLnSRo19K3yx+WKq6BPit8ly3Qf92nT8lERA==	2026-04-04 19:52:35.717083+05	t	2026-03-28 19:52:35.717262+05
39	ce8bb747-624d-46c2-9d76-da557a53dd90	MOny2jaRw4V9Zion2LPJ4i/wuYGjGzg7j7a4aNYrGvs/HV7HBQReFBYpIQZAqCDCt6lx3dAIyKdQxCr2RVFB4A==	2026-04-04 20:12:12.083905+05	t	2026-03-28 20:12:12.08391+05
40	ce8bb747-624d-46c2-9d76-da557a53dd90	wRHHx/AYuFrDl0cNzZH8+ooJmIiqYTIosF+OAqu76HyioPLfl2WdauQpzwewV4G6RMRP6IsPW35fE3Z+aRV9pg==	2026-04-04 21:30:28.868623+05	t	2026-03-28 21:30:28.868626+05
41	ce8bb747-624d-46c2-9d76-da557a53dd90	4r/Qt2ALS/vP5qMblqSBAdfMAgSTOruw0DKR/pTJ68/H+s+fO3TmjnXEMG9uIfZePCouWWX0lkmXdivFONsWeQ==	2026-04-04 21:52:14.046164+05	t	2026-03-28 21:52:14.046167+05
38	025061e6-e30b-4dee-bafc-6230e032ac54	umiUWbots5JjqdQcaO5zfushG4eg2SSQemENbR+dKy997RoiJN+sDsPr7CSaNwiAtuYeGFAgBFMtLHZ7V1Cwrg==	2026-04-04 20:05:08.308141+05	t	2026-03-28 20:05:08.308321+05
34	31cbf32e-5d54-4e86-8b1f-13e4765be45e	83FpPfELrBV5c2PvpTXdcyU9RVXj5k9dnp+1XLY30yqOOuDP7dqKfHe+ft8ClGAdVsrwKc0M4GaGt0eaERzHJQ==	2026-04-04 19:36:47.389348+05	t	2026-03-28 19:36:47.38935+05
17	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	gk+jKzzXl38Wxrtm/W6phaahIZa41G+N+xk6tBI7t1ck7f0P9nxz1kcabb9rAzif6DUW5tl8zNH6tlcj/vDvwg==	2026-04-03 00:08:07.186329+05	t	2026-03-27 00:08:07.186334+05
42	ce8bb747-624d-46c2-9d76-da557a53dd90	QYkxReG3hs7Z2goA8oEq9WKvLailROOs1roc1gHHdy0pi/uZg2w1YAECG6MEL0fa38anY0U59xWxBVYSFbkJSg==	2026-04-04 22:12:28.899116+05	t	2026-03-28 22:12:28.899118+05
43	ce8bb747-624d-46c2-9d76-da557a53dd90	xlE1RF+MrWItO59VxNCuB9HL6EloUF0Y2mnbeL3HR3VjQeHIOkFPhyY5Zpd/CPGB9h8KWpUzS9sv5Q+YdHe1xA==	2026-04-04 22:33:54.849401+05	t	2026-03-28 22:33:54.849404+05
45	ce8bb747-624d-46c2-9d76-da557a53dd90	RVRzehf5JQX3RluvEMvtnxZJuP7qC2MSmcRtRNY0Xne/Zp98JnO5cYKjjvPWukawiRA/2zbnCDUeRZcWcJFO0g==	2026-04-04 22:39:48.434908+05	t	2026-03-28 22:39:48.434909+05
46	ce8bb747-624d-46c2-9d76-da557a53dd90	V7fAZSEy/XDy2WgOqqtD1ifOg/23qevf1HDA7TG69IVoPjt1q6Up01Qf4EQ3va9+92KYMvw2wyQ1E8V9NaYPnw==	2026-04-04 23:00:30.933527+05	t	2026-03-28 23:00:30.93353+05
47	ce8bb747-624d-46c2-9d76-da557a53dd90	tiuD7Y1PxvUr1Hdr43rq66kcz2xZ98M0orDDyEGqm11PmMDYgiqcWw1yBNOroz35nqH+uxyxh4bzQq970VPiog==	2026-04-04 23:24:28.615207+05	t	2026-03-28 23:24:28.616279+05
44	025061e6-e30b-4dee-bafc-6230e032ac54	pIiWjEI2y3X574Hsv4E7eNTES+qHZpRKUkwBfyAR5Nx4cMadU0nEGHOGZjMUIW7e4RFHVaYKn/EzTQp6R2rJLQ==	2026-04-04 22:38:45.948987+05	t	2026-03-28 22:38:45.94899+05
49	025061e6-e30b-4dee-bafc-6230e032ac54	q+7ZFT5jCpAC3oq3SSglMK1cGEbGCO6zRZmXgMFaDPTD1vNMkr5g8HzV8QG0ja7PMx0zALTU/u+0SBvPzMEIRA==	2026-04-04 23:42:32.559341+05	f	2026-03-28 23:42:32.559343+05
48	ce8bb747-624d-46c2-9d76-da557a53dd90	tMjOo0SgGqOnMZU8rQLZDPHYO1LdCgoYmkbc8ZzJYnSpVZiD10NZOK3926EOabFApEyQZXiF6oRKKRHAvDU3Lw==	2026-04-04 23:38:02.460486+05	t	2026-03-28 23:38:02.460634+05
50	ce8bb747-624d-46c2-9d76-da557a53dd90	r3KjwTzE2eqRhaQOxmVeRn27+1aHvM0YkMvRTCjK3oE3MDcBvZoa2Sh/nO50m5N76Fy77eOQx3B3mbG9RfbdJw==	2026-04-04 23:46:19.575433+05	t	2026-03-28 23:46:19.575436+05
51	ce8bb747-624d-46c2-9d76-da557a53dd90	1o6EfZAGQQVXWCPqCqGIBmNp6DWr7RK1nKNhAHa6ffXlFCWQOQK/6m8AQ8716guTDG5S8InMvK0Qe4ZE9mYObQ==	2026-04-05 00:14:36.890119+05	f	2026-03-29 00:14:36.890341+05
52	31cbf32e-5d54-4e86-8b1f-13e4765be45e	NAvq/hf4FXCrOukVU6HX7eBP/inetvtMy5ep2Aia/5Oh59mzoHDS9ilTOXKCdTFWAUQBVjpT/Q1vgV4bWKalUQ==	2026-04-06 19:03:37.793578+05	f	2026-03-30 19:03:37.793741+05
53	c80ec3ca-080d-4d9c-8c8a-fc858b56c578	q95oAxkZ9Wh61VzHdMA7oZRDijrz71cnOJsVggJBob2m/NcHzQHtnlF/Y6x3nekhmml6CcUkgMCDCEh2oMZpuw==	2026-04-06 19:07:50.256347+05	f	2026-03-30 19:07:50.25635+05
54	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	2Cya6rjy74lyFG7Xvh934yQ7VHtRCob5exSUJYVSobpI1vgMQS40e7UC0uiKPoUgRorr036JRcCzh30zkLsltA==	2026-04-06 19:08:42.355796+05	t	2026-03-30 19:08:42.355798+05
55	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	YaVmdY3DsPwld0mi8QTEg5BXJFYuCHFPGY5Y9YgcRmX9mm4FWo8mPOoZ+ORaH7wL2WDrjN3ofsgeFhgFgaS2KA==	2026-04-06 19:40:52.707438+05	t	2026-03-30 19:40:52.707439+05
56	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	lCTXSdeIHdG9WpqFUbFLhYBpF/KJCHktwUSWF02R1efwU2r7dweK6cjXtDXh+g14dBt/2fXTU04+adn1wr6tCA==	2026-04-06 20:07:50.883689+05	t	2026-03-30 20:07:50.883872+05
57	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	h3ZCVhF0D8TxpDgfQSEpX1GJermGo9uw/ziZuLBcaLnb1woIxepNwFCw8Ws/sf7QkqQA5WNoljxPqCWE8YZZcg==	2026-04-06 22:24:22.989139+05	t	2026-03-30 22:24:22.989309+05
58	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	FEx+Mj46HlmbcnHQjZK9dXtkVWl+hLHdcyntoQ2RRdGlX+D0QbBv02viErI7O/nu0grrSmh12H7g5xt6M34rSw==	2026-04-06 22:47:29.011546+05	f	2026-03-30 22:47:29.011548+05
\.


--
-- TOC entry 5460 (class 0 OID 81779)
-- Dependencies: 258
-- Data for Name: jwt_settings; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.jwt_settings ("Id", "Key", "Issuer", "Audience", "AccessTokenExpiryMinutes", "RefreshTokenExpiryDays", "UpdatedAt") FROM stdin;
1	replace-this-with-very-secure-32+char-key-123456789	QuoteBuilderBackend.API	QuoteBuilderBackend.API	20	7	2026-03-25 18:24:22.125625+05
\.


--
-- TOC entry 5461 (class 0 OID 81796)
-- Dependencies: 259
-- Data for Name: menu_access; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.menu_access (security_group_id, menu_id, last_modified, date_created) FROM stdin;
1	1	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	3	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	4	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	5	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	6	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
2	1	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
2	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
2	3	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
3	1	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
3	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
3	4	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
3	5	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
4	1	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
4	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
5	1	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	2	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	3	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	4	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	5	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	6	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
6	1	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
6	2	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
6	3	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
7	1	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
7	2	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
7	4	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
7	5	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
8	1	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
8	2	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
9	1	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
9	2	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
9	3	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
9	4	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
9	5	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
9	6	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
10	1	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
10	2	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
10	3	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
11	1	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
11	2	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
11	4	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
11	5	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
12	1	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
12	2	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
13	1	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
13	2	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
13	3	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
13	4	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
13	5	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
13	6	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
14	1	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
14	2	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
14	3	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
15	1	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
15	2	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
15	4	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
15	5	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
16	1	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
16	2	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
\.


--
-- TOC entry 5462 (class 0 OID 81804)
-- Dependencies: 260
-- Data for Name: roles; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.roles ("Id", "Name", "NormalizedName", "ConcurrencyStamp", "RoleId") FROM stdin;
974b7fd0-a825-495c-97e3-237a32fded31	Customer	CUSTOMER	76005d71-03ce-4eeb-a0ee-6c095a475bbb	1
77ed1763-8dd0-4da4-93fd-8335ed540c7b	User	USER	e2856bea-6171-4166-b38c-d7c8ce655f16	2
967df2ef-4ec0-4f76-baab-8fa76b28cd08	Admin	ADMIN	5166fd74-d86e-496c-8924-f0de55a7ad7b	3
ae342069-ca62-4114-8ce6-587ecf1e5caf	Owner	OWNER	615351a1-bb44-4876-bc9e-8cee7c326ee4	4
b7e91c2d-f3a4-4b56-9c12-d8e047f6a123	Super	SUPER	c9d12e45-1f23-4a56-8b78-90ef12345678	5
\.


--
-- TOC entry 5464 (class 0 OID 81812)
-- Dependencies: 262
-- Data for Name: roles_claims; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.roles_claims ("Id", "RoleId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- TOC entry 5466 (class 0 OID 81820)
-- Dependencies: 264
-- Data for Name: security_group; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.security_group (security_group_id, parent_id, security_group_name, api_path, last_modified, date_created, business_id, description) FROM stdin;
1	0	Admin Group		2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738	1	\N
2	0	Sales Group		2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738	1	\N
3	0	Operations Group		2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738	1	\N
4	0	Viewer Group		2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738	1	\N
5	0	Admin Group		2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305	2	\N
6	0	Sales Group		2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305	2	\N
7	0	Operations Group		2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305	2	\N
8	0	Viewer Group		2026-03-26 17:05:15.083281	2026-03-25 18:36:55.72305	2	\N
9	0	Admin Group		2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356	3	Full Access to all features.
10	0	Sales Group		2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356	3	Access to customer and quote workflows.
11	0	Operations Group		2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356	3	Access to quote build and fulfilment processes.
12	0	Viewer Group		2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356	3	Provides limited access to selected areas.
13	0	Admin Group		2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203	4	Full Access to all features.
14	0	Sales Group		2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203	4	Access to customer and quote workflows.
15	0	Operations Group		2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203	4	Access to quote build and fulfilment processes.
16	0	Viewer Group		2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203	4	Provides limited access to selected areas.
\.


--
-- TOC entry 5467 (class 0 OID 81832)
-- Dependencies: 265
-- Data for Name: security_group_members; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.security_group_members (security_group_id, user_id, last_modified, date_created) FROM stdin;
1	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
2	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
3	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
4	2	2026-03-25 18:25:35.3738	2026-03-25 18:25:35.3738
1	3	2026-03-25 18:28:12.837144	2026-03-25 18:28:12.837144
2	4	2026-03-25 18:28:42.829116	2026-03-25 18:28:42.829116
3	5	2026-03-25 18:29:38.825611	2026-03-25 18:29:38.825611
4	6	2026-03-25 18:30:06.611058	2026-03-25 18:30:06.611058
6	9	2026-03-25 18:43:02.472888	2026-03-25 18:43:02.472888
7	11	2026-03-25 18:44:15.882159	2026-03-25 18:44:15.882159
8	10	2026-03-25 18:45:52.284973	2026-03-25 18:45:52.284973
6	8	2026-03-26 17:53:34.770031	2026-03-26 17:53:34.770031
9	13	2026-03-26 19:03:47.714356	2026-03-26 19:03:47.714356
13	14	2026-03-27 14:15:11.351203	2026-03-27 14:15:11.351203
5	7	2026-03-30 14:16:49.336242	2026-03-30 14:16:49.336242
\.


--
-- TOC entry 5470 (class 0 OID 81842)
-- Dependencies: 268
-- Data for Name: user_claims; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_claims ("Id", "UserId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- TOC entry 5472 (class 0 OID 81850)
-- Dependencies: 270
-- Data for Name: user_logins; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_logins ("LoginProvider", "ProviderKey", "ProviderDisplayName", "UserId") FROM stdin;
\.


--
-- TOC entry 5473 (class 0 OID 81858)
-- Dependencies: 271
-- Data for Name: user_roles; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_roles ("UserId", "RoleId") FROM stdin;
a1b2c3d4-e5f6-7890-abcd-ef1234567890	b7e91c2d-f3a4-4b56-9c12-d8e047f6a123
ce8bb747-624d-46c2-9d76-da557a53dd90	ae342069-ca62-4114-8ce6-587ecf1e5caf
74ca72ad-4e91-4384-89eb-925be075e300	967df2ef-4ec0-4f76-baab-8fa76b28cd08
31cbf32e-5d54-4e86-8b1f-13e4765be45e	967df2ef-4ec0-4f76-baab-8fa76b28cd08
ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	77ed1763-8dd0-4da4-93fd-8335ed540c7b
c80ec3ca-080d-4d9c-8c8a-fc858b56c578	77ed1763-8dd0-4da4-93fd-8335ed540c7b
6a6fb513-3965-473c-a638-c8e1f3187582	967df2ef-4ec0-4f76-baab-8fa76b28cd08
7a81cd3b-6856-4317-8216-f7e5e3744310	77ed1763-8dd0-4da4-93fd-8335ed540c7b
c0cc5298-18c0-49f5-907d-2487d8ca004f	77ed1763-8dd0-4da4-93fd-8335ed540c7b
025061e6-e30b-4dee-bafc-6230e032ac54	974b7fd0-a825-495c-97e3-237a32fded31
4205be3f-3f45-4edc-a39b-38def5cd18f1	77ed1763-8dd0-4da4-93fd-8335ed540c7b
e59050a3-2863-4b7b-9203-205663803773	ae342069-ca62-4114-8ce6-587ecf1e5caf
6449b653-9ddf-4453-acf6-18df8e6837a1	ae342069-ca62-4114-8ce6-587ecf1e5caf
89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	ae342069-ca62-4114-8ce6-587ecf1e5caf
\.


--
-- TOC entry 5474 (class 0 OID 81865)
-- Dependencies: 272
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.user_tokens ("UserId", "LoginProvider", "Name", "Value") FROM stdin;
\.


--
-- TOC entry 5475 (class 0 OID 81873)
-- Dependencies: 273
-- Data for Name: users; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security.users ("Id", "BusinessId", "UserId", "FirstName", "LastName", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp", "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd", "LockoutEnabled", "AccessFailedCount", "IsDeleted", "PasswordResetPin", "PasswordResetPinExpiry", "PasswordResetToken", "PasswordResetTokenExpiry", "Address", "AddressLine2", "City", "Postcode", "CountryId") FROM stdin;
a1b2c3d4-e5f6-7890-abcd-ef1234567890	0	1	Test1	User1	Test1@User1.com	TEST1@USER1.COM	Test1@User1.com	TEST1@USER1.COM	t	AQAAAAIAAYagAAAAEFaBWJ21pNUvjtrQnw2UjuTV3VqeKHOpid2Ro41rmFcYwGOzK1s4bmH8d3g7Dz0CZA==	f4091345-9eb5-4635-9c93-d6c1cd736e58	65a53c4b-1768-4d0d-8140-29a46b75d445	\N	f	f	\N	f	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
ce8bb747-624d-46c2-9d76-da557a53dd90	1	2	User	Two	UserTwo	USERTWO	Test2@User2.com	TEST2@USER2.COM	f	AQAAAAIAAYagAAAAENzWtLm+qVAYPoFwYgKaftXC2ImjBJBKKO1Kg8CPqdCN/EXiQc17XasrkFT3wTZcQw==	3EI4X7G7ITXELXRSPHEVQLOJL7EQ5CQS	ac822020-f8c5-48d2-990b-d1f830d02d11	+98765432	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
025061e6-e30b-4dee-bafc-6230e032ac54	1	12	New	Customer	NewCustomer	NEWCUSTOMER	Test1@Customer1.com	TEST1@CUSTOMER1.COM	f	AQAAAAIAAYagAAAAEBzULFjGoLJZXAYMb2ZRln/cNO+fpsPKwmShN0/zVeLPddKajohBkuzunjUnUcbCpw==	JSSX2QXT7IHHJMHVH3KLKQFFJ5PVSDJT	ada6ac9c-03a5-4634-ae51-56c87fa5d20f	+34567	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
31cbf32e-5d54-4e86-8b1f-13e4765be45e	1	4	Test2	User	user_796f3660	USER_796F3660	Test2@Admin2.com	TEST2@ADMIN2.COM	f	AQAAAAIAAYagAAAAECHrxG/yt4GSLL24oxpkxmNRVFgsTQAsZXBv7BDI29LtD9tW4HlHle84gv+6rJ7YUA==	HFXMRJXQ6HVZLEF3LZ3ETW2BON4VBIC3	fb7210c2-5947-4e43-81f2-1c0c90f2818e	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	1	5	Test3	User	user_bc7efbde	USER_BC7EFBDE	Test3@User3.com	TEST3@USER3.COM	f	AQAAAAIAAYagAAAAEN3LBLUgeoKFUcoycgFhtF/SqZTDytB+H9TW5FLOZnf7E1X2g4UJ2R9HlyhzWORxuw==	PPEHPWDZDXKANATJOFOC6473VJRQ5M54	95c481ec-02ef-4212-b391-e7ba9eb78471	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
c80ec3ca-080d-4d9c-8c8a-fc858b56c578	1	6	Test4	User	user_9767a11c	USER_9767A11C	Test4@User4.com	TEST4@USER4.COM	f	AQAAAAIAAYagAAAAEBBkG2ifZEzfxxrPQQGiFEUuotElD7QBYOPww6JFlb6JiuU3jsABZJsNS6l4qCxzrw==	O3CL6KIGD5FUPXMGMZNUVDM56K27ACMF	715824d3-f363-437c-9ee6-e7763dd68fe6	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
6a6fb513-3965-473c-a638-c8e1f3187582	2	9	Test4	User	user_a750693d	USER_A750693D	Test4@Admin4.com	TEST4@ADMIN4.COM	f	AQAAAAIAAYagAAAAEGNK9nuKi3qh2Z/5h8OCjWeCnHuLEoTkjFEVBNL+JqcqLyVWqhw4TwvX81iaLn0GhQ==	XLGJY6VKNQ7WM2K7OJDM6T6OJ7TKSXJD	8fd438b1-7414-4428-b966-6ca64b7a1527	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
c0cc5298-18c0-49f5-907d-2487d8ca004f	2	10	Test6	User	Test6@User6.com	TEST6@USER6.COM	Test6@User6.com	TEST6@USER6.COM	f	AQAAAAIAAYagAAAAEC5xHUPkwwNTLQHhM2D+eqyKFAGIci/pSYiP9xjguh4zzMhIsnfqpDK9J8xJ9qwqMg==	HWS6TP2MQWQ3WD22XP23XZZZ46IGB3PA	14150556-3078-4f1d-b3f2-22bad666e3bb	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
7a81cd3b-6856-4317-8216-f7e5e3744310	2	11	Test7	User	user_3e2085e8	USER_3E2085E8	Test7@User7.com	TEST7@USER7.COM	f	AQAAAAIAAYagAAAAEMoe3b712FTpc/QjaZMNlQvF+IlDRGUxu9skmQl1IGE2cG8Wr0sZCxwFkc0Zf6007w==	7HNPYVZ3ANWJJTYZZRH5Y3ZMSKKIGNCN	26380c0f-566c-40db-ba96-264615fa49e1	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	2	7	User	Three	Test5@User5.com	TEST5@USER5.COM	Test5@User5.com	TEST5@USER5.COM	f	AQAAAAIAAYagAAAAED4dyxuR6zHnRQAmz3NVR3Yixb6TMQvvpUhTXBMLgNdlK0L2hUiFpS+/ACkgpvkaTQ==	REJMNDNVQV44A6JK6IKFCHRK63OVDS64	b74dbc2f-d8ca-49dc-80d5-9c71c7620626	+98765432	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
4205be3f-3f45-4edc-a39b-38def5cd18f1	2	8	Test3	User	Test3@Admin3.com	TEST3@ADMIN3.COM	Test3@Admin3.com	TEST3@ADMIN3.COM	f	AQAAAAIAAYagAAAAEK5OhdykDZUhvpxfF+4zs+yrkGBFf3NAblb7IL0a38YIwlKey/LWU35Kpk4SfYyQYg==	YFQMDRI7VUYKRQBDUKKGP5GG36UXUSOT	44218a07-329b-4453-9537-4289be975915	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
e59050a3-2863-4b7b-9203-205663803773	3	13	User	Four	UserFour	USERFOUR	Test9@User9.com	TEST9@USER9.COM	f	AQAAAAIAAYagAAAAEHopj6BkMUib5AlspprpbNi3UC0BHrRNV1SZhk+NEZyEE5ddTkaObrc4MTXxaUYqCQ==	7FYCPH4A2DYP2ABMDD2FTYPCEVZ26ZMA	6db92009-25fc-464f-8e2c-b05f1f9d4957	+98765432	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
6449b653-9ddf-4453-acf6-18df8e6837a1	4	14	User	Six	UserSix	USERSIX	Test10@User10.com	TEST10@USER10.COM	f	AQAAAAIAAYagAAAAEAk/NbdjvY0Qe1WCFe6i5bC39vgGZ4rxpyTFUgBLePppon2rGlTloGTIww+JkzWslA==	DWGCCXOGF3PLLDXH3C545DP54JAGETEL	0ee80f98-f2d8-4f1e-98be-617c8b324c81	+98765432	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
74ca72ad-4e91-4384-89eb-925be075e300	1	3	Test1	User	User 123	USER_7F5A1FDB	Test1@Admin1.com	TEST1@ADMIN1.COM	f	AQAAAAIAAYagAAAAECGFebzZulpFe22KoDYBYU6r/yz3LB18AB2tzznd/MeoBRGJON+RBqh+KKAEfezfkQ==	HRP6UKXQVQCLR4TKMPXGFYFRKIBXG2LE	eb2624ea-ba11-4ebc-b58b-48c623f816af	+2345678	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5477 (class 0 OID 81890)
-- Dependencies: 275
-- Data for Name: DependentQuestions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."DependentQuestions" ("DependentQId", "QOptionId", "NextQuestionId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
1	3	1	t	2026-03-27 22:22:56.373831+05	\N	\N	\N
2	4	2	t	2026-03-27 22:22:56.464602+05	\N	\N	\N
3	5	1	t	2026-03-27 22:26:18.955577+05	\N	\N	\N
4	6	2	t	2026-03-27 22:26:18.991525+05	\N	\N	\N
5	7	3	t	2026-03-27 23:10:47.161003+05	\N	\N	\N
6	8	4	t	2026-03-27 23:15:38.081805+05	\N	\N	\N
9	12	5	t	2026-03-27 23:39:33.323124+05	\N	\N	\N
10	12	8	t	2026-03-27 23:39:33.323382+05	\N	\N	\N
11	15	9	t	2026-03-28 19:19:09.873007+05	\N	\N	\N
12	16	10	t	2026-03-28 19:19:09.880551+05	\N	\N	\N
13	17	9	t	2026-03-28 19:19:09.880743+05	\N	\N	\N
14	18	10	t	2026-03-28 19:19:09.880863+05	\N	\N	\N
15	19	11	t	2026-03-28 19:19:09.880938+05	\N	\N	\N
16	20	12	t	2026-03-28 19:19:09.881189+05	\N	\N	\N
17	21	13	t	2026-03-28 19:19:09.881267+05	\N	\N	\N
18	21	16	t	2026-03-28 19:19:09.881395+05	\N	\N	\N
19	25	17	t	2026-03-28 19:20:42.094726+05	\N	\N	\N
20	26	18	t	2026-03-28 19:20:42.094969+05	\N	\N	\N
21	27	17	t	2026-03-28 19:20:42.095057+05	\N	\N	\N
22	28	18	t	2026-03-28 19:20:42.095117+05	\N	\N	\N
23	29	19	t	2026-03-28 19:20:42.095178+05	\N	\N	\N
24	30	20	t	2026-03-28 19:20:42.095238+05	\N	\N	\N
25	31	21	t	2026-03-28 19:20:42.095291+05	\N	\N	\N
26	31	24	t	2026-03-28 19:20:42.095343+05	\N	\N	\N
27	35	25	t	2026-03-28 19:43:20.697541+05	\N	\N	\N
28	36	26	t	2026-03-28 19:43:20.697678+05	\N	\N	\N
29	37	25	t	2026-03-28 19:43:20.697735+05	\N	\N	\N
30	38	26	t	2026-03-28 19:43:20.69778+05	\N	\N	\N
31	39	27	t	2026-03-28 19:43:20.697817+05	\N	\N	\N
32	40	28	t	2026-03-28 19:43:20.697852+05	\N	\N	\N
33	41	29	t	2026-03-28 19:43:20.697887+05	\N	\N	\N
34	41	32	t	2026-03-28 19:43:20.697922+05	\N	\N	\N
35	45	33	t	2026-03-28 23:27:14.132705+05	\N	\N	\N
36	46	34	t	2026-03-28 23:27:14.13782+05	\N	\N	\N
37	47	33	t	2026-03-28 23:27:14.138122+05	\N	\N	\N
38	48	34	t	2026-03-28 23:27:14.138343+05	\N	\N	\N
39	49	35	t	2026-03-28 23:27:14.138451+05	\N	\N	\N
40	50	36	t	2026-03-28 23:27:14.138689+05	\N	\N	\N
41	51	37	t	2026-03-28 23:27:14.138774+05	\N	\N	\N
42	51	40	t	2026-03-28 23:27:14.138847+05	\N	\N	\N
43	57	42	t	2026-03-28 23:39:21.425662+05	\N	\N	\N
44	58	43	t	2026-03-28 23:39:21.429745+05	\N	\N	\N
45	59	42	t	2026-03-28 23:39:21.429915+05	\N	\N	\N
46	60	43	t	2026-03-28 23:39:21.430022+05	\N	\N	\N
47	61	44	t	2026-03-28 23:39:21.430125+05	\N	\N	\N
48	62	45	t	2026-03-28 23:39:21.430338+05	\N	\N	\N
49	63	46	t	2026-03-28 23:39:21.430454+05	\N	\N	\N
50	63	49	t	2026-03-28 23:39:21.430558+05	\N	\N	\N
51	67	50	t	2026-03-28 23:40:55.425205+05	\N	\N	\N
52	68	51	t	2026-03-28 23:40:55.42541+05	\N	\N	\N
53	69	50	t	2026-03-28 23:40:55.425575+05	\N	\N	\N
54	70	51	t	2026-03-28 23:40:55.425683+05	\N	\N	\N
55	71	52	t	2026-03-28 23:40:55.425781+05	\N	\N	\N
56	72	53	t	2026-03-28 23:40:55.425914+05	\N	\N	\N
57	73	54	t	2026-03-28 23:40:55.426083+05	\N	\N	\N
58	73	57	t	2026-03-28 23:40:55.426186+05	\N	\N	\N
\.


--
-- TOC entry 5479 (class 0 OID 81899)
-- Dependencies: 277
-- Data for Name: FieldTypes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."FieldTypes" ("FieldTypeId", "FieldName", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "DisplayName") FROM stdin;
1	Dropdown	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Dropdown
2	Checkboxes	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Checkboxes
3	Radio buttons	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Radio buttons
4	Table	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Table
5	Numeric input	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Numeric input
6	Text input	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Text input
7	Date input	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Date input
8	Text Area	t	2026-03-27 22:13:29.217339+05	2026-03-27 22:13:29.217339+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	Text Area
\.


--
-- TOC entry 5481 (class 0 OID 81909)
-- Dependencies: 279
-- Data for Name: Iframes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Iframes" ("PID", "WebsiteName", "Link", "TempVersionId", "Status", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "Partial_key", "Full_key", "TemplateId", "BusinessId") FROM stdin;
1	Testing Iframe 1	https://localhost:7195/swagger/index.html	4	Active	t	2026-03-28 19:57:01.225387+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	_CbduXqsWZQus2AV0AX05jChoORicu	_CbduXqsWZQus2AV0AX05jChoORicuO16IQ53yz7-P5g_CwvH5zllFbREHuQlTPC	1	1
\.


--
-- TOC entry 5483 (class 0 OID 81921)
-- Dependencies: 281
-- Data for Name: MetafieldAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."MetafieldAnswers" (metafield_answer_id, template_version_id, quote_id, metafield_id, metafield_input, "QuoteRevisionId") FROM stdin;
1	1	1	1	meta answer 1	1
2	1	1	1	meta answer 1	2
3	1	1	2	Meta Answer 2	2
4	4	2	23	Answer meta 23	3
5	4	3	23	Answer meta 23	4
\.


--
-- TOC entry 5485 (class 0 OID 81931)
-- Dependencies: 283
-- Data for Name: Metafields; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Metafields" ("PID", "TempVersionId", "Name", "FieldType", "Tag", "Visibility", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "TableStyle", "MetafieldGuid", "DisplayOrder") FROM stdin;
1	1	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-27 23:42:11.108797+05	2026-03-28 19:16:53.786383+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	6
2	1	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-27 23:42:39.186553+05	2026-03-28 19:16:53.786384+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	5
3	1	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-27 23:42:53.447804+05	2026-03-28 19:16:53.786385+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	4
4	1	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-27 23:43:07.959429+05	2026-03-28 19:16:53.786385+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	d2840904-b8dd-4dd2-98b5-c65846021774	3
5	1	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 00:16:41.890655+05	2026-03-28 19:16:53.786386+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	2
6	1	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 19:11:19.188752+05	2026-03-28 19:16:53.786386+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	1
7	2	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 19:19:09.881565+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
8	2	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 19:19:09.88178+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
9	2	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 19:19:09.881831+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
10	2	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 19:19:09.881877+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
11	2	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 19:19:09.881938+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
12	2	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 19:19:09.881991+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
13	2	Meta 9	Single Line Text	N/A	Customer and Admin	t	2026-03-28 19:19:09.947389+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6d164318-7069-45e4-ac50-4a179c99dac9	1
14	3	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 19:20:42.095408+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
15	3	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 19:20:42.095527+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
16	3	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 19:20:42.095566+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
17	3	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 19:20:42.095602+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
18	3	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 19:20:42.09564+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
19	3	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 19:20:42.095679+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
20	3	Meta 7	Single Line Text	N/A	Admin Only	t	2026-03-28 19:20:42.223201+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	64e00e39-4570-4feb-a6c6-2ad933b6c933	1
21	3	Meta 8	Single Line Text	N/A	Admin Only	t	2026-03-28 19:20:42.237582+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	89838f35-2244-4b98-9c34-23cbe71fd7ae	2
22	4	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 19:43:20.697962+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
23	4	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 19:43:20.698008+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
24	4	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 19:43:20.698029+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
25	4	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 19:43:20.698044+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
26	4	Meta 8	Single Line Text	N/A	Admin Only	t	2026-03-28 19:43:20.69806+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	89838f35-2244-4b98-9c34-23cbe71fd7ae	0
27	4	Meta 7	Single Line Text	N/A	Admin Only	t	2026-03-28 19:43:20.698078+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	64e00e39-4570-4feb-a6c6-2ad933b6c933	0
28	4	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 19:43:20.698104+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
29	4	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 19:43:20.69812+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
30	6	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 23:27:14.141942+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
31	6	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 23:27:14.144524+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
32	6	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 23:27:14.144621+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
33	6	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 23:27:14.144676+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
34	6	Meta 8	Single Line Text	N/A	Admin Only	t	2026-03-28 23:27:14.14472+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	89838f35-2244-4b98-9c34-23cbe71fd7ae	0
35	6	Meta 7	Single Line Text	N/A	Admin Only	t	2026-03-28 23:27:14.145037+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	64e00e39-4570-4feb-a6c6-2ad933b6c933	0
36	6	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 23:27:14.145091+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
37	6	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 23:27:14.145132+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
38	7	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 23:39:21.431851+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
39	7	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 23:39:21.436143+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
40	7	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 23:39:21.436563+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
41	7	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 23:39:21.436729+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
42	7	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 23:39:21.436844+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
43	7	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 23:39:21.436992+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
44	7	Meta 7	Single Line Text	N/A	Admin Only	t	2026-03-28 23:39:21.437115+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	64e00e39-4570-4feb-a6c6-2ad933b6c933	0
45	7	Meta 8	Single Line Text	N/A	Admin Only	t	2026-03-28 23:39:21.437204+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	89838f35-2244-4b98-9c34-23cbe71fd7ae	0
46	7	Meta 10	Single Line Text	N/A	Customer and Admin	t	2026-03-28 23:39:21.617875+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	33f65d2d-1b68-403c-a109-a0d508ee74f2	1
47	8	meta 5	Single Line Text	\N	Customer and Admin	t	2026-03-28 23:40:55.426284+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	2fc6b53f-cdc3-4dbf-a303-acb5c8446e89	0
48	8	Metafield 4	Single Line Text	meta 4	Admin Only	t	2026-03-28 23:40:55.426458+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	d2840904-b8dd-4dd2-98b5-c65846021774	0
49	8	Metafield 3	Single Line Text	meta 3	Customer and Admin	t	2026-03-28 23:40:55.42653+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	6fb2ac68-938f-476c-b3ba-600e07b12180	0
50	8	Meta 4	Single Line Text	N/A	Customer and Admin	t	2026-03-28 23:40:55.426599+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	3e99deb0-9631-4eaa-bfe4-5bcc2307f4e4	0
51	8	Metafield 2	Single Line Text	meta 2	Admin Only	t	2026-03-28 23:40:55.426687+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	57f3ee98-8fd3-4119-94ee-ee9e98d2f8f4	0
52	8	Metafield 1	Single Line Text	meta 1	Customer and Admin	t	2026-03-28 23:40:55.42675+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	b3d5ca2b-2878-46e4-8c3a-bffff2fd1604	0
53	8	Meta 10	Single Line Text	N/A	Customer and Admin	t	2026-03-28 23:40:55.504101+05	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	\N	20b7d343-2f7e-4935-b322-099d02cef0e3	1
\.


--
-- TOC entry 5487 (class 0 OID 81949)
-- Dependencies: 285
-- Data for Name: QuestionGroups; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionGroups" ("QuestionGroupId", "Name", "DisplayOrder", "TemplateId", "IsActive", "CreatedAt", "TemplateVersionId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "GroupGuid") FROM stdin;
1	Group 1	1	1	t	2026-03-27 21:55:50.282551+05	1	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
2	Group 2	2	1	t	2026-03-27 21:56:07.95051+05	1	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
3	Group 1	1	1	t	2026-03-28 19:19:09.5683+05	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
4	Group 2	2	1	t	2026-03-28 19:19:09.5842+05	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
5	Group 1	1	1	t	2026-03-28 19:20:41.67628+05	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
6	Group 2	2	1	t	2026-03-28 19:20:41.680938+05	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
7	Group 1	1	1	t	2026-03-28 19:43:20.410769+05	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
8	Group 2	2	1	t	2026-03-28 19:43:20.417029+05	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
9	Group 4	3	1	t	2026-03-28 19:43:20.756657+05	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	493db416-7802-41a8-8a9f-6431f71848f6
10	Group 1	1	1	t	2026-03-28 23:27:13.775657+05	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
11	Group 2	2	1	t	2026-03-28 23:27:13.812871+05	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
12	Group 1	1	1	t	2026-03-28 23:39:21.041433+05	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
13	Group 2	2	1	t	2026-03-28 23:39:21.061848+05	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
14	Group 1	1	1	t	2026-03-28 23:40:55.047346+05	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6dad5032-38c5-44ff-933d-ccd65b81fff0
15	Group 2	2	1	t	2026-03-28 23:40:55.054297+05	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	2547eac1-c733-455d-9488-6dfa7e541aa7
\.


--
-- TOC entry 5489 (class 0 OID 81963)
-- Dependencies: 287
-- Data for Name: QuestionOptions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionOptions" ("QOptionId", "OptionText", "QuestionId", "DisplayOrder", "FieldTypeId", "MaterialCompId", "IsActive", "CreatedAt", "ModifiedAt", "MatCompName", "CreatedById", "ModifiedById", "OptionGuid", "MaterialComponentAssociationId") FROM stdin;
1	Answer 1.1.1	1	1	\N	1	t	2026-03-27 22:21:03.772226+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	10
2	Answer 1.2.1	2	1	\N	2	t	2026-03-27 22:21:40.114677+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	b130204d-51ac-4cfe-b561-afc485d8963e	10
3	Answer 1.3.1	3	1	\N	1	t	2026-03-27 22:22:56.241154+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	10
4	Answer 1.3.2	3	2	\N	2	t	2026-03-27 22:22:56.446779+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	10
5	Answer 1.4.1	4	1	\N	1	t	2026-03-27 22:26:18.921809+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	11
6	Answer 1.4.2	4	2	\N	2	t	2026-03-27 22:26:18.968561+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	11
7	Answer 2.1.1	5	1	\N	1	t	2026-03-27 23:10:46.946657+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	11
8	Answer 2.2.1	6	1	\N	2	t	2026-03-27 23:15:38.051387+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	11
10	Answer 2.4.1	8	1	\N	1	t	2026-03-27 23:17:26.685968+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	10
9	Answer 2.3.1	7	1	\N	2	f	2026-03-27 23:16:58.167296+05	2026-03-27 23:39:33.207816+05	\N	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	a0a6adc4-31dc-4922-902b-4e8f7fd6f9bf	10
12	Answer 2.3.1	7	1	\N	1	t	2026-03-27 23:39:33.228586+05	\N	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	10
13	Answer 1.1.1	9	1	\N	1	t	2026-03-28 19:19:09.67767+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	0
14	Answer 1.2.1	10	1	\N	2	t	2026-03-28 19:19:09.70421+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	0
15	Answer 1.3.1	11	1	\N	1	t	2026-03-28 19:19:09.721975+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	0
16	Answer 1.3.2	11	2	\N	2	t	2026-03-28 19:19:09.728351+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	0
17	Answer 1.4.1	12	1	\N	1	t	2026-03-28 19:19:09.746651+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	0
18	Answer 1.4.2	12	2	\N	2	t	2026-03-28 19:19:09.754761+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	0
19	Answer 2.1.1	13	1	\N	1	t	2026-03-28 19:19:09.785463+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	0
20	Answer 2.2.1	14	1	\N	2	t	2026-03-28 19:19:09.811002+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	0
21	Answer 2.3.1	15	1	\N	1	t	2026-03-28 19:19:09.83784+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	0
22	Answer 2.4.1	16	1	\N	1	t	2026-03-28 19:19:09.867063+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	0
23	Answer 1.1.1	17	1	\N	1	t	2026-03-28 19:20:41.714022+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	0
24	Answer 1.2.1	18	1	\N	2	t	2026-03-28 19:20:41.814018+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	0
25	Answer 1.3.1	19	1	\N	1	t	2026-03-28 19:20:41.846028+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	0
26	Answer 1.3.2	19	2	\N	2	t	2026-03-28 19:20:41.855394+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	0
27	Answer 1.4.1	20	1	\N	1	t	2026-03-28 19:20:41.888331+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	0
28	Answer 1.4.2	20	2	\N	2	t	2026-03-28 19:20:41.8948+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	0
29	Answer 2.1.1	21	1	\N	1	t	2026-03-28 19:20:41.923052+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	0
30	Answer 2.2.1	22	1	\N	2	t	2026-03-28 19:20:41.955587+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	0
31	Answer 2.3.1	23	1	\N	1	t	2026-03-28 19:20:42.015262+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	0
32	Answer 2.4.1	24	1	\N	1	t	2026-03-28 19:20:42.090233+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	0
33	Answer 1.1.1	25	1	\N	1	t	2026-03-28 19:43:20.45799+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	0
34	Answer 1.2.1	26	1	\N	2	t	2026-03-28 19:43:20.480115+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	0
35	Answer 1.3.1	27	1	\N	1	t	2026-03-28 19:43:20.49826+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	0
36	Answer 1.3.2	27	2	\N	2	t	2026-03-28 19:43:20.528055+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	0
37	Answer 1.4.1	28	1	\N	1	t	2026-03-28 19:43:20.548027+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	0
38	Answer 1.4.2	28	2	\N	2	t	2026-03-28 19:43:20.552276+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	0
39	Answer 2.1.1	29	1	\N	1	t	2026-03-28 19:43:20.574157+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	0
40	Answer 2.2.1	30	1	\N	2	t	2026-03-28 19:43:20.592603+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	0
41	Answer 2.3.1	31	1	\N	1	t	2026-03-28 19:43:20.614378+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	0
42	Answer 2.4.1	32	1	\N	1	t	2026-03-28 19:43:20.638331+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	0
43	Answer 1.1.1	33	1	\N	1	t	2026-03-28 23:27:13.887995+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	0
44	Answer 1.2.1	34	1	\N	2	t	2026-03-28 23:27:13.91877+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	0
45	Answer 1.3.1	35	1	\N	1	t	2026-03-28 23:27:13.93646+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	0
46	Answer 1.3.2	35	2	\N	2	t	2026-03-28 23:27:13.940896+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	0
47	Answer 1.4.1	36	1	\N	1	t	2026-03-28 23:27:13.995046+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	0
48	Answer 1.4.2	36	2	\N	2	t	2026-03-28 23:27:13.99999+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	0
49	Answer 2.1.1	37	1	\N	1	t	2026-03-28 23:27:14.021762+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	0
50	Answer 2.2.1	38	1	\N	2	t	2026-03-28 23:27:14.044019+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	0
51	Answer 2.3.1	39	1	\N	1	t	2026-03-28 23:27:14.072906+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	0
52	Answer 2.4.1	40	1	\N	1	t	2026-03-28 23:27:14.119291+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	0
53	Answer 1.5.1	41	1	\N	1	t	2026-03-28 23:27:14.285704+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	759ccac1-4dc1-4a73-892b-f0aa31e5bae2	10
54	Answer 1.5.2	41	2	\N	2	t	2026-03-28 23:27:14.298069+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	32d73581-1625-4d81-8a6b-d0a546182dd4	10
55	Answer 1.1.1	42	1	\N	1	t	2026-03-28 23:39:21.153303+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	0
56	Answer 1.2.1	43	1	\N	2	t	2026-03-28 23:39:21.182673+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	0
57	Answer 1.3.1	44	1	\N	1	t	2026-03-28 23:39:21.204464+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	0
58	Answer 1.3.2	44	2	\N	2	t	2026-03-28 23:39:21.212483+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	0
59	Answer 1.4.1	45	1	\N	1	t	2026-03-28 23:39:21.23554+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	0
60	Answer 1.4.2	45	2	\N	2	t	2026-03-28 23:39:21.246892+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	0
61	Answer 2.1.1	46	1	\N	1	t	2026-03-28 23:39:21.277088+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	0
62	Answer 2.2.1	47	1	\N	2	t	2026-03-28 23:39:21.309752+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	0
63	Answer 2.3.1	48	1	\N	1	t	2026-03-28 23:39:21.38014+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	0
64	Answer 2.4.1	49	1	\N	1	t	2026-03-28 23:39:21.417817+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	0
65	Answer 1.1.1	50	1	\N	1	t	2026-03-28 23:40:55.104421+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7b9319eb-289d-4ba1-b862-c4b462063a23	10
66	Answer 1.2.1	51	1	\N	2	t	2026-03-28 23:40:55.156914+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	b130204d-51ac-4cfe-b561-afc485d8963e	10
67	Answer 1.3.1	52	1	\N	1	t	2026-03-28 23:40:55.225512+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	69bd0f4e-63ad-4e30-93ba-14d7f3e45878	10
68	Answer 1.3.2	52	2	\N	2	t	2026-03-28 23:40:55.238395+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	7a3c87f5-6def-4ce4-8294-897afc1da763	10
69	Answer 1.4.1	53	1	\N	1	t	2026-03-28 23:40:55.270232+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	84e914df-1f36-4b12-ab07-10f878b6c6c4	11
70	Answer 1.4.2	53	2	\N	2	t	2026-03-28 23:40:55.287892+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	255e7059-c17d-4db8-bb1c-4d49bc861332	11
71	Answer 2.1.1	54	1	\N	1	t	2026-03-28 23:40:55.330715+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	709c1f40-6a9e-44f2-aeeb-c01ab0e4f122	11
72	Answer 2.2.1	55	1	\N	2	t	2026-03-28 23:40:55.363737+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	60ba319b-1bc9-4e6c-81bb-00da3c4117f3	11
73	Answer 2.3.1	56	1	\N	1	t	2026-03-28 23:40:55.392511+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	63365249-20e2-435a-8d08-8ee258e4fd0c	10
74	Answer 2.4.1	57	1	\N	1	t	2026-03-28 23:40:55.419943+05	\N	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	eb668078-d7f3-4d7d-8e59-baa343ed2068	10
\.


--
-- TOC entry 5491 (class 0 OID 81977)
-- Dependencies: 289
-- Data for Name: Questions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Questions" ("QuestionId", "Text", "IsRequired", "DisplayOrder", "QuestionGroupId", "TemplateId", "ParentId", "ValidFrom", "ValidTo", "TagId", "IsActive", "CreatedAt", "TemplateVersionId", "FieldTypeId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "QuestionGuid") FROM stdin;
1	Question 1.1	t	1	1	1	\N	\N	\N	\N	t	2026-03-27 22:21:03.583143+05	1	1	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
2	Question 1.2	f	2	1	1	\N	\N	\N	\N	t	2026-03-27 22:21:40.084316+05	1	2	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
3	Question 1.3	t	3	1	1	\N	\N	\N	\N	t	2026-03-27 22:22:56.218044+05	1	3	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
4	Question 1.4	f	4	1	1	\N	\N	\N	\N	t	2026-03-27 22:26:18.856764+05	1	4	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
5	Question 2.1	t	1	2	1	\N	\N	\N	\N	t	2026-03-27 23:10:46.569866+05	1	5	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
6	Question 2.2	f	2	2	1	\N	\N	\N	\N	t	2026-03-27 23:15:38.009947+05	1	8	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
8	Question 2.4	f	4	2	1	\N	\N	\N	\N	t	2026-03-27 23:17:26.619528+05	1	6	\N	74ca72ad-4e91-4384-89eb-925be075e300	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
7	Question 2.3	t	3	2	1	\N	\N	\N	\N	t	2026-03-27 23:16:58.14475+05	1	7	2026-03-27 23:39:33.196604+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
9	Question 1.1	t	1	3	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.637104+05	2	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
10	Question 1.2	f	2	3	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.690577+05	2	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
11	Question 1.3	t	3	3	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.709811+05	2	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
12	Question 1.4	f	4	3	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.732376+05	2	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
13	Question 2.1	t	1	4	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.764792+05	2	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
14	Question 2.2	f	2	4	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.791306+05	2	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
15	Question 2.3	t	3	4	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.816245+05	2	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
16	Question 2.4	f	4	4	1	\N	\N	\N	\N	t	2026-03-28 19:19:09.845157+05	2	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
17	Question 1.1	t	1	5	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.697042+05	3	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
18	Question 1.2	f	2	5	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.753048+05	3	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
19	Question 1.3	t	3	5	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.822803+05	3	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
20	Question 1.4	f	4	5	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.863379+05	3	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
21	Question 2.1	t	1	6	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.902721+05	3	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
22	Question 2.2	f	2	6	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.929855+05	3	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
23	Question 2.3	t	3	6	1	\N	\N	\N	\N	t	2026-03-28 19:20:41.97472+05	3	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
24	Question 2.4	f	4	6	1	\N	\N	\N	\N	t	2026-03-28 19:20:42.028062+05	3	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
25	Question 1.1	t	1	7	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.428914+05	4	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
26	Question 1.2	f	2	7	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.463687+05	4	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
27	Question 1.3	t	3	7	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.484394+05	4	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
28	Question 1.4	f	4	7	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.533955+05	4	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
29	Question 2.1	t	1	8	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.555945+05	4	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
30	Question 2.2	f	2	8	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.57887+05	4	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
31	Question 2.3	t	3	8	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.5978+05	4	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
32	Question 2.4	f	4	8	1	\N	\N	\N	\N	t	2026-03-28 19:43:20.618894+05	4	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
33	Question 1.1	t	1	10	1	\N	\N	\N	\N	t	2026-03-28 23:27:13.842355+05	6	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
34	Question 1.2	f	2	10	1	\N	\N	\N	\N	t	2026-03-28 23:27:13.904928+05	6	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
35	Question 1.3	t	3	10	1	\N	\N	\N	\N	t	2026-03-28 23:27:13.922964+05	6	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
36	Question 1.4	f	4	10	1	\N	\N	\N	\N	t	2026-03-28 23:27:13.9452+05	6	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
37	Question 2.1	t	1	11	1	\N	\N	\N	\N	t	2026-03-28 23:27:14.004854+05	6	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
38	Question 2.2	f	2	11	1	\N	\N	\N	\N	t	2026-03-28 23:27:14.026572+05	6	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
39	Question 2.3	t	3	11	1	\N	\N	\N	\N	t	2026-03-28 23:27:14.049745+05	6	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
40	Question 2.4	f	4	11	1	\N	\N	\N	\N	t	2026-03-28 23:27:14.079828+05	6	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
41	Question 1.5	t	5	10	1	\N	\N	\N	\N	t	2026-03-28 23:27:14.224057+05	6	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	3ebd82d6-39dd-44e6-aff2-561dd36a23dd
42	Question 1.1	t	1	12	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.090837+05	7	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
43	Question 1.2	f	2	12	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.167244+05	7	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
44	Question 1.3	t	3	12	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.189911+05	7	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
45	Question 1.4	f	4	12	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.217927+05	7	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
46	Question 2.1	t	1	13	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.25645+05	7	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
47	Question 2.2	f	2	13	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.285671+05	7	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
48	Question 2.3	t	3	13	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.319698+05	7	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
49	Question 2.4	f	4	13	1	\N	\N	\N	\N	t	2026-03-28 23:39:21.388203+05	7	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
50	Question 1.1	t	1	14	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.067299+05	8	1	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	8aa31ce9-1266-4642-8ac1-e7512a9855e6
51	Question 1.2	f	2	14	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.129263+05	8	2	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	6800fb59-482b-44cb-8f63-38a19c84e16d
52	Question 1.3	t	3	14	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.163115+05	8	3	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	4efcf165-628e-4830-a3ed-3187d461a676
53	Question 1.4	f	4	14	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.24615+05	8	4	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	f54e19ab-7cac-4b17-8adb-d0a733d994c5
54	Question 2.1	t	1	15	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.298127+05	8	5	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	e08a757f-c2b5-4c5a-af63-fad154a6d201
55	Question 2.2	f	2	15	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.343743+05	8	8	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	b23bc902-765e-4e81-b9b5-49f5529fbf1f
56	Question 2.3	t	3	15	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.370883+05	8	7	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	75b991e9-f353-4c01-9b78-a6aca8fec9d9
57	Question 2.4	f	4	15	1	\N	\N	\N	\N	t	2026-03-28 23:40:55.398495+05	8	6	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	d3a845e1-ef06-46d2-90b9-923d2f5a7c14
\.


--
-- TOC entry 5493 (class 0 OID 81993)
-- Dependencies: 291
-- Data for Name: TemplateItems; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateItems" ("TemplateItemId", "TemplateId", "ServiceName", "Description", "Quantity", "Unit", "ItemPrice", "Total", "TemplateVersion", "CreatedAt", "IsActive", "ModifiedAt", "CreatedById", "ModifiedById", "QuoteId", "CustomerId", business_id, "QuoteRevisionId", "CostPrice", "LevelNumber") FROM stdin;
4	1	Service 1	Description 1	10	100	10.00	100.00	4	2026-03-28 22:14:13.832969+05	t	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	2	1	1	3	20.00	2
5	1	Service 2	Description 2	10	100	20.00	200.00	4	2026-03-28 22:14:13.835764+05	t	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	2	1	1	3	40.00	2
6	1	Service 3	Description 3	10	100	30.00	300.00	4	2026-03-28 22:14:13.838456+05	t	\N	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	2	1	1	3	60.00	2
7	1	service 3	description 3	10	100	20.00	200.00	1	2026-03-30 20:10:03.090842+05	t	\N	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	\N	1	2	2	2	40.00	2
\.


--
-- TOC entry 5495 (class 0 OID 82003)
-- Dependencies: 293
-- Data for Name: TemplateVersions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateVersions" ("TempVersionId", "TemplateId", "TempValidFrom", "TempValidTo", "IsActive", "CreatedAt", "TempVersion", "ModifiedAt", "CreatedById", "ModifiedById", business_id, template_path) FROM stdin;
5	2	2026-03-28 21:41:19.884463+05	\N	t	2026-03-28 21:41:19.883977+05	1	2026-03-28 23:06:28.311987+05	ce8bb747-624d-46c2-9d76-da557a53dd90	\N	1	businesses/1/templates/5/template.odt
1	1	2026-03-27 21:51:00.995026+05	2026-03-28 23:40:55.033119+05	t	2026-03-27 21:51:00.994631+05	1	2026-03-28 23:40:55.033119+05	74ca72ad-4e91-4384-89eb-925be075e300	ce8bb747-624d-46c2-9d76-da557a53dd90	1	\N
2	1	2026-03-28 19:19:09.521475+05	2026-03-28 19:20:41.662709+05	t	2026-03-28 19:19:09.521756+05	2	2026-03-28 19:20:41.662709+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	\N
3	1	2026-03-28 19:20:41.670541+05	2026-03-28 23:39:20.831629+05	t	2026-03-28 19:20:41.670542+05	3	2026-03-28 23:39:20.831629+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	businesses/1/templates/3/template.odt
4	1	2026-03-28 19:43:20.404356+05	2026-03-28 23:27:13.659201+05	t	2026-03-28 19:43:20.404357+05	4	2026-03-28 23:27:13.659201+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	businesses/1/templates/3/template.odt
6	1	2026-03-28 23:27:13.754147+05	2026-03-28 23:39:20.831629+05	t	2026-03-28 23:27:13.754148+05	5	2026-03-28 23:39:20.831629+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	businesses/1/templates/3/template.odt
7	1	2026-03-28 23:39:20.975129+05	2026-03-28 23:40:55.033119+05	t	2026-03-28 23:39:20.975355+05	6	2026-03-28 23:40:55.033119+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	businesses/1/templates/3/template.odt
8	1	2026-03-28 23:40:55.040524+05	\N	t	2026-03-28 23:40:55.040525+05	7	2026-03-28 23:40:55.510121+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	\N
9	3	2026-03-30 19:17:14.324548+05	\N	t	2026-03-30 19:17:14.324287+05	1	\N	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	\N	2	\N
\.


--
-- TOC entry 5497 (class 0 OID 82013)
-- Dependencies: 295
-- Data for Name: Templates; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Templates" ("TemplateId", "TemplateName", "IsActive", "CreatedAt", "Description", "ModifiedAt", "CreatedById", "ModifiedById", business_id, template_path) FROM stdin;
2	Testing template 2	t	2026-03-28 21:41:19.883168+05	\N	2026-03-28 23:06:28.25168+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	\N
1	Testing Template 1	t	2026-03-27 21:51:00.992282+05	Temp Description 1	2026-03-30 19:18:15.743227+05	74ca72ad-4e91-4384-89eb-925be075e300	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	1	\N
3	Testing Template 2	t	2026-03-30 19:17:14.322752+05	\N	2026-03-30 19:19:08.596533+05	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	2	\N
\.


--
-- TOC entry 5499 (class 0 OID 82023)
-- Dependencies: 297
-- Data for Name: UserAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."UserAnswers" ("UAnswerId", "QuestionId", "QOptionId", "AnswerText", "DisplayOrder", "DateTime", "RecordId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "CustomerId", "QuoteVersionId", business_id, "ParentOptionId", "QuoteRevisionId") FROM stdin;
4	3	4		\N	2026-03-27 23:58:51.680332+05	1	t	2026-03-27 23:58:51.680331+05	2026-03-27 23:58:51.680332+05	74ca72ad-4e91-4384-89eb-925be075e300	74ca72ad-4e91-4384-89eb-925be075e300	2	1	1	7	1
5	3	4		\N	2026-03-28 19:26:38.932932+05	1	t	2026-03-28 19:26:38.933677+05	2026-03-28 19:26:38.934001+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	2	1	1	7	2
6	4	5	field 5	\N	2026-03-28 19:28:38.833846+05	1	t	2026-03-28 19:28:38.833846+05	2026-03-28 19:28:38.833847+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	2	1	1	8	2
7	4	6	10	\N	2026-03-28 19:30:15.744864+05	1	t	2026-03-28 19:30:15.744863+05	2026-03-28 19:30:15.744864+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	2	1	1	8	2
8	30	40	10	\N	2026-03-28 20:10:14.566445+05	2	t	2026-03-28 20:10:14.566248+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
9	31	41	10	\N	2026-03-28 20:10:14.574563+05	2	t	2026-03-28 20:10:14.574562+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
10	28	37	10	\N	2026-03-28 20:10:14.583207+05	2	t	2026-03-28 20:10:14.583207+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
11	25	33	10	\N	2026-03-28 20:10:14.591062+05	2	t	2026-03-28 20:10:14.591061+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
12	27	35	10	\N	2026-03-28 20:10:14.599754+05	2	t	2026-03-28 20:10:14.599753+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
13	29	39	10	\N	2026-03-28 20:10:14.607998+05	2	t	2026-03-28 20:10:14.607997+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	3
14	30	40	10	\N	2026-03-28 22:06:28.828277+05	3	t	2026-03-28 22:06:28.828278+05	2026-03-28 22:06:28.828278+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
15	31	41	10	\N	2026-03-28 22:06:28.829268+05	3	t	2026-03-28 22:06:28.829269+05	2026-03-28 22:06:28.829269+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
16	28	37	10	\N	2026-03-28 22:06:28.82927+05	3	t	2026-03-28 22:06:28.82927+05	2026-03-28 22:06:28.82927+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
17	25	33	10	\N	2026-03-28 22:06:28.829271+05	3	t	2026-03-28 22:06:28.829271+05	2026-03-28 22:06:28.829271+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
18	27	35	10	\N	2026-03-28 22:06:28.829271+05	3	t	2026-03-28 22:06:28.829271+05	2026-03-28 22:06:28.829271+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
19	29	39	10	\N	2026-03-28 22:06:28.829272+05	3	t	2026-03-28 22:06:28.829272+05	2026-03-28 22:06:28.829272+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	\N	4
20	26	34		\N	2026-03-28 22:08:35.558385+05	3	t	2026-03-28 22:08:35.558384+05	2026-03-28 22:08:35.558386+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	3	1	1	36	4
21	25	33		\N	2026-03-28 22:37:13.363539+05	4	t	2026-03-28 22:37:13.363538+05	2026-03-28 22:37:13.364127+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	35	5
22	30	40	10	\N	2026-03-28 22:39:08.945458+05	5	t	2026-03-28 22:39:08.945458+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
23	31	41	10	\N	2026-03-28 22:39:08.98251+05	5	t	2026-03-28 22:39:08.982509+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
24	28	37	10	\N	2026-03-28 22:39:08.998766+05	5	t	2026-03-28 22:39:08.998764+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
25	25	33	10	\N	2026-03-28 22:39:09.019285+05	5	t	2026-03-28 22:39:09.019285+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
26	27	35	10	\N	2026-03-28 22:39:09.031157+05	5	t	2026-03-28 22:39:09.031156+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
27	29	39	10	\N	2026-03-28 22:39:09.039825+05	5	t	2026-03-28 22:39:09.039825+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	6
28	30	40	10	\N	2026-03-28 22:52:38.0093+05	5	t	2026-03-28 22:52:38.009729+05	2026-03-28 22:52:38.009731+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
29	31	41	10	\N	2026-03-28 22:52:38.009904+05	5	t	2026-03-28 22:52:38.009904+05	2026-03-28 22:52:38.009904+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
30	28	37	10	\N	2026-03-28 22:52:38.009905+05	5	t	2026-03-28 22:52:38.009905+05	2026-03-28 22:52:38.009905+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
31	25	33	10	\N	2026-03-28 22:52:38.009906+05	5	t	2026-03-28 22:52:38.009906+05	2026-03-28 22:52:38.009906+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
32	27	35	10	\N	2026-03-28 22:52:38.009906+05	5	t	2026-03-28 22:52:38.009906+05	2026-03-28 22:52:38.009907+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
33	29	39	10	\N	2026-03-28 22:52:38.009908+05	5	t	2026-03-28 22:52:38.009909+05	2026-03-28 22:52:38.009909+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	1	1	1	\N	7
34	50	65	10	\N	2026-03-28 23:45:52.816743+05	6	t	2026-03-28 23:45:52.816436+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
35	51	66	10	\N	2026-03-28 23:45:52.832108+05	6	t	2026-03-28 23:45:52.832108+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
36	52	67	10	\N	2026-03-28 23:45:52.846303+05	6	t	2026-03-28 23:45:52.846302+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
37	53	69	10	\N	2026-03-28 23:45:52.858081+05	6	t	2026-03-28 23:45:52.85808+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
38	54	71	10	\N	2026-03-28 23:45:52.869603+05	6	t	2026-03-28 23:45:52.869603+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
39	55	72	10	\N	2026-03-28 23:45:52.88215+05	6	t	2026-03-28 23:45:52.882149+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
40	56	73	10	\N	2026-03-28 23:45:52.893799+05	6	t	2026-03-28 23:45:52.893799+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
41	57	74	10	\N	2026-03-28 23:45:52.905452+05	6	t	2026-03-28 23:45:52.905451+05	\N	025061e6-e30b-4dee-bafc-6230e032ac54	\N	1	1	1	\N	8
42	1	1		\N	2026-03-28 23:52:06.362363+05	7	t	2026-03-28 23:52:06.362362+05	2026-03-28 23:52:06.362598+05	ce8bb747-624d-46c2-9d76-da557a53dd90	ce8bb747-624d-46c2-9d76-da557a53dd90	2	1	1	3	9
\.


--
-- TOC entry 5501 (class 0 OID 82035)
-- Dependencies: 299
-- Data for Name: UserRecords; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."UserRecords" ("RecStatusId", "QuoteReference", "TempVersionId", "TemplateId", "MiscCodeEnum", "MiscCodeName", "TotalCost", "IsActive", "CreatedAt", "MiscLookupCodeEnum", "ModifiedAt", "PDFLINK", "CreatedById", "ModifiedById") FROM stdin;
\.


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 228
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: customers; Owner: postgres
--

SELECT pg_catalog.setval('customers.customers_customer_id_seq', 3, true);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 230
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general."Statistics_statistic_id_seq"', 11, true);


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 232
-- Name: business_business_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.business_business_id_seq', 4, true);


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 234
-- Name: business_document_business_document_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.business_document_business_document_id_seq', 1, false);


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 237
-- Name: menu_menu_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.menu_menu_id_seq', 6, true);


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 239
-- Name: Components_ComponentId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."Components_ComponentId_seq"', 2, true);


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 241
-- Name: MaterialComponentHistory_HistoryId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."MaterialComponentHistory_HistoryId_seq"', 8, true);


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 243
-- Name: MaterialComponents_MatCompId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."MaterialComponents_MatCompId_seq"', 3, true);


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 245
-- Name: Materials_MaterialId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."Materials_MaterialId_seq"', 2, true);


--
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 247
-- Name: MiscLookups_CodeEnum_seq; Type: SEQUENCE SET; Schema: misc; Owner: postgres
--

SELECT pg_catalog.setval('misc."MiscLookups_CodeEnum_seq"', 11, true);


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 250
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: misc; Owner: postgres
--

SELECT pg_catalog.setval('misc.countries_id_seq', 138, true);


--
-- TOC entry 5539 (class 0 OID 0)
-- Dependencies: 253
-- Name: QuoteRevisions_QuoteRevisionId_seq; Type: SEQUENCE SET; Schema: quotes; Owner: postgres
--

SELECT pg_catalog.setval('quotes."QuoteRevisions_QuoteRevisionId_seq"', 11, true);


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 255
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE SET; Schema: quotes; Owner: postgres
--

SELECT pg_catalog.setval('quotes."UserRecords_RecStatusId_seq"', 9, true);


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 257
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."RefreshTokens_Id_seq"', 58, true);


--
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 261
-- Name: roles_RoleId_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."roles_RoleId_seq"', 5, true);


--
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 263
-- Name: roles_claims_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."roles_claims_Id_seq"', 1, false);


--
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 266
-- Name: security_group_members_security_group_id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security.security_group_members_security_group_id_seq', 1, false);


--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 267
-- Name: security_group_sec_group_id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security.security_group_sec_group_id_seq', 16, true);


--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 269
-- Name: user_claims_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."user_claims_Id_seq"', 1, false);


--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 274
-- Name: users_UserId_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."users_UserId_seq"', 14, true);


--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 276
-- Name: DependentQuestions_DependentQId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."DependentQuestions_DependentQId_seq"', 58, true);


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 278
-- Name: FieldTypes_FieldTypeId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."FieldTypes_FieldTypeId_seq"', 16, true);


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 280
-- Name: Iframes_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Iframes_PID_seq"', 1, true);


--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 282
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."MetafieldAnswers_metafield_answer_id_seq"', 5, true);


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 284
-- Name: Metafields_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Metafields_PID_seq"', 53, true);


--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 286
-- Name: QuestionGroups_QuestionGroupId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionGroups_QuestionGroupId_seq"', 15, true);


--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 288
-- Name: QuestionOptions_QOptionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionOptions_QOptionId_seq"', 74, true);


--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 290
-- Name: Questions_QuestionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Questions_QuestionId_seq"', 57, true);


--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 292
-- Name: TemplateItems_TemplateItemId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateItems_TemplateItemId_seq"', 7, true);


--
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 294
-- Name: TemplateVersions_TempVersionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateVersions_TempVersionId_seq"', 9, true);


--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 296
-- Name: Templates_TemplateId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Templates_TemplateId_seq"', 3, true);


--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 298
-- Name: UserAnswers_UAnswerId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."UserAnswers_UAnswerId_seq"', 42, true);


--
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 300
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."UserRecords_RecStatusId_seq"', 1, false);


--
-- TOC entry 5063 (class 2606 OID 82063)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: customers; Owner: postgres
--

ALTER TABLE ONLY customers.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 5068 (class 2606 OID 82065)
-- Name: Statistics Statistics_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics"
    ADD CONSTRAINT "Statistics_pkey" PRIMARY KEY (statistic_id);


--
-- TOC entry 5072 (class 2606 OID 82067)
-- Name: business_document business_document_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business_document
    ADD CONSTRAINT business_document_pkey PRIMARY KEY (business_document_id);


--
-- TOC entry 5070 (class 2606 OID 82069)
-- Name: business business_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.business
    ADD CONSTRAINT business_pkey PRIMARY KEY (business_id);


--
-- TOC entry 5074 (class 2606 OID 82071)
-- Name: menu menu_pkey; Type: CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general.menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (menu_id);


--
-- TOC entry 5079 (class 2606 OID 82073)
-- Name: Components PK_Components; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Components"
    ADD CONSTRAINT "PK_Components" PRIMARY KEY ("ComponentId");


--
-- TOC entry 5081 (class 2606 OID 82075)
-- Name: MaterialComponentHistory PK_MaterialComponentHistory; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponentHistory"
    ADD CONSTRAINT "PK_MaterialComponentHistory" PRIMARY KEY ("HistoryId");


--
-- TOC entry 5085 (class 2606 OID 82077)
-- Name: MaterialComponents PK_MaterialComponents; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "PK_MaterialComponents" PRIMARY KEY ("MatCompId");


--
-- TOC entry 5088 (class 2606 OID 82079)
-- Name: Materials PK_Materials; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Materials"
    ADD CONSTRAINT "PK_Materials" PRIMARY KEY ("MaterialId");


--
-- TOC entry 5090 (class 2606 OID 82081)
-- Name: MiscLookups PK_MiscLookups; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "PK_MiscLookups" PRIMARY KEY ("CodeEnum");


--
-- TOC entry 5092 (class 2606 OID 82083)
-- Name: code_lookup code_lookup_pkey; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc.code_lookup
    ADD CONSTRAINT code_lookup_pkey PRIMARY KEY (code_name, code_enum);


--
-- TOC entry 5094 (class 2606 OID 82085)
-- Name: countries countries_name_key; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc.countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- TOC entry 5096 (class 2606 OID 82087)
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 82089)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 5104 (class 2606 OID 82091)
-- Name: UserRecords PK_UserRecords; Type: CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."UserRecords"
    ADD CONSTRAINT "PK_UserRecords" PRIMARY KEY ("RecStatusId");


--
-- TOC entry 5100 (class 2606 OID 82093)
-- Name: QuoteRevisions QuoteRevisions_pkey; Type: CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."QuoteRevisions"
    ADD CONSTRAINT "QuoteRevisions_pkey" PRIMARY KEY ("QuoteRevisionId");


--
-- TOC entry 5112 (class 2606 OID 82095)
-- Name: jwt_settings PK_jwt_settings; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.jwt_settings
    ADD CONSTRAINT "PK_jwt_settings" PRIMARY KEY ("Id");


--
-- TOC entry 5116 (class 2606 OID 82097)
-- Name: roles PK_roles; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles
    ADD CONSTRAINT "PK_roles" PRIMARY KEY ("Id");


--
-- TOC entry 5120 (class 2606 OID 82099)
-- Name: roles_claims PK_roles_claims; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles_claims
    ADD CONSTRAINT "PK_roles_claims" PRIMARY KEY ("Id");


--
-- TOC entry 5127 (class 2606 OID 82101)
-- Name: user_claims PK_user_claims; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_claims
    ADD CONSTRAINT "PK_user_claims" PRIMARY KEY ("Id");


--
-- TOC entry 5130 (class 2606 OID 82103)
-- Name: user_logins PK_user_logins; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_logins
    ADD CONSTRAINT "PK_user_logins" PRIMARY KEY ("LoginProvider", "ProviderKey");


--
-- TOC entry 5133 (class 2606 OID 82105)
-- Name: user_roles PK_user_roles; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "PK_user_roles" PRIMARY KEY ("UserId", "RoleId");


--
-- TOC entry 5135 (class 2606 OID 82107)
-- Name: user_tokens PK_user_tokens; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_tokens
    ADD CONSTRAINT "PK_user_tokens" PRIMARY KEY ("UserId", "LoginProvider", "Name");


--
-- TOC entry 5138 (class 2606 OID 82109)
-- Name: users PK_users; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


--
-- TOC entry 5110 (class 2606 OID 82111)
-- Name: RefreshTokens RefreshTokens_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security."RefreshTokens"
    ADD CONSTRAINT "RefreshTokens_pkey" PRIMARY KEY ("Id");


--
-- TOC entry 5114 (class 2606 OID 82113)
-- Name: menu_access menu_access_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.menu_access
    ADD CONSTRAINT menu_access_pkey PRIMARY KEY (security_group_id, menu_id);


--
-- TOC entry 5124 (class 2606 OID 82115)
-- Name: security_group_members security_group_members_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group_members
    ADD CONSTRAINT security_group_members_pkey PRIMARY KEY (security_group_id, user_id);


--
-- TOC entry 5122 (class 2606 OID 82117)
-- Name: security_group security_group_pkey; Type: CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group
    ADD CONSTRAINT security_group_pkey PRIMARY KEY (security_group_id);


--
-- TOC entry 5153 (class 2606 OID 82119)
-- Name: MetafieldAnswers MetafieldAnswers_pkey; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT "MetafieldAnswers_pkey" PRIMARY KEY (metafield_answer_id);


--
-- TOC entry 5145 (class 2606 OID 82121)
-- Name: DependentQuestions PK_DependentQuestions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "PK_DependentQuestions" PRIMARY KEY ("DependentQId");


--
-- TOC entry 5149 (class 2606 OID 82123)
-- Name: FieldTypes PK_FieldTypes; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "PK_FieldTypes" PRIMARY KEY ("FieldTypeId");


--
-- TOC entry 5151 (class 2606 OID 82125)
-- Name: Iframes PK_Iframes; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Iframes"
    ADD CONSTRAINT "PK_Iframes" PRIMARY KEY ("PID");


--
-- TOC entry 5157 (class 2606 OID 82127)
-- Name: Metafields PK_Metafields; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Metafields"
    ADD CONSTRAINT "PK_Metafields" PRIMARY KEY ("PID");


--
-- TOC entry 5164 (class 2606 OID 82129)
-- Name: QuestionGroups PK_QuestionGroups; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "PK_QuestionGroups" PRIMARY KEY ("QuestionGroupId");


--
-- TOC entry 5171 (class 2606 OID 82131)
-- Name: QuestionOptions PK_QuestionOptions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "PK_QuestionOptions" PRIMARY KEY ("QOptionId");


--
-- TOC entry 5182 (class 2606 OID 82133)
-- Name: Questions PK_Questions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "PK_Questions" PRIMARY KEY ("QuestionId");


--
-- TOC entry 5186 (class 2606 OID 82135)
-- Name: TemplateItems PK_TemplateItems; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT "PK_TemplateItems" PRIMARY KEY ("TemplateItemId");


--
-- TOC entry 5192 (class 2606 OID 82137)
-- Name: TemplateVersions PK_TemplateVersions; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "PK_TemplateVersions" PRIMARY KEY ("TempVersionId");


--
-- TOC entry 5197 (class 2606 OID 82139)
-- Name: Templates PK_Templates; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "PK_Templates" PRIMARY KEY ("TemplateId");


--
-- TOC entry 5208 (class 2606 OID 82141)
-- Name: UserAnswers PK_UserAnswers; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "PK_UserAnswers" PRIMARY KEY ("UAnswerId");


--
-- TOC entry 5215 (class 2606 OID 82143)
-- Name: UserRecords PK_UserRecords; Type: CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "PK_UserRecords" PRIMARY KEY ("RecStatusId");


--
-- TOC entry 5061 (class 1259 OID 82144)
-- Name: IX_customers_BusinessId; Type: INDEX; Schema: customers; Owner: postgres
--

CREATE INDEX "IX_customers_BusinessId" ON customers.customers USING btree (business_id);


--
-- TOC entry 5064 (class 1259 OID 82145)
-- Name: IX_Statistics_BusinessId; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_BusinessId" ON general."Statistics" USING btree (business_id);


--
-- TOC entry 5065 (class 1259 OID 82146)
-- Name: IX_Statistics_CreatedById; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_CreatedById" ON general."Statistics" USING btree (created_by_id);


--
-- TOC entry 5066 (class 1259 OID 82147)
-- Name: IX_Statistics_ModifiedById; Type: INDEX; Schema: general; Owner: postgres
--

CREATE INDEX "IX_Statistics_ModifiedById" ON general."Statistics" USING btree (modified_by_id);


--
-- TOC entry 5075 (class 1259 OID 82148)
-- Name: IX_Components_BusinessId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_BusinessId" ON inventory."Components" USING btree (business_id);


--
-- TOC entry 5076 (class 1259 OID 82149)
-- Name: IX_Components_CreatedById; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_CreatedById" ON inventory."Components" USING btree ("CreatedById");


--
-- TOC entry 5077 (class 1259 OID 82150)
-- Name: IX_Components_ModifiedById; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Components_ModifiedById" ON inventory."Components" USING btree ("ModifiedById");


--
-- TOC entry 5082 (class 1259 OID 82151)
-- Name: IX_MaterialComponents_ComponentId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_MaterialComponents_ComponentId" ON inventory."MaterialComponents" USING btree ("ComponentId");


--
-- TOC entry 5083 (class 1259 OID 82152)
-- Name: IX_MaterialComponents_MaterialId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_MaterialComponents_MaterialId" ON inventory."MaterialComponents" USING btree ("MaterialId");


--
-- TOC entry 5086 (class 1259 OID 82153)
-- Name: IX_Materials_BusinessId; Type: INDEX; Schema: inventory; Owner: postgres
--

CREATE INDEX "IX_Materials_BusinessId" ON inventory."Materials" USING btree (business_id);


--
-- TOC entry 5101 (class 1259 OID 82154)
-- Name: IX_UserRecords_BusinessId; Type: INDEX; Schema: quotes; Owner: postgres
--

CREATE INDEX "IX_UserRecords_BusinessId" ON quotes."UserRecords" USING btree (business_id);


--
-- TOC entry 5102 (class 1259 OID 82155)
-- Name: IX_UserRecords_StatusId; Type: INDEX; Schema: quotes; Owner: postgres
--

CREATE INDEX "IX_UserRecords_StatusId" ON quotes."UserRecords" USING btree ("StatusId");


--
-- TOC entry 5136 (class 1259 OID 82156)
-- Name: EmailIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "EmailIndex" ON security.users USING btree ("NormalizedEmail");


--
-- TOC entry 5118 (class 1259 OID 82157)
-- Name: IX_roles_claims_RoleId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_roles_claims_RoleId" ON security.roles_claims USING btree ("RoleId");


--
-- TOC entry 5105 (class 1259 OID 82158)
-- Name: IX_security_RefreshTokens_ExpiryDate; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_ExpiryDate" ON security."RefreshTokens" USING btree ("ExpiryDate");


--
-- TOC entry 5106 (class 1259 OID 82159)
-- Name: IX_security_RefreshTokens_Token; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "IX_security_RefreshTokens_Token" ON security."RefreshTokens" USING btree ("Token");


--
-- TOC entry 5107 (class 1259 OID 82160)
-- Name: IX_security_RefreshTokens_Token_IsRevoked; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_Token_IsRevoked" ON security."RefreshTokens" USING btree ("Token", "IsRevoked");


--
-- TOC entry 5108 (class 1259 OID 82161)
-- Name: IX_security_RefreshTokens_UserId_IsRevoked; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_security_RefreshTokens_UserId_IsRevoked" ON security."RefreshTokens" USING btree ("UserId", "IsRevoked");


--
-- TOC entry 5125 (class 1259 OID 82162)
-- Name: IX_user_claims_UserId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_claims_UserId" ON security.user_claims USING btree ("UserId");


--
-- TOC entry 5128 (class 1259 OID 82163)
-- Name: IX_user_logins_UserId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_logins_UserId" ON security.user_logins USING btree ("UserId");


--
-- TOC entry 5131 (class 1259 OID 82164)
-- Name: IX_user_roles_RoleId; Type: INDEX; Schema: security; Owner: postgres
--

CREATE INDEX "IX_user_roles_RoleId" ON security.user_roles USING btree ("RoleId");


--
-- TOC entry 5117 (class 1259 OID 82165)
-- Name: RoleNameIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "RoleNameIndex" ON security.roles USING btree ("NormalizedName");


--
-- TOC entry 5139 (class 1259 OID 82166)
-- Name: UserNameIndex; Type: INDEX; Schema: security; Owner: postgres
--

CREATE UNIQUE INDEX "UserNameIndex" ON security.users USING btree ("NormalizedUserName");


--
-- TOC entry 5140 (class 1259 OID 82167)
-- Name: IX_DependentQuestions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_CreatedById" ON templates."DependentQuestions" USING btree ("CreatedById");


--
-- TOC entry 5141 (class 1259 OID 82168)
-- Name: IX_DependentQuestions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_ModifiedById" ON templates."DependentQuestions" USING btree ("ModifiedById");


--
-- TOC entry 5142 (class 1259 OID 82169)
-- Name: IX_DependentQuestions_NextQuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_DependentQuestions_NextQuestionId" ON templates."DependentQuestions" USING btree ("NextQuestionId");


--
-- TOC entry 5143 (class 1259 OID 82170)
-- Name: IX_DependentQuestions_QOptionId_NextQuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE UNIQUE INDEX "IX_DependentQuestions_QOptionId_NextQuestionId" ON templates."DependentQuestions" USING btree ("QOptionId", "NextQuestionId");


--
-- TOC entry 5146 (class 1259 OID 82171)
-- Name: IX_FieldTypes_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_FieldTypes_CreatedById" ON templates."FieldTypes" USING btree ("CreatedById");


--
-- TOC entry 5147 (class 1259 OID 82172)
-- Name: IX_FieldTypes_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_FieldTypes_ModifiedById" ON templates."FieldTypes" USING btree ("ModifiedById");


--
-- TOC entry 5154 (class 1259 OID 82173)
-- Name: IX_Metafields_Guid_VersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Metafields_Guid_VersionId" ON templates."Metafields" USING btree ("MetafieldGuid", "TempVersionId");


--
-- TOC entry 5155 (class 1259 OID 82174)
-- Name: IX_Metafields_MetafieldGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Metafields_MetafieldGuid" ON templates."Metafields" USING btree ("MetafieldGuid");


--
-- TOC entry 5158 (class 1259 OID 82175)
-- Name: IX_QuestionGroups_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_BusinessId" ON templates."QuestionGroups" USING btree (business_id);


--
-- TOC entry 5159 (class 1259 OID 82176)
-- Name: IX_QuestionGroups_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_CreatedById" ON templates."QuestionGroups" USING btree ("CreatedById");


--
-- TOC entry 5160 (class 1259 OID 82177)
-- Name: IX_QuestionGroups_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_ModifiedById" ON templates."QuestionGroups" USING btree ("ModifiedById");


--
-- TOC entry 5161 (class 1259 OID 82178)
-- Name: IX_QuestionGroups_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_TemplateId" ON templates."QuestionGroups" USING btree ("TemplateId");


--
-- TOC entry 5162 (class 1259 OID 82179)
-- Name: IX_QuestionGroups_TemplateVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionGroups_TemplateVersionId" ON templates."QuestionGroups" USING btree ("TemplateVersionId");


--
-- TOC entry 5165 (class 1259 OID 82180)
-- Name: IX_QuestionOptions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_CreatedById" ON templates."QuestionOptions" USING btree ("CreatedById");


--
-- TOC entry 5166 (class 1259 OID 82181)
-- Name: IX_QuestionOptions_FieldTypeId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_FieldTypeId" ON templates."QuestionOptions" USING btree ("FieldTypeId");


--
-- TOC entry 5167 (class 1259 OID 82182)
-- Name: IX_QuestionOptions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_ModifiedById" ON templates."QuestionOptions" USING btree ("ModifiedById");


--
-- TOC entry 5168 (class 1259 OID 82183)
-- Name: IX_QuestionOptions_OptionGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_OptionGuid" ON templates."QuestionOptions" USING btree ("OptionGuid");


--
-- TOC entry 5169 (class 1259 OID 82184)
-- Name: IX_QuestionOptions_QuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_QuestionOptions_QuestionId" ON templates."QuestionOptions" USING btree ("QuestionId");


--
-- TOC entry 5172 (class 1259 OID 82185)
-- Name: IX_Questions_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_BusinessId" ON templates."Questions" USING btree (business_id);


--
-- TOC entry 5173 (class 1259 OID 82186)
-- Name: IX_Questions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_CreatedById" ON templates."Questions" USING btree ("CreatedById");


--
-- TOC entry 5174 (class 1259 OID 82187)
-- Name: IX_Questions_FieldTypeId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_FieldTypeId" ON templates."Questions" USING btree ("FieldTypeId");


--
-- TOC entry 5175 (class 1259 OID 82188)
-- Name: IX_Questions_Guid_VersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_Guid_VersionId" ON templates."Questions" USING btree ("QuestionGuid", "TemplateVersionId");


--
-- TOC entry 5176 (class 1259 OID 82189)
-- Name: IX_Questions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_ModifiedById" ON templates."Questions" USING btree ("ModifiedById");


--
-- TOC entry 5177 (class 1259 OID 82190)
-- Name: IX_Questions_QuestionGroupId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_QuestionGroupId" ON templates."Questions" USING btree ("QuestionGroupId");


--
-- TOC entry 5178 (class 1259 OID 82191)
-- Name: IX_Questions_QuestionGuid; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_QuestionGuid" ON templates."Questions" USING btree ("QuestionGuid");


--
-- TOC entry 5179 (class 1259 OID 82192)
-- Name: IX_Questions_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_TemplateId" ON templates."Questions" USING btree ("TemplateId");


--
-- TOC entry 5180 (class 1259 OID 82193)
-- Name: IX_Questions_TemplateVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Questions_TemplateVersionId" ON templates."Questions" USING btree ("TemplateVersionId");


--
-- TOC entry 5183 (class 1259 OID 82194)
-- Name: IX_TemplateItems_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateItems_BusinessId" ON templates."TemplateItems" USING btree (business_id);


--
-- TOC entry 5184 (class 1259 OID 82195)
-- Name: IX_TemplateItems_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateItems_TemplateId" ON templates."TemplateItems" USING btree ("TemplateId");


--
-- TOC entry 5187 (class 1259 OID 82196)
-- Name: IX_TemplateVersions_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_BusinessId" ON templates."TemplateVersions" USING btree (business_id);


--
-- TOC entry 5188 (class 1259 OID 82197)
-- Name: IX_TemplateVersions_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_CreatedById" ON templates."TemplateVersions" USING btree ("CreatedById");


--
-- TOC entry 5189 (class 1259 OID 82198)
-- Name: IX_TemplateVersions_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_ModifiedById" ON templates."TemplateVersions" USING btree ("ModifiedById");


--
-- TOC entry 5190 (class 1259 OID 82199)
-- Name: IX_TemplateVersions_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_TemplateVersions_TemplateId" ON templates."TemplateVersions" USING btree ("TemplateId");


--
-- TOC entry 5193 (class 1259 OID 82200)
-- Name: IX_Templates_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_BusinessId" ON templates."Templates" USING btree (business_id);


--
-- TOC entry 5194 (class 1259 OID 82201)
-- Name: IX_Templates_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_CreatedById" ON templates."Templates" USING btree ("CreatedById");


--
-- TOC entry 5195 (class 1259 OID 82202)
-- Name: IX_Templates_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_Templates_ModifiedById" ON templates."Templates" USING btree ("ModifiedById");


--
-- TOC entry 5198 (class 1259 OID 82203)
-- Name: IX_UserAnswers_BusinessId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_BusinessId" ON templates."UserAnswers" USING btree (business_id);


--
-- TOC entry 5199 (class 1259 OID 82204)
-- Name: IX_UserAnswers_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_CreatedById" ON templates."UserAnswers" USING btree ("CreatedById");


--
-- TOC entry 5200 (class 1259 OID 82205)
-- Name: IX_UserAnswers_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_ModifiedById" ON templates."UserAnswers" USING btree ("ModifiedById");


--
-- TOC entry 5201 (class 1259 OID 82206)
-- Name: IX_UserAnswers_ParentOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_ParentOptionId" ON templates."UserAnswers" USING btree ("ParentOptionId");


--
-- TOC entry 5202 (class 1259 OID 82207)
-- Name: IX_UserAnswers_QOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QOptionId" ON templates."UserAnswers" USING btree ("QOptionId");


--
-- TOC entry 5203 (class 1259 OID 82208)
-- Name: IX_UserAnswers_QuestionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuestionId" ON templates."UserAnswers" USING btree ("QuestionId");


--
-- TOC entry 5204 (class 1259 OID 82209)
-- Name: IX_UserAnswers_QuestionId_ParentOptionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuestionId_ParentOptionId" ON templates."UserAnswers" USING btree ("QuestionId", "ParentOptionId");


--
-- TOC entry 5205 (class 1259 OID 82210)
-- Name: IX_UserAnswers_QuoteVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_QuoteVersionId" ON templates."UserAnswers" USING btree ("QuoteVersionId");


--
-- TOC entry 5206 (class 1259 OID 82211)
-- Name: IX_UserAnswers_RecordId_QuoteVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserAnswers_RecordId_QuoteVersionId" ON templates."UserAnswers" USING btree ("RecordId", "QuoteVersionId");


--
-- TOC entry 5209 (class 1259 OID 82212)
-- Name: IX_UserRecords_CreatedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_CreatedById" ON templates."UserRecords" USING btree ("CreatedById");


--
-- TOC entry 5210 (class 1259 OID 82213)
-- Name: IX_UserRecords_MiscLookupCodeEnum; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_MiscLookupCodeEnum" ON templates."UserRecords" USING btree ("MiscLookupCodeEnum");


--
-- TOC entry 5211 (class 1259 OID 82214)
-- Name: IX_UserRecords_ModifiedById; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_ModifiedById" ON templates."UserRecords" USING btree ("ModifiedById");


--
-- TOC entry 5212 (class 1259 OID 82215)
-- Name: IX_UserRecords_TempVersionId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_TempVersionId" ON templates."UserRecords" USING btree ("TempVersionId");


--
-- TOC entry 5213 (class 1259 OID 82216)
-- Name: IX_UserRecords_TemplateId; Type: INDEX; Schema: templates; Owner: postgres
--

CREATE INDEX "IX_UserRecords_TemplateId" ON templates."UserRecords" USING btree ("TemplateId");


--
-- TOC entry 5216 (class 2606 OID 82217)
-- Name: Statistics FK_Statistics_Business; Type: FK CONSTRAINT; Schema: general; Owner: postgres
--

ALTER TABLE ONLY general."Statistics"
    ADD CONSTRAINT "FK_Statistics_Business" FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5219 (class 2606 OID 82222)
-- Name: MaterialComponents FK_MaterialComponents_Components_ComponentId; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "FK_MaterialComponents_Components_ComponentId" FOREIGN KEY ("ComponentId") REFERENCES inventory."Components"("ComponentId") ON DELETE CASCADE;


--
-- TOC entry 5220 (class 2606 OID 82227)
-- Name: MaterialComponents FK_MaterialComponents_Materials_MaterialId; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponents"
    ADD CONSTRAINT "FK_MaterialComponents_Materials_MaterialId" FOREIGN KEY ("MaterialId") REFERENCES inventory."Materials"("MaterialId") ON DELETE CASCADE;


--
-- TOC entry 5217 (class 2606 OID 82232)
-- Name: Components fk_components_business; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Components"
    ADD CONSTRAINT fk_components_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5218 (class 2606 OID 82237)
-- Name: MaterialComponentHistory fk_history_business; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."MaterialComponentHistory"
    ADD CONSTRAINT fk_history_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5221 (class 2606 OID 82242)
-- Name: Materials fk_materials_business; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory."Materials"
    ADD CONSTRAINT fk_materials_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5222 (class 2606 OID 82247)
-- Name: MiscLookups FK_MiscLookups_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "FK_MiscLookups_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5223 (class 2606 OID 82252)
-- Name: MiscLookups FK_MiscLookups_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: misc; Owner: postgres
--

ALTER TABLE ONLY misc."MiscLookups"
    ADD CONSTRAINT "FK_MiscLookups_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5224 (class 2606 OID 82257)
-- Name: QuoteRevisions FK_QuoteRevisions_UserRecords; Type: FK CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."QuoteRevisions"
    ADD CONSTRAINT "FK_QuoteRevisions_UserRecords" FOREIGN KEY ("QuoteId") REFERENCES quotes."UserRecords"("RecStatusId") ON DELETE CASCADE;


--
-- TOC entry 5225 (class 2606 OID 82262)
-- Name: UserRecords fk_userrecords_business; Type: FK CONSTRAINT; Schema: quotes; Owner: postgres
--

ALTER TABLE ONLY quotes."UserRecords"
    ADD CONSTRAINT fk_userrecords_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5226 (class 2606 OID 82267)
-- Name: roles_claims FK_roles_claims_roles_RoleId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.roles_claims
    ADD CONSTRAINT "FK_roles_claims_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES security.roles("Id") ON DELETE CASCADE;


--
-- TOC entry 5228 (class 2606 OID 82272)
-- Name: user_claims FK_user_claims_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_claims
    ADD CONSTRAINT "FK_user_claims_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5229 (class 2606 OID 82277)
-- Name: user_logins FK_user_logins_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_logins
    ADD CONSTRAINT "FK_user_logins_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5230 (class 2606 OID 82282)
-- Name: user_roles FK_user_roles_roles_RoleId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "FK_user_roles_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES security.roles("Id") ON DELETE CASCADE;


--
-- TOC entry 5231 (class 2606 OID 82287)
-- Name: user_roles FK_user_roles_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_roles
    ADD CONSTRAINT "FK_user_roles_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5232 (class 2606 OID 82292)
-- Name: user_tokens FK_user_tokens_users_UserId; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.user_tokens
    ADD CONSTRAINT "FK_user_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES security.users("Id") ON DELETE CASCADE;


--
-- TOC entry 5227 (class 2606 OID 82297)
-- Name: security_group fk_security_group_business; Type: FK CONSTRAINT; Schema: security; Owner: postgres
--

ALTER TABLE ONLY security.security_group
    ADD CONSTRAINT fk_security_group_business FOREIGN KEY (business_id) REFERENCES general.business(business_id);


--
-- TOC entry 5233 (class 2606 OID 82302)
-- Name: DependentQuestions FK_DependentQuestions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5234 (class 2606 OID 82307)
-- Name: DependentQuestions FK_DependentQuestions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5235 (class 2606 OID 82312)
-- Name: DependentQuestions FK_DependentQuestions_QuestionOptions_QOptionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_QuestionOptions_QOptionId" FOREIGN KEY ("QOptionId") REFERENCES templates."QuestionOptions"("QOptionId");


--
-- TOC entry 5236 (class 2606 OID 82317)
-- Name: DependentQuestions FK_DependentQuestions_Questions_NextQuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."DependentQuestions"
    ADD CONSTRAINT "FK_DependentQuestions_Questions_NextQuestionId" FOREIGN KEY ("NextQuestionId") REFERENCES templates."Questions"("QuestionId");


--
-- TOC entry 5237 (class 2606 OID 82322)
-- Name: FieldTypes FK_FieldTypes_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "FK_FieldTypes_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5238 (class 2606 OID 82327)
-- Name: FieldTypes FK_FieldTypes_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."FieldTypes"
    ADD CONSTRAINT "FK_FieldTypes_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5239 (class 2606 OID 82332)
-- Name: Iframes FK_Iframes_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Iframes"
    ADD CONSTRAINT "FK_Iframes_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5240 (class 2606 OID 82337)
-- Name: MetafieldAnswers FK_MetafieldAnswers_QuoteRevisions; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT "FK_MetafieldAnswers_QuoteRevisions" FOREIGN KEY ("QuoteRevisionId") REFERENCES quotes."QuoteRevisions"("QuoteRevisionId") ON DELETE RESTRICT;


--
-- TOC entry 5244 (class 2606 OID 82342)
-- Name: Metafields FK_Metafields_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Metafields"
    ADD CONSTRAINT "FK_Metafields_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5245 (class 2606 OID 82347)
-- Name: QuestionGroups FK_QuestionGroups_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5246 (class 2606 OID 82352)
-- Name: QuestionGroups FK_QuestionGroups_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5247 (class 2606 OID 82357)
-- Name: QuestionGroups FK_QuestionGroups_TemplateVersions_TemplateVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_TemplateVersions_TemplateVersionId" FOREIGN KEY ("TemplateVersionId") REFERENCES templates."TemplateVersions"("TempVersionId");


--
-- TOC entry 5248 (class 2606 OID 82362)
-- Name: QuestionGroups FK_QuestionGroups_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT "FK_QuestionGroups_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5250 (class 2606 OID 82367)
-- Name: QuestionOptions FK_QuestionOptions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5251 (class 2606 OID 82372)
-- Name: QuestionOptions FK_QuestionOptions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5252 (class 2606 OID 82377)
-- Name: QuestionOptions FK_QuestionOptions_FieldTypes_FieldTypeId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_FieldTypes_FieldTypeId" FOREIGN KEY ("FieldTypeId") REFERENCES templates."FieldTypes"("FieldTypeId");


--
-- TOC entry 5253 (class 2606 OID 82382)
-- Name: QuestionOptions FK_QuestionOptions_Questions_QuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionOptions"
    ADD CONSTRAINT "FK_QuestionOptions_Questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES templates."Questions"("QuestionId") ON DELETE CASCADE;


--
-- TOC entry 5254 (class 2606 OID 82387)
-- Name: Questions FK_Questions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5255 (class 2606 OID 82392)
-- Name: Questions FK_Questions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5256 (class 2606 OID 82397)
-- Name: Questions FK_Questions_FieldTypes_FieldTypeId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_FieldTypes_FieldTypeId" FOREIGN KEY ("FieldTypeId") REFERENCES templates."FieldTypes"("FieldTypeId");


--
-- TOC entry 5257 (class 2606 OID 82402)
-- Name: Questions FK_Questions_QuestionGroups_QuestionGroupId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_QuestionGroups_QuestionGroupId" FOREIGN KEY ("QuestionGroupId") REFERENCES templates."QuestionGroups"("QuestionGroupId") ON DELETE CASCADE;


--
-- TOC entry 5258 (class 2606 OID 82407)
-- Name: Questions FK_Questions_TemplateVersions_TemplateVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_TemplateVersions_TemplateVersionId" FOREIGN KEY ("TemplateVersionId") REFERENCES templates."TemplateVersions"("TempVersionId");


--
-- TOC entry 5259 (class 2606 OID 82412)
-- Name: Questions FK_Questions_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT "FK_Questions_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5261 (class 2606 OID 82417)
-- Name: TemplateItems FK_TemplateItems_QuoteRevisions; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT "FK_TemplateItems_QuoteRevisions" FOREIGN KEY ("QuoteRevisionId") REFERENCES quotes."QuoteRevisions"("QuoteRevisionId") ON DELETE RESTRICT;


--
-- TOC entry 5262 (class 2606 OID 82422)
-- Name: TemplateItems FK_TemplateItems_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT "FK_TemplateItems_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5264 (class 2606 OID 82427)
-- Name: TemplateVersions FK_TemplateVersions_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5265 (class 2606 OID 82432)
-- Name: TemplateVersions FK_TemplateVersions_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5266 (class 2606 OID 82437)
-- Name: TemplateVersions FK_TemplateVersions_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT "FK_TemplateVersions_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5268 (class 2606 OID 82442)
-- Name: Templates FK_Templates_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "FK_Templates_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5269 (class 2606 OID 82447)
-- Name: Templates FK_Templates_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT "FK_Templates_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5271 (class 2606 OID 82452)
-- Name: UserAnswers FK_UserAnswers_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5272 (class 2606 OID 82457)
-- Name: UserAnswers FK_UserAnswers_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5273 (class 2606 OID 82462)
-- Name: UserAnswers FK_UserAnswers_QuestionOptions_QOptionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_QuestionOptions_QOptionId" FOREIGN KEY ("QOptionId") REFERENCES templates."QuestionOptions"("QOptionId");


--
-- TOC entry 5274 (class 2606 OID 82467)
-- Name: UserAnswers FK_UserAnswers_Questions_QuestionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_Questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES templates."Questions"("QuestionId") ON DELETE CASCADE;


--
-- TOC entry 5275 (class 2606 OID 82472)
-- Name: UserAnswers FK_UserAnswers_QuoteRevisions; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT "FK_UserAnswers_QuoteRevisions" FOREIGN KEY ("QuoteRevisionId") REFERENCES quotes."QuoteRevisions"("QuoteRevisionId") ON DELETE RESTRICT;


--
-- TOC entry 5277 (class 2606 OID 82477)
-- Name: UserRecords FK_UserRecords_AspNetUsers_CreatedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_AspNetUsers_CreatedById" FOREIGN KEY ("CreatedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5278 (class 2606 OID 82482)
-- Name: UserRecords FK_UserRecords_AspNetUsers_ModifiedById; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_AspNetUsers_ModifiedById" FOREIGN KEY ("ModifiedById") REFERENCES security.users("Id") ON DELETE RESTRICT;


--
-- TOC entry 5279 (class 2606 OID 82487)
-- Name: UserRecords FK_UserRecords_MiscLookups_MiscLookupCodeEnum; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_MiscLookups_MiscLookupCodeEnum" FOREIGN KEY ("MiscLookupCodeEnum") REFERENCES misc."MiscLookups"("CodeEnum");


--
-- TOC entry 5280 (class 2606 OID 82492)
-- Name: UserRecords FK_UserRecords_TemplateVersions_TempVersionId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_TemplateVersions_TempVersionId" FOREIGN KEY ("TempVersionId") REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE CASCADE;


--
-- TOC entry 5281 (class 2606 OID 82497)
-- Name: UserRecords FK_UserRecords_Templates_TemplateId; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserRecords"
    ADD CONSTRAINT "FK_UserRecords_Templates_TemplateId" FOREIGN KEY ("TemplateId") REFERENCES templates."Templates"("TemplateId") ON DELETE CASCADE;


--
-- TOC entry 5241 (class 2606 OID 82502)
-- Name: MetafieldAnswers fk_metafield; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_metafield FOREIGN KEY (metafield_id) REFERENCES templates."Metafields"("PID") ON DELETE RESTRICT;


--
-- TOC entry 5249 (class 2606 OID 82507)
-- Name: QuestionGroups fk_questiongroups_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."QuestionGroups"
    ADD CONSTRAINT fk_questiongroups_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5260 (class 2606 OID 82512)
-- Name: Questions fk_questions_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Questions"
    ADD CONSTRAINT fk_questions_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5242 (class 2606 OID 82517)
-- Name: MetafieldAnswers fk_quote; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_quote FOREIGN KEY (quote_id) REFERENCES quotes."UserRecords"("RecStatusId") ON DELETE RESTRICT;


--
-- TOC entry 5243 (class 2606 OID 82522)
-- Name: MetafieldAnswers fk_template_version; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."MetafieldAnswers"
    ADD CONSTRAINT fk_template_version FOREIGN KEY (template_version_id) REFERENCES templates."TemplateVersions"("TempVersionId") ON DELETE RESTRICT;


--
-- TOC entry 5263 (class 2606 OID 82527)
-- Name: TemplateItems fk_templateitems_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateItems"
    ADD CONSTRAINT fk_templateitems_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5270 (class 2606 OID 82532)
-- Name: Templates fk_templates_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."Templates"
    ADD CONSTRAINT fk_templates_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5267 (class 2606 OID 82537)
-- Name: TemplateVersions fk_templateversions_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."TemplateVersions"
    ADD CONSTRAINT fk_templateversions_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


--
-- TOC entry 5276 (class 2606 OID 82542)
-- Name: UserAnswers fk_useranswers_business; Type: FK CONSTRAINT; Schema: templates; Owner: postgres
--

ALTER TABLE ONLY templates."UserAnswers"
    ADD CONSTRAINT fk_useranswers_business FOREIGN KEY (business_id) REFERENCES general.business(business_id) ON DELETE RESTRICT;


-- Completed on 2026-03-30 23:06:13

--
-- PostgreSQL database dump complete
--

\unrestrict nim5Vj8llDzwW3YcrEEYEnWCt5wJeYSNKp6IfGWjCXIhJGx8XeZbgCuEddKgoA9

