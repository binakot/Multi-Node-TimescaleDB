--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Ubuntu 15.4-2.pgdg22.04+1)
-- Dumped by pg_dump version 15.4 (Ubuntu 15.4-2.pgdg22.04+1)

-- Started on 2023-10-13 17:01:03 UTC

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
-- TOC entry 293 (class 1259 OID 22334)
-- Name: _dist_hyper_1_1_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._dist_hyper_1_1_chunk (
    CONSTRAINT constraint_1 CHECK ((("time" >= '2019-12-26 00:00:00+00'::timestamp with time zone) AND ("time" < '2020-01-02 00:00:00+00'::timestamp with time zone))),
    CONSTRAINT constraint_2 CHECK ((_timescaledb_functions.get_partition_hash(imei) >= 1073741823))
)
INHERITS (public.telemetries);


ALTER TABLE _timescaledb_internal._dist_hyper_1_1_chunk OWNER TO postgres;

--
-- TOC entry 7023 (class 0 OID 22334)
-- Dependencies: 293
-- Data for Name: _dist_hyper_1_1_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._dist_hyper_1_1_chunk (imei, "time", latitude, longitude, geography, speed, course) FROM stdin;
\.


--
-- TOC entry 6861 (class 2606 OID 22340)
-- Name: _dist_hyper_1_1_chunk 1_1_telemetries_pkey; Type: CONSTRAINT; Schema: _timescaledb_internal; Owner: postgres
--

ALTER TABLE ONLY _timescaledb_internal._dist_hyper_1_1_chunk
    ADD CONSTRAINT "1_1_telemetries_pkey" PRIMARY KEY (imei, "time");


--
-- TOC entry 6862 (class 1259 OID 22343)
-- Name: _dist_hyper_1_1_chunk_telemetries_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _dist_hyper_1_1_chunk_telemetries_time_idx ON _timescaledb_internal._dist_hyper_1_1_chunk USING btree ("time" DESC);


-- Completed on 2023-10-13 17:01:03 UTC

--
-- PostgreSQL database dump complete
--

