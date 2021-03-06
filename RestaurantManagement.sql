PGDMP         3        	        x         	   projetoBD    11.5    11.5 �    G           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            H           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            I           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            J           1262    24952 	   projetoBD    DATABASE     �   CREATE DATABASE "projetoBD" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Portuguese_Portugal.1252' LC_CTYPE = 'Portuguese_Portugal.1252';
    DROP DATABASE "projetoBD";
             postgres    false            )           1255    34319 +   add_fatura_c_nif(integer, integer, integer) 	   PROCEDURE     E  CREATE PROCEDURE public.add_fatura_c_nif(nif integer, mesa integer, restaurante integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_f integer;
id_prod integer;
id_cl integer;
msg varchar(50);
codigo varchar(10);
cur CURSOR FOR SELECT * FROM pedidos WHERE pedido_mesa = mesa;
rec RECORD;
preco money;
BEGIN		
	SELECT c_id INTO id_cl FROM clientes WHERE c_nif = nif;
		IF id_cl IS null THEN
			CALL criar_cliente('anonimo');
			SELECT c_id INTO id_cl FROM clientes ORDER BY c_id DESC LIMIT 1;
			CALL atualizarnif_cliente(id_cl, nif);
		END IF;
		
	OPEN cur;
	LOOP
		id_f = nextval('faturas_sequencia');
		FETCH cur INTO rec;
		EXIT WHEN NOT FOUND;
		
		SELECT prato_id INTO id_prod FROM pratos WHERE prato_designacao = rec.pedido_produto;
		IF id_prod IS null THEN
			SELECT p_preco INTO preco FROM produtos WHERE p_designacao = rec.pedido_produto;
		ELSE
			SELECT prato_preco INTO preco FROM pratos WHERE prato_designacao = rec.pedido_produto;
		END IF;
		
		INSERT INTO faturas VALUES(id_cl, restaurante, rec.pedido_produto, id_f, preco, nif, LOCALTIMESTAMP(0), 'por pagar', mesa);
		DELETE FROM pedidos WHERE CURRENT OF cur;
	END LOOP;
	CLOSE cur;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 X   DROP PROCEDURE public.add_fatura_c_nif(nif integer, mesa integer, restaurante integer);
       public       postgres    false            0           1255    34320 +   add_fatura_s_nif(integer, integer, integer) 	   PROCEDURE     c  CREATE PROCEDURE public.add_fatura_s_nif(cliente integer, mesa integer, restaurante integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_f integer;
id_prod integer;
id_cl integer;
msg varchar(100);
codigo varchar(10);
cur CURSOR FOR SELECT * FROM pedidos WHERE pedido_mesa = mesa;
rec RECORD;
preco money;
BEGIN		
	OPEN cur;
	LOOP
		id_f = nextval('faturas_sequencia');
		FETCH cur INTO rec;
		EXIT WHEN NOT FOUND;
		
		IF NOT EXISTS (SELECT * FROM clientes WHERE c_id = cliente) THEN 
			CALL criar_cliente('anonimo');
			SELECT MAX (c_id) INTO id_cl FROM clientes;
		ELSE 
			id_cl = cliente;
		END IF;
		
		SELECT prato_id INTO id_prod FROM pratos WHERE prato_designacao = rec.pedido_produto;
		IF id_prod IS null THEN
			SELECT p_preco INTO preco FROM produtos WHERE p_designacao = rec.pedido_produto;
		ELSE
			SELECT prato_preco INTO preco FROM pratos WHERE prato_designacao = rec.pedido_produto;
		END IF;
			
		INSERT INTO faturas(f_cliente, f_data, f_restaurante, f_prod, f_id, f_preco, f_mesa, f_estado) VALUES(id_cl, localtimestamp(0), restaurante, rec.pedido_produto, id_f, preco, mesa, 'por pagar');
		DELETE FROM pedidos WHERE CURRENT OF cur;
	END LOOP;
	CLOSE cur;

	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 100); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 100); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 100); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 \   DROP PROCEDURE public.add_fatura_s_nif(cliente integer, mesa integer, restaurante integer);
       public       postgres    false            �            1255    33636 5   add_ingrediente(character varying, character varying) 	   PROCEDURE     w  CREATE PROCEDURE public.add_ingrediente(prato character varying, ing character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
id_prato integer;
id_prod integer;

BEGIN
	SELECT prato_id INTO id_prato FROM pratos WHERE prato_designacao LIKE prato;
	SELECT p_id INTO id_prod FROM produtos WHERE p_designacao LIKE ing;
	
	INSERT INTO pratos_produtos (prato_id, prod_id) VALUES (id_prato, id_prod);
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 W   DROP PROCEDURE public.add_ingrediente(prato character varying, ing character varying);
       public       postgres    false                       1255    52129 .   adicionar_produtos(character varying, integer) 	   PROCEDURE     /  CREATE PROCEDURE public.adicionar_produtos(prod character varying, qnt integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF EXISTS (SELECT * FROM produtos WHERE p_designacao LIKE prod) THEN
		UPDATE produtos SET p_quantidade = p_quantidade + qnt
		WHERE p_designacao LIKE prod;
		RETURN;
	END IF;
END;
$$;
 O   DROP PROCEDURE public.adicionar_produtos(prod character varying, qnt integer);
       public       postgres    false                       1255    34144 ?   alergia_produtos(character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.alergia_produtos(produto character varying, al character varying, gravidade integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
id_p integer;
id_a integer;
BEGIN
	SELECT p_id INTO id_p FROM produtos WHERE p_designacao LIKE produto;
	SELECT a_id INTO id_a FROM alergias WHERE a_designacao LIKE al;

	IF id_a NOT IN (SELECT alergia FROM prod_alergias WHERE prod_id = id_p) THEN
		INSERT INTO prod_alergias VALUES(id_p, id_a, gravidade);
	END IF;
END; 
$$;
 l   DROP PROCEDURE public.alergia_produtos(produto character varying, al character varying, gravidade integer);
       public       postgres    false            �            1255    33730 &   atualizarnif_cliente(integer, integer) 	   PROCEDURE     �   CREATE PROCEDURE public.atualizarnif_cliente(cl_id integer, cl_nif integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE clientes SET c_nif = cl_nif WHERE c_id = cl_id;
END;
$$;
 K   DROP PROCEDURE public.atualizarnif_cliente(cl_id integer, cl_nif integer);
       public       postgres    false            
           1255    52127 1   atualizarnome_cliente(integer, character varying) 	   PROCEDURE     �   CREATE PROCEDURE public.atualizarnome_cliente(cl_id integer, cl_nome character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE clientes SET c_nome = cl_nome WHERE c_id = cl_id;
END;
$$;
 W   DROP PROCEDURE public.atualizarnome_cliente(cl_id integer, cl_nome character varying);
       public       postgres    false                       1255    52128 0   atualizarobs_cliente(integer, character varying) 	   PROCEDURE     �   CREATE PROCEDURE public.atualizarobs_cliente(cl_id integer, cl_obs character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE clientes SET c_descricao = cl_obs WHERE c_id = cl_id;
END;
$$;
 U   DROP PROCEDURE public.atualizarobs_cliente(cl_id integer, cl_obs character varying);
       public       postgres    false            2           1255    52041 .   atualizarpreco_prato(character varying, money) 	   PROCEDURE     �   CREATE PROCEDURE public.atualizarpreco_prato(prato character varying, preco money)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE pratos SET prato_preco = preco WHERE prato_designacao LIKE prato;
END;
$$;
 R   DROP PROCEDURE public.atualizarpreco_prato(prato character varying, preco money);
       public       postgres    false            9           1255    52057    cancelar_pedido(integer) 	   PROCEDURE       CREATE PROCEDURE public.cancelar_pedido(id_pedido integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
tr varchar(30);
prod varchar(30);
pr integer;
qtd INTEGER;
cur CURSOR FOR SELECT * FROM pratos_produtos;
rec RECORD;
BEGIN
	SELECT pedido_tipo INTO tr FROM pedidos WHERE pedido_id = id_pedido;
	SELECT pedido_produto INTO prod FROM pedidos WHERE pedido_id = id_pedido;

	IF tr LIKE 'Prato' THEN
		SELECT prato_id INTO pr FROM pratos WHERE prato_designacao LIKE prod;
		OPEN cur;
		LOOP
			FETCH cur INTO rec;
			EXIT WHEN NOT FOUND;
			IF rec.prato_id = pr THEN 
				SELECT p_quantidade INTO qtd 
				FROM produtos
				WHERE p_id = rec.prod_id;
				
				UPDATE produtos 
				SET p_quantidade = qtd + 1
				WHERE p_id = rec.prod_id;
			END IF;
		END LOOP;
		CLOSE cur;
	ELSE
		SELECT p_id INTO pr FROM produtos WHERE p_designacao LIKE prod;
		SELECT p_quantidade INTO qtd 
		FROM produtos
		WHERE p_id = pr;
				
		UPDATE produtos 
		SET p_quantidade = qtd + 1
		WHERE p_id = pr;
	END IF;
	
	DELETE FROM pedidos 
	WHERE pedido_id = id_pedido;
END;
$$;
 :   DROP PROCEDURE public.cancelar_pedido(id_pedido integer);
       public       postgres    false            '           1255    52038     confirmar_criacao_conta(integer) 	   PROCEDURE     �  CREATE PROCEDURE public.confirmar_criacao_conta(id_conta integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
	new_user varchar(30);
	pass varchar(100);
	estatuto integer;
	rest integer;
BEGIN
	IF EXISTS (SELECT * FROM pedidos_registo_conta WHERE pr_id = id_conta) THEN
		SELECT pr_user INTO new_user
		FROM pedidos_registo_conta WHERE pr_id = id_conta;
		SELECT pr_password INTO pass
		FROM pedidos_registo_conta WHERE pr_id = id_conta;
		SELECT pr_admin INTO estatuto
		FROM pedidos_registo_conta WHERE pr_id = id_conta;
		SELECT pr_restaurante INTO rest
		FROM pedidos_registo_conta WHERE pr_id = id_conta;
		
		INSERT INTO login VALUES(id_conta, new_user, pass, estatuto, rest);
		DELETE FROM pedidos_registo_conta WHERE pr_id = id_conta;
	END IF;
END;
$$;
 A   DROP PROCEDURE public.confirmar_criacao_conta(id_conta integer);
       public       postgres    false                       1255    52120    consultar_alertastock(integer)    FUNCTION       CREATE FUNCTION public.consultar_alertastock(restaurante integer) RETURNS TABLE(prod character varying, quantidade integer, minimo integer, d date, fornecedor character varying, contacto integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT p_designacao, p_quantidade, p_stockminimo, data, fornecedor_designacao, fornecedor_contacto
	FROM alerta_stock
		JOIN produtos ON alerta_stock.produto = p_id
		JOIN fornecedores ON alerta_stock.fornecedor = fornecedor_id
	ORDER BY alerta_stock.data;
END;
$$;
 A   DROP FUNCTION public.consultar_alertastock(restaurante integer);
       public       postgres    false                       1255    52124    consultar_clientes(integer)    FUNCTION     &  CREATE FUNCTION public.consultar_clientes(restaurante integer) RETURNS TABLE(id_c integer, nome character varying, nif integer, descricao character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT c_id, c_nome, c_nif, c_descricao
	FROM clientes
	ORDER BY c_id desc;
END;
$$;
 >   DROP FUNCTION public.consultar_clientes(restaurante integer);
       public       postgres    false            /           1255    52033 "   consultar_pedidos_registo(integer)    FUNCTION     u  CREATE FUNCTION public.consultar_pedidos_registo(restaurante integer) RETURNS TABLE(id_pr integer, data_pr date, funcao integer, user_pr character varying, pass_pr character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN


	RETURN QUERY (
		SELECT pr_id, pr_data, pr_admin, pr_user, pr_password 
		FROM pedidos_registo_conta 
		WHERE pr_restaurante = restaurante);
END;
$$;
 E   DROP FUNCTION public.consultar_pedidos_registo(restaurante integer);
       public       postgres    false                       1255    33807 )   criar_alergia(character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.criar_alergia(alergia character varying, gravidade integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
id_alergia integer;
msg VARCHAR(30);
codigo integer;
BEGIN
	SELECT a_id INTO id_alergia FROM alergias WHERE a_designacao LIKE alergia;
	IF id_alergia IS null THEN 
		id_alergia = nextval('alergias_sequencia');
		INSERT INTO alergias VALUES(id_alergia, alergia, gravidade);
	ELSE
		RAISE EXCEPTION 'Já existe essa alergia na base de dados!';
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 S   DROP PROCEDURE public.criar_alergia(alergia character varying, gravidade integer);
       public       postgres    false                       1255    33726     criar_cliente(character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.criar_cliente(nome character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
cl integer;
BEGIN		
	cl = nextval('clientes_sequencia');
	INSERT INTO clientes(c_id, c_nome) VALUES(cl, nome);
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 =   DROP PROCEDURE public.criar_cliente(nome character varying);
       public       postgres    false            ,           1255    52031 M   criar_conta(character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.criar_conta(new_user character varying, pass character varying, funcao character varying, restaurante integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	data_registo date;
	id_conta integer;
BEGIN
	IF EXISTS (SELECT * FROM login WHERE login_user = new_user) THEN
		RETURN 0;
	ELSE
		SELECT CURRENT_DATE INTO data_registo;
		id_conta = nextval('login_sequencia');
		IF funcao LIKE 'Administrador' THEN
			INSERT INTO pedidos_registo_conta VALUES(id_conta, data_registo, new_user, pass, restaurante, 1);
		ELSE
			INSERT INTO pedidos_registo_conta VALUES(id_conta, data_registo, new_user, pass, restaurante, 0);
		END IF;
	END IF;
	RETURN 1;
END;
$$;
 �   DROP FUNCTION public.criar_conta(new_user character varying, pass character varying, funcao character varying, restaurante integer);
       public       postgres    false            �            1255    33634 %   criar_prato(character varying, money) 	   PROCEDURE     g  CREATE PROCEDURE public.criar_prato(nome character varying, preco money)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
id_p integer;
BEGIN
	IF nome IN (SELECT prato_designacao FROM pratos) THEN
		RAISE EXCEPTION 'Prato já criado existente';
	ELSE
		id_p = nextval('pratos_sequencia');
		INSERT INTO pratos (prato_id, prato_designacao, prato_preco) VALUES (id_p, nome, preco);
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 H   DROP PROCEDURE public.criar_prato(nome character varying, preco money);
       public       postgres    false            6           1255    50340 �   criar_produto(character varying, character varying, character varying, money, double precision, integer, character varying, integer) 	   PROCEDURE     '
  CREATE PROCEDURE public.criar_produto(confecao character varying, tiporefeicao character varying, tipoproduto character varying, preco money, iva double precision, quantidade integer, designacao character varying, stockminimo integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_prod integer;
id_tr integer;
id_tp integer;
msg varchar(50);
codigo varchar(10);
conf integer;
BEGIN
	IF EXISTS (SELECT * FROM produtos WHERE p_designacao LIKE designacao) THEN
		UPDATE produtos SET p_quantidade = p_quantidade + quantidade WHERE p_designacao LIKE designacao;
		RETURN;
	END IF;
	
	IF confecao NOT IN (SELECT zconf_designacao FROM zonas_confecao) THEN
		RAISE EXCEPTION 'Zona de confeção não existente';
	ELSE
		IF tipoRefeicao NOT IN(SELECT tr_designacao FROM tipos_refeicao) THEN
			RAISE EXCEPTION 'Tipo de refeição não existente';
		ELSE		
			IF confecao LIKE 'Cozinha' THEN
				conf = 1;
			ELSE
				IF confecao LIKE 'Balcão' THEN
					conf = 2;
				END IF;
			END IF;
			IF tiporefeicao LIKE 'Prato' THEN
				id_tr = 1;
			ELSE
				IF tiporefeicao LIKE 'Vegetariano' THEN
					id_tr = 2;
				ELSE
					IF tiporefeicao LIKE 'Sobremesa' THEN
						id_tr = 3;
					ELSE
						IF tiporefeicao LIKE 'Entrada' THEN
							id_tr = 4;
						ELSE
							IF tiporefeicao LIKE 'Snack' THEN
								id_tr = 5;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			IF tipoproduto LIKE 'Bebida' THEN
				id_tp = 1;
			ELSE
				IF tipoproduto LIKE 'Peixe' THEN
					id_tp = 2;
				ELSE
					IF tipoproduto LIKE 'Carne' THEN
						id_tp = 3;
					ELSE
						IF tipoproduto LIKE 'Acompanhamento' THEN
							id_tp = 4;
						ELSE
							IF tipoproduto LIKE 'Fruta' THEN
								id_tp = 5;
							ELSE
								IF tipoproduto LIKE 'Salgados' THEN
									id_tp = 6;
								ELSE
									id_tp = 7;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			id_prod = nextval('produtos_sequencia');
			INSERT INTO produtos (zconf_id, tr_id, tp_id, p_id, p_preco, p_iva, p_quantidade, p_designacao, p_stockminimo) VALUES (conf, id_tr, id_tp, id_prod, preco, iva, quantidade, designacao, stockminimo);
		END IF;
	END IF;
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 �   DROP PROCEDURE public.criar_produto(confecao character varying, tiporefeicao character varying, tipoproduto character varying, preco money, iva double precision, quantidade integer, designacao character varying, stockminimo integer);
       public       postgres    false            4           1255    48747 ^   criar_reserva(date, integer, character varying, character varying, integer, character varying) 	   PROCEDURE     E  CREATE PROCEDURE public.criar_reserva(r_data date, npessoas integer, cliente character varying, funcionario character varying, restaurante integer, descricao character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_reserva integer;
msg varchar(50);
codigo varchar(10);
cl integer;
f integer;
BEGIN		
	select f_id into f from funcionarios WHERE f_nome LIKE funcionario;
	IF (select SUM(reserva_pessoas) from reservas WHERE reserva_restaurante = restaurante AND reserva_data = r_data) > 20 THEN
		RAISE EXCEPTION 'Limite de reservas máximo atingido';
	ELSE
		SELECT c_id INTO cl FROM clientes WHERE c_nome = cliente;
		IF cl IS null THEN
			CALL criar_cliente(cliente);
			SELECT c_id INTO cl FROM clientes WHERE c_nome = cliente;
		END IF;
			id_reserva = nextval('reservas_sequencia');
			INSERT INTO reservas VALUES (id_reserva, r_data, npessoas, cl, f, restaurante, descricao);
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 �   DROP PROCEDURE public.criar_reserva(r_data date, npessoas integer, cliente character varying, funcionario character varying, restaurante integer, descricao character varying);
       public       postgres    false                       1255    43016    gravar_historico_ementa()    FUNCTION     �  CREATE FUNCTION public.gravar_historico_ementa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
	historico_id integer;
	he_data DATE;
	preco money;
BEGIN
	historico_id = nextval('historico_sequencia');
	SELECT prato_preco INTO preco
	FROM pratos
	WHERE prato_id = NEW.e_prato;
	
	SELECT CURRENT_DATE into he_data;
	INSERT INTO historico_ementa VALUES(historico_id, NEW.r_id, he_data, NEW.e_prato, preco, NEW.e_diasemanal);
	RETURN NEW;
END; 
$$;
 0   DROP FUNCTION public.gravar_historico_ementa();
       public       postgres    false                        1255    50692    gravarxml(integer)    FUNCTION     o  CREATE FUNCTION public.gravarxml(restaurante integer) RETURNS xml
    LANGUAGE plpgsql
    AS $$
DECLARE
 output XML;
BEGIN
		SELECT XMLELEMENT(name BACKUP,
 					(SELECT XMLAGG(XMLELEMENT(name Prato, 
						XMLFOREST(prato_designacao AS nome, 
								  prato_preco AS Preco)))),
					(SELECT XMLAGG(XMLELEMENT(name Produto,
						XMLFOREST(p_designacao AS Nome, 
								  p_preco AS Preco, 
								  p_iva AS IVA, 
								  p_quantidade AS Stock,
								  p_stockminimo AS StockMinimo,
								  fornecedor_designacao AS Fornecedor)))
					FROM produtos JOIN fornecedores 
					 ON produtos.tp_id = fornecedores.fornecedor_tipo),
	   				(SELECT XMLAGG(XMLELEMENT(name Fatura,
						XMLFOREST(f_cliente AS Id_cliente, 
								  f_nif AS NIF, 
								  f_preco AS Preco, 
								  f_data AS "Data")))
					FROM faturas),
					(SELECT XMLAGG(XMLELEMENT(name "HistoricoEmentas",
						XMLFOREST(prato_designacao AS Prato, 
								  h_preco AS Preco, 
								  he_data AS "Data")))
					FROM historico_ementa JOIN pratos 
					 ON historico_ementa.h_prato = pratos.prato_id))
		FROM pratos INTO output;
	RETURN output;
END;
$$;
 5   DROP FUNCTION public.gravarxml(restaurante integer);
       public       postgres    false                       1255    34790    inserir_alerta_stock()    FUNCTION     �  CREATE FUNCTION public.inserir_alerta_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
prod integer;
forn integer;
BEGIN
	prod = NEW.p_id;
	SELECT fornecedor_id INTO forn 
	FROM fornecedores
	WHERE fornecedor_tipo = NEW.tr_id;
	
	IF NEW.p_quantidade < NEW.p_stockminimo THEN 
		DELETE FROM alerta_stock WHERE produto = NEW.p_id;
		INSERT INTO alerta_stock values(prod, localtimestamp(0), forn);
	END IF;
	return NEW;
END; 
$$;
 -   DROP FUNCTION public.inserir_alerta_stock();
       public       postgres    false                       1255    33754 V   inserir_prato_ementa(character varying, character varying, character varying, integer) 	   PROCEDURE     -  CREATE PROCEDURE public.inserir_prato_ementa(prato character varying, descricao character varying, diasemanal character varying, restaurante integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
pr_id integer;
ementa_id integer;
BEGIN
	SELECT prato_id INTO pr_id FROM pratos WHERE prato_designacao LIKE prato;
	IF pr_id IS NOT null THEN
		ementa_id = nextval('ementas_sequencia');
		INSERT INTO ementa VALUES (ementa_id, pr_id, descricao, diaSemanal, restaurante);
	ELSE
		RAISE EXCEPTION 'Ocorreu algum erro na criação do prato. Volte a criar e depois adicione à ementa';
	END IF;
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 �   DROP PROCEDURE public.inserir_prato_ementa(prato character varying, descricao character varying, diasemanal character varying, restaurante integer);
       public       postgres    false            &           1255    52024 +   login(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.login(utilizador character varying, pass character varying) RETURNS TABLE(estatuto integer, restaurante integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF EXISTS (SELECT * FROM login WHERE login_user LIKE utilizador AND login_password LIKE pass) THEN
		RETURN QUERY (
			SELECT login_admin, login_restaurante 
			FROM login 
			WHERE login_user LIKE utilizador AND login_password LIKE pass);
	END IF;
END;
$$;
 R   DROP FUNCTION public.login(utilizador character varying, pass character varying);
       public       postgres    false                       1255    34281    mesa_desocupada()    FUNCTION     �   CREATE FUNCTION public.mesa_desocupada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
mesa integer;
BEGIN
	mesa = OLD.pedido_mesa;
	UPDATE mesas
	SET m_estado = 0
	WHERE m_id = mesa;	
	return null;
END; 
$$;
 (   DROP FUNCTION public.mesa_desocupada();
       public       postgres    false            	           1255    34192    mesa_ocupada()    FUNCTION     �   CREATE FUNCTION public.mesa_ocupada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
mesa integer;
BEGIN
	mesa = NEW.pedido_mesa;
	UPDATE mesas
	SET m_estado = 1
	WHERE m_id = mesa;	
	
	return NEW;
END; 
$$;
 %   DROP FUNCTION public.mesa_ocupada();
       public       postgres    false                       1255    34773    pedido_stock()    FUNCTION     z  CREATE FUNCTION public.pedido_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
tr varchar(30);
pr integer;
prato varchar(30);
qtd INTEGER;
cur CURSOR FOR SELECT * FROM pratos_produtos;
rec RECORD;
BEGIN
	tr = NEW.pedido_tipo;
	prato = NEW.pedido_produto;
	
	SELECT prato_id INTO pr 
	FROM pratos 
	WHERE prato_designacao LIKE prato;
	
	IF tr LIKE 'Prato' THEN
		OPEN cur;
		LOOP
			FETCH cur INTO rec;
			EXIT WHEN NOT FOUND;
			IF rec.prato_id = pr THEN 
				SELECT p_quantidade INTO qtd 
				FROM produtos
				WHERE p_id = rec.prod_id;
				
				UPDATE produtos 
				SET p_quantidade = qtd - 1
				WHERE p_id = rec.prod_id;
			END IF;
		END LOOP;
		CLOSE cur;
		RETURN NEW;
	ELSE 
		SELECT p_quantidade INTO qtd 
		FROM produtos
		WHERE p_designacao LIKE prato;
	
		UPDATE produtos 
		SET p_quantidade = qtd - 1
		WHERE p_designacao LIKE prato;
	END IF;
	return NEW;
END;$$;
 %   DROP FUNCTION public.pedido_stock();
       public       postgres    false            1           1255    42308    registar_pagamento(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.registar_pagamento(fa_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE faturas 
	SET f_estado = 'pago' 
	WHERE f_id = fa_id;
END;
$$;
 9   DROP PROCEDURE public.registar_pagamento(fa_id integer);
       public       postgres    false            8           1255    33870 Q   registar_pedido(character varying, character varying, integer, character varying) 	   PROCEDURE       CREATE PROCEDURE public.registar_pedido(tiporefeicao character varying, prod character varying, mesa integer, funcionario character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_pedido integer;
id_prod integer;
id_tr integer;
id_func integer;
msg varchar(50);
codigo varchar(10);
BEGIN		

	SELECT tr_id INTO id_tr FROM tipos_refeicao WHERE tr_designacao LIKE tiporefeicao;
	SELECT f_id INTO id_func FROM funcionarios WHERE f_nome LIKE funcionario;
	IF id_tr = 1 THEN
		SELECT prato_id INTO id_prod FROM pratos WHERE prato_designacao LIKE prod;
	ELSE
		SELECT p_id INTO id_prod FROM produtos WHERE p_designacao LIKE prod;
		SELECT tr_id INTO id_tr FROM produtos WHERE p_designacao LIKE prod;
	END IF;
		
	id_pedido = nextval('pedidos_sequencia');
	INSERT INTO pedidos VALUES (id_pedido, id_tr, prod, localtimestamp(0), mesa, id_func);
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 �   DROP PROCEDURE public.registar_pedido(tiporefeicao character varying, prod character varying, mesa integer, funcionario character varying);
       public       postgres    false                       1255    52130    remover_alerta_stock()    FUNCTION       CREATE FUNCTION public.remover_alerta_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
prod integer;
BEGIN
	prod = NEW.p_id;
	
	IF NEW.p_quantidade > NEW.p_stockminimo THEN 
		DELETE FROM alerta_stock WHERE produto = NEW.p_id;
	END IF;
	return NEW;
END; 
$$;
 -   DROP FUNCTION public.remover_alerta_stock();
       public       postgres    false            (           1255    52039    remover_pedido_conta(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.remover_pedido_conta(id_conta integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM pedidos_registo_conta WHERE pr_id = id_conta;
END;
$$;
 >   DROP PROCEDURE public.remover_pedido_conta(id_conta integer);
       public       postgres    false            -           1255    37355     remover_prato(character varying) 	   PROCEDURE     Q  CREATE PROCEDURE public.remover_prato(prato character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
id_prato integer;
BEGIN
	SELECT prato_id INTO id_prato FROM pratos WHERE prato_designacao LIKE prato;
	IF id_prato IN (SELECT e_prato FROM ementa) THEN
		DELETE FROM ementa WHERE e_prato = id_prato;
	END IF;
	DELETE FROM pratos WHERE prato_id = id_prato;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 >   DROP PROCEDURE public.remover_prato(prato character varying);
       public       postgres    false                       1255    42647    remover_prato_ementa(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.remover_prato_ementa(id_e integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM ementa 
	WHERE e_id = id_e;
END;
$$;
 :   DROP PROCEDURE public.remover_prato_ementa(id_e integer);
       public       postgres    false            5           1255    36304 "   remover_produto(character varying) 	   PROCEDURE       CREATE PROCEDURE public.remover_produto(produto character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);
id_prod integer;
BEGIN
	SELECT p_id INTO id_prod FROM produtos WHERE p_designacao LIKE produto;
	DELETE FROM pratos_produtos WHERE prod_id = id_prod;
	DELETE FROM produtos WHERE p_id = id_prod;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 B   DROP PROCEDURE public.remover_produto(produto character varying);
       public       postgres    false            �            1255    42557    reset_ementa(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.reset_ementa(restaurante integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM ementa 
	WHERE r_id = restaurante;
END;
$$;
 9   DROP PROCEDURE public.reset_ementa(restaurante integer);
       public       postgres    false            7           1255    52040 %   ver_detalhes_prato(character varying)    FUNCTION       CREATE FUNCTION public.ver_detalhes_prato(prato character varying) RETURNS TABLE(preco money, ingredientes character varying, alergias character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	ing_list varchar(200);
	alergia_list VARCHAR(100);
	al varchar(30);
	p_id integer;
	cur CURSOR FOR SELECT * FROM produtos;
	rec RECORD;
	i integer;
	x integer;
BEGIN
	SELECT prato_id INTO p_id FROM pratos WHERE prato_designacao LIKE prato;
	i = 0;
	x = 0;
	OPEN cur;
	LOOP
		FETCH cur INTO rec;
		EXIT WHEN NOT FOUND;
		IF rec.p_id IN (SELECT prod_id FROM pratos_produtos WHERE prato_id = p_id) THEN
			i = i + 1;
			IF rec.p_id IN (SELECT prod_id FROM prod_alergias) THEN 
				x = x + 1;
				SELECT a_designacao INTO al 
				FROM alergias JOIN prod_alergias ON a_id = alergia
				WHERE prod_alergias.prod_id = rec.p_id;
				IF x != 0 THEN
				 --SELECT concat_ws(', ', alergia_list, al) into alergia_list;
				 select concat( al,'(', rec.p_designacao, ')') into alergia_list;
				ELSE 
					alergia_list = al;
				END IF;
			END IF;
			IF i != 0 THEN
			 SELECT concat_ws(', ', ing_list, rec.p_designacao) INTO ing_list;
			ELSE 
				ing_list = rec.p_designacao;
			END IF;
		END IF;
	END LOOP;
	CLOSE cur;
	
	RETURN QUERY
		SELECT prato_preco, ing_list, alergia_list FROM pratos WHERE prato_id = p_id;

END; $$;
 B   DROP FUNCTION public.ver_detalhes_prato(prato character varying);
       public       postgres    false                       1255    42628    ver_ementa(integer)    FUNCTION     w  CREATE FUNCTION public.ver_ementa(restaurante integer) RETURNS TABLE(id_e integer, dia character varying, prato character varying, preco money)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT DISTINCT e_id, e_diasemanal, prato_designacao, prato_preco
	FROM pratos 
		JOIN ementa ON e_prato = prato_id
	WHERE r_id = restaurante
	ORDER BY prato_designacao;
END;
$$;
 6   DROP FUNCTION public.ver_ementa(restaurante integer);
       public       postgres    false            #           1255    41075    ver_ementa_pratos(integer)    FUNCTION       CREATE FUNCTION public.ver_ementa_pratos(restaurante integer) RETURNS TABLE(prato character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT DISTINCT prato_designacao
	FROM pratos 
		JOIN ementa ON e_prato = prato_id
	WHERE r_id = restaurante;
	END;
$$;
 =   DROP FUNCTION public.ver_ementa_pratos(restaurante integer);
       public       postgres    false            $           1255    41462    ver_fatura_cliente(integer)    FUNCTION     �  CREATE FUNCTION public.ver_fatura_cliente(mesa integer) RETURNS TABLE(cliente character varying, nif integer, data timestamp without time zone, consumo character varying, preco money)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	nome varchar(30);
BEGIN

	RETURN QUERY(
		SELECT c_nome, f_nif, f_data, f_prod, f_preco
		FROM faturas JOIN clientes
			ON f_cliente = c_id
		WHERE f_mesa = mesa	AND f_estado = 'por pagar'
	);
END;
$$;
 7   DROP FUNCTION public.ver_fatura_cliente(mesa integer);
       public       postgres    false            +           1255    42230    ver_faturas(integer)    FUNCTION     �  CREATE FUNCTION public.ver_faturas(restaurante integer) RETURNS TABLE(if_f integer, cliente character varying, nif integer, data timestamp without time zone, consumo character varying, preco money, estado character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	nome varchar(30);
BEGIN

	RETURN QUERY(
		SELECT f_id, c_nome, f_nif, f_data, f_prod, f_preco, f_estado
		FROM faturas JOIN clientes
			ON f_cliente = c_id
		WHERE f_restaurante = restaurante);
END;
$$;
 7   DROP FUNCTION public.ver_faturas(restaurante integer);
       public       postgres    false            *           1255    42007    ver_faturas_por_pagar(integer)    FUNCTION     �  CREATE FUNCTION public.ver_faturas_por_pagar(restaurante integer) RETURNS TABLE(if_f integer, cliente character varying, nif integer, data timestamp without time zone, consumo character varying, preco money)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	nome varchar(30);
BEGIN

	RETURN QUERY(
		SELECT f_id, c_nome, f_nif, f_data, f_prod, f_preco
		FROM faturas JOIN clientes
			ON f_cliente = c_id
		WHERE f_restaurante = restaurante	AND 
			  f_estado = 'por pagar');
END;
$$;
 A   DROP FUNCTION public.ver_faturas_por_pagar(restaurante integer);
       public       postgres    false            .           1255    42231    ver_faturas_semana(integer)    FUNCTION     �  CREATE FUNCTION public.ver_faturas_semana(restaurante integer) RETURNS TABLE(if_f integer, cliente character varying, nif integer, data timestamp without time zone, consumo character varying, preco money, estado character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	nome varchar(30);
BEGIN

	RETURN QUERY(
		SELECT f_id, c_nome, f_nif, f_data, f_prod, f_preco, f_estado
		FROM faturas JOIN clientes
			ON f_cliente = c_id
		WHERE f_restaurante = restaurante	AND 
			  f_data > CURRENT_DATE - 7);
END;
$$;
 >   DROP FUNCTION public.ver_faturas_semana(restaurante integer);
       public       postgres    false            �            1255    33846    ver_funcionarios(integer)    FUNCTION     �   CREATE FUNCTION public.ver_funcionarios(r integer) RETURNS TABLE(funciorario character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	SELECT f_nome FROM ver_funcionarios WHERE f_restaurante = r;
END;
$$;
 2   DROP FUNCTION public.ver_funcionarios(r integer);
       public       postgres    false            %           1255    51994    ver_historicoementa(integer)    FUNCTION     ~  CREATE FUNCTION public.ver_historicoementa(restaurante integer) RETURNS TABLE(p character varying, dia money, prato date, diasemanal character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT DISTINCT prato_designacao, h_preco, he_data, h_diaementa
	FROM pratos 
		JOIN historico_ementa ON h_prato = prato_id
	WHERE r_id = restaurante
	ORDER BY he_data;
END;
$$;
 ?   DROP FUNCTION public.ver_historicoementa(restaurante integer);
       public       postgres    false                       1255    33647 )   ver_ingredientes_prato(character varying)    FUNCTION     k  CREATE FUNCTION public.ver_ingredientes_prato(prato character varying) RETURNS TABLE(ingredientes character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);

BEGIN
	RETURN QUERY(
		SELECT p_designacao
		FROM produtos JOIN pratos_produtos
			ON produtos.p_id = pratos_produtos.prod_id 
		WHERE pratos_produtos.prato_id = (SELECT prato_id FROM pratos WHERE prato_designacao = prato)
		);
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 F   DROP FUNCTION public.ver_ingredientes_prato(prato character varying);
       public       postgres    false                       1255    33648 -   ver_ingredientes_restantes(character varying)    FUNCTION     �  CREATE FUNCTION public.ver_ingredientes_restantes(prato character varying) RETURNS TABLE(ingredientes character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
msg varchar(50);
codigo varchar(10);

BEGIN
	RETURN QUERY(
		SELECT p_designacao FROM produtos WHERE p_id NOT IN (
		SELECT p_id FROM produtos JOIN pratos_produtos
			ON produtos.p_id = pratos_produtos.prod_id 
		WHERE pratos_produtos.prato_id = (SELECT prato_id FROM pratos WHERE prato_designacao = prato)));
			
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 J   DROP FUNCTION public.ver_ingredientes_restantes(prato character varying);
       public       postgres    false                       1255    33828    ver_mesas_restaurante(integer)    FUNCTION     ;  CREATE FUNCTION public.ver_mesas_restaurante(restaurante integer) RETURNS TABLE(mesas integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_restaurante integer;
msg varchar(50);
codigo varchar(10);
BEGIN		

	IF restaurante IN ( SELECT r_id FROM restaurantes WHERE r_id = restaurante) THEN
		RETURN QUERY 
			SELECT m_id FROM mesas WHERE m_restaurante = restaurante;
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 A   DROP FUNCTION public.ver_mesas_restaurante(restaurante integer);
       public       postgres    false                       1255    33822 .   ver_mesas_restaurante_estado(integer, integer)    FUNCTION     h  CREATE FUNCTION public.ver_mesas_restaurante_estado(restaurante integer, estado integer) RETURNS TABLE(mesas integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_restaurante integer;
msg varchar(50);
codigo varchar(10);
BEGIN		

	IF restaurante IN ( SELECT r_id FROM restaurantes WHERE r_id = restaurante) THEN
		RETURN QUERY 
			SELECT m_id FROM mesas WHERE m_restaurante = restaurante AND m_estado = estado;
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN no_data_found THEN
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
		WHEN OTHERS THEN 
			msg := substr(SQLERRM, 1, 50); 
			codigo := SQLSTATE; 
			INSERT INTO erros VALUES(msg,codigo, CURRENT_TIMESTAMP);
END;
$$;
 X   DROP FUNCTION public.ver_mesas_restaurante_estado(restaurante integer, estado integer);
       public       postgres    false                        1255    34074    ver_nome_alergias()    FUNCTION     �   CREATE FUNCTION public.ver_nome_alergias() RETURNS TABLE(alergia character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	REFRESH MATERIALIZED VIEW ver_nome_alergias;
	RETURN QUERY
		SELECT * FROM ver_nome_alergias;
END; 
$$;
 *   DROP FUNCTION public.ver_nome_alergias();
       public       postgres    false                       1255    33875    ver_nome_produtos()    FUNCTION     �   CREATE FUNCTION public.ver_nome_produtos() RETURNS TABLE(produto character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	REFRESH MATERIALIZED VIEW ver_nome_produtos;
	RETURN QUERY
		SELECT * FROM ver_nome_produtos;
END; $$;
 *   DROP FUNCTION public.ver_nome_produtos();
       public       postgres    false            "           1255    40178    ver_nome_restaurantes()    FUNCTION     �   CREATE FUNCTION public.ver_nome_restaurantes() RETURNS TABLE(restaurante character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		SELECT r_designacao FROM restaurantes;
END; $$;
 .   DROP FUNCTION public.ver_nome_restaurantes();
       public       postgres    false            3           1255    41565    ver_pedidos(integer)    FUNCTION       CREATE FUNCTION public.ver_pedidos(restaurante integer) RETURNS TABLE(id_p integer, produto character varying, pdata timestamp without time zone, mesa integer, funcionario character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE  
	mesa_min integer;
	mesa_max integer;
BEGIN
	IF restaurante = 1 THEN
		mesa_min = 1;
		mesa_max = 9;
	ELSE
		IF restaurante = 2 THEN
			mesa_min = 10;
			mesa_max = 25;
		ELSE
			IF restaurante = 2 THEN
				mesa_min = 26;
				mesa_max = 35;
			ELSE
				mesa_min = 36;
				mesa_max = 50;
			END IF;
		END IF;
	END IF;
	RETURN QUERY
	SELECT pedido_id, pedido_produto, pedido_data, pedido_mesa, f_nome
	FROM pedidos 
	JOIN funcionarios ON pedidos.pedido_funcionario = funcionarios.f_id
	WHERE pedido_mesa >= mesa_min AND pedido_mesa <= mesa_max;
END;
$$;
 7   DROP FUNCTION public.ver_pedidos(restaurante integer);
       public       postgres    false                       1255    33798    ver_pratos()    FUNCTION     �   CREATE FUNCTION public.ver_pratos() RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM ver_pratos;
END;
$$;
 #   DROP FUNCTION public.ver_pratos();
       public       postgres    false                       1255    34300    ver_pratos_alergias()    FUNCTION       CREATE FUNCTION public.ver_pratos_alergias() RETURNS TABLE(prato character varying, produto character varying, alergias character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	REFRESH MATERIALIZED VIEW pratos_com_alergias;
	RETURN QUERY
		SELECT * FROM pratos_com_alergias;
END; 
$$;
 ,   DROP FUNCTION public.ver_pratos_alergias();
       public       postgres    false            !           1255    35454 "   ver_preco_prato(character varying)    FUNCTION     �   CREATE FUNCTION public.ver_preco_prato(prato character varying) RETURNS TABLE(preco money)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	SELECT prato_preco
	FROM pratos
	WHERE prato_designacao LIKE prato;
END;
$$;
 ?   DROP FUNCTION public.ver_preco_prato(prato character varying);
       public       postgres    false            �            1255    33818    ver_produtos()    FUNCTION       CREATE FUNCTION public.ver_produtos() RETURNS TABLE(nome character varying, "preço" money, iva double precision, stock integer, "zona_confeção" character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY (
		SELECT * FROM ver_produtos
	);
END;
$$;
 %   DROP FUNCTION public.ver_produtos();
       public       postgres    false                       1255    49537 .   ver_receita_diaria(character varying, integer)    FUNCTION     5  CREATE FUNCTION public.ver_receita_diaria(d character varying, r integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE 
	TOTAL MONEY;
BEGIN
	SELECT SUM(f_preco) into TOTAL
	FROM faturas
	WHERE to_char(f_data,'YYYY-MM-DD') LIKE d AND f_estado LIKE 'pago' AND f_restaurante = r;
	RETURN TOTAL;
END;
$$;
 I   DROP FUNCTION public.ver_receita_diaria(d character varying, r integer);
       public       postgres    false                       1255    50011 "   ver_receita_media_almocos(integer)    FUNCTION     
  CREATE FUNCTION public.ver_receita_media_almocos(r integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE 
	TOTAL MONEY;
	n integer;
BEGIN
	SELECT SUM (f_preco) into TOTAL
	FROM faturas
	WHERE date_part('hour', f_data) > 10 AND 
		date_part('hour', f_data) < 15 AND 
		f_estado LIKE 'pago' AND 
		f_restaurante = r;
	SELECT COUNT (*) INTO n
	FROM faturas
	WHERE date_part('hour', f_data) > 10 AND 
		date_part('hour', f_data) < 15 AND 
		f_estado LIKE 'pago' AND 
		f_restaurante = r;
	
	RETURN TOTAL / n;
END;
$$;
 ;   DROP FUNCTION public.ver_receita_media_almocos(r integer);
       public       postgres    false                       1255    50074 !   ver_receita_media_diaria(integer)    FUNCTION     q  CREATE FUNCTION public.ver_receita_media_diaria(r integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE 
	TOTAL MONEY;
	n integer;
BEGIN
	SELECT SUM (f_preco) into TOTAL
	FROM faturas
	WHERE f_estado LIKE 'pago' AND 
		f_restaurante = r;
	SELECT COUNT (*) INTO n
	FROM faturas
	WHERE f_estado LIKE 'pago' AND 
		f_restaurante = r;
	
	RETURN TOTAL / n;
END;
$$;
 :   DROP FUNCTION public.ver_receita_media_diaria(r integer);
       public       postgres    false                       1255    50012 #   ver_receita_media_jantares(integer)    FUNCTION       CREATE FUNCTION public.ver_receita_media_jantares(r integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE 
	TOTAL MONEY;
	n integer;
BEGIN
	SELECT SUM (f_preco) into TOTAL
	FROM faturas
	WHERE date_part('hour', f_data) > 18 AND 
		date_part('hour', f_data) < 24 AND 
		f_estado LIKE 'pago' AND 
		f_restaurante = r;
	SELECT COUNT (*) into n
	FROM faturas
	WHERE date_part('hour', f_data) > 18 AND 
		date_part('hour', f_data) < 24 AND 
		f_estado LIKE 'pago' AND 
		f_restaurante = r;
	
	RETURN TOTAL / n;
END;
$$;
 <   DROP FUNCTION public.ver_receita_media_jantares(r integer);
       public       postgres    false                       1255    49778 &   ver_receita_ultimos_sete_dias(integer)    FUNCTION     !  CREATE FUNCTION public.ver_receita_ultimos_sete_dias(r integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE 
	TOTAL MONEY;
BEGIN
	SELECT SUM(f_preco) into TOTAL
	FROM faturas
	WHERE f_data > CURRENT_DATE - 7 AND f_estado LIKE 'pago' AND f_restaurante = r;
	RETURN TOTAL;
END;
$$;
 ?   DROP FUNCTION public.ver_receita_ultimos_sete_dias(r integer);
       public       postgres    false                       1255    48893    ver_reservas(integer)    FUNCTION       CREATE FUNCTION public.ver_reservas(restaurante integer) RETURNS TABLE(d date, cliente character varying, npessoas integer, func character varying, obs character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT reserva_data, c_nome, reserva_pessoas, f_nome, reserva_descricao
	FROM reservas JOIN clientes ON reservas.reserva_cliente = clientes.c_id
		JOIN funcionarios ON reservas.reserva_funcionario = funcionarios.f_id
	WHERE reserva_restaurante = restaurante
	ORDER BY reserva_data DESC;
END;
$$;
 8   DROP FUNCTION public.ver_reservas(restaurante integer);
       public       postgres    false                       1255    35364    ver_zonas_confecao()    FUNCTION     �   CREATE FUNCTION public.ver_zonas_confecao() RETURNS TABLE(zona character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	SELECT zconf_designacao
	FROM zonas_confecao;
END;
$$;
 +   DROP FUNCTION public.ver_zonas_confecao();
       public       postgres    false            �            1259    25172    alergias    TABLE     d   CREATE TABLE public.alergias (
    a_id integer NOT NULL,
    a_designacao character varying(30)
);
    DROP TABLE public.alergias;
       public         postgres    false            �            1259    33803    alergias_sequencia    SEQUENCE     {   CREATE SEQUENCE public.alergias_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.alergias_sequencia;
       public       postgres    false            �            1259    34775    alerta_stock    TABLE     s   CREATE TABLE public.alerta_stock (
    produto integer NOT NULL,
    data date NOT NULL,
    fornecedor integer
);
     DROP TABLE public.alerta_stock;
       public         postgres    false            �            1259    25177    clientes    TABLE     �   CREATE TABLE public.clientes (
    c_id integer NOT NULL,
    c_descricao character varying(30),
    c_nif integer,
    c_nome character varying(30)
);
    DROP TABLE public.clientes;
       public         postgres    false            �            1259    33724    clientes_sequencia    SEQUENCE     {   CREATE SEQUENCE public.clientes_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.clientes_sequencia;
       public       postgres    false            �            1259    25192    ementa    TABLE     �   CREATE TABLE public.ementa (
    e_id integer NOT NULL,
    e_prato integer NOT NULL,
    e_descricao character varying(30),
    e_diasemanal character varying(8) NOT NULL,
    r_id integer NOT NULL
);
    DROP TABLE public.ementa;
       public         postgres    false            �            1259    25214    historico_ementa    TABLE     �   CREATE TABLE public.historico_ementa (
    he_id integer NOT NULL,
    r_id integer,
    he_data date,
    h_prato integer,
    h_preco money,
    h_diaementa character varying(8)
);
 $   DROP TABLE public.historico_ementa;
       public         postgres    false            �            1259    25251    produtos    TABLE       CREATE TABLE public.produtos (
    zconf_id integer,
    tr_id integer,
    tp_id integer,
    p_id integer NOT NULL,
    p_preco money,
    p_iva double precision,
    p_quantidade integer,
    p_designacao character varying(30),
    p_stockminimo integer
);
    DROP TABLE public.produtos;
       public         postgres    false            �            1259    25422    consultar_ementa    VIEW     B  CREATE VIEW public.consultar_ementa AS
 SELECT CURRENT_DATE AS dia,
    produtos.p_designacao AS prato
   FROM ((public.produtos
     JOIN public.ementa ON ((produtos.p_id = ementa.e_prato)))
     JOIN public.historico_ementa ON ((ementa.e_id = historico_ementa.he_id)))
  WHERE (historico_ementa.he_data = CURRENT_DATE);
 #   DROP VIEW public.consultar_ementa;
       public       postgres    false    204    198    201    204    198    201            �            1259    33669    ementas_sequencia    SEQUENCE     z   CREATE SEQUENCE public.ementas_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.ementas_sequencia;
       public       postgres    false            �            1259    25428    erros    TABLE     �   CREATE TABLE public.erros (
    msg character varying(100),
    codigo character varying(10),
    data_erro time without time zone
);
    DROP TABLE public.erros;
       public         postgres    false            �            1259    33739    faturas    TABLE     N  CREATE TABLE public.faturas (
    f_cliente integer NOT NULL,
    f_restaurante integer NOT NULL,
    f_prod character varying(30) NOT NULL,
    f_id integer NOT NULL,
    f_preco money NOT NULL,
    f_nif integer,
    f_data timestamp(4) without time zone NOT NULL,
    f_estado character varying(10) NOT NULL,
    f_mesa integer
);
    DROP TABLE public.faturas;
       public         postgres    false            �            1259    33768    faturas_sequencia    SEQUENCE     z   CREATE SEQUENCE public.faturas_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.faturas_sequencia;
       public       postgres    false            �            1259    25203    fornecedores    TABLE     �   CREATE TABLE public.fornecedores (
    fornecedor_id integer NOT NULL,
    fornecedor_designacao character varying(30) NOT NULL,
    fornecedor_tipo integer NOT NULL,
    fornecedor_contacto integer
);
     DROP TABLE public.fornecedores;
       public         postgres    false            �            1259    25209    funcionarios    TABLE     �   CREATE TABLE public.funcionarios (
    f_id integer NOT NULL,
    f_nome character varying(30) NOT NULL,
    f_restaurante integer NOT NULL
);
     DROP TABLE public.funcionarios;
       public         postgres    false            �            1259    43014    historico_sequencia    SEQUENCE     |   CREATE SEQUENCE public.historico_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.historico_sequencia;
       public       postgres    false            �            1259    25237    locais    TABLE     b   CREATE TABLE public.locais (
    l_id integer NOT NULL,
    l_designacao character varying(30)
);
    DROP TABLE public.locais;
       public         postgres    false            �            1259    51995    login    TABLE     �   CREATE TABLE public.login (
    login_id_user integer NOT NULL,
    login_user character varying(30) NOT NULL,
    login_password character varying(100) NOT NULL,
    login_admin integer NOT NULL,
    login_restaurante integer NOT NULL
);
    DROP TABLE public.login;
       public         postgres    false            �            1259    52015    login_sequencia    SEQUENCE     x   CREATE SEQUENCE public.login_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.login_sequencia;
       public       postgres    false            �            1259    25242    mesas    TABLE     �   CREATE TABLE public.mesas (
    m_id integer NOT NULL,
    zcons_id integer,
    m_capacidade numeric,
    m_estado integer,
    m_restaurante integer
);
    DROP TABLE public.mesas;
       public         postgres    false            �            1259    25268    restaurantes    TABLE     z   CREATE TABLE public.restaurantes (
    l_id integer,
    r_id integer NOT NULL,
    r_designacao character varying(30)
);
     DROP TABLE public.restaurantes;
       public         postgres    false            �            1259    25414    nomes_restaurantes    VIEW     h   CREATE VIEW public.nomes_restaurantes AS
 SELECT restaurantes.r_designacao
   FROM public.restaurantes;
 %   DROP VIEW public.nomes_restaurantes;
       public       postgres    false    205            �            1259    33686    pedidos    TABLE       CREATE TABLE public.pedidos (
    pedido_id integer NOT NULL,
    pedido_tipo character varying(30) NOT NULL,
    pedido_produto character varying(30) NOT NULL,
    pedido_data timestamp(4) without time zone NOT NULL,
    pedido_mesa integer,
    pedido_funcionario integer NOT NULL
);
    DROP TABLE public.pedidos;
       public         postgres    false            �            1259    52005    pedidos_registo_conta    TABLE       CREATE TABLE public.pedidos_registo_conta (
    pr_id integer NOT NULL,
    pr_data date NOT NULL,
    pr_user character varying(30) NOT NULL,
    pr_password character varying(100) NOT NULL,
    pr_restaurante integer NOT NULL,
    pr_admin integer NOT NULL
);
 )   DROP TABLE public.pedidos_registo_conta;
       public         postgres    false            �            1259    33694    pedidos_sequencia    SEQUENCE     z   CREATE SEQUENCE public.pedidos_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.pedidos_sequencia;
       public       postgres    false            �            1259    33608    pratos    TABLE     �   CREATE TABLE public.pratos (
    prato_id integer NOT NULL,
    prato_designacao character varying(30),
    prato_preco money
);
    DROP TABLE public.pratos;
       public         postgres    false            �            1259    33611    pratos_produtos    TABLE     e   CREATE TABLE public.pratos_produtos (
    prato_id integer NOT NULL,
    prod_id integer NOT NULL
);
 #   DROP TABLE public.pratos_produtos;
       public         postgres    false            �            1259    33912    prod_alergias    TABLE     y   CREATE TABLE public.prod_alergias (
    prod_id integer NOT NULL,
    alergia integer NOT NULL,
    gravidade integer
);
 !   DROP TABLE public.prod_alergias;
       public         postgres    false            �            1259    34295    pratos_com_alergias    MATERIALIZED VIEW     �  CREATE MATERIALIZED VIEW public.pratos_com_alergias AS
 SELECT pratos.prato_designacao,
    produtos.p_designacao,
    alergias.a_designacao
   FROM ((((public.pratos
     JOIN public.pratos_produtos ON ((pratos.prato_id = pratos_produtos.prato_id)))
     JOIN public.prod_alergias ON ((pratos_produtos.prod_id = prod_alergias.prod_id)))
     JOIN public.produtos ON ((produtos.p_id = pratos_produtos.prod_id)))
     JOIN public.alergias ON ((prod_alergias.alergia = alergias.a_id)))
  WITH NO DATA;
 3   DROP MATERIALIZED VIEW public.pratos_com_alergias;
       public         postgres    false    230    196    196    204    204    215    215    216    216    230            �            1259    33631    pratos_sequencia    SEQUENCE     y   CREATE SEQUENCE public.pratos_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.pratos_sequencia;
       public       postgres    false            �            1259    25437    produtos_sequencia    SEQUENCE     {   CREATE SEQUENCE public.produtos_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.produtos_sequencia;
       public       postgres    false            �            1259    25442    reservas    TABLE     8  CREATE TABLE public.reservas (
    reserva_id integer NOT NULL,
    reserva_data date NOT NULL,
    reserva_pessoas integer NOT NULL,
    reserva_cliente integer NOT NULL,
    reserva_funcionario integer NOT NULL,
    reserva_restaurante integer NOT NULL,
    reserva_descricao character varying(30) NOT NULL
);
    DROP TABLE public.reservas;
       public         postgres    false            �            1259    33715    reservas_sequencia    SEQUENCE     {   CREATE SEQUENCE public.reservas_sequencia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.reservas_sequencia;
       public       postgres    false            �            1259    25274    tipos_produto    TABLE     k   CREATE TABLE public.tipos_produto (
    tp_id integer NOT NULL,
    tp_designacao character varying(30)
);
 !   DROP TABLE public.tipos_produto;
       public         postgres    false            �            1259    25279    tipos_refeicao    TABLE     l   CREATE TABLE public.tipos_refeicao (
    tr_id integer NOT NULL,
    tr_designacao character varying(30)
);
 "   DROP TABLE public.tipos_refeicao;
       public         postgres    false            �            1259    33839    ver_funcionarios    VIEW     �   CREATE VIEW public.ver_funcionarios AS
 SELECT funcionarios.f_id,
    funcionarios.f_nome,
    funcionarios.f_restaurante
   FROM public.funcionarios;
 #   DROP VIEW public.ver_funcionarios;
       public       postgres    false    200    200    200            �            1259    34070    ver_nome_alergias    MATERIALIZED VIEW     �   CREATE MATERIALIZED VIEW public.ver_nome_alergias AS
 SELECT alergias.a_designacao
   FROM public.alergias
  ORDER BY alergias.a_designacao
  WITH NO DATA;
 1   DROP MATERIALIZED VIEW public.ver_nome_alergias;
       public         postgres    false    196            �            1259    33871    ver_nome_produtos    MATERIALIZED VIEW     �   CREATE MATERIALIZED VIEW public.ver_nome_produtos AS
 SELECT produtos.p_designacao
   FROM public.produtos
  ORDER BY produtos.p_designacao
  WITH NO DATA;
 1   DROP MATERIALIZED VIEW public.ver_nome_produtos;
       public         postgres    false    204            �            1259    33792 
   ver_pratos    VIEW     X   CREATE VIEW public.ver_pratos AS
 SELECT pratos.prato_designacao
   FROM public.pratos;
    DROP VIEW public.ver_pratos;
       public       postgres    false    215            �            1259    25284    zonas_confecao    TABLE     r   CREATE TABLE public.zonas_confecao (
    zconf_id integer NOT NULL,
    zconf_designacao character varying(30)
);
 "   DROP TABLE public.zonas_confecao;
       public         postgres    false            �            1259    33813    ver_produtos    VIEW       CREATE VIEW public.ver_produtos AS
 SELECT produtos.p_designacao,
    produtos.p_preco,
    produtos.p_iva,
    produtos.p_quantidade,
    zonas_confecao.zconf_designacao
   FROM (public.produtos
     JOIN public.zonas_confecao ON ((produtos.zconf_id = zonas_confecao.zconf_id)));
    DROP VIEW public.ver_produtos;
       public       postgres    false    204    204    204    208    208    204    204            �            1259    25289    zona_consumo    TABLE     �   CREATE TABLE public.zona_consumo (
    r_id integer,
    zcons_id integer NOT NULL,
    f_id integer,
    zcons_designacao character varying(30)
);
     DROP TABLE public.zona_consumo;
       public         postgres    false                       0    25172    alergias 
   TABLE DATA               6   COPY public.alergias (a_id, a_designacao) FROM stdin;
    public       postgres    false    196   Ow      @          0    34775    alerta_stock 
   TABLE DATA               A   COPY public.alerta_stock (produto, data, fornecedor) FROM stdin;
    public       postgres    false    233   �w      !          0    25177    clientes 
   TABLE DATA               D   COPY public.clientes (c_id, c_descricao, c_nif, c_nome) FROM stdin;
    public       postgres    false    197   �w      "          0    25192    ementa 
   TABLE DATA               P   COPY public.ementa (e_id, e_prato, e_descricao, e_diasemanal, r_id) FROM stdin;
    public       postgres    false    198   �x      .          0    25428    erros 
   TABLE DATA               7   COPY public.erros (msg, codigo, data_erro) FROM stdin;
    public       postgres    false    212   �x      9          0    33739    faturas 
   TABLE DATA               s   COPY public.faturas (f_cliente, f_restaurante, f_prod, f_id, f_preco, f_nif, f_data, f_estado, f_mesa) FROM stdin;
    public       postgres    false    223   �x      #          0    25203    fornecedores 
   TABLE DATA               r   COPY public.fornecedores (fornecedor_id, fornecedor_designacao, fornecedor_tipo, fornecedor_contacto) FROM stdin;
    public       postgres    false    199   fz      $          0    25209    funcionarios 
   TABLE DATA               C   COPY public.funcionarios (f_id, f_nome, f_restaurante) FROM stdin;
    public       postgres    false    200   {      %          0    25214    historico_ementa 
   TABLE DATA               _   COPY public.historico_ementa (he_id, r_id, he_data, h_prato, h_preco, h_diaementa) FROM stdin;
    public       postgres    false    201   �{      &          0    25237    locais 
   TABLE DATA               4   COPY public.locais (l_id, l_designacao) FROM stdin;
    public       postgres    false    202   C|      B          0    51995    login 
   TABLE DATA               j   COPY public.login (login_id_user, login_user, login_password, login_admin, login_restaurante) FROM stdin;
    public       postgres    false    235   �|      '          0    25242    mesas 
   TABLE DATA               V   COPY public.mesas (m_id, zcons_id, m_capacidade, m_estado, m_restaurante) FROM stdin;
    public       postgres    false    203   s}      5          0    33686    pedidos 
   TABLE DATA               w   COPY public.pedidos (pedido_id, pedido_tipo, pedido_produto, pedido_data, pedido_mesa, pedido_funcionario) FROM stdin;
    public       postgres    false    219   7~      C          0    52005    pedidos_registo_conta 
   TABLE DATA               o   COPY public.pedidos_registo_conta (pr_id, pr_data, pr_user, pr_password, pr_restaurante, pr_admin) FROM stdin;
    public       postgres    false    236   T~      1          0    33608    pratos 
   TABLE DATA               I   COPY public.pratos (prato_id, prato_designacao, prato_preco) FROM stdin;
    public       postgres    false    215   q~      2          0    33611    pratos_produtos 
   TABLE DATA               <   COPY public.pratos_produtos (prato_id, prod_id) FROM stdin;
    public       postgres    false    216   :      =          0    33912    prod_alergias 
   TABLE DATA               D   COPY public.prod_alergias (prod_id, alergia, gravidade) FROM stdin;
    public       postgres    false    230   z      (          0    25251    produtos 
   TABLE DATA               {   COPY public.produtos (zconf_id, tr_id, tp_id, p_id, p_preco, p_iva, p_quantidade, p_designacao, p_stockminimo) FROM stdin;
    public       postgres    false    204   �      0          0    25442    reservas 
   TABLE DATA               �   COPY public.reservas (reserva_id, reserva_data, reserva_pessoas, reserva_cliente, reserva_funcionario, reserva_restaurante, reserva_descricao) FROM stdin;
    public       postgres    false    214   :�      )          0    25268    restaurantes 
   TABLE DATA               @   COPY public.restaurantes (l_id, r_id, r_designacao) FROM stdin;
    public       postgres    false    205   ��      *          0    25274    tipos_produto 
   TABLE DATA               =   COPY public.tipos_produto (tp_id, tp_designacao) FROM stdin;
    public       postgres    false    206   �      +          0    25279    tipos_refeicao 
   TABLE DATA               >   COPY public.tipos_refeicao (tr_id, tr_designacao) FROM stdin;
    public       postgres    false    207   T�      -          0    25289    zona_consumo 
   TABLE DATA               N   COPY public.zona_consumo (r_id, zcons_id, f_id, zcons_designacao) FROM stdin;
    public       postgres    false    209   ��      ,          0    25284    zonas_confecao 
   TABLE DATA               D   COPY public.zonas_confecao (zconf_id, zconf_designacao) FROM stdin;
    public       postgres    false    208   G�      K           0    0    alergias_sequencia    SEQUENCE SET     @   SELECT pg_catalog.setval('public.alergias_sequencia', 2, true);
            public       postgres    false    226            L           0    0    clientes_sequencia    SEQUENCE SET     A   SELECT pg_catalog.setval('public.clientes_sequencia', 17, true);
            public       postgres    false    222            M           0    0    ementas_sequencia    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ementas_sequencia', 11, true);
            public       postgres    false    218            N           0    0    faturas_sequencia    SEQUENCE SET     @   SELECT pg_catalog.setval('public.faturas_sequencia', 79, true);
            public       postgres    false    224            O           0    0    historico_sequencia    SEQUENCE SET     A   SELECT pg_catalog.setval('public.historico_sequencia', 6, true);
            public       postgres    false    234            P           0    0    login_sequencia    SEQUENCE SET     >   SELECT pg_catalog.setval('public.login_sequencia', 18, true);
            public       postgres    false    237            Q           0    0    pedidos_sequencia    SEQUENCE SET     @   SELECT pg_catalog.setval('public.pedidos_sequencia', 65, true);
            public       postgres    false    220            R           0    0    pratos_sequencia    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.pratos_sequencia', 46, true);
            public       postgres    false    217            S           0    0    produtos_sequencia    SEQUENCE SET     A   SELECT pg_catalog.setval('public.produtos_sequencia', 29, true);
            public       postgres    false    213            T           0    0    reservas_sequencia    SEQUENCE SET     A   SELECT pg_catalog.setval('public.reservas_sequencia', 14, true);
            public       postgres    false    221            |           2606    34779    alerta_stock alerta_stock_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.alerta_stock
    ADD CONSTRAINT alerta_stock_pkey PRIMARY KEY (produto, data);
 H   ALTER TABLE ONLY public.alerta_stock DROP CONSTRAINT alerta_stock_pkey;
       public         postgres    false    233    233            x           2606    33767    faturas faturas_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.faturas
    ADD CONSTRAINT faturas_pkey PRIMARY KEY (f_id);
 >   ALTER TABLE ONLY public.faturas DROP CONSTRAINT faturas_pkey;
       public         postgres    false    223            ~           2606    51999    login login_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.login
    ADD CONSTRAINT login_pkey PRIMARY KEY (login_id_user);
 :   ALTER TABLE ONLY public.login DROP CONSTRAINT login_pkey;
       public         postgres    false    235            v           2606    33690    pedidos pedidos_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (pedido_id);
 >   ALTER TABLE ONLY public.pedidos DROP CONSTRAINT pedidos_pkey;
       public         postgres    false    219            �           2606    52009 0   pedidos_registo_conta pedidos_registo_conta_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.pedidos_registo_conta
    ADD CONSTRAINT pedidos_registo_conta_pkey PRIMARY KEY (pr_id);
 Z   ALTER TABLE ONLY public.pedidos_registo_conta DROP CONSTRAINT pedidos_registo_conta_pkey;
       public         postgres    false    236            N           2606    25176    alergias pk_alergias 
   CONSTRAINT     T   ALTER TABLE ONLY public.alergias
    ADD CONSTRAINT pk_alergias PRIMARY KEY (a_id);
 >   ALTER TABLE ONLY public.alergias DROP CONSTRAINT pk_alergias;
       public         postgres    false    196            P           2606    25184    clientes pk_clientes 
   CONSTRAINT     T   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT pk_clientes PRIMARY KEY (c_id);
 >   ALTER TABLE ONLY public.clientes DROP CONSTRAINT pk_clientes;
       public         postgres    false    197            R           2606    25196    ementa pk_ementa 
   CONSTRAINT     P   ALTER TABLE ONLY public.ementa
    ADD CONSTRAINT pk_ementa PRIMARY KEY (e_id);
 :   ALTER TABLE ONLY public.ementa DROP CONSTRAINT pk_ementa;
       public         postgres    false    198            T           2606    25207    fornecedores pk_fornecedores 
   CONSTRAINT     e   ALTER TABLE ONLY public.fornecedores
    ADD CONSTRAINT pk_fornecedores PRIMARY KEY (fornecedor_id);
 F   ALTER TABLE ONLY public.fornecedores DROP CONSTRAINT pk_fornecedores;
       public         postgres    false    199            W           2606    25213    funcionarios pk_funcionarios 
   CONSTRAINT     \   ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT pk_funcionarios PRIMARY KEY (f_id);
 F   ALTER TABLE ONLY public.funcionarios DROP CONSTRAINT pk_funcionarios;
       public         postgres    false    200            Y           2606    25218 $   historico_ementa pk_historico_ementa 
   CONSTRAINT     e   ALTER TABLE ONLY public.historico_ementa
    ADD CONSTRAINT pk_historico_ementa PRIMARY KEY (he_id);
 N   ALTER TABLE ONLY public.historico_ementa DROP CONSTRAINT pk_historico_ementa;
       public         postgres    false    201            \           2606    25241    locais pk_locais 
   CONSTRAINT     P   ALTER TABLE ONLY public.locais
    ADD CONSTRAINT pk_locais PRIMARY KEY (l_id);
 :   ALTER TABLE ONLY public.locais DROP CONSTRAINT pk_locais;
       public         postgres    false    202            ^           2606    25249    mesas pk_mesas 
   CONSTRAINT     N   ALTER TABLE ONLY public.mesas
    ADD CONSTRAINT pk_mesas PRIMARY KEY (m_id);
 8   ALTER TABLE ONLY public.mesas DROP CONSTRAINT pk_mesas;
       public         postgres    false    203            a           2606    25255    produtos pk_produtos 
   CONSTRAINT     T   ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT pk_produtos PRIMARY KEY (p_id);
 >   ALTER TABLE ONLY public.produtos DROP CONSTRAINT pk_produtos;
       public         postgres    false    204            d           2606    25272    restaurantes pk_restaurantes 
   CONSTRAINT     \   ALTER TABLE ONLY public.restaurantes
    ADD CONSTRAINT pk_restaurantes PRIMARY KEY (r_id);
 F   ALTER TABLE ONLY public.restaurantes DROP CONSTRAINT pk_restaurantes;
       public         postgres    false    205            g           2606    25278    tipos_produto pk_tipos_produto 
   CONSTRAINT     _   ALTER TABLE ONLY public.tipos_produto
    ADD CONSTRAINT pk_tipos_produto PRIMARY KEY (tp_id);
 H   ALTER TABLE ONLY public.tipos_produto DROP CONSTRAINT pk_tipos_produto;
       public         postgres    false    206            i           2606    25283     tipos_refeicao pk_tipos_refeicao 
   CONSTRAINT     a   ALTER TABLE ONLY public.tipos_refeicao
    ADD CONSTRAINT pk_tipos_refeicao PRIMARY KEY (tr_id);
 J   ALTER TABLE ONLY public.tipos_refeicao DROP CONSTRAINT pk_tipos_refeicao;
       public         postgres    false    207            m           2606    25293    zona_consumo pk_zona_consumo 
   CONSTRAINT     `   ALTER TABLE ONLY public.zona_consumo
    ADD CONSTRAINT pk_zona_consumo PRIMARY KEY (zcons_id);
 F   ALTER TABLE ONLY public.zona_consumo DROP CONSTRAINT pk_zona_consumo;
       public         postgres    false    209            k           2606    25288     zonas_confecao pk_zonas_confecao 
   CONSTRAINT     d   ALTER TABLE ONLY public.zonas_confecao
    ADD CONSTRAINT pk_zonas_confecao PRIMARY KEY (zconf_id);
 J   ALTER TABLE ONLY public.zonas_confecao DROP CONSTRAINT pk_zonas_confecao;
       public         postgres    false    208            r           2606    33617    pratos pratos_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.pratos
    ADD CONSTRAINT pratos_pkey PRIMARY KEY (prato_id);
 <   ALTER TABLE ONLY public.pratos DROP CONSTRAINT pratos_pkey;
       public         postgres    false    215            z           2606    33916     prod_alergias prod_alergias_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.prod_alergias
    ADD CONSTRAINT prod_alergias_pkey PRIMARY KEY (prod_id, alergia);
 J   ALTER TABLE ONLY public.prod_alergias DROP CONSTRAINT prod_alergias_pkey;
       public         postgres    false    230    230            t           2606    33615    pratos_produtos prod_prato 
   CONSTRAINT     g   ALTER TABLE ONLY public.pratos_produtos
    ADD CONSTRAINT prod_prato PRIMARY KEY (prato_id, prod_id);
 D   ALTER TABLE ONLY public.pratos_produtos DROP CONSTRAINT prod_prato;
       public         postgres    false    216    216            p           2606    25446    reservas reservas_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.reservas
    ADD CONSTRAINT reservas_pkey PRIMARY KEY (reserva_id);
 @   ALTER TABLE ONLY public.reservas DROP CONSTRAINT reservas_pkey;
       public         postgres    false    214            e           1259    25273    relationship_10_fk    INDEX     K   CREATE INDEX relationship_10_fk ON public.restaurantes USING btree (l_id);
 &   DROP INDEX public.relationship_10_fk;
       public         postgres    false    205            b           1259    25256    relationship_13_fk    INDEX     H   CREATE INDEX relationship_13_fk ON public.produtos USING btree (tr_id);
 &   DROP INDEX public.relationship_13_fk;
       public         postgres    false    204            _           1259    25250    relationship_18_fk    INDEX     H   CREATE INDEX relationship_18_fk ON public.mesas USING btree (zcons_id);
 &   DROP INDEX public.relationship_18_fk;
       public         postgres    false    203            U           1259    25208    relationship_20_fk    INDEX     T   CREATE INDEX relationship_20_fk ON public.fornecedores USING btree (fornecedor_id);
 &   DROP INDEX public.relationship_20_fk;
       public         postgres    false    199            Z           1259    25219    relationship_4_fk    INDEX     N   CREATE INDEX relationship_4_fk ON public.historico_ementa USING btree (r_id);
 %   DROP INDEX public.relationship_4_fk;
       public         postgres    false    201            n           1259    25294    relationship_9_fk    INDEX     J   CREATE INDEX relationship_9_fk ON public.zona_consumo USING btree (r_id);
 %   DROP INDEX public.relationship_9_fk;
       public         postgres    false    209            �           2620    34791    produtos alerta_stock    TRIGGER     �   CREATE TRIGGER alerta_stock BEFORE UPDATE OF p_quantidade ON public.produtos FOR EACH ROW EXECUTE PROCEDURE public.inserir_alerta_stock();
 .   DROP TRIGGER alerta_stock ON public.produtos;
       public       postgres    false    204    286    204            �           2620    34774    pedidos baixa_stock    TRIGGER     q   CREATE TRIGGER baixa_stock BEFORE INSERT ON public.pedidos FOR EACH ROW EXECUTE PROCEDURE public.pedido_stock();
 ,   DROP TRIGGER baixa_stock ON public.pedidos;
       public       postgres    false    285    219            �           2620    34315    pedidos fatura    TRIGGER     n   CREATE TRIGGER fatura AFTER DELETE ON public.pedidos FOR EACH ROW EXECUTE PROCEDURE public.mesa_desocupada();
 '   DROP TRIGGER fatura ON public.pedidos;
       public       postgres    false    219    263            �           2620    50248    ementa gravar_historico    TRIGGER     �   CREATE TRIGGER gravar_historico BEFORE INSERT ON public.ementa FOR EACH ROW EXECUTE PROCEDURE public.gravar_historico_ementa();
 0   DROP TRIGGER gravar_historico ON public.ementa;
       public       postgres    false    198    272            �           2620    34219    pedidos pedido    TRIGGER     k   CREATE TRIGGER pedido AFTER INSERT ON public.pedidos FOR EACH ROW EXECUTE PROCEDURE public.mesa_ocupada();
 '   DROP TRIGGER pedido ON public.pedidos;
       public       postgres    false    219    265            �           2620    52131    produtos remove_alerta_stock    TRIGGER     �   CREATE TRIGGER remove_alerta_stock BEFORE UPDATE ON public.produtos FOR EACH ROW EXECUTE PROCEDURE public.remover_alerta_stock();
 5   DROP TRIGGER remove_alerta_stock ON public.produtos;
       public       postgres    false    279    204            �           2606    34785 )   alerta_stock alerta_stock_fornecedor_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alerta_stock
    ADD CONSTRAINT alerta_stock_fornecedor_fkey FOREIGN KEY (fornecedor) REFERENCES public.fornecedores(fornecedor_id);
 S   ALTER TABLE ONLY public.alerta_stock DROP CONSTRAINT alerta_stock_fornecedor_fkey;
       public       postgres    false    2900    233    199            �           2606    34780 &   alerta_stock alerta_stock_produto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.alerta_stock
    ADD CONSTRAINT alerta_stock_produto_fkey FOREIGN KEY (produto) REFERENCES public.produtos(p_id);
 P   ALTER TABLE ONLY public.alerta_stock DROP CONSTRAINT alerta_stock_produto_fkey;
       public       postgres    false    204    233    2913            �           2606    33847    ementa ementa_e_prato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ementa
    ADD CONSTRAINT ementa_e_prato_fkey FOREIGN KEY (e_prato) REFERENCES public.pratos(prato_id) NOT VALID;
 D   ALTER TABLE ONLY public.ementa DROP CONSTRAINT ementa_e_prato_fkey;
       public       postgres    false    215    2930    198            �           2606    33744    faturas f_cliente    FK CONSTRAINT     w   ALTER TABLE ONLY public.faturas
    ADD CONSTRAINT f_cliente FOREIGN KEY (f_cliente) REFERENCES public.clientes(c_id);
 ;   ALTER TABLE ONLY public.faturas DROP CONSTRAINT f_cliente;
       public       postgres    false    2896    223    197            �           2606    33757    faturas f_restaurante    FK CONSTRAINT     �   ALTER TABLE ONLY public.faturas
    ADD CONSTRAINT f_restaurante FOREIGN KEY (f_restaurante) REFERENCES public.restaurantes(r_id) NOT VALID;
 ?   ALTER TABLE ONLY public.faturas DROP CONSTRAINT f_restaurante;
       public       postgres    false    2916    223    205            �           2606    33603    ementa fk_ementa_restaurante    FK CONSTRAINT     �   ALTER TABLE ONLY public.ementa
    ADD CONSTRAINT fk_ementa_restaurante FOREIGN KEY (r_id) REFERENCES public.restaurantes(r_id) NOT VALID;
 F   ALTER TABLE ONLY public.ementa DROP CONSTRAINT fk_ementa_restaurante;
       public       postgres    false    2916    198    205            �           2606    25325 /   historico_ementa fk_historic_relations_restaura    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_ementa
    ADD CONSTRAINT fk_historic_relations_restaura FOREIGN KEY (r_id) REFERENCES public.restaurantes(r_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.historico_ementa DROP CONSTRAINT fk_historic_relations_restaura;
       public       postgres    false    205    2916    201            �           2606    25355 !   mesas fk_mesas_relations_zona_con    FK CONSTRAINT     �   ALTER TABLE ONLY public.mesas
    ADD CONSTRAINT fk_mesas_relations_zona_con FOREIGN KEY (zcons_id) REFERENCES public.zona_consumo(zcons_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 K   ALTER TABLE ONLY public.mesas DROP CONSTRAINT fk_mesas_relations_zona_con;
       public       postgres    false    2925    203    209            �           2606    25365 '   produtos fk_produtos_relations_tipos_pr    FK CONSTRAINT     �   ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT fk_produtos_relations_tipos_pr FOREIGN KEY (tp_id) REFERENCES public.tipos_produto(tp_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.produtos DROP CONSTRAINT fk_produtos_relations_tipos_pr;
       public       postgres    false    206    2919    204            �           2606    25360 '   produtos fk_produtos_relations_tipos_re    FK CONSTRAINT     �   ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT fk_produtos_relations_tipos_re FOREIGN KEY (tr_id) REFERENCES public.tipos_refeicao(tr_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.produtos DROP CONSTRAINT fk_produtos_relations_tipos_re;
       public       postgres    false    204    207    2921            �           2606    25370 '   produtos fk_produtos_relations_zonas_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT fk_produtos_relations_zonas_co FOREIGN KEY (zconf_id) REFERENCES public.zonas_confecao(zconf_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.produtos DROP CONSTRAINT fk_produtos_relations_zonas_co;
       public       postgres    false    208    2923    204            �           2606    25385 )   restaurantes fk_restaura_relations_locais    FK CONSTRAINT     �   ALTER TABLE ONLY public.restaurantes
    ADD CONSTRAINT fk_restaura_relations_locais FOREIGN KEY (l_id) REFERENCES public.locais(l_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.restaurantes DROP CONSTRAINT fk_restaura_relations_locais;
       public       postgres    false    2908    205    202            �           2606    25390 +   zona_consumo fk_zona_con_relations_funciona    FK CONSTRAINT     �   ALTER TABLE ONLY public.zona_consumo
    ADD CONSTRAINT fk_zona_con_relations_funciona FOREIGN KEY (f_id) REFERENCES public.funcionarios(f_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.zona_consumo DROP CONSTRAINT fk_zona_con_relations_funciona;
       public       postgres    false    2903    209    200            �           2606    25395 +   zona_consumo fk_zona_con_relations_restaura    FK CONSTRAINT     �   ALTER TABLE ONLY public.zona_consumo
    ADD CONSTRAINT fk_zona_con_relations_restaura FOREIGN KEY (r_id) REFERENCES public.restaurantes(r_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 U   ALTER TABLE ONLY public.zona_consumo DROP CONSTRAINT fk_zona_con_relations_restaura;
       public       postgres    false    2916    205    209            �           2606    33834 ,   funcionarios funcionarios_f_restaurante_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_f_restaurante_fkey FOREIGN KEY (f_restaurante) REFERENCES public.restaurantes(r_id) NOT VALID;
 V   ALTER TABLE ONLY public.funcionarios DROP CONSTRAINT funcionarios_f_restaurante_fkey;
       public       postgres    false    205    200    2916            �           2606    43009 .   historico_ementa historico_ementa_h_prato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_ementa
    ADD CONSTRAINT historico_ementa_h_prato_fkey FOREIGN KEY (h_prato) REFERENCES public.pratos(prato_id) NOT VALID;
 X   ALTER TABLE ONLY public.historico_ementa DROP CONSTRAINT historico_ementa_h_prato_fkey;
       public       postgres    false    215    2930    201            �           2606    33823    mesas mesas_m_restaurante_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mesas
    ADD CONSTRAINT mesas_m_restaurante_fkey FOREIGN KEY (m_restaurante) REFERENCES public.restaurantes(r_id) NOT VALID;
 H   ALTER TABLE ONLY public.mesas DROP CONSTRAINT mesas_m_restaurante_fkey;
       public       postgres    false    203    2916    205            �           2606    33704    pedidos pedido_funcionario    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedido_funcionario FOREIGN KEY (pedido_funcionario) REFERENCES public.funcionarios(f_id) NOT VALID;
 D   ALTER TABLE ONLY public.pedidos DROP CONSTRAINT pedido_funcionario;
       public       postgres    false    219    200    2903            �           2606    52010 ?   pedidos_registo_conta pedidos_registo_conta_pr_restaurante_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pedidos_registo_conta
    ADD CONSTRAINT pedidos_registo_conta_pr_restaurante_fkey FOREIGN KEY (pr_restaurante) REFERENCES public.restaurantes(r_id);
 i   ALTER TABLE ONLY public.pedidos_registo_conta DROP CONSTRAINT pedidos_registo_conta_pr_restaurante_fkey;
       public       postgres    false    236    2916    205            �           2606    33618 -   pratos_produtos pratos_produtos_prato_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pratos_produtos
    ADD CONSTRAINT pratos_produtos_prato_id_fkey FOREIGN KEY (prato_id) REFERENCES public.pratos(prato_id) NOT VALID;
 W   ALTER TABLE ONLY public.pratos_produtos DROP CONSTRAINT pratos_produtos_prato_id_fkey;
       public       postgres    false    215    216    2930            �           2606    33623 ,   pratos_produtos pratos_produtos_prod_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pratos_produtos
    ADD CONSTRAINT pratos_produtos_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.produtos(p_id) NOT VALID;
 V   ALTER TABLE ONLY public.pratos_produtos DROP CONSTRAINT pratos_produtos_prod_id_fkey;
       public       postgres    false    204    216    2913            �           2606    33710    reservas reserva_funcionario    FK CONSTRAINT     �   ALTER TABLE ONLY public.reservas
    ADD CONSTRAINT reserva_funcionario FOREIGN KEY (reserva_funcionario) REFERENCES public.funcionarios(f_id) NOT VALID;
 F   ALTER TABLE ONLY public.reservas DROP CONSTRAINT reserva_funcionario;
       public       postgres    false    2903    200    214            �           2606    33719    reservas reserva_restaurante    FK CONSTRAINT     �   ALTER TABLE ONLY public.reservas
    ADD CONSTRAINT reserva_restaurante FOREIGN KEY (reserva_restaurante) REFERENCES public.restaurantes(r_id) NOT VALID;
 F   ALTER TABLE ONLY public.reservas DROP CONSTRAINT reserva_restaurante;
       public       postgres    false    214    2916    205            �           2606    52000    login restaurante    FK CONSTRAINT     �   ALTER TABLE ONLY public.login
    ADD CONSTRAINT restaurante FOREIGN KEY (login_restaurante) REFERENCES public.restaurantes(r_id) NOT VALID;
 ;   ALTER TABLE ONLY public.login DROP CONSTRAINT restaurante;
       public       postgres    false    235    2916    205            ?           0    34295    pratos_com_alergias    MATERIALIZED VIEW DATA     6   REFRESH MATERIALIZED VIEW public.pratos_com_alergias;
            public       postgres    false    232    3142            >           0    34070    ver_nome_alergias    MATERIALIZED VIEW DATA     4   REFRESH MATERIALIZED VIEW public.ver_nome_alergias;
            public       postgres    false    231    3142            <           0    33871    ver_nome_produtos    MATERIALIZED VIEW DATA     4   REFRESH MATERIALIZED VIEW public.ver_nome_produtos;
            public       postgres    false    229    3142                5   x�3��IL.�/N�2�t�)-I��2�t�I-J�LTH�W((�O)-������ >��      @   $   x�3��4202�50�50�4�24B�-9��b���� u��      !   �   x�]��
� E��W���#�e�.��̈́HLM���Fps�uF�b�'�W�L ��Q
�R
dC\ù��#��G��R��zF��yh�J-���v�Д�wnK�b���D�{��𜉿��4���8>k�55�5P�I!N�1ǿ&P��k�$��M�y��� ��l]      "   :   x�34���J�+I,�t����K��4�24�4�t���?�<�385�4/%�ӄ+F��� j��      .      x������ � �      9   l  x���;N�@���S�b���#5BTTi��KN6�NC�I8 �"7�$�q�b�l}���g�m]�V�3)���'�T���y�}�2������@���y٤�}F���^�%E&0�KB0��)��9e'(�RB�A���9�atƈ([,U��
�|I�TŦ�<9��Q�����1�=)��t��˸�5?|��г���8:&�F�
Ì�2fzU}��8� \�c騧����ȃ���e��v�5�_4ю>P�f��9�@)�����[<��js��+�X��������A� �����%��4�8��3��/G�[R�cY�UWߖBlJ��r�����h%�Ҧ�`�lq��V��r      #   �   x�M�K
1DוS�B�f��� �&J�$ؓ�x���LąЫ⽪V��r��4WN�S?hh���q��.q�'U�{gGl�g*�Ey�����V�J��٨��2,�u=�����S���U�c�B���8�JMR�Ct��wN�ׄ���J/N!��Z7      $   �   x�-�MJ1��/��I�g�Y6��
 [7�N
B���+�<B.fUp�}�Gճ�j�m�	�8<��pO%��JElĔ�ȫ&{�z&�6����#^J�R��x�I��)��7���I|�/fq���$6�p�TW�x��dĻ�N{���9�����g?3ń�X}/g��IF��-�vxl������-ut20p�|�c�  �J	      %   E   x�3�4�4202�50�50��44�10PxԴ��%?73/=�ˌ��Ēӌ���$85�4/%�+F��� �!�      &   0   x�3���,N�O�2��,N-�2��/*��2�>�����|�=... �O9      B   �   x���An� ��5�2��즧���R��4���%�n���_zn_v]{o?��L`h�Ic�n�!`a���!.����|<V�&0	M��vVh�D�1Dh�M�We�z����_�\
�":5}�۪gF��ކ��"��!j
H��3C>��#ti`���m��#�&`3��f�[�<��{9�9��=������Q��%®�=QN�9�9�hMYr?^����A�}@      '   �   x�M���0�3�2�o/鿎'p��D�'�VHU��JB^dg&\I�o�Q�L�Ƨ�����s+��]W�H�v�,Ԡ�;��wڂ��	Gp�7 vީ�?�T�F�e6�uo�XǶ�g�"�k+ɲ]ݚ�n�uMn��m�3�3��:.ɒ��ddyp۾�{2�����Ϗ��lGa      5      x������ � �      C      x������ � �      1   �   x�M�=�0���9���Rl-<��J"dXLHC�I<����x�"cf����ˠ4w�7�Ң��w�%�*M���Nr�hW�B'旸�ȧd;(Ѵ�h	�����&(�p����w�%�y��+l�\߉�\/�ȍ��cs&�D��r~n ;��k�p�-�����ξ�9�k�g��$I~C\�      2   0   x�3�4�2�4bC�Ј˂��DX�.CN#S.KN#K�=... ���      =   $   x�3��4�4�24�4�4�24�B.C#0���� KKD      (   |  x���Mn�0���)8@���l����UW�L�,����,{�n{�ޤ'� J1Ub
b�>�7��p��'g������"`��gVz����O�V�d�P���?(Gla�Ĵ� ��΄�ޛ��؊�í(�}����l,HR:%ae2Ӣ[L0K����ؒ ݻ�4g�X��d�_rK~��6|%�vV��hKg��ʂ�[6`�/u=b��!���Em��ּ�*�<4�V�������(�ǰt���f� �]�Q�G�����Ð�7=l�_���5I(w���z%�߾%�i{N;	��X�h���,���<_\��	MF;��BA�r�������k�z�]�+�b	UTڊXL�Pv�RUM�}�^��� �]      0   T   x�M���0�ᳳK��>(�0@��� =T�ɟ~EDP�+<
*
��4iq�H
:�����文��̠.��}��Ĵ�0����      )   E   x����4��,I��L���4r��/��9��R��A\ΐ��b�T��Ĥ���b�=... ��;      *   Q   x��;
�0�z�a���[�5Y4`��D��Δ4��,��U�'�i�F���b/!+ZZ�m|�l5��Y�$��5&~      +   B   x�3�(J,��2��O*J�M-N�2�t�+)JLI,�2��KL��2�KMO-I,�L������� 
�E      -   �   x�E�K
1Dם��tO2���	f+H�e���Q��U�b��y^�ͱ��z�=��-`#�m�e�\���y�
vy�>룦�	S'l��	[0u�V�[��@ԅ;9ʣy��T�d�����牨 ��
���B�Jtc�H�Bw�������O�      ,   !   x�3�tί���H�2�tJ�I>�8�+F��� c�E     