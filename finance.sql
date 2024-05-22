create sequence finance.seq_tipos;
create sequence finance.seq_categorias;

create table finance.tipos
(seq integer default nextval('finance.seq_tipos'::regclass),
tipo text);

create table finance.categorias
(seq integer default nextval('finance.seq_categorias'::regclass),
categoria text);

create view finance.vw_extrato as select * from finance.extrato order by conta, data, seq, situacao desc;
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

select * from finance.vw_extrato where data = '2024-05-31';
select * from finance.tipos;
select * from finance.categorias;

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
	 1) localizar o movimento a efetvar
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

