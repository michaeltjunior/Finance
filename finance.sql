create sequence finance.seq_extrato;
create sequence finance.seq_tipos;
create sequence finance.seq_categorias;

CREATE TABLE finance.extrato (
	"data" date NULL,
	tipo varchar(100) NULL,
	historico varchar(256) NULL,
	credito numeric NULL,
	debito numeric NULL,
	saldo numeric NULL,
	categoria varchar(100) NULL,
	situacao varchar(30) NULL,
	seq int4 NOT NULL DEFAULT nextval('finance.seq_extrato'::regclass),
	periodo date NULL,
	conta varchar(100) NOT NULL,
	saldo_aplicacao numeric NULL,
	seq_dia integer,
	CONSTRAINT extrato_pkey PRIMARY KEY (seq, conta)
);
CREATE INDEX extrato_ix1 ON finance.extrato USING btree (conta);
CREATE INDEX extrato_ix2 ON finance.extrato USING btree (data);
CREATE INDEX extrato_ix3 ON finance.extrato USING btree (situacao);

create table finance.tipos
(seq integer default nextval('finance.seq_tipos'::regclass),
tipo text);

create table finance.categorias
(seq integer default nextval('finance.seq_categorias'::regclass),
categoria text);

create or replace view finance.vw_extrato as select * from finance.extrato order by conta, data, seq_dia, seq, situacao desc;
grant all on finance.vw_extrato to public;
grant all on finance.tipos to public;
grant all on finance.categorias to public;

insert into tipos (tipo) values ('Aplicação');
insert into tipos (tipo) values ('Cartão crédito');
insert into tipos (tipo) values ('Cartão débito');
insert into tipos (tipo) values ('Conta consumo');
insert into tipos (tipo) values ('Débito aplicativo');
insert into tipos (tipo) values ('Depósito');
insert into tipos (tipo) values ('Pagamento cobrança');
insert into tipos (tipo) values ('Pagamento tributos');
insert into tipos (tipo) values ('Pague fácil');
insert into tipos (tipo) values ('Pix qr Code');
insert into tipos (tipo) values ('Saque');
insert into tipos (tipo) values ('Tarifa bancária');
insert into tipos (tipo) values ('TED');
insert into tipos (tipo) values ('Transferência PIX');
insert into tipos (tipo) values ('SALDO ANTERIOR');

insert into finance.categorias (categoria) values ('(-) Transferência');
insert into finance.categorias (categoria) values ('(+) Transferência');
insert into finance.categorias (categoria) values ('Alimentação');
insert into finance.categorias (categoria) values ('Cantina Igor');
insert into finance.categorias (categoria) values ('Cartão de crédito');
insert into finance.categorias (categoria) values ('Casa');
insert into finance.categorias (categoria) values ('Celular');
insert into finance.categorias (categoria) values ('Combustível');
insert into finance.categorias (categoria) values ('Cursos');
insert into finance.categorias (categoria) values ('Escola');
insert into finance.categorias (categoria) values ('Estacionamento');
insert into finance.categorias (categoria) values ('Farmácia');
insert into finance.categorias (categoria) values ('IASD');
insert into finance.categorias (categoria) values ('Igor');
insert into finance.categorias (categoria) values ('Impostos');
insert into finance.categorias (categoria) values ('Internet/TV');
insert into finance.categorias (categoria) values ('Luz');
insert into finance.categorias (categoria) values ('Mercados');
insert into finance.categorias (categoria) values ('Outras receitas');
insert into finance.categorias (categoria) values ('Patrícia');
insert into finance.categorias (categoria) values ('Rendimentos');
insert into finance.categorias (categoria) values ('Salário');
insert into finance.categorias (categoria) values ('Saque');
insert into finance.categorias (categoria) values ('Saúde');
insert into finance.categorias (categoria) values ('Seguro');
insert into finance.categorias (categoria) values ('Site');
insert into finance.categorias (categoria) values ('Tarifas bancárias');
insert into finance.categorias (categoria) values ('Transporte');
insert into finance.categorias (categoria) values ('Vestuário');
insert into finance.categorias (categoria) values ('Saldo anterior');

