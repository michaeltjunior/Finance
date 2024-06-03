import streamlit as st
import pandas as pd
from menu import menu
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

menu()
lista_contas = ["Selecione"]

if 'contas' not in st.session_state:
    st.session_state['contas'] = ''    

def busca_contas():
    contas = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/contas").json()))

    for conta in contas:
        lista_contas.append(conta['conta'])
    st.session_state['contas'] = lista_contas

def mostra_conta(dados):
    st.table(dados)

def busca_resumo():
    resumoContas = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/resumo").json()))
    total = 0.00

    for resumo in resumoContas:        
        total = total + float(resumo['saldo'])

    df = pd.DataFrame(resumoContas)
    
    df.loc[len(df)] = ["Total", total]    
    df = df.astype({"saldo": float})
    df["saldo"] = df["saldo"].map("R$ {:,.2f}".format)

    df

st.title("| Resumo")

busca_resumo()

busca_contas()
listaContas = st.selectbox("Detalhar conta", st.session_state['contas'], key="contaBanco")
