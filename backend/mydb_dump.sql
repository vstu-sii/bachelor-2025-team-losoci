--
-- PostgreSQL database dump
--

\restrict cylKk9QSLKpSoGnXlON0T2oakyUnhVnGJRcKBITJOzRVSoOOzlPNLzU4hfoFzgA

-- Dumped from database version 16.10 (Debian 16.10-1.pgdg13+1)
-- Dumped by pg_dump version 16.10 (Debian 16.10-1.pgdg13+1)

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
-- Name: delete_unconfirmed_users(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_unconfirmed_users() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM users
    WHERE email_confirmed = false
      AND created_at < NOW() - INTERVAL '1 hour';
END;
$$;


ALTER FUNCTION public.delete_unconfirmed_users() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chats (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    sender_id integer NOT NULL,
    recipient_id integer,
    context character varying(250)
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- Name: chats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chats_id_seq OWNER TO postgres;

--
-- Name: chats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chats_id_seq OWNED BY public.chats.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    date date NOT NULL,
    importance_id integer,
    completed boolean DEFAULT false,
    user_id integer NOT NULL,
    recipient_id integer
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friends (
    id integer NOT NULL,
    user_id integer NOT NULL,
    friend_id integer NOT NULL,
    context character varying(250)
);


ALTER TABLE public.friends OWNER TO postgres;

--
-- Name: friends_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friends_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friends_id_seq OWNER TO postgres;

--
-- Name: friends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friends_id_seq OWNED BY public.friends.id;


--
-- Name: importance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.importance (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.importance OWNER TO postgres;

--
-- Name: importance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.importance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.importance_id_seq OWNER TO postgres;

--
-- Name: importance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.importance_id_seq OWNED BY public.importance.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    text text NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now(),
    chat_id integer NOT NULL,
    role character varying(20) NOT NULL
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: photo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.photo (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.photo OWNER TO postgres;

--
-- Name: photo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.photo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.photo_id_seq OWNER TO postgres;

--
-- Name: photo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.photo_id_seq OWNED BY public.photo.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(250) NOT NULL,
    name character varying(50),
    surname character varying(50),
    username character varying(50),
    birthdate date,
    gender character varying(10),
    description text,
    telegram_link character varying(100),
    email_confirmed boolean DEFAULT false,
    telegram_link_confirmed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    telegram_chat_id bigint,
    telegram_username character varying(100),
    telegram_init_id character varying(50)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: chats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats ALTER COLUMN id SET DEFAULT nextval('public.chats_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: friends id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends ALTER COLUMN id SET DEFAULT nextval('public.friends_id_seq'::regclass);


--
-- Name: importance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importance ALTER COLUMN id SET DEFAULT nextval('public.importance_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: photo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.photo ALTER COLUMN id SET DEFAULT nextval('public.photo_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (id, title, sender_id, recipient_id, context) FROM stdin;
38	sadsadsadas	30	\N	sadsadsadas
39	dsadasdsa	30	\N	dsadasdsa
40	╨║╤В╨╛ ╤В╤Л ╨▓╨╛╨╕╨╜	30	\N	╨║╤В╨╛ ╤В╤Л ╨▓╨╛╨╕╨╜
41	╨┤╨░╨▓╨░╨╣ ╨┐╨╛╨┤╨▒╨╡╤А╨╡╨╝ ╨┐╨╛╨┤╨░╤А╨╛╨║	30	\N	╨┤╨░╨▓╨░╨╣ ╨┐╨╛╨┤╨▒╨╡╤А╨╡╨╝ ╨┐╨╛╨┤╨░╤А╨╛╨║
42	╨Я╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤М: @dencoc\n╨б╨╛╨▒╤Л╤В╨╕╨╡: ╨┤╨╡╨╜╤М ╤А╨╛╨╢╨┤╨╡╨╜╨╕╤П\n╨Ф╨╛╨┐╨╛╨╗╨╜╨╕...	30	30	╨Я╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤М: @dencoc\n╨б╨╛╨▒╤Л╤В╨╕╨╡: ╨┤╨╡╨╜╤М ╤А╨╛╨╢╨┤╨╡╨╜╨╕╤П\n╨Ф╨╛╨┐╨╛╨╗╨╜╨╕╤В╨╡╨╗╤М╨╜╨╛: yghjnm,
43	╨┐╨╛╨┤╨▒╨╡╤А╨╕ ╨┐╨╛╨┤╨░╤А╨╛╨║	30	\N	╨┐╨╛╨┤╨▒╨╡╤А╨╕ ╨┐╨╛╨┤╨░╤А╨╛╨║
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, title, description, date, importance_id, completed, user_id, recipient_id) FROM stdin;
18	hdfjkhakjf	djfjkdshkfjd	2025-12-10	\N	f	30	30
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friends (id, user_id, friend_id, context) FROM stdin;
\.


--
-- Data for Name: importance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.importance (id, name) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, text, "timestamp", chat_id, role) FROM stdin;
385	sadsadsadas	2025-12-09 19:04:26.174058	38	user
386	asdasdasds	2025-12-09 19:06:08.003586	38	user
387	{"response":"╨Я╨╛╨╢╨░╨╗╤Г╨╣╤Б╤В╨░, ╨┤╨░╨▓╨░╨╣ ╨╜╨░╤З╨╜╨╡╨╝ ╤Б╨╜╨░╤З╨░╨╗╨░. ╨з╤В╨╛╨▒╤Л ╨┐╨╛╨┤╨╛╨▒╤А╨░╤В╤М ╨┐╨╛╨┤╨░╤А╨╛╨║, ╨╝╨╜╨╡ ╨╜╤Г╨╢╨╜╨╛ ╨╖╨╜╨░╤В╤М ╨╜╨╡╨╝╨╜╨╛╨│╨╛ ╨▒╨╛╨╗╤М╤И╨╡ ╨╛ ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╨╡. ╨Ъ╨░╨║╨╛╨╣ ╨▓╨╛╨╖╤А╨░╤Б╤В ╤Г ╤З╨╡╨╗╨╛╨▓╨╡╨║╨░? ╨Ш ╨╡╤Б╤В╤М ╨╗╨╕ ╤Г ╨╜╨╡╨│╨╛ ╨║╨░╨║╨╕╨╡-╤В╨╛ ╨╕╨╜╤В╨╡╤А╨╡╤Б╤Л ╨╕╨╗╨╕ ╨┐╤А╨╡╨┤╨┐╨╛╤З╤В╨╡╨╜╨╕╤П? [READY_TO_SEARCH]","gifts":[]}	2025-12-09 19:06:09.372579	38	assistant
388	dsadasdsa	2025-12-09 19:08:30.128365	39	user
389	╨║╤В╨╛ ╤В╤Л ╨▓╨╛╨╕╨╜	2025-12-09 19:16:01.086269	40	user
390	{"response":"╨п ╨╜╨╡ ╨▓╨╛╨╕╨╜, ╨░ ╨┐╨╛╨╝╨╛╤Й╨╜╨╕╨║ ╨▓ ╨┐╨╛╨╕╤Б╨║╨╡ ╨┐╨╛╨┤╨░╤А╨║╨╛╨▓! ╨п ╨┐╨╛╨╝╨╛╨│╤Г ╨▓╤Л╨▒╤А╨░╤В╤М ╨┐╨╛╨┤╤Е╨╛╨┤╤П╤Й╨╕╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║ ╨┤╨╗╤П ╨║╨╛╨│╨╛-╤В╨╛, ╨╛╤В╨▓╨╡╤В╨╕╨▓ ╨╜╨░ ╨▓╨╛╨┐╤А╨╛╤Б╤Л ╨╕ ╨┐╤А╨╡╨┤╨╗╨░╨│╨░╤П ╨║╨╛╨╜╨║╤А╨╡╤В╨╜╤Л╨╡ ╨╕╨┤╨╡╨╕. ╨У╨╛╤В╨╛╨▓ ╨╜╨░╤З╨░╤В╤М? ╨Ъ╨░╨║╨╛╨╣ ╤З╨╡╨╗╨╛╨▓╨╡╨║ ╤В╨╡╨▒╨╡ ╨╜╤Г╨╢╨╡╨╜ ╨┐╨╛╨┤╨░╤А╨╛╨║?","gifts":null}	2025-12-09 19:16:02.461607	40	assistant
391	╤В╤Л ╤Г╨▓╨╡╤А╨╡╨╜ ╨▓ ╤Н╤В╨╛╨╝?	2025-12-09 19:17:18.556073	40	user
392	{"response":"╨Э╨╡╤В, ╨╝╨╛╨╢╨╡╤В ╨▒╤Л╤В╤М ╤П ╨╜╨╡ ╤Б╨╛╨▓╤Б╨╡╨╝ ╤В╨╛╤З╨╜╨╛ ╨╛╨┐╤А╨╡╨┤╨╡╨╗╨╕╨╗ ╤Б╨▓╨╛╤О ╤А╨╛╨╗╤М... ╨п - ╤З╨░╤В-╨▒╨╛╤В, ╨║╨╛╤В╨╛╤А╤Л╨╣ ╨┐╨╛╨╝╨╛╨╢╨╡╤В ╨▓╤Л╨▒╤А╨░╤В╤М ╨┐╨╛╨┤╨░╤А╨╛╨║, ╨╜╨╛ ╤П ╨╜╨╡ ╨▓╨╛╨╕╨╜. ╨У╨╛╤В╨╛╨▓ ╨┐╨╛╨╝╨╛╤З╤М! ╨Ъ╨╛╨╝╤Г ╨╜╤Г╨╢╨╡╨╜ ╨┐╨╛╨┤╨░╤А╨╛╨║ ╨╕ ╨┤╨╗╤П ╤З╨╡╨│╨╛?","gifts":null}	2025-12-09 19:17:19.786508	40	assistant
393	╤В╤Л ╤Г╨▓╨╡╤А╨╡╨╜ ╨▓ ╤Н╤В╨╛╨╝?	2025-12-09 19:17:28.325923	40	user
394	{"response":"╨Э╨╡╤В, ╨╝╨╛╨╢╨╡╤В ╨▒╤Л╤В╤М ╤П ╨▓╤Б╨╡ ╨╢╨╡ ╨╛╤И╨╕╨▒╤Б╤П... ╨Ь╨╜╨╡ ╨╜╤Г╨╢╨╜╨╛ ╨╜╨░╤З╨░╤В╤М ╤Б╨╜╨░╤З╨░╨╗╨░!\\n\\n╨в╤Л ╤Е╨╛╤З╨╡╤И╤М ╨┐╨╛╨┤╨╛╨▒╤А╨░╤В╤М ╨┐╨╛╨┤╨░╤А╨╛╨║ ╨┤╨╗╤П ╨║╨╛╨│╨╛-╤В╨╛. ╨п ╨┐╨╛╨╝╨╛╨│╤Г ╤В╨╡╨▒╨╡ ╨▓ ╤Н╤В╨╛╨╝. ╨з╤В╨╛╨▒╤Л ╨╜╨░╤З╨░╤В╤М, ╨╝╨╜╨╡ ╨╜╤Г╨╢╨╜╨╛ ╨╖╨╜╨░╤В╤М ╨╜╨╡╨╝╨╜╨╛╨│╨╛ ╨╛ ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╨╡. ╨Ъ╨░╨║╨╛╨╣ ╨▓╨╛╨╖╤А╨░╤Б╤В ╤Г ╤З╨╡╨╗╨╛╨▓╨╡╨║╨░, ╨║╨╛╤В╨╛╤А╨╛╨╝╤Г ╤В╤Л ╤Е╨╛╤З╨╡╤И╤М ╨┐╨╛╨┤╨░╤А╨╕╤В╤М?","gifts":null}	2025-12-09 19:17:29.686017	40	assistant
395	╤П ╨╜╨╡ ╨╖╨╜╨░╤О	2025-12-09 19:18:29.572761	40	user
396	{"response":"╨Э╨╕╤З╨╡╨│╨╛ ╤Б╤В╤А╨░╤И╨╜╨╛╨│╨╛! ╨Ф╨░╨▓╨░╨╣ ╨╖╨░╨┤╨░╨┤╨╕╨╝ ╨╡╤Й╨╡ ╨╜╨╡╤Б╨║╨╛╨╗╤М╨║╨╛ ╨▓╨╛╨┐╤А╨╛╤Б╨╛╨▓, ╤З╤В╨╛╨▒╤Л ╨┐╨╛╨╜╤П╤В╤М ╨╗╤Г╤З╤И╨╡. ╨Ъ╨░╨║╨╛╨╣ ╨┐╨╛╨╗ ╤Г ╤З╨╡╨╗╨╛╨▓╨╡╨║╨░, ╨║╨╛╤В╨╛╤А╨╛╨╝╤Г ╤В╤Л ╤Е╨╛╤З╨╡╤И╤М ╨┐╨╛╨┤╨░╤А╨╕╤В╤М?","gifts":null}	2025-12-09 19:18:30.646253	40	assistant
397	╨┐╨╛╨╜╤П╤В╨╜╨╛	2025-12-09 19:18:58.26643	40	user
398	{"response":"╨Ш╤В╨░╨║, ╨╝╤Л ╨┐╨╛╨║╨░ ╨╜╨╕╤З╨╡╨│╨╛ ╨╜╨╡ ╨╖╨╜╨░╨╡╨╝ ╨╛ ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╨╡. ╨Ф╨░╨▓╨░╨╣╤В╨╡ ╨┐╨╛╨┐╤А╨╛╨▒╤Г╨╡╨╝ ╨╡╤Й╨╡ ╤А╨░╨╖! ╨Ф╨╗╤П ╨╜╨░╤З╨░╨╗╨░: ╤З╤В╨╛ ╤П╨▓╨╗╤П╨╡╤В╤Б╤П ╨╛╤Б╨╜╨╛╨▓╨╜╤Л╨╝ ╨┐╨╛╨▓╨╛╨┤╨╛╨╝ ╨┤╨╗╤П ╨┐╨╛╨║╤Г╨┐╨║╨╕ ╨┐╨╛╨┤╨░╤А╨║╨░ (╤А╨╛╨┤╨╕╤В╨╡╨╗╤М╨╜╤Л╨╣ ╨┤╨╡╨╜╤М, ╤А╨╛╨╢╨┤╨╡╨╜╨╕╨╡, ╤Б╨▓╨░╨┤╤М╨▒╨░ ╨╕ ╤В.╨┤.)?","gifts":null}	2025-12-09 19:18:59.474567	40	assistant
399	╤Б╨▓╨░╨┤╤М╨▒╨░ ╤В╨░╤А╨░╨║╨░╨╜╨╛╨▓	2025-12-09 19:20:34.779034	40	user
400	{"response":"╨Т╨╛╤В ╨╕╨╜╤В╨╡╤А╨╡╤Б╨╜╤Л╨╣ ╨┐╨╛╨▓╨╛╨┤! ╨б╨╗╤Г╤И╨░╨╣, ╤П ╨╜╨╡ ╤Б╨╛╨▓╤Б╨╡╨╝ ╨┐╨╛╨╜╤П╨╗, ╨╛ ╤З╨╡╨╝ ╤В╤Л ╨│╨╛╨▓╨╛╤А╨╕╤И╤М. ╨в╨░╤А╨░╤Е╨░╨╜╤Л - ╤Н╤В╨╛ ╨╜╨░╤Б╨╡╨║╨╛╨╝╤Л╨╡, ╨░ ╤Б╨▓╨░╨┤╤М╨▒╨░ - ╤Н╤В╨╛ ╤В╨╛╤А╨╢╨╡╤Б╤В╨▓╨╛ ╨┤╨╗╤П ╨╗╤О╨┤╨╡╨╣. ╨Ш╤В╨░╨║, ╤П ╨┐╤А╨╡╨┤╨┐╨╛╨╗╨░╨│╨░╤О, ╤З╤В╨╛ ╤Н╤В╨╛ ╨╗╨╕╨▒╨╛ ╤И╤Г╤В╨║╨░, ╨╗╨╕╨▒╨╛ ╤В╤Л ╨┐╤А╨╛╤Б╤В╨╛ ╤Е╨╛╤З╨╡╤И╤М ╨┐╨╛╨┤╨░╤А╨╕╤В╤М ╤З╤В╨╛-╤В╨╛ ╨╕╨╜╤В╨╡╤А╨╡╤Б╨╜╨╛╨╡ ╨╜╨░ ╤Б╨▓╨░╨┤╤М╨▒╤Г ╨╕╨╗╨╕ ╨▓ ╤З╨╡╤Б╤В╤М ╤З╨╡╨│╨╛-╤В╨╛ ╨┤╤А╤Г╨│╨╛╨│╨╛?","gifts":null}	2025-12-09 19:20:36.529965	40	assistant
401	╤П ╨╜╨░ ╨┐╨╛╨╗╨╜╨╛╨╝ ╤Б╨╡╤А╤М╨╡╨╖╨╡	2025-12-09 19:21:52.394439	40	user
402	"╨п ╨╜╨╡ ╤Б╨╛╨▓╤Б╨╡╨╝ ╨┐╨╛╨╜╤П╨╗ ╤Б╨╕╤В╤Г╨░╤Ж╨╕╤О... ╨б╨╗╤Г╤И╨░╨╣, ╤П ╨│╨╛╤В╨╛╨▓ ╨┐╨╛╨╝╨╛╤З╤М, ╨╜╨╛ ╨╝╨╜╨╡ ╨╜╤Г╨╢╨╜╨╛ ╨┐╨╛╨╜╤П╤В╤М ╨║╨╛╨╜╤В╨╡╨║╤Б╤В. ╨в╨░╤А╨░╤Е╨░╨╜╤Л - ╤Н╤В╨╛ ╨╝╨░╨╗╨╡╨╜╤М╨║╨╕╨╡ ╨╜╨░╤Б╨╡╨║╨╛╨╝╤Л╨╡, ╨╕ ╤П ╨╜╨╡ ╨╖╨╜╨░╤О, ╤З╤В╨╛ ╤В╨░╨║╨╛╨╡ ╤Б╨▓╨░╨┤╤М╨▒╨░ ╤В╨░╤А╨░╤Е╨░╨╜╨╛╨▓. ╨Х╤Б╤В╤М ╨╗╨╕ ╤Г ╤В╨╡╨▒╤П ╨▓ ╨▓╨╕╨┤╤Г ╨║╨░╨║╨░╤П-╤В╨╛ ╨║╨╛╨╜╨║╤А╨╡╤В╨╜╨░╤П ╨│╤А╤Г╨┐╨┐╨░ ╨╗╤О╨┤╨╡╨╣ ╨╕╨╗╨╕ ╤Б╨╛╨▒╤Л╤В╨╕╨╡?"	2025-12-09 19:21:54.039444	40	assistant
403	╤Б╨╛╨▒╤Л╤В╨╕╨╡ - ╤Б╨▓╨░╨┤╤М╨▒╨░, ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤М ╨╝╤Г╨╢╤З╨╕╨╜╨░ 25 ╨╗╨╡╤В, ╤Г╨▓╨╗╨╡╨║╨░╨╡╤В╤Б╤П ╤З╨░╤Б╨░╨╝╨╕	2025-12-09 19:22:39.341793	40	user
404	"╨в╨╡╨┐╨╡╤А╤М ╨▓╤Б╨╡ ╤П╤Б╨╜╨╛! ╨Ш╤В╨░╨║, ╨╝╤Л ╤Е╨╛╤В╨╕╨╝ ╨┐╨╛╨┤╨░╤А╨╕╤В╤М ╨╝╤Г╨╢╤З╨╕╨╜╨╡ 25 ╨╗╨╡╤В ╨╜╨░ ╨╡╨│╨╛ ╤Б╨▓╨░╨┤╤М╨▒╤Г, ╨║╨╛╤В╨╛╤А╤Л╨╣ ╨╗╤О╨▒╨╕╤В ╤З╨░╤Б╤Л. ╨н╤В╨╛ ╨║╨╗╨░╤Б╤Б╨╜╨░╤П ╤В╨╡╨╝╨░ ╨┤╨╗╤П ╨┐╨╛╨┤╨░╤А╨║╨░!\\n\\n╨Ф╨░╨▓╨░╨╣ ╨┐╨╛╨┐╤А╨╛╨▒╤Г╨╡╨╝ ╨╜╨░╨╣╤В╨╕ ╤З╤В╨╛-╤В╨╛ ╨╕╨╜╤В╨╡╤А╨╡╤Б╨╜╨╛╨╡ ╨╕ ╨┐╨╛╨┤╤Е╨╛╨┤╤П╤Й╨╡╨╡. ╨Ъ╨░╨║╨╛╨╣ ╤Г ╤В╨╡╨▒╤П ╨▒╤О╨┤╨╢╨╡╤В ╨┤╨╗╤П ╨┐╨╛╨┤╨░╤А╨║╨░?"	2025-12-09 19:22:40.766091	40	assistant
405	12 000	2025-12-09 19:22:49.421481	40	user
406	"╨Т╨╛╤В ╨╛╤В╨╗╨╕╤З╨╜╤Л╨╣ ╨▒╤О╨┤╨╢╨╡╤В! ╨б ╤Г╤З╨╡╤В╨╛╨╝ ╨╗╤О╨▒╨▓╨╕ ╨║ ╤З╨░╤Б╨░╨╝, ╤П ╨╝╨╛╨│╤Г ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╕╤В╤М ╨╜╨╡╤Б╨║╨╛╨╗╤М╨║╨╛ ╨▓╨░╤А╨╕╨░╨╜╤В╨╛╨▓:\\n\\n1) ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░ (╨╜╨░╨┐╤А╨╕╨╝╨╡╤А, Omega ╨╕╨╗╨╕ Rolex)\\n2) ╨Э╨░╨▒╨╛╤А ╤З╨░╤Б╨╛╨▓ ╨┤╨╗╤П ╨║╨╛╨╗╨╗╨╡╨║╤Ж╨╕╨╛╨╜╨╕╤А╨╛╨▓╨░╨╜╨╕╤П ╨╕╨╗╨╕ ╨┤╨╡╨╝╨╛╨╜╤Б╤В╤А╨░╤Ж╨╕╨╕\\n3) ╨г╨╜╨╕╨║╨░╨╗╤М╨╜╨░╤П ╤З╨░╤Б╨╛╨▓╨░╤П ╤А╨░╨▒╨╛╤В╨░ ╨╕╤Б╨║╤Г╤Б╤Б╤В╨▓╨░ ╨╕╨╗╨╕ ╤Б╨║╤Г╨╗╤М╨┐╤В╤Г╤А╨░\\n4) ╨н╨║╤Б╨║╨╗╤О╨╖╨╕╨▓╨╜╤Л╨╣ ╤З╨░╤Б╨╛╨▓╨╛╨╣ ╤Б╨╡╤А╨▓╨╕╤Б ╨╕╨╗╨╕ ╨╛╨▒╤Б╨╗╤Г╨╢╨╕╨▓╨░╨╜╨╕╨╡\\n\\n╨Ъ╨░╨║╨╛╨╣ ╨╜╨╛╨╝╨╡╤А ╤В╨╡╨▒╨╡ ╨╜╤А╨░╨▓╨╕╤В╤Б╤П ╨▒╨╛╨╗╤М╤И╨╡ ╨▓╤Б╨╡╨│╨╛?"	2025-12-09 19:22:51.628313	40	assistant
407	1 ╨▓╨░╤А╨╕╨░╨╜╤В	2025-12-09 19:23:03.567139	40	user
408	"╨Ю╤В╨╗╨╕╤З╨╜╨╛, ╤В╨╛╨│╨┤╨░ ╨▒╨╡╤А╤С╨╝ ╨▓╨░╤А╨╕╨░╨╜╤В тДЦ1. ╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n\\n[READY_TO_SEARCH]"	2025-12-09 19:23:04.732993	40	assistant
409	╨▓╤Б╨╡ ╨▓╨╡╤А╨╜╨╛	2025-12-09 19:23:19.848629	40	user
410	"╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n\\n[READY_TO_SEARCH]"	2025-12-09 19:23:20.834104	40	assistant
411	╨╛╤В╨║╤Г╨┤╨░ ╤Б╤В╨╛╨╗╤М╨║╨╛ ╨╝╤Г╤Б╨╛╤А╨░ ╨▓ ╨╖╨░╨┐╤А╨╛╤Б╨╡	2025-12-09 19:32:09.748525	40	user
412	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:32:13.877424	40	assistant
413	╨┤╨░╨▓╨░╨╣ ╨▓╤Б╨╡ ╨▓╨░╤А╨╕╨░╨╜╤В╤Л	2025-12-09 19:41:21.116717	40	user
414	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:41:26.328661	40	assistant
415	╨┤╨░╨▓╨░╨╣ ╨┐╤А╨╛╤Б╨╝╨╛╤В╤А╨╕╨╝ ╨▓╤Б╨╡ ╨▓╨░╤А╨╕╨░╨╜╤В╤Л ╤З╨░╤Б╨╛╨▓	2025-12-09 19:41:37.8152	40	user
416	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:41:40.829112	40	assistant
417	╨┤╨░╨▓╨░╨╣ ╨▓╨╡╤А╨╜╨╡╨╝╤Б╤П ╨╜╨░ ╨┐╤А╨╡╨┤╤Л╨┤╤Г╤Й╨╕╨╣ ╤Г╨╖╨╡╨╗	2025-12-09 19:42:19.493459	40	user
418	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:42:24.723503	40	assistant
419	╨╜╨╡ ╨┐╤А╨╛╤Й╤Г	2025-12-09 19:48:58.038225	40	user
420	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:49:02.907399	40	assistant
421	╨┤╨░╨▓╨░╨╣ ╨┐╨╛╨┤╨▒╨╡╤А╨╡╨╝ ╨┐╨╛╨┤╨░╤А╨╛╨║	2025-12-09 19:53:06.892926	41	user
422	"╨Я╤А╨╛╤Б╤В╨╕ ╨╖╨░ ╤Н╤В╨╛! ╨п ╤Б╨┤╨╡╨╗╨░╨╗ ╨╛╤И╨╕╨▒╨║╤Г. ╨Я╤А╨░╨▓╨╕╨╗╤М╨╜╤Л╨╣ ╨╛╤В╨▓╨╡╤В ╨┤╨╛╨╗╨╢╨╡╨╜ ╨▒╤Л╤В╤М ╨┐╤А╨╛╤Б╤В╨╛:\\n\\n╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╗╨░╤Б╤Б╨╕╤З╨╡╤Б╨║╨╕╨╣ ╨╝╨╡╤Е╨░╨╜╨╕╤З╨╡╤Б╨║╨╕╨╣ ╤З╨░╤Б╤Л ╨╛╤В ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨│╨╛ ╨▒╤А╨╡╨╜╨┤╨░.\\n[READY_TO_SEARCH]"	2025-12-09 19:53:08.80637	41	assistant
423	╨Я╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤М: @dencoc\n╨б╨╛╨▒╤Л╤В╨╕╨╡: ╨┤╨╡╨╜╤М ╤А╨╛╨╢╨┤╨╡╨╜╨╕╤П\n╨Ф╨╛╨┐╨╛╨╗╨╜╨╕╤В╨╡╨╗╤М╨╜╨╛: yghjnm,	2025-12-10 11:21:41.998889	42	user
424	"╨Я╤А╨╕╨▓╨╡╤В! ╨Я╨╛╤Б╨║╨╛╨╗╤М╨║╤Г ╤П ╨╜╨╡ ╨╖╨╜╨░╤О ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤П ╤Б╨╗╨╕╤И╨║╨╛╨╝ ╤Е╨╛╤А╨╛╤И╨╛, ╨┤╨░╨▓╨░╨╣╤В╨╡ ╨╜╨░╤З╨╜╨╡╨╝ ╤Б ╨▓╨╛╨┐╤А╨╛╤Б╨╛╨▓. ╨Ъ╨░╨║╨╛╨╣ ╨▓╨╛╨╖╤А╨░╤Б╤В ╤Г @dencoc? ╨Р ╤В╨░╨║╨╢╨╡ ╨╡╤Б╤В╤М ╨╗╨╕ ╤Г ╨╜╨╡╨│╨╛ ╨║╨░╨║╨╕╨╡-╤В╨╛ ╨╕╨╜╤В╨╡╤А╨╡╤Б╤Л ╨╕╨╗╨╕ ╨┐╤А╨╡╨┤╨┐╨╛╤З╤В╨╡╨╜╨╕╤П, ╨║╨╛╤В╨╛╤А╤Л╨╡ ╨╝╨╛╨╢╨╜╨╛ ╤Г╤З╨╡╤Б╤В╤М ╨┐╤А╨╕ ╨▓╤Л╨▒╨╛╤А╨╡ ╨┐╨╛╨┤╨░╤А╨║╨░? \\n\\n(╨╕, ╨╡╤Б╨╗╨╕ ╤Н╤В╨╛ ╨┐╨╛╨╝╨╛╨╢╨╡╤В, ╤З╤В╨╛ ╤В╨░╨║╨╛╨╡ yghjnm?)"	2025-12-10 11:21:47.506017	42	assistant
425	65	2025-12-10 11:22:00.690957	42	user
426	"╨Т╨╛╨╖╤А╨░╤Б╤В 65 ╨│╨╛╨┤. ╨в╨╡╨┐╨╡╤А╤М ╤П ╨▒╤Л ╤Б╨┐╤А╨╛╤Б╨╕╨╗: ╨Ъ╨░╨║╨╛╨╣ ╨┐╨╛╨╗ @dencoc? ╨Ь╤Г╨╢╤Б╨║╨╛╨╣ ╨╕╨╗╨╕ ╨╢╨╡╨╜╤Б╨║╨╕╨╣?"	2025-12-10 11:22:01.77976	42	assistant
427	╨Ь╤Г╨╢╤Б╨║╨╛╨╣ 	2025-12-10 11:22:11.480707	42	user
428	"╨Ч╨╜╨░╤З╨╕╤В ╨┐╨╛╨╗╤Г╤З╨░╤В╨╡╨╗╤М ╨╝╤Г╨╢╤З╨╕╨╜╨░. ╨Р ╤В╨╡╨┐╨╡╤А╤М ╨▓╨╛╨┐╤А╨╛╤Б ╨╛ ╨┐╨╛╨▓╨╛╨┤╨╡: ╨Ф╨╡╨╜╤М ╤А╨╛╨╢╨┤╨╡╨╜╨╕╤П тАФ ╤Н╤В╨╛ ╨╛╤Б╨╜╨╛╨▓╨╜╨░╤П ╨┐╤А╨╕╤З╨╕╨╜╨░ ╨┐╨╛╨┤╨░╤А╨║╨░, ╨╜╨╛ ╨╡╤Б╤В╤М ╨╗╨╕ ╤Г ╨╜╨╡╨│╨╛ ╨║╨░╨║╨╕╨╡-╤В╨╛ ╨┤╤А╤Г╨│╨╕╨╡ ╨╕╨╜╤В╨╡╤А╨╡╤Б╤Л ╨╕╨╗╨╕ ╤Г╨▓╨╗╨╡╤З╨╡╨╜╨╕╤П, ╨║╨╛╤В╨╛╤А╤Л╨╡ ╨╝╨╛╨╢╨╜╨╛ ╤Г╤З╨╡╤Б╤В╤М ╨┐╤А╨╕ ╨▓╤Л╨▒╨╛╤А╨╡?"	2025-12-10 11:22:12.874243	42	assistant
429	╨║╨░╨║╨╛╨╣╤В╨╛ ╤Б╤А╨╡╨┤╨╜╨╕╨╣ ╨░╨╛╨┤╨░╤А╨╛╤А╨║	2025-12-10 11:22:42.6031	42	user
430	"╨е╨╝... ╤П ╨╜╨╡ ╤Б╨╛╨▓╤Б╨╡╨╝ ╨┐╨╛╨╜╤П╨╗. ╨Р ╨╝╨╛╨╢╨╡╤В ╨▒╤Л╤В╤М, ╤В╤Л ╤Е╨╛╤З╨╡╤И╤М ╤Б╨║╨░╨╖╨░╤В╤М, ╤З╤В╨╛ @dencoc ╤З╨╡╨╗╨╛╨▓╨╡╨║ ╤Б ╨┐╤А╨╛╤Б╤В╤Л╨╝╨╕ ╨╕ ╤В╤А╨░╨┤╨╕╤Ж╨╕╨╛╨╜╨╜╤Л╨╝╨╕ ╨▓╨║╤Г╤Б╨░╨╝╨╕?\\n\\n╨Т ╨╗╤О╨▒╨╛╨╝ ╤Б╨╗╤Г╤З╨░╨╡, ╤В╨╡╨┐╨╡╤А╤М ╤Г ╨╝╨╡╨╜╤П ╨╡╤Б╤В╤М ╨┤╨╛╤Б╤В╨░╤В╨╛╤З╨╜╨╛ ╨╕╨╜╤Д╨╛╤А╨╝╨░╤Ж╨╕╨╕ ╨┤╨╗╤П ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П ╨╜╨╡╨║╨╛╤В╨╛╤А╤Л╤Е ╨╕╨┤╨╡╨╣ ╨┐╨╛╨┤╨░╤А╨║╨╛╨▓. \\n\\n1) ╨Ъ╨╜╨╕╨│╨░ ╨┐╨╛ ╨╕╤Б╤В╨╛╤А╨╕╨╕ ╨╕╨╗╨╕ ╨▒╨╕╨╛╨│╤А╨░╤Д╨╕╤П ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨╣ ╨╗╨╕╤З╨╜╨╛╤Б╤В╨╕.\\n2) ╨Э╨░╨▒╨╛╤А ╨▒╨╕╨╗╤М╤П╤А╨┤╨╜╤Л╤Е ╤И╨░╤А╨╛╨▓ ╨┤╨╗╤П ╨┤╨╛╨╝╨░╤И╨╜╨╡╨│╨╛ ╤Б╤В╨╛╨╗╨░.\\n3) ╨Я╨╛╨┤╨░╤А╨╛╤З╨╜╨░╤П ╨║╨░╤А╤В╨║╨░ ╤Б ╤Д╨╛╤В╨╛╨│╤А╨░╤Д╨╕╨╡╨╝ ╨╕ ╨╗╨╕╤З╨╜╤Л╨╝ ╤Б╨╛╨╛╨▒╤Й╨╡╨╜╨╕╨╡╨╝.\\n4) ╨г╤О╤В╨╜╤Л╨╣ ╨╜╨░╨▒╨╛╤А ╨┤╨╗╤П ╤З╨░╤П ╨╕╨╗╨╕ ╨║╨╛╤Д╨╡.\\n\\n╨Ъ╨░╨║╨╛╨╣ ╨╜╨╛╨╝╨╡╤А ╤В╨╡╨▒╨╡ ╨╜╤А╨░╨▓╨╕╤В╤Б╤П ╨▒╨╛╨╗╤М╤И╨╡ ╨▓╤Б╨╡╨│╨╛?"	2025-12-10 11:22:45.061799	42	assistant
431	1	2025-12-10 11:23:00.033614	42	user
432	"╨Ю╤В╨╗╨╕╤З╨╜╨╛, ╤В╨╛╨│╨┤╨░ ╨▒╨╡╤А╤С╨╝ ╨▓╨░╤А╨╕╨░╨╜╤В тДЦ1. ╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╜╨╕╨│╨░ ╨┐╨╛ ╨╕╤Б╤В╨╛╤А╨╕╨╕ ╨╕╨╗╨╕ ╨▒╨╕╨╛╨│╤А╨░╤Д╨╕╤П ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨╣ ╨╗╨╕╤З╨╜╨╛╤Б╤В╨╕\\n\\n[READY_TO_SEARCH]"	2025-12-10 11:23:06.046257	42	assistant
433	╤Б╤Б╤Л╨╗╨╛╨║ ╨╜╨╡ ╨▒╤Г╨┤╨╡╤В	2025-12-10 11:23:49.024855	42	user
434	"╨Ю╤В╨╗╨╕╤З╨╜╨╛, ╤В╨╛╨│╨┤╨░ ╨▒╨╡╤А╤С╨╝ ╨▓╨░╤А╨╕╨░╨╜╤В тДЦ1. ╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╜╨╕╨│╨░ ╨┐╨╛ ╨╕╤Б╤В╨╛╤А╨╕╨╕ ╨╕╨╗╨╕ ╨▒╨╕╨╛╨│╤А╨░╤Д╨╕╤П ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨╣ ╨╗╨╕╤З╨╜╨╛╤Б╤В╨╕\\n\\n[READY_TO_SEARCH]"	2025-12-10 11:23:51.922203	42	assistant
435	╨┐╨╛╨┤╨▒╨╡╤А╨╕ ╨┐╨╛╨┤╨░╤А╨╛╨║	2025-12-10 11:24:21.387926	43	user
436	"╨п ╤Г╨╢╨╡ ╨▓╤Л╨▒╤А╨░╨╗ ╨┐╨╛╨┤╨░╤А╨╛╨║ ╤А╨░╨╜╨╡╨╡. ╨Т╤Л╨▒╤А╨░╨╜╨╜╤Л╨╣ ╨┐╨╛╨┤╨░╤А╨╛╨║: ╨Ъ╨╜╨╕╨│╨░ ╨┐╨╛ ╨╕╤Б╤В╨╛╤А╨╕╨╕ ╨╕╨╗╨╕ ╨▒╨╕╨╛╨│╤А╨░╤Д╨╕╤П ╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛╨╣ ╨╗╨╕╤З╨╜╨╛╤Б╤В╨╕\\n\\n[READY_TO_SEARCH]"	2025-12-10 11:24:24.464231	43	assistant
\.


--
-- Data for Name: photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.photo (id, name, user_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, name, surname, username, birthdate, gender, description, telegram_link, email_confirmed, telegram_link_confirmed, created_at, telegram_chat_id, telegram_username, telegram_init_id) FROM stdin;
30	denoff39@gmail.com	$2b$10$RzO9gR4HXF1Z6fa5JSHaVem1IKMO/k4DmIO6N3bdGhMTtcCvicM4K	Sergei	\N	dencoc	\N	\N	\N	@habibubalab	t	t	2025-12-09 17:39:12.940035	5365829222	habibubalab	@habibubalab
\.


--
-- Name: chats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chats_id_seq', 43, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 18, true);


--
-- Name: friends_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friends_id_seq', 1, false);


--
-- Name: importance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.importance_id_seq', 1, false);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 436, true);


--
-- Name: photo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.photo_id_seq', 38, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 30, true);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: importance importance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importance
    ADD CONSTRAINT importance_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: photo photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_chats_recipient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chats_recipient_id ON public.chats USING btree (recipient_id);


--
-- Name: idx_chats_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chats_sender_id ON public.chats USING btree (sender_id);


--
-- Name: idx_chats_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chats_title ON public.chats USING btree (title);


--
-- Name: idx_events_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_date ON public.events USING btree (date);


--
-- Name: idx_events_importance_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_importance_id ON public.events USING btree (importance_id);


--
-- Name: idx_events_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_user_id ON public.events USING btree (user_id);


--
-- Name: idx_importance_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_importance_name ON public.importance USING btree (name);


--
-- Name: idx_messages_chat_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_chat_id ON public.messages USING btree (chat_id);


--
-- Name: idx_messages_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_timestamp ON public.messages USING btree ("timestamp");


--
-- Name: idx_photo_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_photo_name ON public.photo USING btree (name);


--
-- Name: idx_photo_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_photo_user_id ON public.photo USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_name ON public.users USING btree (name);


--
-- Name: idx_users_surname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_surname ON public.users USING btree (surname);


--
-- Name: chats chats_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chats chats_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: events events_importance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_importance_id_fkey FOREIGN KEY (importance_id) REFERENCES public.importance(id) ON DELETE SET NULL;


--
-- Name: events events_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: events events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- Name: photo photo_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict cylKk9QSLKpSoGnXlON0T2oakyUnhVnGJRcKBITJOzRVSoOOzlPNLzU4hfoFzgA

