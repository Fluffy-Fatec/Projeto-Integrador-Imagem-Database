PGDMP  !                    |            postgres    16.2    16.2     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                        0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    5    postgres    DATABASE        CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';
    DROP DATABASE postgres;
                postgres    false                       0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                   postgres    false    4865                        3079    16384 	   adminpack 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;
    DROP EXTENSION adminpack;
                   false                       0    0    EXTENSION adminpack    COMMENT     M   COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';
                        false    2            �            1259    24634    app_user    TABLE     t  CREATE TABLE public.app_user (
    id integer NOT NULL,
    username character varying(255),
    password character varying(255),
    role character varying(255),
    nome character varying(255),
    email character varying(255),
    celular character varying(255),
    cpf character varying(255),
    creationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.app_user;
       public         heap    postgres    false            �            1259    24633    app_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.app_user_id_seq;
       public          postgres    false    217                       0    0    app_user_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;
          public          postgres    false    216            �            1259    24644    invite    TABLE       CREATE TABLE public.invite (
    id integer NOT NULL,
    email character varying(255),
    solicitante character varying(255),
    tokeninvite character varying(255),
    typeuser character varying(255),
    creationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.invite;
       public         heap    postgres    false            �            1259    24643    invite_id_seq    SEQUENCE     �   CREATE SEQUENCE public.invite_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.invite_id_seq;
       public          postgres    false    219                       0    0    invite_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.invite_id_seq OWNED BY public.invite.id;
          public          postgres    false    218            �            1259    24654    review    TABLE     y  CREATE TABLE public.review (
    id integer NOT NULL,
    review text,
    comentario text,
    sentimento character varying(255),
    titulo character varying(255),
    estado character varying(255),
    cidade character varying(255),
    rua character varying(255),
    lat numeric,
    long numeric,
    creationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.review;
       public         heap    postgres    false            �            1259    24653    review_id_seq    SEQUENCE     �   CREATE SEQUENCE public.review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.review_id_seq;
       public          postgres    false    221                       0    0    review_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.review_id_seq OWNED BY public.review.id;
          public          postgres    false    220            [           2604    24637    app_user id    DEFAULT     j   ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);
 :   ALTER TABLE public.app_user ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    217    216    217            ]           2604    24647 	   invite id    DEFAULT     f   ALTER TABLE ONLY public.invite ALTER COLUMN id SET DEFAULT nextval('public.invite_id_seq'::regclass);
 8   ALTER TABLE public.invite ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    219    219            _           2604    24657 	   review id    DEFAULT     f   ALTER TABLE ONLY public.review ALTER COLUMN id SET DEFAULT nextval('public.review_id_seq'::regclass);
 8   ALTER TABLE public.review ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    220    221            �          0    24634    app_user 
   TABLE DATA           i   COPY public.app_user (id, username, password, role, nome, email, celular, cpf, creationdate) FROM stdin;
    public          postgres    false    217   D       �          0    24644    invite 
   TABLE DATA           ]   COPY public.invite (id, email, solicitante, tokeninvite, typeuser, creationdate) FROM stdin;
    public          postgres    false    219   a       �          0    24654    review 
   TABLE DATA           z   COPY public.review (id, review, comentario, sentimento, titulo, estado, cidade, rua, lat, long, creationdate) FROM stdin;
    public          postgres    false    221   ~                  0    0    app_user_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.app_user_id_seq', 1, false);
          public          postgres    false    216                       0    0    invite_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.invite_id_seq', 1, false);
          public          postgres    false    218            	           0    0    review_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.review_id_seq', 1, false);
          public          postgres    false    220            b           2606    24642    app_user app_user_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.app_user DROP CONSTRAINT app_user_pkey;
       public            postgres    false    217            d           2606    24652    invite invite_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.invite DROP CONSTRAINT invite_pkey;
       public            postgres    false    219            f           2606    24662    review review_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.review DROP CONSTRAINT review_pkey;
       public            postgres    false    221            �      x������ � �      �      x������ � �      �      x������ � �     