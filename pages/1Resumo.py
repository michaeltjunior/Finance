import streamlit as st
import pandas as pd
import json
import requests

st.set_page_config(layout="centered")   # ou "wide"

if 'sld' not in st.session_state:
    st.session_state['sld'] = 0.00

margins_css = """
    <style>
        .div {
            padding-top: 1rem;            
            padding-bottom: 1rem;            
        }        
    </style>
"""
st.markdown(margins_css, unsafe_allow_html=True)        

lista_contas = ["Selecione"]

def mostra_conta(dados):
    st.table(dados)

def busca_resumo():
    resumoContas = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/resumo").json()))
    total = 0.00
   
    container = st.container(border = True)

    numero_colunas = 0
    for numContas in resumoContas:
        numero_colunas = numero_colunas + 1

    layout_colunas = st.columns(numero_colunas)
    numero_colunas = 0

    for resumo in resumoContas:        
        col = layout_colunas[numero_colunas]
        conta = resumo['conta']
    
        with col:
            total = total + float(resumo['saldo'])
            st.markdown("**"+conta+"**")
            st.write('R$ {:,.2f}'.format(float(resumo['saldo'])))

        numero_colunas = numero_colunas + 1
        
    st.divider()

    with st.columns(3)[1]:
        st.markdown("**"+'Saldo total: ' + 'R$ {:,.2f}'.format(total)+"**")

def saldo_dia_conta(contaSaldo):
    valorSaldo = 0.00
    saldoConta = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/resumo").json()))
    for saldo in saldoConta:
        if(saldo['conta'] == contaSaldo):
            valorSaldo = float(saldo['saldo'])
            st.session_state['sld'] = valorSaldo

def busca_dia():
    st.title("| Para hoje")
    resultado = 0
    paraHoje = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/hoje").json()))

    colunas_hoje = st.columns(4)

    colunas_hoje[0].write('Conta')
    colunas_hoje[1].write('Entradas')
    colunas_hoje[2].write('Saídas')
    colunas_hoje[3].write('Saldo dia')

    for hoje in paraHoje:
        conta = hoje['conta']
        credito = hoje['credito']
        debito = hoje['debito']
        saldo_dia_conta(conta)

        resultado = resultado + float(hoje['credito']) + float(hoje['debito'])

        with colunas_hoje[0]:
            st.markdown("**"+conta+"**")

        with colunas_hoje[1]:
            st.write('R$ {:,.2f}'.format(float(hoje['credito'])))

        with colunas_hoje[2]:
            st.write('R$ {:,.2f}'.format(float(hoje['debito'])))

        with colunas_hoje[3]:
            st.write('R$ {:,.2f}'.format(st.session_state['sld'] + resultado))

        resultado = 0

st.title("| Resumo")

busca_resumo()
st.divider()

busca_dia()