CREATE OR REPLACE VIEW finance.vw_extrato
AS SELECT extrato.data,
    extrato.tipo,
    extrato.historico,
    extrato.credito,
    extrato.debito,
    extrato.saldo,
    extrato.categoria,
    extrato.situacao,
    extrato.seq,
    extrato.periodo,
    extrato.conta,
    extrato.saldo_aplicacao
   FROM finance.extrato
  ORDER BY extrato.conta, extrato.data, extrato.seq, extrato.situacao DESC;
 
select * from finance.vw_extrato where data = '2024-05-31';
select * from finance.tipos;
select * from finance.categorias;

CREATE INDEX extrato_ix1 ON finance.extrato (conta);
CREATE INDEX extrato_ix2 ON finance.extrato (data);
CREATE INDEX extrato_ix3 ON finance.extrato (situacao);

/* saldos atuais das contas */
select conta, saldo, saldo_aplicacao from finance.extrato e where seq = (select max(seq) from finance.extrato ee where ee.conta = e.conta and situacao = 'Realizado');

/* previsão para o mês corrente, a partir da última posição efetivada e dos movimentos já previstos */
select conta, sum(saldo) saldo_atual, sum(saldo_aplicacao) saldo_aplicacao, sum(saldo) + sum(saldo_aplicacao) as saldo_total,
		sum(credito) as entradas, sum(debito) as saidas, 
		(sum(saldo) + sum(saldo_aplicacao) + sum(credito) - abs(sum(debito))) as saldo_previsto
from
(select conta, saldo, saldo_aplicacao, 0 as credito, 0 as debito from finance.extrato e where seq = (select max(seq) from finance.extrato ee where ee.conta = e.conta and situacao = 'Realizado')
union all 
select conta, 0 as saldo, 00 as saldo_aplicacao, sum(credito), sum(debito) from finance.vw_extrato where to_char(data, 'MM/YYYY') = to_char(current_date, 'MM/YYYY') and situacao = 'Previsto' group by conta) as m
group by conta;

/* saldos finais por mês */
select conta, to_char(date_trunc('month', data),'MM/YYYY' ) as mes, saldo , saldo_aplicacao, saldo + saldo_aplicacao as saldo_total
from finance.vw_extrato e 
where conta||'-'||seq = (select conta||'-'||max(seq) 
							from finance.vw_extrato ee 
							where ee.conta = e.conta 
							and to_char(date_trunc('month', e.data),'MM/YYYY' ) = to_char(date_trunc('month', ee.data),'MM/YYYY' )
							group by conta);

/*
 EFETIVAR UM MOVIMENTO PREVISTO
 ------------------------------------------------
	 1) localizar o movimento a efetivar
	 2) confirmar a data da efetivação
	 3) copiar todo o registro PREVISTO para a memória
	 4) DELETER o registro previsto
	 5) INSERIR o registro previsto agora como REALIZADO na data correta
	 6) recalcular o saldo A PARTIR DO DIA SEGUINTE ao do movimento efetivado, levando em conta o crédito ou o débito agora efetivado, SOMENTE NA CONTA AFETADA
  
***   CRIAR PROCESSO PARA ADMINISTRAÇÃO DAS APLICAÇÕES FINANCEIRAS (tela à parte) ***
	- aporte
	- rendimento
	- estorno de rendimento
	- resgate
*/
					
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------   
CREATE OR REPLACE FUNCTION finance.fn_antes_insere_mov()	-- OK - validada
	RETURNS trigger
	LANGUAGE plpgsql
