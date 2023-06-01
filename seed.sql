--
-- PostgreSQL database dump
--

-- Dumped from database version 14.3
-- Dumped by pg_dump version 14.3

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: lessons; Type: TABLE; Schema: public; Owner: jack
--

CREATE TABLE public.lessons (
    id integer NOT NULL,
    venue_id integer NOT NULL,
    day_idx integer NOT NULL,
    start_time time without time zone NOT NULL,
    duration integer NOT NULL,
    capacity integer NOT NULL,
    CONSTRAINT lessons_day_idx_check CHECK (((day_idx >= 0) AND (day_idx <= 6)))
);


ALTER TABLE public.lessons OWNER TO jack;

--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: jack
--

CREATE SEQUENCE public.lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lessons_id_seq OWNER TO jack;

--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jack
--

ALTER SEQUENCE public.lessons_id_seq OWNED BY public.lessons.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: jack
--

CREATE TABLE public.students (
    id integer NOT NULL,
    lesson_id integer NOT NULL,
    name text NOT NULL,
    age integer NOT NULL
);


ALTER TABLE public.students OWNER TO jack;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: jack
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_id_seq OWNER TO jack;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jack
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: user_credentials; Type: TABLE; Schema: public; Owner: jack
--

CREATE TABLE public.user_credentials (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL
);


ALTER TABLE public.user_credentials OWNER TO jack;

--
-- Name: user_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: jack
--

CREATE SEQUENCE public.user_credentials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_credentials_id_seq OWNER TO jack;

--
-- Name: user_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jack
--

ALTER SEQUENCE public.user_credentials_id_seq OWNED BY public.user_credentials.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: jack
--

CREATE TABLE public.venues (
    id integer NOT NULL,
    entry_creation_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    address text NOT NULL
);


ALTER TABLE public.venues OWNER TO jack;

--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: jack
--

CREATE SEQUENCE public.venues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venues_id_seq OWNER TO jack;

--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jack
--

ALTER SEQUENCE public.venues_id_seq OWNED BY public.venues.id;


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.lessons ALTER COLUMN id SET DEFAULT nextval('public.lessons_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: user_credentials id; Type: DEFAULT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.user_credentials ALTER COLUMN id SET DEFAULT nextval('public.user_credentials_id_seq'::regclass);


--
-- Name: venues id; Type: DEFAULT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.venues ALTER COLUMN id SET DEFAULT nextval('public.venues_id_seq'::regclass);


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: jack
--

COPY public.lessons (id, venue_id, day_idx, start_time, duration, capacity) FROM stdin;
2	1	1	15:45:00	30	4
3	1	1	16:15:00	20	1
6	3	2	10:00:00	30	4
7	3	2	11:00:00	30	4
8	3	2	11:30:00	30	4
9	2	3	09:20:00	30	4
10	2	3	09:55:00	30	4
11	2	3	10:30:00	30	4
12	2	3	11:40:00	30	4
13	2	3	12:15:00	30	4
14	2	3	13:45:00	30	4
15	2	3	14:25:00	30	4
18	1	0	16:30:00	30	4
19	1	0	17:00:00	30	2
1	1	1	15:15:00	30	4
4	1	1	16:35:00	30	3
16	1	0	15:30:00	30	12
17	1	0	16:00:00	30	7
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: jack
--

COPY public.students (id, lesson_id, name, age) FROM stdin;
2	16	Sofea	8
3	16	Laila	8
4	16	Milla	9
9	18	Blair	11
10	18	Quinn	7
11	19	Alex	9
12	19	Sara	9
13	1	Abel	8
14	2	Kerry	12
15	2	Felix	10
16	2	Mia	9
17	2	Sam	11
18	3	Maxwell	9
19	4	Shane	7
20	4	Marlowe	7
21	4	Aishani	8
22	6	Amber	12
23	6	Christopher	12
24	6	Kyle	12
25	6	Sana	12
26	7	Angela	13
27	7	Klara	12
28	7	Ben	11
29	7	Adam	12
30	8	Ava	12
31	8	Mia	11
32	8	Samantha	11
33	9	Teddy	6
34	9	Archie	7
35	9	Henry	7
36	9	Sunny	7
37	10	Kylie	8
38	10	Aiden	7
39	10	Agnes	8
40	10	Emanuel	8
41	11	Irma	7
42	11	Otto	8
43	11	Arman	7
44	12	Esther	8
45	12	Minh	8
46	12	Sandy	11
47	12	Sara	10
48	13	Elise	9
49	13	Shahnaz	8
50	13	Marina	9
51	14	Edith	10
52	14	Eloise	10
53	14	Emily	10
54	14	Zoe	10
55	15	Alex	11
56	15	Katia	10
57	15	Manaia	9
58	16	Baxter	10
59	16	Bobby	9
60	16	Bella	10
1	16	Alice	9
\.


--
-- Data for Name: user_credentials; Type: TABLE DATA; Schema: public; Owner: jack
--

COPY public.user_credentials (id, username, password) FROM stdin;
1	admin	$2a$12$jtstvr6PhnVAjUc/4BGNbepGxYJC7yeSzE9aRwW8oFhkgShvLHaa6
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: jack
--

COPY public.venues (id, entry_creation_timestamp, name, address) FROM stdin;
1	2022-08-03 19:19:38.184939	Miramar Community Centre	27 Chelsea Street, Miramar
2	2022-08-03 19:21:09.963027	Newtown School	16 Mein Street, Newtown
3	2022-08-03 19:21:42.559786	Evans Bay Intermediate School	14A Kemp Street, Kilbirnie
4	2022-08-04 14:17:05.379117	Seatoun School	59 Burnham Street, Seatoun
5	2022-08-04 14:17:25.380303	Lyall Bay School	2 Freyberg Street, Lyall Bay
6	2022-08-04 14:18:00.11306	Vogelmorn Bowling Club	93 Mornington Road, Brooklyn
\.


--
-- Name: lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jack
--

SELECT pg_catalog.setval('public.lessons_id_seq', 19, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jack
--

SELECT pg_catalog.setval('public.students_id_seq', 60, true);


--
-- Name: user_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jack
--

SELECT pg_catalog.setval('public.user_credentials_id_seq', 1, true);


--
-- Name: venues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jack
--

SELECT pg_catalog.setval('public.venues_id_seq', 6, true);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: user_credentials user_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.user_credentials
    ADD CONSTRAINT user_credentials_pkey PRIMARY KEY (id);


--
-- Name: user_credentials user_credentials_username_key; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.user_credentials
    ADD CONSTRAINT user_credentials_username_key UNIQUE (username);


--
-- Name: venues venues_name_key; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_name_key UNIQUE (name);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: lessons lessons_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON DELETE CASCADE;


--
-- Name: students students_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jack
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

