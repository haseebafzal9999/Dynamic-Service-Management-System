--
-- PostgreSQL database dump
--

\restrict RXcC1iZ24SR0oZYFNCJfg1ggqlfVOVMNbyPJK8BDz0nAQeQbnJnBCFFDJ4EZS8g

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.0

-- Started on 2026-03-25 23:50:34

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
\.


--
-- TOC entry 5431 (class 0 OID 81600)
-- Dependencies: 229
-- Data for Name: Statistics; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general."Statistics" (statistic_id, total_quotes, total_quotes_value, total_template, total_customer, business_id, created_at, created_by_id, modified_at, modified_by_id) FROM stdin;
\.


--
-- TOC entry 5433 (class 0 OID 81614)
-- Dependencies: 231
-- Data for Name: business; Type: TABLE DATA; Schema: general; Owner: postgres
--

COPY general.business (business_id, name, phone_number, email, address_first_line, city_town, postcode, country, currency, currency_identity, timezoneid, website, address_line_2) FROM stdin;
1	Business 1	+12345678	business1@gmail.com		NY	12000	Albania	USD	en-US	Pakistan Standard Time	/business1/website	
2	Business 2	+12345678	business2@gmail.com		NY	12000	Albania	USD	en-US	Pakistan Standard Time	/business2/website	
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
\.


