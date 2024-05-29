from datetime import datetime
import streamlit as st

st.set_page_config(layout="centered")   # ou "wide"

margins_css = """
    <style>
        .main > div {
            padding-top: 0rem;            
        }
    </style>
"""
st.markdown(margins_css, unsafe_allow_html=True)        

if 'mensagem' not in st.session_state:
    st.session_state['mensagem'] = ''

def botao_salvar():
    st.session_state['mensagem'] = 'registro salvo'
    st.session_state['historico'] = ''
    st.session_state['valor'] = 0
    st.session_state['conta'] = 'Selecione'
    st.session_state['tipo'] = 'Selecione'
    st.session_state['categoria'] = 'Selecione'

coluna1, coluna2 = st.columns([0.45, 0.55])
coluna1.title("| Movimentação ")
tipoEscolhido = ""

data = st.date_input("Data", key="datamovimento")
conta = st.selectbox("Conta", ["Selecione", "Bradesco", "Inter", "APL CDI Inter"], key="conta")
tipo = st.selectbox("Tipo", ["Selecione", "Cartão de débito", "Cartão de crédito", "Transferência PIX", "Salário", "Aplicação"], key="tipo")

if(tipo == 'Aplicação'):
    contaDestino = st.selectbox("Aplicação", ["APL CDI Inter"], key="contaDestino")

historico = st.text_area("Descrição", height=1, key="historico")
valor = st.number_input("Valor R$", key="valor")
categoria = st.selectbox("Categoria", ["Selecione", "Mercados","Alimentação", "Saúde", "Casa", "Aplicação", "(-) Transferência", "(+) Transferência"], key="categoria")

st.button('Salvar', on_click=botao_salvar)

if(not st.session_state['mensagem'] == ''):
    st.success(' Registro salvo', icon="✅")
    st.session_state['mensagem'] = ''