AS 
$function$
DECLARE  
	cursorSaldos CURSOR FOR SELECT seq, saldo, saldo_aplicacao 
							from finance.vw_extrato e 
							where conta = new.conta 
							and seq = (select max(seq) from finance.vw_extrato ee where ee.conta = e.conta /*and situacao = 'Realizado'*/ and data = new.data);
	nSeq 		integer;
	nSaldo 		numeric;
	nSaldoApl 	numeric;
	nNovaSeq	integer;

	cursorSeqDia cursor for select coalesce(max(seq_dia), 0)+1 as seq_dia from finance.extrato e where conta = new.conta and data = new.data;

	x 			RECORD;
	nSeqDia		integer;
begin
	if (new.situacao = 'Realizado') then
		/* obter a sequencia do dia */
		open cursorSeqDia;
		fetch cursorSeqDia into nSeqDia;
		close cursorSeqDia;
	
		new.seq_dia = nSeqDia;
	end if;

	/* PREVER MOVIMENTAÇÃO DE APLICAÇÃO FINANCEIRA */
    OPEN cursorSaldos;
    FETCH cursorSaldos INTO nSeq, nSaldo, nSaldoApl;
	    
    IF FOUND THEN
		new.saldo = nSaldo + new.credito - abs(new.debito);
	else
		new.saldo = 0;
    END IF;
    
    CLOSE cursorSaldos;

    RETURN NEW;
END;
$function$;
--
create trigger extrato_antes_insere before insert on finance.extrato for each row execute function finance.fn_antes_insere_mov();  
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------   
CREATE OR REPLACE FUNCTION finance.fn_apos_insere_mov()	-- testar
	RETURNS trigger
	LANGUAGE plpgsql
AS 
$function$
declare 
	x record;
begin
	/* PREVER MOVIMENTAÇÃO DE APLICAÇÃO FINANCEIRA */
	
	for x in select seq , data, conta from finance.vw_extrato e where e.conta = new.conta and data > new.data loop 
		update finance.extrato set saldo = saldo + new.credito - abs(new.debito) where seq = x.seq;
	end loop;				

--	update finance.extrato set saldo = saldo + new.credito - abs(new.debito) where conta = new.conta and data > new.data;

    RETURN NEW;
END;
$function$;
--
create trigger extrato_apos_insere after insert on finance.extrato for each row execute function finance.fn_apos_insere_mov();  
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------   
CREATE OR REPLACE FUNCTION finance.fn_apos_delete_mov()		-- OK - validada
	RETURNS trigger
	LANGUAGE plpgsql
AS 
$function$
declare
	cursorUltimaData cursor for select max(data) as ultimaData from finance.extrato e where conta = old.conta and data < old.data;
	dUltimaData date;
	x record;
	ultimoSaldo numeric;
begin
	/* PREVER MOVIMENTAÇÃO DE APLICAÇÃO FINANCEIRA */
	
	ultimoSaldo = -9999999;
	
	open cursorUltimaData;
	fetch cursorUltimaData into dUltimaData;
	close cursorUltimaData;

	for x in select * from finance.vw_extrato ve where data >= dUltimaData and conta = old.conta loop 
		if (ultimoSaldo = -9999999) then 
			ultimoSaldo = x.saldo;
		else 
			update finance.extrato set saldo = ultimoSaldo + x.credito - abs(x.debito) where seq = x.seq;
			ultimoSaldo = ultimoSaldo + x.credito - abs(x.debito);
		end if;
	end loop;

    RETURN OLD;
END;
$function$;
--
create trigger extrato_apos_delete after delete on finance.extrato for each row execute function finance.fn_apos_delete_mov();  
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------   
CREATE OR REPLACE FUNCTION finance.fn_apos_update_mov()		-- testar
	RETURNS trigger
	LANGUAGE plpgsql
AS 
$function$
declare 
	x record;
	nSaldoAntigo numeric;
	cursorUltimaSeq cursor for select coalesce(max(seq_dia), 0) + 1 from finance.extrato e where conta = new.conta and data = new.data;
	nSeqDia integer;