--
-- TOC entry 5442 (class 0 OID 81678)
-- Dependencies: 240
-- Data for Name: MaterialComponentHistory; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."MaterialComponentHistory" ("HistoryId", "MaterialComponentId", "MaterialComponentType", "MaterialId", "ComponentId", "Name", "Description", "CostPrice", "SellPrice", "IsActive", "PartNo", "Supplier", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
\.


--
-- TOC entry 5444 (class 0 OID 81687)
-- Dependencies: 242
-- Data for Name: MaterialComponents; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."MaterialComponents" ("MatCompId", "MaterialId", "ComponentId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
\.


--
-- TOC entry 5446 (class 0 OID 81698)
-- Dependencies: 244
-- Data for Name: Materials; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory."Materials" ("MaterialId", "Name", "Description", "SellPrice", "IsActive", "CreatedAt", "CostPrice", "PartNo", "Supplier", "ModifiedAt", "CreatedById", "ModifiedById", business_id) FROM stdin;
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
\.


--
-- TOC entry 5456 (class 0 OID 81744)
-- Dependencies: 254
-- Data for Name: UserRecords; Type: TABLE DATA; Schema: quotes; Owner: postgres
--

COPY quotes."UserRecords" ("RecStatusId", "QuoteReference", "TempVersionId", "TemplateId", "MiscCodeEnum", "MiscCodeName", "TotalCost", "IsActive", "CreatedAt", "MiscLookupCodeEnum", "ModifiedAt", "CreatedById", "ModifiedById", "PDFLINK", "Status", "TotalCostPrice", "TotalSellPrice", "CustomerId", business_id, "StatusId") FROM stdin;
\.


--
-- TOC entry 5458 (class 0 OID 81765)
-- Dependencies: 256
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: security; Owner: postgres
--

COPY security."RefreshTokens" ("Id", "UserId", "Token", "ExpiryDate", "IsRevoked", "CreatedDate") FROM stdin;
2	ce8bb747-624d-46c2-9d76-da557a53dd90	uBvskNi0G2lODUukR7CKpoBg/pZtQLEhvjFeb7awczSpaPVNXGGZgfr+FrQH4DdOxCnTG+4ZWMfPr8h8kOV4YQ==	2026-04-01 23:26:19.830432+05	f	2026-03-25 23:26:19.830434+05
1	a1b2c3d4-e5f6-7890-abcd-ef1234567890	z0qwTIpJfqqhVZr380QI5twJ8eoLZsK5Y/E6VLe8ybBamLrIFv++ZW/l8Ku7q2ypZlWjrJ30RiL9V2HjsqoHag==	2026-04-01 23:24:46.056219+05	t	2026-03-25 23:24:46.056222+05
3	a1b2c3d4-e5f6-7890-abcd-ef1234567890	k09c1YwZTh35X+22KQ3kNQVDLz2ZuAeK+ZrNnxTOE+kuJbdpTZD7whSkIBf3NmBpfJMEkB5NL63yY/w5EXtSmQ==	2026-04-01 23:36:39.163542+05	f	2026-03-25 23:36:39.163545+05
4	ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	6RszquQGgxFvg2Xz1jVo23mvIHrpcw8u82CxxDr9VFQN1/YYt+x4PJ6ICB/kNo/4Ng47zV+xJCrIqlPRmvaSFA==	2026-04-01 23:37:52.769771+05	f	2026-03-25 23:37:52.769773+05
5	89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	CwtWxN1PI4HojsHlO4PlbEdS4HNoithueNVXVQxHAtHhwDwX+ZuK/I0LS+u+Pe02WqUOFJbZaVefhM+8Q888jA==	2026-04-01 23:39:46.308855+05	f	2026-03-25 23:39:46.308857+05
6	c0cc5298-18c0-49f5-907d-2487d8ca004f	c7MJ2JcKupQg8VUNdrJ5tvEBVswRIihoQSaO8Yvwq5yOoXK99lSvuZh3R84rNeWvx5H3opGhRlvZsA0MIJfG/A==	2026-04-01 23:46:46.136615+05	f	2026-03-25 23:46:46.136617+05
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
8	0	Viewer Group		2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305	2	\N
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
5	7	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
6	7	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
7	7	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
8	7	2026-03-25 18:36:55.72305	2026-03-25 18:36:55.72305
5	8	2026-03-25 18:42:33.988779	2026-03-25 18:42:33.988779
6	9	2026-03-25 18:43:02.472888	2026-03-25 18:43:02.472888
7	11	2026-03-25 18:44:15.882159	2026-03-25 18:44:15.882159
8	10	2026-03-25 18:45:52.284973	2026-03-25 18:45:52.284973
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
89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	ae342069-ca62-4114-8ce6-587ecf1e5caf
4205be3f-3f45-4edc-a39b-38def5cd18f1	967df2ef-4ec0-4f76-baab-8fa76b28cd08
6a6fb513-3965-473c-a638-c8e1f3187582	967df2ef-4ec0-4f76-baab-8fa76b28cd08
7a81cd3b-6856-4317-8216-f7e5e3744310	77ed1763-8dd0-4da4-93fd-8335ed540c7b
c0cc5298-18c0-49f5-907d-2487d8ca004f	77ed1763-8dd0-4da4-93fd-8335ed540c7b
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
74ca72ad-4e91-4384-89eb-925be075e300	1	3	Test1	User	user_7f5a1fdb	USER_7F5A1FDB	Test1@Admin1.com	TEST1@ADMIN1.COM	f	AQAAAAIAAYagAAAAECGFebzZulpFe22KoDYBYU6r/yz3LB18AB2tzznd/MeoBRGJON+RBqh+KKAEfezfkQ==	HRP6UKXQVQCLR4TKMPXGFYFRKIBXG2LE	eb2624ea-ba11-4ebc-b58b-48c623f816af	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
31cbf32e-5d54-4e86-8b1f-13e4765be45e	1	4	Test2	User	user_796f3660	USER_796F3660	Test2@Admin2.com	TEST2@ADMIN2.COM	f	AQAAAAIAAYagAAAAECHrxG/yt4GSLL24oxpkxmNRVFgsTQAsZXBv7BDI29LtD9tW4HlHle84gv+6rJ7YUA==	HFXMRJXQ6HVZLEF3LZ3ETW2BON4VBIC3	fb7210c2-5947-4e43-81f2-1c0c90f2818e	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
ca27e3d2-59c2-4972-a8e2-1983d3e5de9b	1	5	Test3	User	user_bc7efbde	USER_BC7EFBDE	Test3@User3.com	TEST3@USER3.COM	f	AQAAAAIAAYagAAAAEN3LBLUgeoKFUcoycgFhtF/SqZTDytB+H9TW5FLOZnf7E1X2g4UJ2R9HlyhzWORxuw==	PPEHPWDZDXKANATJOFOC6473VJRQ5M54	95c481ec-02ef-4212-b391-e7ba9eb78471	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
c80ec3ca-080d-4d9c-8c8a-fc858b56c578	1	6	Test4	User	user_9767a11c	USER_9767A11C	Test4@User4.com	TEST4@USER4.COM	f	AQAAAAIAAYagAAAAEBBkG2ifZEzfxxrPQQGiFEUuotElD7QBYOPww6JFlb6JiuU3jsABZJsNS6l4qCxzrw==	O3CL6KIGD5FUPXMGMZNUVDM56K27ACMF	715824d3-f363-437c-9ee6-e7763dd68fe6	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
89f19ff7-78f1-4a8a-97d1-f2dfbc4faada	2	7	User	Three	UserThree	USERTHREE	Test5@User5.com	TEST5@USER5.COM	f	AQAAAAIAAYagAAAAED4dyxuR6zHnRQAmz3NVR3Yixb6TMQvvpUhTXBMLgNdlK0L2hUiFpS+/ACkgpvkaTQ==	REJMNDNVQV44A6JK6IKFCHRK63OVDS64	c24e6ac0-afc2-4e60-80d6-9b2687c731c6	+98765432	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
4205be3f-3f45-4edc-a39b-38def5cd18f1	2	8	Test3	User	user_97c18a09	USER_97C18A09	Test3@Admin3.com	TEST3@ADMIN3.COM	f	AQAAAAIAAYagAAAAEK5OhdykDZUhvpxfF+4zs+yrkGBFf3NAblb7IL0a38YIwlKey/LWU35Kpk4SfYyQYg==	YFQMDRI7VUYKRQBDUKKGP5GG36UXUSOT	2333eab9-02f4-41af-8189-c1d292aa17f3	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
6a6fb513-3965-473c-a638-c8e1f3187582	2	9	Test4	User	user_a750693d	USER_A750693D	Test4@Admin4.com	TEST4@ADMIN4.COM	f	AQAAAAIAAYagAAAAEGNK9nuKi3qh2Z/5h8OCjWeCnHuLEoTkjFEVBNL+JqcqLyVWqhw4TwvX81iaLn0GhQ==	XLGJY6VKNQ7WM2K7OJDM6T6OJ7TKSXJD	8fd438b1-7414-4428-b966-6ca64b7a1527	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
c0cc5298-18c0-49f5-907d-2487d8ca004f	2	10	Test6	User	Test6@User6.com	TEST6@USER6.COM	Test6@User6.com	TEST6@USER6.COM	f	AQAAAAIAAYagAAAAEC5xHUPkwwNTLQHhM2D+eqyKFAGIci/pSYiP9xjguh4zzMhIsnfqpDK9J8xJ9qwqMg==	HWS6TP2MQWQ3WD22XP23XZZZ46IGB3PA	14150556-3078-4f1d-b3f2-22bad666e3bb	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
7a81cd3b-6856-4317-8216-f7e5e3744310	2	11	Test7	User	user_3e2085e8	USER_3E2085E8	Test7@User7.com	TEST7@USER7.COM	f	AQAAAAIAAYagAAAAEMoe3b712FTpc/QjaZMNlQvF+IlDRGUxu9skmQl1IGE2cG8Wr0sZCxwFkc0Zf6007w==	7HNPYVZ3ANWJJTYZZRH5Y3ZMSKKIGNCN	26380c0f-566c-40db-ba96-264615fa49e1	\N	f	f	\N	t	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5477 (class 0 OID 81890)
-- Dependencies: 275
-- Data for Name: DependentQuestions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."DependentQuestions" ("DependentQId", "QOptionId", "NextQuestionId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById") FROM stdin;
\.


--
-- TOC entry 5479 (class 0 OID 81899)
-- Dependencies: 277
-- Data for Name: FieldTypes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."FieldTypes" ("FieldTypeId", "FieldName", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "DisplayName") FROM stdin;
\.


--
-- TOC entry 5481 (class 0 OID 81909)
-- Dependencies: 279
-- Data for Name: Iframes; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Iframes" ("PID", "WebsiteName", "Link", "TempVersionId", "Status", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "Partial_key", "Full_key", "TemplateId", "BusinessId") FROM stdin;
\.


--
-- TOC entry 5483 (class 0 OID 81921)
-- Dependencies: 281
-- Data for Name: MetafieldAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."MetafieldAnswers" (metafield_answer_id, template_version_id, quote_id, metafield_id, metafield_input, "QuoteRevisionId") FROM stdin;
\.


--
-- TOC entry 5485 (class 0 OID 81931)
-- Dependencies: 283
-- Data for Name: Metafields; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Metafields" ("PID", "TempVersionId", "Name", "FieldType", "Tag", "Visibility", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "TableStyle", "MetafieldGuid", "DisplayOrder") FROM stdin;
\.


--
-- TOC entry 5487 (class 0 OID 81949)
-- Dependencies: 285
-- Data for Name: QuestionGroups; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionGroups" ("QuestionGroupId", "Name", "DisplayOrder", "TemplateId", "IsActive", "CreatedAt", "TemplateVersionId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "GroupGuid") FROM stdin;
\.


--
-- TOC entry 5489 (class 0 OID 81963)
-- Dependencies: 287
-- Data for Name: QuestionOptions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."QuestionOptions" ("QOptionId", "OptionText", "QuestionId", "DisplayOrder", "FieldTypeId", "MaterialCompId", "IsActive", "CreatedAt", "ModifiedAt", "MatCompName", "CreatedById", "ModifiedById", "OptionGuid", "MaterialComponentAssociationId") FROM stdin;
\.


--
-- TOC entry 5491 (class 0 OID 81977)
-- Dependencies: 289
-- Data for Name: Questions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Questions" ("QuestionId", "Text", "IsRequired", "DisplayOrder", "QuestionGroupId", "TemplateId", "ParentId", "ValidFrom", "ValidTo", "TagId", "IsActive", "CreatedAt", "TemplateVersionId", "FieldTypeId", "ModifiedAt", "CreatedById", "ModifiedById", business_id, "QuestionGuid") FROM stdin;
\.


--
-- TOC entry 5493 (class 0 OID 81993)
-- Dependencies: 291
-- Data for Name: TemplateItems; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateItems" ("TemplateItemId", "TemplateId", "ServiceName", "Description", "Quantity", "Unit", "ItemPrice", "Total", "TemplateVersion", "CreatedAt", "IsActive", "ModifiedAt", "CreatedById", "ModifiedById", "QuoteId", "CustomerId", business_id, "QuoteRevisionId", "CostPrice", "LevelNumber") FROM stdin;
\.


--
-- TOC entry 5495 (class 0 OID 82003)
-- Dependencies: 293
-- Data for Name: TemplateVersions; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."TemplateVersions" ("TempVersionId", "TemplateId", "TempValidFrom", "TempValidTo", "IsActive", "CreatedAt", "TempVersion", "ModifiedAt", "CreatedById", "ModifiedById", business_id, template_path) FROM stdin;
\.


--
-- TOC entry 5497 (class 0 OID 82013)
-- Dependencies: 295
-- Data for Name: Templates; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."Templates" ("TemplateId", "TemplateName", "IsActive", "CreatedAt", "Description", "ModifiedAt", "CreatedById", "ModifiedById", business_id, template_path) FROM stdin;
\.


--
-- TOC entry 5499 (class 0 OID 82023)
-- Dependencies: 297
-- Data for Name: UserAnswers; Type: TABLE DATA; Schema: templates; Owner: postgres
--

COPY templates."UserAnswers" ("UAnswerId", "QuestionId", "QOptionId", "AnswerText", "DisplayOrder", "DateTime", "RecordId", "IsActive", "CreatedAt", "ModifiedAt", "CreatedById", "ModifiedById", "CustomerId", "QuoteVersionId", business_id, "ParentOptionId", "QuoteRevisionId") FROM stdin;
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

SELECT pg_catalog.setval('customers.customers_customer_id_seq', 1, false);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 230
-- Name: Statistics_statistic_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general."Statistics_statistic_id_seq"', 1, false);


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 232
-- Name: business_business_id_seq; Type: SEQUENCE SET; Schema: general; Owner: postgres
--

SELECT pg_catalog.setval('general.business_business_id_seq', 2, true);


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

SELECT pg_catalog.setval('inventory."Components_ComponentId_seq"', 1, false);


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 241
-- Name: MaterialComponentHistory_HistoryId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."MaterialComponentHistory_HistoryId_seq"', 1, false);


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 243
-- Name: MaterialComponents_MatCompId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."MaterialComponents_MatCompId_seq"', 1, false);


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 245
-- Name: Materials_MaterialId_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory."Materials_MaterialId_seq"', 1, false);


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

SELECT pg_catalog.setval('quotes."QuoteRevisions_QuoteRevisionId_seq"', 1, false);


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 255
-- Name: UserRecords_RecStatusId_seq; Type: SEQUENCE SET; Schema: quotes; Owner: postgres
--

SELECT pg_catalog.setval('quotes."UserRecords_RecStatusId_seq"', 1, false);


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 257
-- Name: RefreshTokens_Id_seq; Type: SEQUENCE SET; Schema: security; Owner: postgres
--

SELECT pg_catalog.setval('security."RefreshTokens_Id_seq"', 6, true);


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

SELECT pg_catalog.setval('security.security_group_sec_group_id_seq', 8, true);


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

SELECT pg_catalog.setval('security."users_UserId_seq"', 11, true);


--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 276
-- Name: DependentQuestions_DependentQId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."DependentQuestions_DependentQId_seq"', 1, false);


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 278
-- Name: FieldTypes_FieldTypeId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."FieldTypes_FieldTypeId_seq"', 1, false);


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 280
-- Name: Iframes_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Iframes_PID_seq"', 1, false);


--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 282
-- Name: MetafieldAnswers_metafield_answer_id_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."MetafieldAnswers_metafield_answer_id_seq"', 1, false);


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 284
-- Name: Metafields_PID_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Metafields_PID_seq"', 1, false);


--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 286
-- Name: QuestionGroups_QuestionGroupId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionGroups_QuestionGroupId_seq"', 1, false);


--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 288
-- Name: QuestionOptions_QOptionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."QuestionOptions_QOptionId_seq"', 1, false);


--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 290
-- Name: Questions_QuestionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Questions_QuestionId_seq"', 1, false);


--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 292
-- Name: TemplateItems_TemplateItemId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateItems_TemplateItemId_seq"', 1, false);


--
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 294
-- Name: TemplateVersions_TempVersionId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."TemplateVersions_TempVersionId_seq"', 1, false);


--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 296
-- Name: Templates_TemplateId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."Templates_TemplateId_seq"', 1, false);


--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 298
-- Name: UserAnswers_UAnswerId_seq; Type: SEQUENCE SET; Schema: templates; Owner: postgres
--

SELECT pg_catalog.setval('templates."UserAnswers_UAnswerId_seq"', 1, false);


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


-- Completed on 2026-03-25 23:50:34

--
-- PostgreSQL database dump complete
--

\unrestrict RXcC1iZ24SR0oZYFNCJfg1ggqlfVOVMNbyPJK8BDz0nAQeQbnJnBCFFDJ4EZS8g

