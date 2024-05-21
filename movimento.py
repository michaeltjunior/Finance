from datetime import datetime
import streamlit as st

st.set_page_config(layout="centered")   # ou "wide"

coluna1, coluna2 = st.columns([0.35, 0.65])
coluna1.title("| Finance ")

def clear_form():
    st.session_state["datamovimento"] = datetime.today()
    st.session_state["tipo"] = "Selecione"
    st.session_state["historico"] = ""
    st.session_state["valor"] = 0
    st.session_state["categoria"] = "Selecione"

with st.form("formulario"):
    data = st.date_input("Data", key="datamovimento")
    tipo = st.selectbox("Tipo", ["Selecione", "Cartão de débito", "Cartão de crédito", "Transferência PIX", "Salário", "Aplicação"], key="tipo")
    historico = st.text_area("Descrição", height=1, key="historico")
    valor = st.number_input("Valor R$", key="valor")
    categoria = st.selectbox("Categoria", ["Selecione", "Mercados","Alimentação", "Saúde", "Casa", "Aplicação", "(-) Transferência", "(+) Transferência"], key="categoria")

    coluna3, coluna4, coluna5, coluna6, coluna7 = st.columns([0.2, 0.2, 0.2, 0.2, 0.2])
    submitted = coluna5.form_submit_button("Salvar", on_click=clear_form)


    #if submitted:        
    #    coluna5.write("Registro salvo")