begin
	nSaldoAntigo = -999999;
	open cursorUltimaSeq;
	fetch cursorUltimaSeq into nSeqDia;
	close cursorUltimaSeq;

	if (new.situacao <> old.situacao) then 
		/* mudou a situação - registro foi efetivado */
		/* regra: registro já efetivado não pode ser alterado para previsto novamente (deve ser excluído e programado de novo neste caso) */
		for x in select seq , data, conta , saldo from finance.vw_extrato e where e.conta = new.conta and data > new.data loop 
			if(nSaldoAntigo = -999999) then 
				nSaldoAntigo = new.saldo;
			end if;			
		
			update finance.extrato set saldo = nSaldoAntigo + new.credito - abs(new.debito) where seq = x.seq;
			nSaldoAntigo = nSaldoAntigo + new.credito - abs(new.debito);
		end loop;				
	end if;

	update finance.extrato set seq_dia = nSeqDia where seq = new.seq;

    RETURN NEW;
END;
$function$;
--
create trigger extrato_apos_update after update on finance.extrato for each row execute function finance.fn_apos_update_mov();  
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------   


select * from finance.extrato where seq = 1532;
--delete from finance.extrato where seq = 1544;

-- INSERT DE TESTE
insert into finance.extrato 
(data, tipo, historico, credito, debito, categoria, situacao, periodo, conta) 
values 
(current_date, 'Cartão débito', 'Teste', 0, -10, 'Mercados', 'Realizado', '2024-05-01', 'Bradesco');

insert into finance.extrato 
(data, tipo, historico, credito, debito, categoria, situacao, periodo, conta) 
values 
('2024-05-31', 'Saque', 'Dentista Igor', 0, -90, 'Saúde', 'Previsto', '2024-05-01', 'Bradesco');

update finance.extrato set situacao = 'Realizado' , data ='2024-05-21' where seq = 1544;

select * from finance.vw_extrato where periodo = '2024-05-01' and conta = 'Inter';
select * from finance.vw_extrato where periodo = '2024-05-01' and conta = 'Bradesco';
select * from finance.vw_extrato where periodo = '2024-06-01' and conta = 'Bradesco';
select * from finance.vw_extrato where conta = 'Inter';
select * from finance.vw_extrato where conta = 'Bradesco' and data >= '2024-05-20';


/* RECUPERAÇÃO DOS SALDOS EM CASO DE PERDA DE INTEGRIDADE */
do
$$
declare
	x 			record;
	nSaldoAtual numeric;
	vConta 		text;
	dData 		date;
	nSeqDia		integer;
begin
	dData = '2000-01-01';
	nSeqDia = 0;

	vConta = 'Bradesco';
	nSaldoAtual = 23783.03;  -- bradesco	

--	vConta = 'Inter';
--	nSaldoAtual = 0;  -- inter
	
	for x in select * from finance.vw_extrato ve where conta = vConta loop
		if (x.data <> dData) then 
			/* mudou a data */
			nSeqDia = 1;
			dData = x.data;
		else 	
			/* segue na mesma data */
			nSeqDia = nSeqDia + 1;
		end if;
	
		if(x.situacao = 'Previsto') then
			nSeqDia = null;
		end if;

		if(x.categoria <> 'Rendimentos') then
			nSaldoAtual = nSaldoAtual + x.credito - abs(x.debito);	
		
			update finance.extrato set saldo = nSaldoAtual, seq_dia = nSeqDia where seq = x.seq;
		else
			if(vConta = 'Bradesco') then
				nSaldoAtual = nSaldoAtual + x.credito - abs(x.debito);
			
				update finance.extrato set saldo = nSaldoAtual, seq_dia = nSeqDia where seq = x.seq;
			else
				update finance.extrato set saldo = nSaldoAtual , seq_dia = nSeqDia where seq = x.seq;
			end if;
		end if;
	end loop;	

	commit;
end;
$$
language plpgsql;


create or replace procedure finance.atualiza_saldo(iConta text, iDataInicial date)
as 
$$
declare 
	x record;
begin 
	for x in select max(seq)
end;
$$
language plpgsql;


