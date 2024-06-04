import streamlit as st
import pandas as pd
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
#st.markdown(margins_css, unsafe_allow_html=True)        

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
    
        with col:
            total = total + float(resumo['saldo'])
            #with st.popover(resumo['conta']):
            st.markdown("**:resumo['conta']**")
            #st.write(resumo['conta'])
            st.write('R$ {:,.2f}'.format(float(resumo['saldo'])))

        numero_colunas = numero_colunas + 1
        
    with st.columns(3)[1]:
        st.write('Saldo total: ' + 'R$ {:,.2f}'.format(total))

st.title("| Resumo")

busca_resumo()