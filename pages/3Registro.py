import streamlit as st
from datetime import date, datetime
import json
import requests

st.set_page_config(layout="centered")   # ou "wide"

margins_css = """
    <style>
        .main > div {
            padding-top: 1rem;            
        }
        
        .stTextArea textarea {
            height: 1px;
        }
    </style>
"""
st.markdown(margins_css, unsafe_allow_html=True)        

lista_contas = ["Selecione"]
lista_tipos_contas = ["Selecione"]
lista_tipos_movimento = ["Selecione"]
lista_categorias = ["Selecione"]

if 'mensagem' not in st.session_state:
    st.session_state['mensagem'] = ''

if 'valorCredito' not in st.session_state:
    st.session_state['valorCredito'] = 0

if 'valorDebito' not in st.session_state:
    st.session_state['valorDebito'] = 0

#if 'periodo' not in st.session_state:
#    st.session_state['periodo'] = date(datetime.now().year, datetime.now().month, 1)

def botao_salvar():    
    valorCredito = 0
    valorDebito = 0

    if(st.session_state.valor < 0):
        valorCredito = 0
        valorDebito = st.session_state.valor

    if(st.session_state.valor >= 0):
        valorDebito = 0
        valorCredito = st.session_state.valor

    url = 'https://intelliseven.com.br/meteo/finance/registro'
    objeto = {'data': st.session_state.datamovimento.strftime("%Y-%m-%d") , 'conta': st.session_state.conta, 'tipo': st.session_state.tipo, 'historico': st.session_state.historico, 'categoria': st.session_state.categoria, 'credito': st.session_state.valorCredito, 'debito': st.session_state.valorDebito, 'situacao': st.session_state.situacao, 'periodo': date(st.session_state.datamovimento.year, st.session_state.datamovimento.month, 1).strftime("%Y-%m-%d"), 'tipo_conta': st.session_state.tipo_conta}
    x = requests.post(url, json = json.dumps(objeto))

    # limpar os campos após envio
    st.session_state['mensagem'] = 'registro salvo'
    st.session_state['historico'] = ''
    st.session_state['valor'] = 0
    st.session_state['conta'] = 'Selecione'
    st.session_state['tipos_movimento'] = 'Selecione'
    st.session_state['categorias'] = 'Selecione'
    st.session_state['situacoes'] = 'Selecione'

def carrega_lista_contas():
    contas = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/contas").json()))

    for conta in contas:
        lista_contas.append(conta['conta'])
    st.session_state['contas'] = lista_contas

    for tipo in contas:
        lista_tipos_contas.append(tipo['tipo'])
    st.session_state['tipos_conta'] = lista_tipos_contas

def carrega_lista_tipos_movimento():
    tipos = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/tipos").json()))

    for tipo in tipos:
        lista_tipos_movimento.append(tipo['tipo'])
    st.session_state['tipos_movimento'] = lista_tipos_movimento

def carrega_lista_categorias():
    categorias = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/categorias").json()))

    for categoria in categorias:
        lista_categorias.append(categoria['categoria'])
    st.session_state['categorias'] = lista_categorias

def carrega_listas():
    carrega_lista_contas()
    carrega_lista_tipos_movimento()
    carrega_lista_categorias()

    st.session_state['situacoes'] = ["Selecione", "Previsto", "Realizado"]
    
# ---------------------------------------------------------------------------------------------------------------------

carrega_listas()

# ---------------------------------------------------------------------------------------------------------------------

coluna1, coluna2 = st.columns([0.45, 0.55])
coluna1.title("| Movimentação ")
tipoEscolhido = ""

data = st.date_input("Data", key="datamovimento")

conta = st.selectbox("Conta", st.session_state['contas'], key="conta")
st.session_state['tipo_conta'] = lista_tipos_contas[st.session_state['contas'].index(conta)]

tipo = st.selectbox("Tipo", st.session_state['tipos_movimento'], key="tipo")

if(tipo == 'Aplicação'):
    contaDestino = st.selectbox("Conta aplicação", ["APL CDI Inter"], key="contaDestino")

historico = st.text_area("Descrição", height=1, key="historico")
valor = st.number_input("Valor R$", key="valor")
categoria = st.selectbox("Categoria", st.session_state['categorias'], key="categoria")
situacao = st.selectbox("Situação", st.session_state['situacoes'], key="situacao")

st.button('Salvar', on_click=botao_salvar)

if(not st.session_state['mensagem'] == ''):
    st.success(' Registro salvo', icon="✅")
    st.session_state['mensagem'] = ''
